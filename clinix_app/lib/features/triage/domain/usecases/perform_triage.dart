// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Perform Triage Use Case
// Principal-level implementation of core triage business logic
//
// Flow:
// ┌─────────────────────────────────────────────────────────┐
// │  1. Initialize Cactus → 2. Create Session → 3. Record    │
// │                                              Symptoms    │
// │                                                           │
// │  4. Get Knowledge → 5. Load Patient → 6. Run Hybrid AI   │
// │     Base Context      History to RAG                      │
// │                                                           │
// │  7. Parse Response → 8. Save Result → 9. Return Outcome  │
// └─────────────────────────────────────────────────────────┘
//
// Routing Logic (from HybridRouter):
// - Critical symptoms → Cloud AI (GPT-4o, Claude 3.5 Sonnet)
// - Complex cases → Local with cloud escalation
// - Standard cases → Local LLM (LFM2-1.2B-RAG)
// - Offline → Always local

import 'dart:convert';

import '../../../../core/ai/cactus_service.dart';
import '../../../../core/ai/hybrid_router.dart';
import '../../../../core/ai/knowledge_base_service.dart';
import '../../../../core/database/local_database.dart';

// =============================================================================
// USE CASE
// =============================================================================

/// Perform Triage Use Case.
///
/// This is the CORE business logic of ClinixAI.
/// It orchestrates the entire triage flow using the HybridRouter:
///
/// 1. Create a session in local database
/// 2. Record symptoms with metadata
/// 3. Route to appropriate AI (local/cloud) based on risk/complexity
/// 4. Run AI inference with RAG knowledge base for medical context
/// 5. Include patient history in RAG context for personalization
/// 6. Save results with source attributions for transparency
/// 7. Return comprehensive triage outcome
///
/// ## Routing Logic
///
/// - Critical symptoms → Cloud AI (GPT-4o, Claude 3.5 Sonnet)
/// - Complex cases → Local with cloud escalation
/// - Standard cases → Local LLM (LFM2-1.2B-RAG)
/// - Offline → Always local
///
/// ## Usage Example
///
/// ```dart
/// final useCase = PerformTriageUseCase();
/// final outcome = await useCase.execute(
///   TriageInput(
///     symptoms: [SymptomInput(description: 'High fever')],
///     deviceId: 'device-123',
///   ),
/// );
/// print(outcome.summary);
/// ```
class PerformTriageUseCase {
  final HybridRouter _router;
  final CactusService _cactusService;
  final LocalDatabase _database;
  final KnowledgeBaseService _knowledgeBase;

  PerformTriageUseCase({
    HybridRouter? router,
    CactusService? cactusService,
    LocalDatabase? database,
    KnowledgeBaseService? knowledgeBase,
  })  : _router = router ?? HybridRouter.instance,
        _cactusService = cactusService ?? CactusService(),
        _database = database ?? LocalDatabase.instance,
        _knowledgeBase = knowledgeBase ?? KnowledgeBaseService.instance;

  /// Execute the triage flow with intelligent hybrid routing
  /// 
  /// Returns a [TriageOutcome] with the session and result
  Future<TriageOutcome> execute(TriageInput input) async {
    // Step 1: Ensure Cactus is initialized and LM is ready
    if (!_cactusService.isInitialized) {
      await _cactusService.initialize();
    }
    if (!_cactusService.isLMLoaded) {
      await _cactusService.downloadLLMModel(CactusModelConfig.lfm2Rag);
      await _cactusService.loadLLMModel(CactusModelConfig.lfm2Rag);
    }

    // Step 2: Create a new triage session
    final session = LocalTriageSession.create(
      deviceId: input.deviceId,
      deviceModel: input.deviceModel,
      appVersion: input.appVersion,
    );

    // Save session to get ID
    final sessionId = await _database.createTriageSession(session);
    session.id = sessionId;

    // Step 3: Record symptoms
    final symptoms = input.symptoms.map((s) => LocalSymptom.create(
      sessionId: sessionId,
      description: s.description,
      severity: s.severity,
      durationHours: s.durationHours,
      bodyLocation: s.bodyLocation,
      imageUrl: s.imageUrl,
    )).toList();

    await _database.addSymptoms(symptoms);

    // Step 4: Build symptom text for AI
    final symptomText = _buildSymptomText(symptoms);

    // Step 5: Get patient profile for context and RAG
    final profile = await _database.getPatientProfile();
    
    // Step 6: Get medical knowledge context from Knowledge Base
    RAGContext? medicalContext;
    List<String> sourceAttributions = [];
    if (_knowledgeBase.isInitialized) {
      medicalContext = await _knowledgeBase.getContextForQuery(
        symptomText,
        maxChunks: 5,
        maxTokens: 1500,
      );
      if (medicalContext.hasContext) {
        sourceAttributions = medicalContext.attributions;
      }
    }
    
    // Step 7: Load patient history into RAG if available
    String? patientId;
    if (profile != null) {
      patientId = profile.id.toString();
      await _loadPatientHistoryToRAG(profile);
    }

    // Step 8: Run HYBRID AI inference (local/cloud routing) with medical context
    final hybridResult = await _router.runHybridTriage(
      symptoms: symptomText,
      patientAge: profile?.age,
      patientGender: profile?.gender,
      medicalHistory: profile?.chronicConditions,
      vitalSigns: input.vitalSigns,
      patientId: patientId,
      forceLocal: input.forceLocal,
      forceCloud: input.forceCloud,
      medicalContext: medicalContext?.context, // Include KB context
    );

    // Step 9: Parse AI response and create result
    LocalTriageResult result;

    if (hybridResult.success) {
      try {
        final jsonResponse = jsonDecode(hybridResult.response);
        result = LocalTriageResult.fromJson(jsonResponse, sessionId);
        // Add routing metadata
        result.aiModelVersion = hybridResult.modelUsed;
        result.escalatedToCloud = hybridResult.wasEscalated;
        // Add source attributions for transparency
        if (sourceAttributions.isNotEmpty) {
          result.sourceAttributions = sourceAttributions;
        }
      } catch (e) {
        // If JSON parsing fails, create a default result
        result = _createDefaultResult(sessionId, hybridResult.response, hybridResult.modelUsed);
      }
    } else {
      // AI failed - create error result
      result = _createErrorResult(sessionId, hybridResult.error ?? 'Unknown error');
    }

    // Step 10: Save result
    await _database.saveTriageResult(result);

    // Step 11: Complete the session
    session.complete();
    await _database.updateTriageSession(session);

    // Step 12: Return outcome with routing info and attributions
    return TriageOutcome(
      session: session,
      symptoms: symptoms,
      result: result,
      inferenceTimeMs: hybridResult.totalLatency?.inMilliseconds ?? 0,
      routeUsed: hybridResult.routeUsed,
      modelUsed: hybridResult.modelUsed,
      wasEscalated: hybridResult.wasEscalated,
      localConfidence: hybridResult.localConfidence,
      cloudConfidence: hybridResult.cloudConfidence,
      sourceAttributions: sourceAttributions,
    );
  }

  /// Load patient's medical history into Knowledge Base for personalized triage
  Future<void> _loadPatientHistoryToRAG(LocalPatientProfile profile) async {
    if (!_knowledgeBase.isInitialized) {
      return;
    }
    
    final patientId = profile.id.toString();
    
    // Add chronic conditions
    if (profile.chronicConditions != null && profile.chronicConditions!.isNotEmpty) {
      await _knowledgeBase.addDocument(
        documentId: '${patientId}_chronic',
        title: 'Patient Chronic Conditions',
        source: 'Patient Profile',
        documentType: RAGDocumentType.patientHistory,
        content: 'Patient has chronic conditions: ${profile.chronicConditions!.join(", ")}',
        isSystemDocument: false,
        generateEmbeddings: _cactusService.isLMLoaded,
      );
    }
    
    // Add allergies
    if (profile.allergies != null && profile.allergies!.isNotEmpty) {
      await _knowledgeBase.addDocument(
        documentId: '${patientId}_allergies',
        title: 'Patient Allergies',
        source: 'Patient Profile',
        documentType: RAGDocumentType.patientHistory,
        content: 'Patient has allergies to: ${profile.allergies!.join(", ")}. '
            'These allergies must be considered when recommending treatments or medications.',
        isSystemDocument: false,
        generateEmbeddings: _cactusService.isLMLoaded,
      );
    }
    
    // Add current medications
    if (profile.currentMedications != null && profile.currentMedications!.isNotEmpty) {
      await _knowledgeBase.addDocument(
        documentId: '${patientId}_medications',
        title: 'Patient Current Medications',
        source: 'Patient Profile',
        documentType: RAGDocumentType.patientHistory,
        content: 'Patient is currently taking: ${profile.currentMedications!.join(", ")}. '
            'Check for potential drug interactions with any new recommendations.',
        isSystemDocument: false,
        generateEmbeddings: _cactusService.isLMLoaded,
      );
    }
    
    // Add demographic info
    final demoBuffer = StringBuffer('Patient demographics: ');
    if (profile.gender != null) demoBuffer.write('${profile.gender}, ');
    if (profile.age != null) demoBuffer.write('${profile.age} years old, ');
    if (profile.bloodType != null) demoBuffer.write('blood type ${profile.bloodType}');
    
    await _knowledgeBase.addDocument(
      documentId: '${patientId}_demographics',
      title: 'Patient Demographics',
      source: 'Patient Profile',
      documentType: RAGDocumentType.patientHistory,
      content: demoBuffer.toString(),
      isSystemDocument: false,
      generateEmbeddings: _cactusService.isLMLoaded,
    );
  }

  /// Build symptom text for AI prompt
  String _buildSymptomText(List<LocalSymptom> symptoms) {
    final buffer = StringBuffer();

    for (int i = 0; i < symptoms.length; i++) {
      final s = symptoms[i];
      buffer.writeln('${i + 1}. ${s.description}');
      if (s.severity != null) {
        buffer.writeln('   - Severity: ${s.severityDescription} (${s.severity}/10)');
      }
      if (s.durationHours != null) {
        buffer.writeln('   - Duration: ${s.durationDescription}');
      }
      if (s.bodyLocation != null) {
        buffer.writeln('   - Location: ${s.bodyLocation}');
      }
      if (s.progression != null) {
        buffer.writeln('   - Progression: ${s.progression}');
      }
    }

    return buffer.toString();
  }

  /// Create default result when JSON parsing fails
  LocalTriageResult _createDefaultResult(int sessionId, String rawResponse, String modelUsed) {
    return LocalTriageResult()
      ..sessionId = sessionId
      ..urgencyLevel = UrgencyLevel.standard
      ..confidenceScore = 0.5
      ..aiModelVersion = modelUsed
      ..primaryAssessment = 'Unable to parse AI response. Please consult a healthcare professional.'
      ..recommendedAction = 'Visit a healthcare facility for proper evaluation.'
      ..followUpRequired = true
      ..glyphSignal = 'standard_glow'
      ..createdAt = DateTime.now();
  }

  /// Create error result when AI fails
  LocalTriageResult _createErrorResult(int sessionId, String error) {
    return LocalTriageResult()
      ..sessionId = sessionId
      ..urgencyLevel = UrgencyLevel.standard
      ..confidenceScore = 0.0
      ..aiModelVersion = 'ERROR'
      ..primaryAssessment = 'AI analysis could not be completed: $error'
      ..recommendedAction = 'Please try again or consult a healthcare professional directly.'
      ..followUpRequired = true
      ..glyphSignal = 'none'
      ..createdAt = DateTime.now();
  }
}

// =============================================================================
// INPUT VALUE OBJECTS
// =============================================================================

/// Input for triage use case.
///
/// Contains all data needed to perform a triage:
/// - List of symptoms (required)
/// - Device metadata for analytics
/// - Optional location for regional disease consideration
/// - Vital signs if available
/// - Force flags for testing local/cloud paths
class TriageInput {
  final List<SymptomInput> symptoms;
  final String? deviceId;
  final String? deviceModel;
  final String? appVersion;
  final double? locationLat;
  final double? locationLng;
  final Map<String, dynamic>? vitalSigns;
  final bool forceLocal;
  final bool forceCloud;

  TriageInput({
    required this.symptoms,
    this.deviceId,
    this.deviceModel,
    this.appVersion,
    this.locationLat,
    this.locationLng,
    this.vitalSigns,
    this.forceLocal = false,
    this.forceCloud = false,
  });
}

/// Individual symptom input for triage.
///
/// Captures:
/// - Free-text description (required)
/// - Severity on 1-10 scale
/// - Duration in hours
/// - Body location (head, chest, abdomen, etc.)
/// - Optional image URL for visual symptoms
class SymptomInput {
  final String description;
  final int? severity;
  final int? durationHours;
  final String? bodyLocation;
  final String? imageUrl;

  SymptomInput({
    required this.description,
    this.severity,
    this.durationHours,
    this.bodyLocation,
    this.imageUrl,
  });
}

// =============================================================================
// OUTPUT VALUE OBJECTS
// =============================================================================

/// Comprehensive output from triage use case.
///
/// Contains:
/// - Session and symptom records (persisted to DB)
/// - AI analysis result with urgency classification
/// - Routing metadata (which AI was used, escalation info)
/// - Performance metrics (inference time)
/// - Source attributions from knowledge base
///
/// ## Display Helper
///
/// Use [summary] for a formatted text representation suitable
/// for debugging or simple UI display.
class TriageOutcome {
  final LocalTriageSession session;
  final List<LocalSymptom> symptoms;
  final LocalTriageResult result;
  final int inferenceTimeMs;
  final RouteDecision routeUsed;
  final String modelUsed;
  final bool wasEscalated;
  final double? localConfidence;
  final double? cloudConfidence;
  final List<String> sourceAttributions;

  TriageOutcome({
    required this.session,
    required this.symptoms,
    required this.result,
    required this.inferenceTimeMs,
    required this.routeUsed,
    required this.modelUsed,
    this.wasEscalated = false,
    this.localConfidence,
    this.cloudConfidence,
    this.sourceAttributions = const [],
  });

  /// Check if triage was successful
  bool get isSuccess => result.confidenceScore > 0;
  
  /// Check if cloud was used
  bool get usedCloud => routeUsed == RouteDecision.cloud || wasEscalated;
  
  /// Check if knowledge base was used
  bool get usedKnowledgeBase => sourceAttributions.isNotEmpty;

  /// Get formatted source attributions for display
  String get formattedSources {
    if (sourceAttributions.isEmpty) return '';
    return '\n📚 Medical Sources:\n${sourceAttributions.map((s) => '• $s').join('\n')}';
  }

  /// Get a summary for display
  String get summary => '''
Triage Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session: ${session.sessionUuid.substring(0, 8)}...
Urgency: ${result.urgencyDisplayText}
Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%
Inference Time: ${inferenceTimeMs}ms
Route: ${_routeDescription}
Model: $modelUsed
Knowledge Base: ${usedKnowledgeBase ? '✓ Used' : 'Not used'}

Assessment:
${result.primaryAssessment}

Recommended Action:
${result.recommendedAction}

Possible Conditions:
${result.differentialDiagnoses.map((d) => '• ${d.condition}').join('\n')}
$formattedSources
⚠️ ${result.disclaimer}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

  String get _routeDescription {
    switch (routeUsed) {
      case RouteDecision.local:
        return '🏠 Local (On-Device)';
      case RouteDecision.cloud:
        return '☁️ Cloud API';
      case RouteDecision.localWithEscalation:
        return wasEscalated ? '🏠→☁️ Local → Cloud (Escalated)' : '🏠 Local (No escalation needed)';
      case RouteDecision.hybrid:
        return '🔄 Hybrid (Both)';
    }
  }
}

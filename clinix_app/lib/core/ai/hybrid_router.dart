import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'cactus_service.dart';
import 'openrouter_service.dart';

/// Intelligent Hybrid Router for ClinixAI
/// 
/// Routes inference requests between local (Cactus) and cloud (OpenRouter)
/// based on:
/// - Risk Score: Critical symptoms → Cloud
/// - Complexity Score: Multi-system symptoms → Cloud  
/// - Connectivity: Offline → Local only
/// - Confidence: Low local confidence → Escalate to cloud
/// 
/// Implements the "Hybrid Hero" strategy from research docs.

/// Routing decision result
enum RouteDecision {
  /// Use local LLM only
  local,
  /// Use cloud API only
  cloud,
  /// Use local first, escalate to cloud if low confidence
  localWithEscalation,
  /// Use both and combine results
  hybrid,
}

/// Detailed routing result
class RoutingResult {
  final RouteDecision decision;
  final double riskScore;
  final double complexityScore;
  final bool isOnline;
  final String reasoning;
  final ModelTier recommendedCloudTier;

  const RoutingResult({
    required this.decision,
    required this.riskScore,
    required this.complexityScore,
    required this.isOnline,
    required this.reasoning,
    required this.recommendedCloudTier,
  });
}

/// Combined triage result from hybrid inference
class HybridTriageResult {
  final String response;
  final bool success;
  final String? error;
  final RouteDecision routeUsed;
  final String modelUsed;
  final Duration? totalLatency;
  final bool wasEscalated;
  final double? localConfidence;
  final double? cloudConfidence;

  const HybridTriageResult({
    required this.response,
    required this.success,
    required this.routeUsed,
    required this.modelUsed,
    this.error,
    this.totalLatency,
    this.wasEscalated = false,
    this.localConfidence,
    this.cloudConfidence,
  });

  factory HybridTriageResult.failure(String error) {
    return HybridTriageResult(
      response: '',
      success: false,
      error: error,
      routeUsed: RouteDecision.local,
      modelUsed: 'none',
    );
  }
}

/// Intelligent Router for hybrid local/cloud inference
class HybridRouter {
  // Singleton pattern
  static HybridRouter? _instance;
  static HybridRouter get instance => _instance ??= HybridRouter._();
  
  HybridRouter._();

  // Cactus service instance - shared with main.dart
  CactusService? _cactus;
  final OpenRouterService _openRouter = OpenRouterService.instance;
  
  /// Set the Cactus service instance
  set cactusService(CactusService service) {
    _cactus = service;
  }
  
  // ============================================================
  // INITIALIZATION STATE
  // ============================================================
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  /// Initialize the hybrid router with all AI services
  Future<void> initialize({
    CactusService? cactusService,
    void Function(double? progress, String status, bool isError)? onProgress,
  }) async {
    if (_isInitialized) return;
    
    // Use provided cactus service or create new one
    _cactus ??= cactusService ?? CactusService();
    
    onProgress?.call(0.0, 'Starting AI initialization...', false);
    
    // Initialize Cactus service if needed
    if (!_cactus!.isInitialized) {
      await _cactus!.initialize();
    }
    
    onProgress?.call(0.5, 'Cactus service initialized', false);
    
    // Check cloud connectivity
    onProgress?.call(0.9, 'Checking cloud connectivity...', false);
    if (_openRouter.isConfigured) {
      await _openRouter.testConnection();
    }
    
    onProgress?.call(1.0, 'AI ready', false);
    _isInitialized = true;
    
    debugPrint('[HybridRouter] Initialized');
    debugPrint('  - Local LLM: ${_cactus!.isLMLoaded ? "Loaded" : "Not loaded (will download on first use)"}');
    debugPrint('  - RAG: ${_cactus!.isRAGInitialized ? "Ready" : "Not initialized"}');
    debugPrint('  - Cloud: ${_openRouter.isConfigured ? "Configured" : "Not Configured"}');
  }
  
  /// Dispose resources
  void dispose() {
    _isInitialized = false;
  }
  
  // ============================================================
  // ROUTING THRESHOLDS (Configurable)
  // ============================================================
  
  /// Risk score threshold to trigger cloud inference
  double riskThreshold = 0.6;
  
  /// Complexity score threshold to trigger cloud inference
  double complexityThreshold = 0.5;
  
  /// Local confidence threshold below which to escalate to cloud
  double confidenceEscalationThreshold = 0.7;
  
  /// Keywords that indicate critical/emergency situations
  static const List<String> _criticalKeywords = [
    'chest pain', 'heart attack', 'stroke', 'unconscious', 'not breathing',
    'severe bleeding', 'seizure', 'convulsion', 'paralysis', 'anaphylaxis',
    'choking', 'drowning', 'poisoning', 'overdose', 'suicide', 'suicidal',
    'severe burn', 'electric shock', 'snake bite', 'severe trauma',
    'head injury', 'spinal injury', 'gunshot', 'stabbing', 'severe accident',
  ];
  
  /// Keywords that indicate urgent but not critical situations
  static const List<String> _urgentKeywords = [
    'high fever', 'fever above 39', 'fever above 40', 'severe headache',
    'severe pain', 'vomiting blood', 'blood in stool', 'difficulty breathing',
    'shortness of breath', 'chest tightness', 'irregular heartbeat',
    'severe abdominal pain', 'severe diarrhea', 'dehydration', 'confusion',
    'disorientation', 'sudden vision loss', 'sudden hearing loss',
    'severe allergic reaction', 'swelling throat', 'severe rash',
  ];
  
  /// Keywords that suggest complex cases (multi-system)
  static const List<String> _complexityKeywords = [
    'multiple symptoms', 'several days', 'getting worse', 'spreading',
    'chronic', 'diabetes', 'hypertension', 'HIV', 'cancer', 'heart disease',
    'kidney disease', 'liver disease', 'autoimmune', 'immunocompromised',
    'pregnancy', 'pregnant', 'elderly', 'infant', 'newborn', 'child under 5',
    'combination of', 'along with', 'accompanied by', 'in addition to',
  ];
  
  /// Africa-specific disease keywords
  static const List<String> _africaSpecificKeywords = [
    'malaria', 'typhoid', 'cholera', 'tb', 'tuberculosis', 'yellow fever',
    'dengue', 'ebola', 'lassa fever', 'meningitis', 'bilharzia', 
    'schistosomiasis', 'sleeping sickness', 'river blindness',
  ];

  // ============================================================
  // CONNECTIVITY CHECK
  // ============================================================
  
  /// Check if device is online
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      // connectivity_plus returns ConnectivityResult (single value)
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('[HybridRouter] Connectivity check failed: $e');
      return false;
    }
  }

  // ============================================================
  // RISK & COMPLEXITY SCORING
  // ============================================================
  
  /// Calculate risk score from symptoms (0.0 - 1.0)
  double calculateRiskScore(String symptoms) {
    final lowerSymptoms = symptoms.toLowerCase();
    double score = 0.0;
    
    // Check for critical keywords (high weight)
    for (final keyword in _criticalKeywords) {
      if (lowerSymptoms.contains(keyword)) {
        score += 0.4;
        debugPrint('[HybridRouter] Critical keyword found: $keyword');
      }
    }
    
    // Check for urgent keywords (medium weight)
    for (final keyword in _urgentKeywords) {
      if (lowerSymptoms.contains(keyword)) {
        score += 0.2;
      }
    }
    
    // Check for Africa-specific diseases (medium weight - often serious)
    for (final keyword in _africaSpecificKeywords) {
      if (lowerSymptoms.contains(keyword)) {
        score += 0.15;
      }
    }
    
    // Cap at 1.0
    return score.clamp(0.0, 1.0);
  }
  
  /// Calculate complexity score from symptoms (0.0 - 1.0)
  double calculateComplexityScore(String symptoms, {
    List<String>? medicalHistory,
    int? patientAge,
  }) {
    final lowerSymptoms = symptoms.toLowerCase();
    double score = 0.0;
    
    // Check for complexity keywords
    for (final keyword in _complexityKeywords) {
      if (lowerSymptoms.contains(keyword)) {
        score += 0.15;
      }
    }
    
    // Medical history increases complexity
    if (medicalHistory != null && medicalHistory.isNotEmpty) {
      score += 0.1 * medicalHistory.length.clamp(0, 3);
    }
    
    // Age factors (very young or elderly = more complex)
    if (patientAge != null) {
      if (patientAge < 5) score += 0.2;  // Children under 5
      if (patientAge > 65) score += 0.15; // Elderly
      if (patientAge < 1) score += 0.3;  // Infants
    }
    
    // Count distinct symptom categories (rough heuristic)
    final symptomCount = symptoms.split(',').length + 
                        symptoms.split('and').length - 1;
    if (symptomCount > 3) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  // ============================================================
  // ROUTING DECISION
  // ============================================================
  
  /// Determine the routing decision based on symptoms and context
  Future<RoutingResult> determineRoute({
    required String symptoms,
    List<String>? medicalHistory,
    int? patientAge,
    String? patientGender,
    bool forceLocal = false,
    bool forceCloud = false,
  }) async {
    // Calculate scores
    final riskScore = calculateRiskScore(symptoms);
    final complexityScore = calculateComplexityScore(
      symptoms, 
      medicalHistory: medicalHistory,
      patientAge: patientAge,
    );
    
    // Check connectivity
    final isOnline = await _checkConnectivity();
    
    // Determine cloud tier based on risk
    ModelTier cloudTier;
    if (riskScore >= 0.8) {
      cloudTier = ModelTier.critical;
    } else if (riskScore >= 0.6 || complexityScore >= 0.6) {
      cloudTier = ModelTier.complex;
    } else if (riskScore >= 0.4 || complexityScore >= 0.4) {
      cloudTier = ModelTier.standard;
    } else {
      cloudTier = ModelTier.simple;
    }
    
    // Force overrides
    if (forceLocal || !isOnline) {
      return RoutingResult(
        decision: RouteDecision.local,
        riskScore: riskScore,
        complexityScore: complexityScore,
        isOnline: isOnline,
        reasoning: forceLocal 
            ? 'Forced local inference' 
            : 'Offline - using local inference',
        recommendedCloudTier: cloudTier,
      );
    }
    
    if (forceCloud && isOnline) {
      return RoutingResult(
        decision: RouteDecision.cloud,
        riskScore: riskScore,
        complexityScore: complexityScore,
        isOnline: isOnline,
        reasoning: 'Forced cloud inference',
        recommendedCloudTier: cloudTier,
      );
    }
    
    // Routing logic
    RouteDecision decision;
    String reasoning;
    
    if (riskScore >= riskThreshold) {
      // High risk - use cloud for maximum accuracy
      decision = isOnline ? RouteDecision.cloud : RouteDecision.local;
      reasoning = isOnline 
          ? 'High risk (${(riskScore * 100).toInt()}%) - routing to cloud for accuracy'
          : 'High risk but offline - using local with caution';
    } else if (complexityScore >= complexityThreshold) {
      // Complex case - prefer cloud but can escalate from local
      decision = isOnline ? RouteDecision.localWithEscalation : RouteDecision.local;
      reasoning = 'Complex case (${(complexityScore * 100).toInt()}%) - local with escalation option';
    } else if (riskScore >= 0.3 && complexityScore >= 0.3) {
      // Moderate risk+complexity - local with escalation
      decision = RouteDecision.localWithEscalation;
      reasoning = 'Moderate risk/complexity - local with cloud escalation';
    } else {
      // Low risk/complexity - local only
      decision = RouteDecision.local;
      reasoning = 'Low risk/complexity - local inference sufficient';
    }
    
    debugPrint('[HybridRouter] Route decision: $decision');
    debugPrint('[HybridRouter] Risk: $riskScore, Complexity: $complexityScore, Online: $isOnline');
    
    return RoutingResult(
      decision: decision,
      riskScore: riskScore,
      complexityScore: complexityScore,
      isOnline: isOnline,
      reasoning: reasoning,
      recommendedCloudTier: cloudTier,
    );
  }

  // ============================================================
  // HYBRID INFERENCE
  // ============================================================
  
  /// Run hybrid triage with intelligent routing
  Future<HybridTriageResult> runHybridTriage({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId, // For RAG lookup
    String? medicalContext, // Pre-retrieved knowledge base context
    bool forceLocal = false,
    bool forceCloud = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    // Ensure Cactus is available
    if (_cactus == null) {
      _cactus = CactusService();
      await _cactus!.initialize();
    }
    
    // Determine routing
    final routing = await determineRoute(
      symptoms: symptoms,
      medicalHistory: medicalHistory,
      patientAge: patientAge,
      patientGender: patientGender,
      forceLocal: forceLocal,
      forceCloud: forceCloud,
    );
    
    debugPrint('[HybridRouter] Routing: ${routing.decision} - ${routing.reasoning}');
    
    try {
      switch (routing.decision) {
        case RouteDecision.local:
          return await _runLocalInference(
            symptoms: symptoms,
            patientAge: patientAge,
            patientGender: patientGender,
            medicalHistory: medicalHistory,
            vitalSigns: vitalSigns,
            patientId: patientId,
            medicalContext: medicalContext,
            stopwatch: stopwatch,
          );
          
        case RouteDecision.cloud:
          return await _runCloudInference(
            symptoms: symptoms,
            patientAge: patientAge,
            patientGender: patientGender,
            medicalHistory: medicalHistory,
            vitalSigns: vitalSigns,
            medicalContext: medicalContext,
            tier: routing.recommendedCloudTier,
            stopwatch: stopwatch,
            riskScore: routing.riskScore,
            complexityScore: routing.complexityScore,
            escalationReason: routing.reasoning,
          );
          
        case RouteDecision.localWithEscalation:
          return await _runLocalWithEscalation(
            symptoms: symptoms,
            patientAge: patientAge,
            patientGender: patientGender,
            medicalHistory: medicalHistory,
            vitalSigns: vitalSigns,
            patientId: patientId,
            medicalContext: medicalContext,
            tier: routing.recommendedCloudTier,
            stopwatch: stopwatch,
            riskScore: routing.riskScore,
            complexityScore: routing.complexityScore,
            escalationReason: routing.reasoning,
          );
          
        case RouteDecision.hybrid:
          return await _runHybridBothInference(
            symptoms: symptoms,
            patientAge: patientAge,
            patientGender: patientGender,
            medicalHistory: medicalHistory,
            vitalSigns: vitalSigns,
            patientId: patientId,
            medicalContext: medicalContext,
            tier: routing.recommendedCloudTier,
            stopwatch: stopwatch,
            riskScore: routing.riskScore,
            complexityScore: routing.complexityScore,
            escalationReason: routing.reasoning,
          );
      }
    } catch (e) {
      stopwatch.stop();
      return HybridTriageResult.failure('Hybrid inference failed: $e');
    }
  }

  /// Build the triage system prompt for local inference
  String _buildTriageSystemPrompt() {
    return '''You are ClinixAI, a medical triage assistant for Africa. Analyze symptoms and provide triage assessment.

URGENCY LEVELS:
- "critical": Life-threatening emergency (stroke, heart attack, severe trauma)
- "urgent": Serious, needs care within 2-4 hours (high fever, severe pain)
- "standard": Non-emergency, care within 24-48 hours
- "non-urgent": Minor issue, self-care appropriate

AFRICA CONSIDERATIONS:
- Endemic diseases: malaria, typhoid, cholera, TB, yellow fever, dengue
- Resource limitations in healthcare
- Climate and waterborne diseases

Respond in JSON format:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence": 0.0-1.0,
  "assessment": "brief clinical assessment",
  "recommended_action": "specific recommended action",
  "red_flags": ["warning signs if any"],
  "referral_type": "emergency|hospital|clinic|pharmacy|self-care"
}''';
  }

  /// Build user prompt for triage
  String _buildTriageUserPrompt({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('PATIENT:');
    if (patientAge != null) buffer.writeln('- Age: $patientAge');
    if (patientGender != null) buffer.writeln('- Gender: $patientGender');
    if (medicalHistory != null && medicalHistory.isNotEmpty) {
      buffer.writeln('- History: ${medicalHistory.join(", ")}');
    }
    if (vitalSigns != null && vitalSigns.isNotEmpty) {
      buffer.writeln('VITALS:');
      vitalSigns.forEach((k, v) => buffer.writeln('- $k: $v'));
    }
    buffer.writeln('\nSYMPTOMS: $symptoms');
    buffer.writeln('\nProvide triage assessment in JSON.');
    return buffer.toString();
  }

  /// Run local-only inference
  Future<HybridTriageResult> _runLocalInference({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    String? medicalContext,
    required Stopwatch stopwatch,
  }) async {
    // Ensure LM is loaded
    if (!_cactus!.isLMLoaded) {
      debugPrint('[HybridRouter] Downloading and loading local model...');
      await _cactus!.downloadLLMModel(CactusModelConfig.lfm2Rag);
      await _cactus!.loadLLMModel(CactusModelConfig.lfm2Rag);
    }
    
    // Build the user prompt with optional medical context
    String userPrompt = _buildTriageUserPrompt(
      symptoms: symptoms,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
    );
    
    // Prepend medical knowledge context if available
    if (medicalContext != null && medicalContext.isNotEmpty) {
      userPrompt = '''Based on the following medical knowledge:

$medicalContext

---

$userPrompt''';
    }
    
    // Build conversation history for context
    final conversationHistory = <Map<String, String>>[];
    
    // Use RAG if available and patient ID provided (for patient-specific context)
    CactusResult result;
    if (patientId != null && _cactus!.isRAGInitialized) {
      result = await _cactus!.generateRAGResponse(
        query: userPrompt,
        systemPrompt: _buildTriageSystemPrompt(),
      );
    } else {
      result = await _cactus!.generateCompletion(
        prompt: userPrompt,
        systemPrompt: _buildTriageSystemPrompt(),
        conversationHistory: conversationHistory,
      );
    }
    
    stopwatch.stop();
    
    // Extract confidence from response
    double? confidence;
    try {
      final parsed = jsonDecode(result.response);
      if (parsed is Map && parsed['confidence'] != null) {
        confidence = (parsed['confidence'] as num).toDouble();
      }
    } catch (_) {}
    
    return HybridTriageResult(
      response: result.response,
      success: result.success,
      error: result.error,
      routeUsed: RouteDecision.local,
      modelUsed: _cactus!.currentModelName ?? 'local',
      totalLatency: stopwatch.elapsed,
      localConfidence: confidence,
    );
  }

  /// Run cloud-only inference
  Future<HybridTriageResult> _runCloudInference({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? medicalContext,
    required ModelTier tier,
    required Stopwatch stopwatch,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    // Check if OpenRouter is configured
    if (!_openRouter.isConfigured) {
      debugPrint('[HybridRouter] OpenRouter not configured, falling back to local');
      return _runLocalInference(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        patientId: null,
        medicalContext: medicalContext,
        stopwatch: stopwatch,
      );
    }
    
    // Build prompt with medical context for cloud
    String cloudPrompt = _buildTriageUserPrompt(
      symptoms: symptoms,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
    );
    
    if (medicalContext != null && medicalContext.isNotEmpty) {
      cloudPrompt = '''Based on the following medical knowledge:

$medicalContext

---

$cloudPrompt''';
    }
    
    final result = await _openRouter.runTriageInference(
      symptoms: symptoms,
      tier: tier,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
      riskScore: riskScore,
      complexityScore: complexityScore,
      escalationReason: escalationReason,
    );
    
    stopwatch.stop();
    
    // Extract confidence from response
    double? confidence;
    final parsed = result.parseAsJson();
    if (parsed != null && parsed['confidence'] != null) {
      confidence = (parsed['confidence'] as num).toDouble();
    }
    
    return HybridTriageResult(
      response: result.response,
      success: result.success,
      error: result.error,
      routeUsed: RouteDecision.cloud,
      modelUsed: result.modelUsed,
      totalLatency: stopwatch.elapsed,
      cloudConfidence: confidence,
    );
  }

  /// Run local first, escalate to cloud if low confidence
  Future<HybridTriageResult> _runLocalWithEscalation({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    String? medicalContext,
    required ModelTier tier,
    required Stopwatch stopwatch,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    // First, try local
    final localResult = await _runLocalInference(
      symptoms: symptoms,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
      patientId: patientId,
      medicalContext: medicalContext,
      stopwatch: Stopwatch()..start(),
    );
    
    // Check if we should escalate
    final shouldEscalate = !localResult.success ||
        (localResult.localConfidence != null && 
         localResult.localConfidence! < confidenceEscalationThreshold);
    
    if (shouldEscalate && _openRouter.isConfigured) {
      debugPrint('[HybridRouter] Escalating to cloud (confidence: ${localResult.localConfidence})');
      
      // Add local confidence to escalation reason
      final fullEscalationReason = localResult.localConfidence != null
          ? '$escalationReason | Local model confidence was ${(localResult.localConfidence! * 100).toInt()}% (below ${(confidenceEscalationThreshold * 100).toInt()}% threshold)'
          : escalationReason;
      
      final cloudResult = await _runCloudInference(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        medicalContext: medicalContext,
        tier: tier,
        stopwatch: Stopwatch()..start(),
        riskScore: riskScore,
        complexityScore: complexityScore,
        escalationReason: fullEscalationReason,
      );
      
      stopwatch.stop();
      
      return HybridTriageResult(
        response: cloudResult.response,
        success: cloudResult.success,
        error: cloudResult.error,
        routeUsed: RouteDecision.localWithEscalation,
        modelUsed: cloudResult.modelUsed,
        totalLatency: stopwatch.elapsed,
        wasEscalated: true,
        localConfidence: localResult.localConfidence,
        cloudConfidence: cloudResult.cloudConfidence,
      );
    }
    
    stopwatch.stop();
    return HybridTriageResult(
      response: localResult.response,
      success: localResult.success,
      error: localResult.error,
      routeUsed: RouteDecision.localWithEscalation,
      modelUsed: localResult.modelUsed,
      totalLatency: stopwatch.elapsed,
      wasEscalated: false,
      localConfidence: localResult.localConfidence,
    );
  }

  /// Run both local and cloud, combine results
  Future<HybridTriageResult> _runHybridBothInference({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    String? medicalContext,
    required ModelTier tier,
    required Stopwatch stopwatch,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    // Run both in parallel
    final results = await Future.wait([
      _runLocalInference(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        patientId: patientId,
        medicalContext: medicalContext,
        stopwatch: Stopwatch()..start(),
      ),
      _runCloudInference(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        medicalContext: medicalContext,
        tier: tier,
        stopwatch: Stopwatch()..start(),
        riskScore: riskScore,
        complexityScore: complexityScore,
        escalationReason: escalationReason,
      ),
    ]);
    
    stopwatch.stop();
    
    final localResult = results[0];
    final cloudResult = results[1];
    
    // Prefer cloud result if both succeed, otherwise use whichever succeeded
    if (cloudResult.success) {
      return HybridTriageResult(
        response: cloudResult.response,
        success: true,
        routeUsed: RouteDecision.hybrid,
        modelUsed: '${localResult.modelUsed} + ${cloudResult.modelUsed}',
        totalLatency: stopwatch.elapsed,
        localConfidence: localResult.localConfidence,
        cloudConfidence: cloudResult.cloudConfidence,
      );
    } else if (localResult.success) {
      return HybridTriageResult(
        response: localResult.response,
        success: true,
        routeUsed: RouteDecision.hybrid,
        modelUsed: localResult.modelUsed,
        totalLatency: stopwatch.elapsed,
        localConfidence: localResult.localConfidence,
      );
    } else {
      return HybridTriageResult.failure(
        'Both local and cloud inference failed',
      );
    }
  }
}

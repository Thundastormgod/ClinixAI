// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Hybrid Router
// Intelligent routing between local (Cactus) and cloud (OpenRouter) LLMs
//
// Architecture:
// ┌─────────────────────────────────────────────────────────────────┐
// │                        HybridRouter                             │
// ├─────────────────────────────────────────────────────────────────┤
// │  INPUTS                   │  OUTPUTS                            │
// │  ├─ Symptoms              │  ├─ Route Decision                  │
// │  ├─ Patient Context       │  ├─ Risk/Complexity Scores          │
// │  └─ Vital Signs           │  └─ Triage Result                   │
// ├─────────────────────────────────────────────────────────────────┤
// │  ROUTING LOGIC                                                  │
// │  ├─ Risk Score Analysis (critical keywords)                     │
// │  ├─ Complexity Score (multi-system, comorbidities)             │
// │  ├─ Connectivity Check (online/offline mode)                   │
// │  └─ Confidence-Based Escalation                                 │
// ├─────────────────────────────────────────────────────────────────┤
// │  LOCAL STACK              │  CLOUD STACK                        │
// │  ├─ Cactus SDK            │  ├─ OpenRouter API                  │
// │  ├─ LiquidAI LFM2         │  ├─ Claude 3.5 Sonnet               │
// │  └─ Isar RAG              │  └─ Neo4j GraphRAG                  │
// └─────────────────────────────────────────────────────────────────┘
//
// Routing Strategy ("Hybrid Hero"):
// - Critical Risk → Cloud for maximum accuracy
// - Complex Cases → Local with escalation option
// - Simple Cases → Local only
// - Offline → Local with graceful degradation

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Returns true if running on a platform that supports Cactus SDK (mobile only).
/// Cactus SDK uses GGML/llama.cpp compiled for ARM, so it only works on Android/iOS.
bool get _isCactusSupportedPlatform {
  if (kIsWeb) return false;
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (_) {
    return false;
  }
}

import 'cactus_service.dart';
import 'openrouter_service.dart';
import 'hybrid_rag_service.dart';
import 'knowledge_base_service.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// Routing decision result.
///
/// Determines which LLM stack(s) will process the inference request.
enum RouteDecision {
  /// Use local LLM only (Cactus with LiquidAI LFM2).
  /// Selected for: low risk, low complexity, or offline mode.
  local,

  /// Use cloud API only (OpenRouter → Claude Sonnet).
  /// Selected for: high risk cases requiring maximum accuracy.
  cloud,

  /// Use local first, escalate to cloud if confidence is low.
  /// Selected for: moderate risk/complexity cases.
  localWithEscalation,

  /// Use both local and cloud, combine results.
  /// Selected for: critical cases requiring redundant analysis.
  hybrid;

  /// Human-readable description of this decision.
  String get description => switch (this) {
        local => 'Local inference only',
        cloud => 'Cloud inference only',
        localWithEscalation => 'Local with cloud escalation',
        hybrid => 'Hybrid (both local and cloud)',
      };
}

// ============================================================================
// VALUE OBJECTS
// ============================================================================

/// Detailed routing result with scores and reasoning.
///
/// Provides full transparency into routing decisions for debugging
/// and audit purposes.
@immutable
class RoutingResult {
  /// The routing decision made.
  final RouteDecision decision;

  /// Calculated risk score (0.0 - 1.0).
  final double riskScore;

  /// Calculated complexity score (0.0 - 1.0).
  final double complexityScore;

  /// Whether the device is online.
  final bool isOnline;

  /// Human-readable explanation of the routing decision.
  final String reasoning;

  /// Recommended cloud model tier for this case.
  final ModelTier recommendedCloudTier;

  const RoutingResult({
    required this.decision,
    required this.riskScore,
    required this.complexityScore,
    required this.isOnline,
    required this.reasoning,
    required this.recommendedCloudTier,
  });

  /// Whether this routing requires cloud connectivity.
  bool get requiresCloud =>
      decision == RouteDecision.cloud ||
      decision == RouteDecision.hybrid ||
      decision == RouteDecision.localWithEscalation;

  @override
  String toString() =>
      'RoutingResult($decision, risk: ${(riskScore * 100).toInt()}%, '
      'complexity: ${(complexityScore * 100).toInt()}%, online: $isOnline)';
}

/// Combined triage result from hybrid inference.
///
/// Contains the inference response along with metadata about which
/// route was used, latencies, confidence scores, and RAG attributions.
@immutable
class HybridTriageResult {
  /// The triage response text (usually JSON format).
  final String response;

  /// Whether the inference was successful.
  final bool success;

  /// Error message if inference failed.
  final String? error;

  /// The routing decision that was executed.
  final RouteDecision routeUsed;

  /// Name of the model(s) used for inference.
  final String modelUsed;

  /// Total time taken for the inference.
  final Duration? totalLatency;

  /// Whether the request was escalated from local to cloud.
  final bool wasEscalated;

  /// Confidence score from local model (if used).
  final double? localConfidence;

  /// Confidence score from cloud model (if used).
  final double? cloudConfidence;

  /// Which RAG source(s) were used.
  final RAGSource? ragSourceUsed;

  /// Number of RAG sources used.
  final int ragSourceCount;

  /// Source attributions from RAG.
  final List<String> ragAttributions;

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
    this.ragSourceUsed,
    this.ragSourceCount = 0,
    this.ragAttributions = const [],
  });

  /// Creates a failure result with the given error message.
  factory HybridTriageResult.failure(String error) => HybridTriageResult(
        response: '',
        success: false,
        error: error,
        routeUsed: RouteDecision.local,
        modelUsed: 'none',
      );

  /// The best confidence score available (prefers cloud over local).
  double? get bestConfidence => cloudConfidence ?? localConfidence;

  /// Whether this result includes RAG context.
  bool get hasRAGContext => ragSourceCount > 0;

  /// Parses the response as JSON if possible.
  Map<String, dynamic>? parseAsJson() {
    try {
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'HybridTriageResult(success: $success, route: $routeUsed, '
      'model: $modelUsed, latency: ${totalLatency?.inMilliseconds}ms)';
}

// ============================================================================
// CONFIGURATION
// ============================================================================

/// Configuration for the HybridRouter.
///
/// Controls routing thresholds and keyword lists for risk/complexity scoring.
@immutable
class HybridRouterConfig {
  /// Risk score threshold to trigger cloud inference (0.0 - 1.0).
  final double riskThreshold;

  /// Complexity score threshold to trigger cloud inference (0.0 - 1.0).
  final double complexityThreshold;

  /// Confidence threshold below which to escalate to cloud (0.0 - 1.0).
  final double confidenceEscalationThreshold;

  const HybridRouterConfig({
    this.riskThreshold = 0.6,
    this.complexityThreshold = 0.5,
    this.confidenceEscalationThreshold = 0.7,
  });

  /// Default configuration.
  factory HybridRouterConfig.defaults() => const HybridRouterConfig();

  /// More aggressive cloud usage for higher accuracy.
  factory HybridRouterConfig.cloudPreferred() => const HybridRouterConfig(
        riskThreshold: 0.4,
        complexityThreshold: 0.3,
        confidenceEscalationThreshold: 0.8,
      );

  /// More conservative cloud usage for cost optimization.
  factory HybridRouterConfig.localPreferred() => const HybridRouterConfig(
        riskThreshold: 0.8,
        complexityThreshold: 0.7,
        confidenceEscalationThreshold: 0.5,
      );

  /// Creates a copy with specified fields replaced.
  HybridRouterConfig copyWith({
    double? riskThreshold,
    double? complexityThreshold,
    double? confidenceEscalationThreshold,
  }) =>
      HybridRouterConfig(
        riskThreshold: riskThreshold ?? this.riskThreshold,
        complexityThreshold: complexityThreshold ?? this.complexityThreshold,
        confidenceEscalationThreshold:
            confidenceEscalationThreshold ?? this.confidenceEscalationThreshold,
      );
}

// ============================================================================
// SERVICE
// ============================================================================

// ============================================================================
// SERVICE
// ============================================================================

/// Intelligent Hybrid Router for ClinixAI.
///
/// Routes inference requests between local (Cactus) and cloud (OpenRouter)
/// based on:
/// - **Risk Score**: Critical symptoms → Cloud for maximum accuracy
/// - **Complexity Score**: Multi-system symptoms → Cloud with full context
/// - **Connectivity**: Offline → Local only with graceful degradation
/// - **Confidence**: Low local confidence → Escalate to cloud
///
/// ## Usage
///
/// ```dart
/// final router = HybridRouter.instance;
///
/// // Initialize with services
/// await router.initialize(
///   cactusService: cactus,
///   knowledgeBaseService: kb,
///   backendUrl: 'https://api.clinixai.com',
/// );
///
/// // Run hybrid triage
/// final result = await router.runHybridTriage(
///   symptoms: 'severe chest pain radiating to left arm',
///   patientAge: 55,
///   patientGender: 'male',
/// );
///
/// if (result.success) {
///   print('Urgency: ${result.parseAsJson()?['urgency_level']}');
///   print('Used: ${result.modelUsed}');
///   print('Latency: ${result.totalLatency?.inMilliseconds}ms');
/// }
/// ```
class HybridRouter {
  // Singleton implementation
  static HybridRouter? _instance;

  /// Returns the singleton instance of [HybridRouter].
  static HybridRouter get instance => _instance ??= HybridRouter._();

  /// Replaces the singleton instance (for testing only).
  @visibleForTesting
  static void setInstance(HybridRouter instance) {
    _instance = instance;
  }

  HybridRouter._();

  // Dependencies
  CactusService? _cactus;
  final OpenRouterService _openRouter = OpenRouterService.instance;
  final HybridRAGService _hybridRAG = HybridRAGService.instance;
  KnowledgeBaseService? _knowledgeBase;

  // Configuration
  HybridRouterConfig _config = HybridRouterConfig.defaults();

  /// Sets the Cactus service instance.
  set cactusService(CactusService service) {
    _cactus = service;
  }

  /// Sets the Knowledge Base service instance (for local RAG).
  set knowledgeBaseService(KnowledgeBaseService service) {
    _knowledgeBase = service;
  }

  /// Gets/sets the routing configuration.
  HybridRouterConfig get config => _config;
  set config(HybridRouterConfig value) => _config = value;

  // Convenience accessors for config values
  double get riskThreshold => _config.riskThreshold;
  set riskThreshold(double value) =>
      _config = _config.copyWith(riskThreshold: value);

  double get complexityThreshold => _config.complexityThreshold;
  set complexityThreshold(double value) =>
      _config = _config.copyWith(complexityThreshold: value);

  double get confidenceEscalationThreshold =>
      _config.confidenceEscalationThreshold;
  set confidenceEscalationThreshold(double value) =>
      _config = _config.copyWith(confidenceEscalationThreshold: value);

  // ============================================================
  // INITIALIZATION
  // ============================================================

  bool _isInitialized = false;

  /// Whether the router has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the hybrid router with all AI services.
  ///
  /// Parameters:
  /// - [cactusService]: Optional Cactus service (creates new if not provided).
  /// - [knowledgeBaseService]: Optional knowledge base for local RAG.
  /// - [backendUrl]: Backend URL for GraphRAG service.
  /// - [config]: Optional routing configuration.
  /// - [onProgress]: Progress callback for UI updates.
  Future<void> initialize({
    CactusService? cactusService,
    KnowledgeBaseService? knowledgeBaseService,
    String? backendUrl,
    HybridRouterConfig? config,
    void Function(double? progress, String status, bool isError)? onProgress,
  }) async {
    if (_isInitialized) {
      debugPrint('[HybridRouter] Already initialized, skipping');
      return;
    }

    if (config != null) {
      _config = config;
    }

    // Use provided cactus service or create new one
    _cactus ??= cactusService ?? CactusService();
    _knowledgeBase = knowledgeBaseService;

    onProgress?.call(0.0, 'Starting AI initialization...', false);

    // Initialize Cactus service if needed
    if (!_cactus!.isInitialized) {
      await _cactus!.initialize();
    }

    onProgress?.call(0.3, 'Cactus service initialized', false);

    // Initialize Hybrid RAG service if knowledge base is available
    if (_knowledgeBase != null) {
      onProgress?.call(0.5, 'Initializing Hybrid RAG...', false);
      await _hybridRAG.initialize(
        localRAG: _knowledgeBase!,
        backendUrl: backendUrl,
      );
    }

    onProgress?.call(0.7, 'Hybrid RAG initialized', false);

    // Check cloud connectivity
    onProgress?.call(0.9, 'Checking cloud connectivity...', false);
    if (_openRouter.isConfigured) {
      await _openRouter.testConnection();
    }

    onProgress?.call(1.0, 'AI ready', false);
    _isInitialized = true;

    _logInitializationStatus();
  }

  void _logInitializationStatus() {
    debugPrint('[HybridRouter] Initialized');
    debugPrint('  - Local LLM: ${_cactus!.isLMLoaded ? "Loaded" : "Not loaded (will download on first use)"}');
    debugPrint('  - Local RAG: ${_knowledgeBase?.isInitialized == true ? "Ready" : "Not initialized"}');
    debugPrint('  - Hybrid RAG: ${_hybridRAG.isInitialized ? "Ready" : "Not initialized"}');
    debugPrint('  - Cloud: ${_openRouter.isConfigured ? "Configured" : "Not Configured"}');
    debugPrint('  - Risk Threshold: ${(_config.riskThreshold * 100).toInt()}%');
    debugPrint('  - Complexity Threshold: ${(_config.complexityThreshold * 100).toInt()}%');
    debugPrint('  - Escalation Threshold: ${(_config.confidenceEscalationThreshold * 100).toInt()}%');
  }

  /// Disposes resources held by the router.
  void dispose() {
    _isInitialized = false;
    debugPrint('[HybridRouter] Disposed');
  }
  
  // ============================================================
  // KEYWORD DATABASES
  // ============================================================

  /// Keywords that indicate critical/emergency situations.
  ///
  /// These keywords trigger the highest risk scores and typically
  /// route directly to cloud for maximum accuracy.
  static const List<String> _criticalKeywords = [
    // Cardiovascular emergencies
    'chest pain', 'heart attack', 'cardiac arrest', 'irregular heartbeat',
    // Neurological emergencies
    'stroke', 'unconscious', 'paralysis', 'seizure', 'convulsion',
    // Respiratory emergencies
    'not breathing', 'choking', 'drowning', 'severe asthma',
    // Trauma
    'severe bleeding', 'severe burn', 'electric shock', 'gunshot', 'stabbing',
    'severe trauma', 'head injury', 'spinal injury', 'severe accident',
    // Other critical
    'anaphylaxis', 'snake bite', 'poisoning', 'overdose',
    'suicide', 'suicidal', 'self-harm',
  ];

  /// Keywords that indicate urgent but not critical situations.
  ///
  /// These keywords trigger moderate risk scores and may use
  /// local-with-escalation routing.
  static const List<String> _urgentKeywords = [
    // Fever
    'high fever', 'fever above 39', 'fever above 40', 'persistent fever',
    // Pain
    'severe headache', 'severe pain', 'severe abdominal pain',
    // GI emergencies
    'vomiting blood', 'blood in stool', 'severe diarrhea', 'dehydration',
    // Respiratory
    'difficulty breathing', 'shortness of breath', 'chest tightness',
    // Cardiac
    'irregular heartbeat', 'palpitations', 'racing heart',
    // Neurological
    'confusion', 'disorientation', 'sudden vision loss', 'sudden hearing loss',
    // Allergic
    'severe allergic reaction', 'swelling throat', 'severe rash',
  ];

  /// Keywords that suggest complex cases (multi-system involvement).
  ///
  /// These keywords increase complexity scores and may warrant
  /// more comprehensive analysis.
  static const List<String> _complexityKeywords = [
    // Symptom patterns
    'multiple symptoms', 'several days', 'getting worse', 'spreading',
    // Chronic conditions
    'chronic', 'diabetes', 'hypertension', 'HIV', 'cancer',
    'heart disease', 'kidney disease', 'liver disease',
    'autoimmune', 'immunocompromised',
    // Special populations
    'pregnancy', 'pregnant', 'elderly', 'infant', 'newborn', 'child under 5',
    // Complexity indicators
    'combination of', 'along with', 'accompanied by', 'in addition to',
  ];

  /// Africa-specific disease keywords.
  ///
  /// Endemic diseases that require special consideration in African
  /// healthcare contexts.
  static const List<String> _africaSpecificKeywords = [
    // Vector-borne
    'malaria', 'yellow fever', 'dengue', 'sleeping sickness', 'river blindness',
    // Water/food-borne
    'typhoid', 'cholera', 'bilharzia', 'schistosomiasis',
    // Respiratory
    'tb', 'tuberculosis',
    // Hemorrhagic fevers
    'ebola', 'lassa fever',
    // Other
    'meningitis',
  ];

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  /// Checks if device is online.
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('[HybridRouter] Connectivity check failed: $e');
      return false;
    }
  }

  // ============================================================
  // RISK & COMPLEXITY SCORING
  // ============================================================

  /// Calculates risk score from symptoms (0.0 - 1.0).
  ///
  /// Higher scores indicate more critical/urgent conditions that
  /// should be routed to cloud for maximum accuracy.
  ///
  /// Scoring weights:
  /// - Critical keywords: +0.4 each (capped)
  /// - Urgent keywords: +0.2 each
  /// - Africa-specific diseases: +0.15 each
  double calculateRiskScore(String symptoms) {
    final lowerSymptoms = symptoms.toLowerCase();
    double score = 0.0;

    // Check for critical keywords (highest weight)
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

    return score.clamp(0.0, 1.0);
  }

  /// Calculates complexity score from symptoms and patient context (0.0 - 1.0).
  ///
  /// Higher scores indicate cases that require more comprehensive
  /// analysis and may benefit from cloud inference.
  ///
  /// Factors:
  /// - Complexity keywords: +0.15 each
  /// - Medical history: +0.1 per condition (max 3)
  /// - Age: Young children and elderly get higher scores
  /// - Multiple symptoms: +0.2 for >3 symptoms
  double calculateComplexityScore(
    String symptoms, {
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
      if (patientAge < 1) score += 0.3; // Infants - highest complexity
      else if (patientAge < 5) score += 0.2; // Young children
      else if (patientAge > 65) score += 0.15; // Elderly
    }

    // Count distinct symptoms (rough heuristic)
    final symptomCount =
        symptoms.split(',').length + symptoms.split('and').length - 1;
    if (symptomCount > 3) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  // ============================================================
  // ROUTING DECISION
  // ============================================================

  /// Determines the routing decision based on symptoms and context.
  ///
  /// This is the core routing logic that analyzes the patient case
  /// and decides whether to use local, cloud, or hybrid inference.
  ///
  /// Parameters:
  /// - [symptoms]: The patient's symptoms description.
  /// - [medicalHistory]: Optional list of pre-existing conditions.
  /// - [patientAge]: Optional patient age for complexity scoring.
  /// - [patientGender]: Optional patient gender.
  /// - [forceLocal]: Force local-only routing (ignores scores).
  /// - [forceCloud]: Force cloud-only routing (if online).
  ///
  /// Returns a [RoutingResult] with the decision and scores.
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
    final cloudTier = _determineCloudTier(riskScore, complexityScore);

    // Handle force overrides
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

    // Apply routing logic
    final (decision, reasoning) = _applyRoutingLogic(
      riskScore: riskScore,
      complexityScore: complexityScore,
      isOnline: isOnline,
    );

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

  /// Determines the appropriate cloud model tier based on scores.
  ModelTier _determineCloudTier(double riskScore, double complexityScore) {
    if (riskScore >= 0.8) {
      return ModelTier.critical;
    } else if (riskScore >= 0.6 || complexityScore >= 0.6) {
      return ModelTier.complex;
    } else if (riskScore >= 0.4 || complexityScore >= 0.4) {
      return ModelTier.standard;
    } else {
      return ModelTier.simple;
    }
  }

  /// Applies the routing logic to determine decision and reasoning.
  (RouteDecision, String) _applyRoutingLogic({
    required double riskScore,
    required double complexityScore,
    required bool isOnline,
  }) {
    if (riskScore >= _config.riskThreshold) {
      // High risk - use cloud for maximum accuracy
      return isOnline
          ? (
              RouteDecision.cloud,
              'High risk (${(riskScore * 100).toInt()}%) - routing to cloud for accuracy'
            )
          : (
              RouteDecision.local,
              'High risk but offline - using local with caution'
            );
    }

    if (complexityScore >= _config.complexityThreshold) {
      // Complex case - prefer cloud but can escalate from local
      return (
        isOnline ? RouteDecision.localWithEscalation : RouteDecision.local,
        'Complex case (${(complexityScore * 100).toInt()}%) - local with escalation option'
      );
    }

    if (riskScore >= 0.3 && complexityScore >= 0.3) {
      // Moderate risk+complexity - local with escalation
      return (
        RouteDecision.localWithEscalation,
        'Moderate risk/complexity - local with cloud escalation'
      );
    }

    // Low risk/complexity - local only
    return (
      RouteDecision.local,
      'Low risk/complexity - local inference sufficient'
    );
  }

  // ============================================================
  // HYBRID INFERENCE
  // ============================================================

  /// Runs hybrid triage with intelligent routing and RAG.
  ///
  /// This is the primary entry point for medical triage. It:
  /// 1. Calculates risk/complexity scores from symptoms
  /// 2. Determines optimal routing (local vs cloud)
  /// 3. Fetches RAG context from local (Isar) and/or cloud (Neo4j) sources
  /// 4. Runs inference with the selected LLM
  /// 5. Optionally escalates to cloud if local confidence is low
  ///
  /// Parameters:
  /// - [symptoms]: Patient's symptom description (required).
  /// - [patientAge]: Optional patient age for complexity scoring.
  /// - [patientGender]: Optional patient gender.
  /// - [medicalHistory]: Optional list of pre-existing conditions.
  /// - [vitalSigns]: Optional vital signs map.
  /// - [patientId]: Optional patient ID for RAG lookup.
  /// - [medicalContext]: Pre-retrieved knowledge context (deprecated).
  /// - [forceLocal]: Force local-only routing.
  /// - [forceCloud]: Force cloud-only routing.
  /// - [ragSource]: RAG source preference (default: auto).
  ///
  /// Returns a [HybridTriageResult] with the assessment and metadata.
  ///
  /// Example:
  /// ```dart
  /// final result = await router.runHybridTriage(
  ///   symptoms: 'severe chest pain, shortness of breath',
  ///   patientAge: 55,
  ///   patientGender: 'male',
  ///   medicalHistory: ['hypertension', 'diabetes'],
  /// );
  ///
  /// if (result.success) {
  ///   final json = result.parseAsJson();
  ///   print('Urgency: ${json?['urgency_level']}');
  /// }
  /// ```
  Future<HybridTriageResult> runHybridTriage({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    @Deprecated('Use ragSource instead') String? medicalContext,
    bool forceLocal = false,
    bool forceCloud = false,
    RAGSource ragSource = RAGSource.auto,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Platform check: Force cloud on desktop/web where Cactus SDK is unavailable
    if (!_isCactusSupportedPlatform) {
      debugPrint('[HybridRouter] Desktop/Web platform detected - forcing cloud inference');
      debugPrint('[HybridRouter] Cactus SDK only supports Android/iOS');
      forceCloud = true;
      forceLocal = false;
    }

    // Ensure Cactus is available (only on supported platforms)
    if (_isCactusSupportedPlatform && _cactus == null) {
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

    // Fetch RAG context using hybrid RAG service
    final ragContext = await _fetchRAGContext(
      symptoms: symptoms,
      routing: routing,
      ragSource: ragSource,
    );

    // Use RAG context if available, fallback to provided medicalContext
    final effectiveMedicalContext =
        ragContext?.formattedForPrompt ?? medicalContext;

    try {
      final result = await _executeRouting(
        routing: routing,
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        patientId: patientId,
        ragContext: ragContext,
        effectiveMedicalContext: effectiveMedicalContext,
        stopwatch: stopwatch,
      );
      return result;
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('[HybridRouter] Inference error: $e\n$st');
      return HybridTriageResult.failure('Hybrid inference failed: $e');
    }
  }

  /// Fetches RAG context based on routing decision.
  Future<HybridRAGContext?> _fetchRAGContext({
    required String symptoms,
    required RoutingResult routing,
    required RAGSource ragSource,
  }) async {
    if (!_hybridRAG.isInitialized) return null;

    try {
      // Determine effective RAG source based on routing decision
      final effectiveRAGSource = _resolveRAGSource(routing, ragSource);

      final context = await _hybridRAG.getRAGContext(
        query: symptoms,
        source: effectiveRAGSource,
        riskScore: routing.riskScore,
      );

      debugPrint(
          '[HybridRouter] RAG context fetched: ${context.sourceCount} sources from ${context.sourceUsed}');
      return context;
    } catch (e) {
      debugPrint('[HybridRouter] RAG context fetch failed: $e');
      return null;
    }
  }

  /// Resolves the effective RAG source based on routing decision.
  RAGSource _resolveRAGSource(RoutingResult routing, RAGSource requested) {
    if (requested != RAGSource.auto) return requested;

    return switch (routing.decision) {
      RouteDecision.local => RAGSource.localOnly,
      RouteDecision.cloud =>
        routing.isOnline ? RAGSource.hybrid : RAGSource.localOnly,
      RouteDecision.localWithEscalation => RAGSource.hybrid,
      RouteDecision.hybrid => RAGSource.hybrid,
    };
  }

  /// Executes the routing decision and returns the result.
  Future<HybridTriageResult> _executeRouting({
    required RoutingResult routing,
    required String symptoms,
    required int? patientAge,
    required String? patientGender,
    required List<String>? medicalHistory,
    required Map<String, dynamic>? vitalSigns,
    required String? patientId,
    required HybridRAGContext? ragContext,
    required String? effectiveMedicalContext,
    required Stopwatch stopwatch,
  }) async {
    switch (routing.decision) {
      case RouteDecision.local:
        final result = await _runLocalInference(
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          vitalSigns: vitalSigns,
          patientId: patientId,
          medicalContext: effectiveMedicalContext,
          stopwatch: stopwatch,
        );
        return _enrichResultWithRAG(result, ragContext);

      case RouteDecision.cloud:
        return _runCloudInferenceWithRAG(
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          vitalSigns: vitalSigns,
          ragContext: ragContext,
          tier: routing.recommendedCloudTier,
          stopwatch: stopwatch,
          riskScore: routing.riskScore,
          complexityScore: routing.complexityScore,
          escalationReason: routing.reasoning,
        );

      case RouteDecision.localWithEscalation:
        return _runLocalWithEscalationAndRAG(
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          vitalSigns: vitalSigns,
          patientId: patientId,
          ragContext: ragContext,
          tier: routing.recommendedCloudTier,
          stopwatch: stopwatch,
          riskScore: routing.riskScore,
          complexityScore: routing.complexityScore,
          escalationReason: routing.reasoning,
        );

      case RouteDecision.hybrid:
        return _runHybridBothInferenceWithRAG(
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          vitalSigns: vitalSigns,
          patientId: patientId,
          ragContext: ragContext,
          tier: routing.recommendedCloudTier,
          stopwatch: stopwatch,
          riskScore: routing.riskScore,
          complexityScore: routing.complexityScore,
          escalationReason: routing.reasoning,
        );
    }
  }
  
  // ============================================================
  // INFERENCE HELPERS
  // ============================================================

  /// Enriches a result with RAG metadata.
  HybridTriageResult _enrichResultWithRAG(
    HybridTriageResult result,
    HybridRAGContext? ragContext,
  ) {
    if (ragContext == null) return result;

    return HybridTriageResult(
      response: result.response,
      success: result.success,
      error: result.error,
      routeUsed: result.routeUsed,
      modelUsed: result.modelUsed,
      totalLatency: result.totalLatency,
      wasEscalated: result.wasEscalated,
      localConfidence: result.localConfidence,
      cloudConfidence: result.cloudConfidence,
      ragSourceUsed: ragContext.sourceUsed,
      ragSourceCount: ragContext.sourceCount,
      ragAttributions: ragContext.allAttributions,
    );
  }

  /// Runs cloud inference with RAG context.
  Future<HybridTriageResult> _runCloudInferenceWithRAG({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    HybridRAGContext? ragContext,
    required ModelTier tier,
    required Stopwatch stopwatch,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    // Check if OpenRouter is configured
    if (!_openRouter.isConfigured) {
      debugPrint('[HybridRouter] OpenRouter not configured, falling back to local');
      final localResult = await _runLocalInference(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        patientId: null,
        medicalContext: ragContext?.formattedForPrompt,
        stopwatch: stopwatch,
      );
      return _enrichResultWithRAG(localResult, ragContext);
    }

    // Use RAG-enhanced inference if we have RAG context
    OpenRouterResult result;
    if (ragContext != null && ragContext.hasContext) {
      result = await _openRouter.runRAGTriageInference(
        symptoms: symptoms,
        ragContext: ragContext.formattedForPrompt,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        riskScore: riskScore,
        complexityScore: complexityScore,
        escalationReason: escalationReason,
        sourceAttributions: ragContext.allAttributions,
      );
    } else {
      result = await _openRouter.runTriageInference(
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
    }

    stopwatch.stop();

    // Extract confidence from response
    final confidence = _extractConfidence(result.parseAsJson());

    return HybridTriageResult(
      response: result.response,
      success: result.success,
      error: result.error,
      routeUsed: RouteDecision.cloud,
      modelUsed: result.modelUsed,
      totalLatency: stopwatch.elapsed,
      cloudConfidence: confidence,
      ragSourceUsed: ragContext?.sourceUsed,
      ragSourceCount: ragContext?.sourceCount ?? 0,
      ragAttributions: ragContext?.allAttributions ?? [],
    );
  }

  /// Runs local first with escalation to cloud if needed.
  Future<HybridTriageResult> _runLocalWithEscalationAndRAG({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    HybridRAGContext? ragContext,
    required ModelTier tier,
    required Stopwatch stopwatch,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    // First, try local with RAG context
    final localResult = await _runLocalInference(
      symptoms: symptoms,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
      patientId: patientId,
      medicalContext: ragContext?.localContext,
      stopwatch: Stopwatch()..start(),
    );

    // Check if we should escalate
    final shouldEscalate = !localResult.success ||
        (localResult.localConfidence != null &&
            localResult.localConfidence! < _config.confidenceEscalationThreshold);

    if (shouldEscalate && _openRouter.isConfigured) {
      debugPrint(
          '[HybridRouter] Escalating to cloud with RAG (confidence: ${localResult.localConfidence})');

      // Build detailed escalation reason
      final fullEscalationReason = localResult.localConfidence != null
          ? '$escalationReason | Local model confidence was '
              '${(localResult.localConfidence! * 100).toInt()}% '
              '(below ${(_config.confidenceEscalationThreshold * 100).toInt()}% threshold)'
          : escalationReason;

      final cloudResult = await _runCloudInferenceWithRAG(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        ragContext: ragContext,
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
        ragSourceUsed: ragContext?.sourceUsed,
        ragSourceCount: ragContext?.sourceCount ?? 0,
        ragAttributions: ragContext?.allAttributions ?? [],
      );
    }

    stopwatch.stop();
    return _enrichResultWithRAG(
      HybridTriageResult(
        response: localResult.response,
        success: localResult.success,
        error: localResult.error,
        routeUsed: RouteDecision.localWithEscalation,
        modelUsed: localResult.modelUsed,
        totalLatency: stopwatch.elapsed,
        wasEscalated: false,
        localConfidence: localResult.localConfidence,
      ),
      ragContext,
    );
  }

  /// Runs both local and cloud inference in parallel.
  Future<HybridTriageResult> _runHybridBothInferenceWithRAG({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    String? patientId,
    HybridRAGContext? ragContext,
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
        medicalContext: ragContext?.localContext,
        stopwatch: Stopwatch()..start(),
      ),
      _runCloudInferenceWithRAG(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        ragContext: ragContext,
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
        ragSourceUsed: ragContext?.sourceUsed,
        ragSourceCount: ragContext?.sourceCount ?? 0,
        ragAttributions: ragContext?.allAttributions ?? [],
      );
    } else if (localResult.success) {
      return _enrichResultWithRAG(
        HybridTriageResult(
          response: localResult.response,
          success: true,
          routeUsed: RouteDecision.hybrid,
          modelUsed: localResult.modelUsed,
          totalLatency: stopwatch.elapsed,
          localConfidence: localResult.localConfidence,
        ),
        ragContext,
      );
    } else {
      return HybridTriageResult.failure(
        'Both local and cloud inference failed',
      );
    }
  }

  // ============================================================
  // CONFIDENCE EXTRACTION
  // ============================================================

  /// Extracts confidence score from a parsed JSON response.
  ///
  /// Returns the confidence value as a double between 0.0 and 1.0,
  /// or null if the confidence field is not present.
  double? _extractConfidence(Map<String, dynamic>? parsed) {
    if (parsed == null || parsed['confidence'] == null) return null;
    return (parsed['confidence'] as num).toDouble();
  }

  // ============================================================
  // PROMPT BUILDING
  // ============================================================

  /// Builds the triage system prompt for local inference.
  ///
  /// This prompt is optimized for the LiquidAI LFM2 model and provides
  /// clear structure for medical triage assessment with:
  /// - Explicit urgency level definitions
  /// - Africa-specific endemic disease considerations
  /// - Structured JSON response format
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

  /// Builds the user prompt for triage inference.
  ///
  /// Constructs a structured prompt with patient demographics,
  /// vital signs, and symptoms for triage assessment.
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

  // ============================================================
  // LOCAL INFERENCE
  // ============================================================

  /// Runs local-only inference using Cactus/LiquidAI LFM2.
  ///
  /// This method:
  /// 1. Ensures the local LLM model is loaded
  /// 2. Builds the user prompt with optional medical context
  /// 3. Executes inference using Cactus SDK
  /// 4. Extracts confidence from the response
  ///
  /// Uses RAG-enhanced inference if patient ID is provided and RAG is initialized.
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
    } catch (_) {
      // Ignore parse errors - confidence will remain null
    }

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
}
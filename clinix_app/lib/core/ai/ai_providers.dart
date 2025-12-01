// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Riverpod Providers
// Principal-level state management for AI services
//
// Architecture:
// ┌─────────────────────────────────────────────────────────┐
// │                 PROVIDER HIERARCHY                       │
// │                                                           │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │          SERVICE PROVIDERS (Singletons)           │   │
// │  │  cactusServiceProvider    → CactusService         │   │
// │  │  openRouterServiceProvider → OpenRouterService    │   │
// │  │  hybridRouterProvider     → HybridRouter          │   │
// │  │  knowledgeBaseServiceProvider → KnowledgeBaseSvc  │   │
// │  └─────────────────────────────────────────────────┘   │
// │                       │                                  │
// │                       ▼                                  │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │          ASYNC INIT PROVIDERS (FutureProvider)    │   │
// │  │  cactusLMReadyProvider     → bool                 │   │
// │  │  cactusSTTReadyProvider    → bool                 │   │
// │  │  hybridRouterReadyProvider → bool                 │   │
// │  │  knowledgeBaseReadyProvider → bool                │   │
// │  └─────────────────────────────────────────────────┘   │
// │                       │                                  │
// │                       ▼                                  │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │          STATE NOTIFIERS (StateNotifierProvider)  │   │
// │  │  triageAnalysisProvider   → TriageAnalysisState   │   │
// │  │  ragSearchProvider        → RAGSearchState        │   │
// │  └─────────────────────────────────────────────────┘   │
// └─────────────────────────────────────────────────────────┘

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clinix_ai_service.dart';
import 'cactus_service.dart';
import 'huggingface_service.dart';
import 'openrouter_service.dart';
import 'hybrid_router.dart';
import 'knowledge_base_service.dart';
import '../database/local_database.dart';

// =============================================================================
// CONFIGURATION PROVIDERS
// =============================================================================

/// AI Service Configuration Provider.
///
/// Provides the appropriate [AIServiceConfig] based on build mode:
/// - Production: Uses production URLs with stricter thresholds
/// - Development: Uses localhost with relaxed thresholds
final aiServiceConfigProvider = Provider<AIServiceConfig>((ref) {
  // In production, this would come from environment or remote config
  const isProduction = bool.fromEnvironment('dart.vm.product');
  
  return isProduction 
    ? AIServiceConfig.production()
    : AIServiceConfig.development();
});

// =============================================================================
// SERVICE PROVIDERS
// =============================================================================

/// Main ClinixAI Service Provider.
///
/// Provides singleton access to [ClinixAIService] with automatic
/// configuration and disposal handling.
final clinixAIServiceProvider = Provider<ClinixAIService>((ref) {
  final config = ref.watch(aiServiceConfigProvider);
  final service = ClinixAIService.instance;
  
  // Initialize asynchronously
  service.initialize(config: config);
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Cactus Service Instance
final _cactusInstance = CactusService();

/// Cactus (On-Device LLM) Service Provider
final cactusServiceProvider = Provider<CactusService>((ref) {
  ref.onDispose(() {
    _cactusInstance.dispose();
  });
  return _cactusInstance;
});

/// Cactus LM Initialization Provider
/// Downloads and initializes the LiquidAI LFM2 language model using Cactus SDK v1.2.0
final cactusLMReadyProvider = FutureProvider<bool>((ref) async {
  final cactus = ref.watch(cactusServiceProvider);
  if (cactus.isLMLoaded) return true;
  
  try {
    // Initialize Cactus service first
    await cactus.initialize();
    
    // Download and load LFM2 RAG model
    final downloaded = await cactus.downloadLLMModel(CactusModelConfig.lfm2Rag);
    if (!downloaded) return false;
    
    return await cactus.loadLLMModel(CactusModelConfig.lfm2Rag);
  } catch (e) {
    return false;
  }
});

/// Cactus STT Initialization Provider
/// Downloads and initializes the Whisper STT model using Cactus SDK v1.2.0
final cactusSTTReadyProvider = FutureProvider<bool>((ref) async {
  final cactus = ref.watch(cactusServiceProvider);
  if (cactus.isSTTLoaded) return true;
  
  try {
    // Download and load Whisper Tiny model
    final downloaded = await cactus.downloadSTTModel(STTModelConfig.whisperTiny);
    if (!downloaded) return false;
    
    return await cactus.loadSTTModel(STTModelConfig.whisperTiny);
  } catch (e) {
    return false;
  }
});

// =============================================================================
// STATUS PROVIDERS
// =============================================================================

/// Cactus Model Status Provider.
///
/// Provides real-time status of all Cactus SDK components:
/// - LM (Language Model) readiness and current model
/// - STT (Speech-to-Text) readiness
/// - RAG initialization status
final cactusModelStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final cactus = ref.watch(cactusServiceProvider);
  
  return {
    'lm': {
      'isReady': cactus.isLMLoaded,
      'model': cactus.currentModelName ?? 'none',
      'isDownloading': cactus.isDownloading,
    },
    'stt': {
      'isReady': cactus.isSTTLoaded,
      'isDownloading': cactus.isDownloading,
    },
    'rag': {
      'isReady': cactus.isRAGInitialized,
    },
  };
});

/// HuggingFace Service Provider
final huggingFaceServiceProvider = Provider<HuggingFaceService>((ref) {
  return HuggingFaceService.instance;
});

/// OpenRouter Cloud Service Provider
final openRouterServiceProvider = Provider<OpenRouterService>((ref) {
  return OpenRouterService.instance;
});

/// OpenRouter Initialization Provider
final openRouterReadyProvider = FutureProvider<bool>((ref) async {
  final openRouter = ref.watch(openRouterServiceProvider);
  if (!openRouter.isConfigured) return false;
  
  try {
    return await openRouter.testConnection();
  } catch (e) {
    return false;
  }
});

/// Hybrid Router Service Provider
final hybridRouterProvider = Provider<HybridRouter>((ref) {
  ref.onDispose(() {
    HybridRouter.instance.dispose();
  });
  return HybridRouter.instance;
});

/// Hybrid Router Initialization Provider
final hybridRouterReadyProvider = FutureProvider<bool>((ref) async {
  final router = ref.watch(hybridRouterProvider);
  if (router.isInitialized) return true;
  
  try {
    await router.initialize();
    return router.isInitialized;
  } catch (e) {
    return false;
  }
});

/// Hybrid Router Status Provider
final hybridRouterStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final router = ref.watch(hybridRouterProvider);
  final cactus = ref.watch(cactusServiceProvider);
  final openRouter = ref.watch(openRouterServiceProvider);
  
  return {
    'isInitialized': router.isInitialized,
    'local': {
      'lmReady': cactus.isLMLoaded,
      'ragReady': cactus.isRAGInitialized,
    },
    'cloud': {
      'configured': openRouter.isConfigured,
      'currentModel': openRouter.currentModel,
    },
    'routing': {
      'riskThreshold': 0.6,
      'complexityThreshold': 0.5,
    },
  };
});

/// Vision Model Initialization Provider
final cactusVisionReadyProvider = FutureProvider<bool>((ref) async {
  final cactus = ref.watch(cactusServiceProvider);
  
  // Vision uses the same LM with a vision model config
  try {
    final downloaded = await cactus.downloadLLMModel(CactusModelConfig.lfm2Vision);
    return downloaded;
  } catch (e) {
    return false;
  }
});

/// RAG Initialization Provider
final cactusRAGReadyProvider = FutureProvider<bool>((ref) async {
  final cactus = ref.watch(cactusServiceProvider);
  if (cactus.isRAGInitialized) return true;
  
  // RAG is automatically initialized when loading a RAG-enabled model
  // Ensure LM is loaded first
  if (!cactus.isLMLoaded) {
    final lmReady = await ref.watch(cactusLMReadyProvider.future);
    if (!lmReady) return false;
  }
  
  return cactus.isRAGInitialized;
});

/// Cloud Health Status Provider
final cloudHealthProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(clinixAIServiceProvider);
  return service.checkCloudHealth();
});

/// AI Providers Status Provider
final aiProvidersStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(clinixAIServiceProvider);
  return service.getProvidersStatus();
});

// =============================================================================
// TRIAGE STATE MANAGEMENT
// =============================================================================

/// State container for triage analysis operations.
///
/// Tracks:
/// - Loading state during analysis
/// - Analysis result when complete
/// - Error information if failed
/// - Processing time for performance monitoring
class TriageAnalysisState {
  final bool isLoading;
  final TriageResult? result;
  final String? error;
  final Duration? processingTime;

  const TriageAnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
    this.processingTime,
  });

  TriageAnalysisState copyWith({
    bool? isLoading,
    TriageResult? result,
    String? error,
    Duration? processingTime,
  }) {
    return TriageAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
      processingTime: processingTime ?? this.processingTime,
    );
  }
}

/// Triage Analysis Notifier
class TriageAnalysisNotifier extends StateNotifier<TriageAnalysisState> {
  final ClinixAIService _service;
  
  TriageAnalysisNotifier(this._service) : super(const TriageAnalysisState());
  
  /// Run triage analysis
  Future<TriageResult?> analyze({
    required String sessionId,
    required List<SymptomInput> symptoms,
    VitalSignsInput? vitalSigns,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await _service.analyzeTriage(
        sessionId: sessionId,
        symptoms: symptoms,
        vitalSigns: vitalSigns,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
      );
      
      stopwatch.stop();
      
      state = state.copyWith(
        isLoading: false,
        result: result,
        processingTime: stopwatch.elapsed,
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        processingTime: stopwatch.elapsed,
      );
      return null;
    }
  }
  
  /// Clear the current result
  void clear() {
    state = const TriageAnalysisState();
  }
}

/// Triage Analysis Provider
final triageAnalysisProvider = 
    StateNotifierProvider<TriageAnalysisNotifier, TriageAnalysisState>((ref) {
  final service = ref.watch(clinixAIServiceProvider);
  return TriageAnalysisNotifier(service);
});

// =============================================================================
// AI MODE CONFIGURATION
// =============================================================================

/// AI inference mode selection.
///
/// Determines how triage inference is routed:
/// - [cloudOnly]: Always use cloud (requires connectivity)
/// - [localOnly]: Always use on-device (works offline)
/// - [hybridLocalFirst]: Try local, fallback to cloud
/// - [hybridCloudFirst]: Try cloud, fallback to local
/// - [auto]: Intelligent routing based on connectivity/complexity
enum AIMode {
  /// Always use cloud inference
  cloudOnly,
  
  /// Always use local inference
  localOnly,
  
  /// Prefer local, fallback to cloud
  hybridLocalFirst,
  
  /// Prefer cloud, fallback to local
  hybridCloudFirst,
  
  /// Automatically choose based on connectivity and complexity
  auto,
}

/// AI Mode State Provider
final aiModeProvider = StateProvider<AIMode>((ref) => AIMode.auto);

/// Connectivity Status for AI routing
final aiConnectivityProvider = FutureProvider<bool>((ref) async {
  // Check if cloud service is reachable
  final service = ref.watch(clinixAIServiceProvider);
  return service.checkCloudHealth();
});

/// Model Download Progress Provider
class ModelDownloadState {
  final bool isDownloading;
  final double progress;
  final String? currentModel;
  final String? error;

  const ModelDownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.currentModel,
    this.error,
  });
}

final modelDownloadProvider = StateProvider<ModelDownloadState>((ref) {
  return const ModelDownloadState();
});

// =============================================================================
// KNOWLEDGE BASE PROVIDERS
// =============================================================================

/// Knowledge Base Service Instance
final _knowledgeBaseInstance = KnowledgeBaseService.instance;

/// Knowledge Base Service Provider
final knowledgeBaseServiceProvider = Provider<KnowledgeBaseService>((ref) {
  return _knowledgeBaseInstance;
});

/// Knowledge Base Initialization Provider
/// Initializes the knowledge base with Isar and Cactus dependencies
final knowledgeBaseReadyProvider = FutureProvider<bool>((ref) async {
  final kb = ref.watch(knowledgeBaseServiceProvider);
  if (kb.isInitialized) return true;
  
  try {
    final database = LocalDatabase.instance;
    final cactus = ref.watch(cactusServiceProvider);
    
    // Ensure database is ready
    if (!database.isReady) {
      await database.initialize();
    }
    
    // Initialize knowledge base
    await kb.initialize(
      isar: database.isar,
      cactusService: cactus,
    );
    
    return true;
  } catch (e) {
    return false;
  }
});

/// Knowledge Base Loading Provider (loads bundled medical documents)
final knowledgeBaseLoadedProvider = FutureProvider<bool>((ref) async {
  // Ensure KB is initialized first
  final isReady = await ref.watch(knowledgeBaseReadyProvider.future);
  if (!isReady) return false;
  
  final kb = ref.watch(knowledgeBaseServiceProvider);
  
  try {
    // Load bundled medical knowledge base
    await kb.loadBundledKnowledgeBase();
    return true;
  } catch (e) {
    return false;
  }
});

/// Knowledge Base Stats Provider
final knowledgeBaseStatsProvider = FutureProvider<KnowledgeBaseStats?>((ref) async {
  final isReady = await ref.watch(knowledgeBaseReadyProvider.future);
  if (!isReady) return null;
  
  final kb = ref.watch(knowledgeBaseServiceProvider);
  return kb.getStats();
});

/// Knowledge Base Status Provider (for UI)
final knowledgeBaseStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final kb = ref.watch(knowledgeBaseServiceProvider);
  
  return {
    'isInitialized': kb.isInitialized,
    'isLoading': kb.isLoading,
    'documentCount': kb.documentCount,
    'chunkCount': kb.chunkCount,
  };
});

/// RAG Search Provider - performs semantic search on knowledge base
class RAGSearchNotifier extends StateNotifier<RAGSearchState> {
  final KnowledgeBaseService _kb;
  
  RAGSearchNotifier(this._kb) : super(const RAGSearchState());
  
  /// Search the knowledge base
  Future<List<RAGSearchResult>> search(String query, {int limit = 5}) async {
    if (!_kb.isInitialized) {
      state = state.copyWith(error: 'Knowledge base not initialized');
      return [];
    }
    
    state = state.copyWith(isSearching: true, error: null);
    
    try {
      final results = await _kb.search(query, limit: limit);
      state = state.copyWith(
        isSearching: false,
        results: results,
        lastQuery: query,
      );
      return results;
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
      return [];
    }
  }
  
  /// Get context for a query (for RAG-augmented generation)
  Future<RAGContext?> getContext(String query, {int maxChunks = 5}) async {
    if (!_kb.isInitialized) return null;
    
    try {
      return await _kb.getContextForQuery(query, maxChunks: maxChunks);
    } catch (e) {
      return null;
    }
  }
  
  void clear() {
    state = const RAGSearchState();
  }
}

/// RAG Search State
class RAGSearchState {
  final bool isSearching;
  final List<RAGSearchResult> results;
  final String? lastQuery;
  final String? error;

  const RAGSearchState({
    this.isSearching = false,
    this.results = const [],
    this.lastQuery,
    this.error,
  });

  RAGSearchState copyWith({
    bool? isSearching,
    List<RAGSearchResult>? results,
    String? lastQuery,
    String? error,
  }) {
    return RAGSearchState(
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      lastQuery: lastQuery ?? this.lastQuery,
      error: error,
    );
  }
}

/// RAG Search Provider
final ragSearchProvider = StateNotifierProvider<RAGSearchNotifier, RAGSearchState>((ref) {
  final kb = ref.watch(knowledgeBaseServiceProvider);
  return RAGSearchNotifier(kb);
});

/// RAG-Augmented Triage Provider
/// Combines knowledge base search with triage analysis
final ragAugmentedTriageProvider = FutureProvider.family<String?, String>((ref, symptoms) async {
  final kb = ref.watch(knowledgeBaseServiceProvider);
  final cactus = ref.watch(cactusServiceProvider);
  
  if (!kb.isInitialized || !cactus.isLMLoaded) {
    return null;
  }
  
  try {
    // Get relevant medical context
    final context = await kb.getContextForQuery(symptoms, maxChunks: 5);
    
    if (!context.hasContext) {
      // No relevant context found - use standard generation
      final result = await cactus.generateCompletion(prompt: symptoms);
      return result.response;
    }
    
    // Generate RAG-augmented response
    final augmentedPrompt = '''Based on the following medical knowledge:

${context.context}

---

Patient symptoms: $symptoms

Please provide a triage assessment based on the above medical context.''';

    final result = await cactus.generateCompletion(
      prompt: augmentedPrompt,
      systemPrompt: '''You are ClinixAI, a medical triage assistant with access to a curated medical knowledge base.
Use the provided context to give accurate, evidence-based assessments.
Always cite your sources when relevant.
Recommend professional medical consultation for serious symptoms.''',
    );
    
    // Append source attributions
    return '${result.response}${context.formattedAttributions}';
  } catch (e) {
    return null;
  }
});

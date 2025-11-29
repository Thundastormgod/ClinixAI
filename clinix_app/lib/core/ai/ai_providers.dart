import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'clinix_ai_service.dart';
import 'cactus_service.dart';
import 'huggingface_service.dart';
import 'openrouter_service.dart';
import 'hybrid_router.dart';

/// AI Service Configuration Provider
final aiServiceConfigProvider = Provider<AIServiceConfig>((ref) {
  // In production, this would come from environment or remote config
  const isProduction = bool.fromEnvironment('dart.vm.product');
  
  return isProduction 
    ? AIServiceConfig.production()
    : AIServiceConfig.development();
});

/// Main ClinixAI Service Provider
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

/// Cactus Model Status Provider
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

/// Triage Analysis State
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

/// AI Mode Enum
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

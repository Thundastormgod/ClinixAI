// ClinixAI Cactus Service - On-Device LLM Inference
// Using Cactus SDK v1.2.0 for LiquidAI LFM2 model inference

import 'dart:async';
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';

/// Configuration for local AI models
class CactusModelConfig {
  final String modelName;
  final String displayName;
  final int contextSize;
  final double temperature;
  final int maxTokens;
  final bool enableRAG;

  const CactusModelConfig({
    required this.modelName,
    required this.displayName,
    this.contextSize = 2048,
    this.temperature = 0.7,
    this.maxTokens = 512,
    this.enableRAG = false,
  });

  // LiquidAI LFM2 Models for ClinixAI
  static const lfm2Rag = CactusModelConfig(
    modelName: 'lfm2-1.2b-rag',
    displayName: 'LiquidAI LFM2 RAG',
    contextSize: 4096,
    temperature: 0.3,
    maxTokens: 1024,
    enableRAG: true,
  );

  static const lfm2Vision = CactusModelConfig(
    modelName: 'lfm2-vl-450m',
    displayName: 'LiquidAI LFM2 Vision',
    contextSize: 2048,
    temperature: 0.5,
    maxTokens: 512,
    enableRAG: false,
  );

  static const qwen3Small = CactusModelConfig(
    modelName: 'qwen3-0.6',
    displayName: 'Qwen 3 0.6B',
    contextSize: 2048,
    temperature: 0.7,
    maxTokens: 512,
    enableRAG: false,
  );
}

/// Speech-to-text model configuration
class STTModelConfig {
  final String modelName;
  final String displayName;
  final String language;

  const STTModelConfig({
    required this.modelName,
    required this.displayName,
    this.language = 'en',
  });

  static const whisperTiny = STTModelConfig(
    modelName: 'whisper-tiny',
    displayName: 'Whisper Tiny',
    language: 'en',
  );

  static const whisperBase = STTModelConfig(
    modelName: 'whisper-base',
    displayName: 'Whisper Base',
    language: 'en',
  );
}

/// Result of a local LLM inference
class CactusResult {
  final String response;
  final int tokensGenerated;
  final Duration processingTime;
  final bool success;
  final String? error;

  CactusResult({
    required this.response,
    this.tokensGenerated = 0,
    required this.processingTime,
    this.success = true,
    this.error,
  });

  factory CactusResult.error(String message) {
    return CactusResult(
      response: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// Result of speech-to-text transcription
class TranscriptionResult {
  final String text;
  final Duration processingTime;
  final bool success;
  final String? error;
  final String? language;

  TranscriptionResult({
    required this.text,
    required this.processingTime,
    this.success = true,
    this.error,
    this.language,
  });

  factory TranscriptionResult.error(String message) {
    return TranscriptionResult(
      text: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// Result of vision analysis
class VisionResult {
  final String description;
  final List<String> detectedConditions;
  final double confidence;
  final Duration processingTime;
  final bool success;
  final String? error;

  VisionResult({
    required this.description,
    this.detectedConditions = const [],
    this.confidence = 0.0,
    required this.processingTime,
    this.success = true,
    this.error,
  });

  factory VisionResult.error(String message) {
    return VisionResult(
      description: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// RAG document for medical knowledge
class RAGDocument {
  final String id;
  final String fileName;
  final String content;
  final int fileSize;
  final DateTime addedAt;

  RAGDocument({
    required this.id,
    required this.fileName,
    required this.content,
    required this.fileSize,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

/// ClinixAI on-device AI service using Cactus SDK v1.2.0
class CactusService {
  // Cactus SDK instances
  CactusLM? _lm;
  CactusSTT? _stt;
  CactusRAG? _rag;

  // Current configurations
  CactusModelConfig? _currentLMConfig;
  CactusModelConfig? _currentVisionConfig;
  STTModelConfig? _currentSTTConfig;

  // State tracking
  bool _isInitialized = false;
  bool _isLMLoaded = false;
  bool _isSTTLoaded = false;
  bool _isRAGInitialized = false;
  bool _isDownloading = false;

  // Callbacks
  void Function(double? progress, String status, bool isError)? onDownloadProgress;
  void Function(String status)? onStatusChange;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLMLoaded => _isLMLoaded;
  bool get isSTTLoaded => _isSTTLoaded;
  bool get isRAGInitialized => _isRAGInitialized;
  bool get isDownloading => _isDownloading;
  String? get currentModelName => _currentLMConfig?.displayName;

  /// Initialize the Cactus service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _lm = CactusLM();
      _stt = CactusSTT();
      _rag = CactusRAG();
      _isInitialized = true;
      _notifyStatus('Cactus service initialized');
    } catch (e) {
      _notifyStatus('Failed to initialize Cactus: $e');
      rethrow;
    }
  }

  /// Download an LLM model
  Future<bool> downloadLLMModel(CactusModelConfig config) async {
    if (!_isInitialized) await initialize();
    if (_isDownloading) return false;

    _isDownloading = true;
    _notifyStatus('Downloading ${config.displayName}...');

    try {
      await _lm!.downloadModel(
        model: config.modelName,
        downloadProcessCallback: (progress, status, isError) {
          onDownloadProgress?.call(progress, status, isError);
          if (isError) {
            _notifyStatus('Download error: $status');
          }
        },
      );
      _isDownloading = false;
      _notifyStatus('${config.displayName} downloaded successfully');
      return true;
    } catch (e) {
      _isDownloading = false;
      _notifyStatus('Failed to download ${config.displayName}: $e');
      return false;
    }
  }

  /// Download an STT model
  Future<bool> downloadSTTModel(STTModelConfig config) async {
    if (!_isInitialized) await initialize();
    if (_isDownloading) return false;

    _isDownloading = true;
    _notifyStatus('Downloading ${config.displayName}...');

    try {
      await _stt!.downloadModel(
        model: config.modelName,
        downloadProcessCallback: (progress, status, isError) {
          onDownloadProgress?.call(progress, status, isError);
          if (isError) {
            _notifyStatus('Download error: $status');
          }
        },
      );
      _isDownloading = false;
      _notifyStatus('${config.displayName} downloaded successfully');
      return true;
    } catch (e) {
      _isDownloading = false;
      _notifyStatus('Failed to download ${config.displayName}: $e');
      return false;
    }
  }

  /// Load an LLM model for inference
  Future<bool> loadLLMModel(CactusModelConfig config) async {
    if (!_isInitialized) await initialize();

    // Unload any existing model
    if (_isLMLoaded) {
      await unloadLLM();
    }

    _notifyStatus('Loading ${config.displayName}...');

    try {
      await _lm!.initializeModel(
        params: CactusInitParams(
          model: config.modelName,
          contextSize: config.contextSize,
        ),
      );
      _currentLMConfig = config;
      _isLMLoaded = true;
      _notifyStatus('${config.displayName} loaded successfully');

      // Initialize RAG if enabled
      if (config.enableRAG) {
        await _initializeRAG();
      }

      return true;
    } catch (e) {
      _notifyStatus('Failed to load ${config.displayName}: $e');
      return false;
    }
  }

  /// Load an STT model
  Future<bool> loadSTTModel(STTModelConfig config) async {
    if (!_isInitialized) await initialize();

    if (_isSTTLoaded) {
      await unloadSTT();
    }

    _notifyStatus('Loading ${config.displayName}...');

    try {
      await _stt!.initializeModel(
        params: CactusInitParams(model: config.modelName),
      );
      _currentSTTConfig = config;
      _isSTTLoaded = true;
      _notifyStatus('${config.displayName} loaded successfully');
      return true;
    } catch (e) {
      _notifyStatus('Failed to load ${config.displayName}: $e');
      return false;
    }
  }

  /// Initialize RAG with the current LLM for embeddings
  Future<void> _initializeRAG() async {
    if (!_isLMLoaded || _lm == null) {
      throw StateError('LLM must be loaded before initializing RAG');
    }

    try {
      await _rag!.initialize();
      
      // Set the embedding generator using the loaded LLM
      _rag!.setEmbeddingGenerator((text) async {
        final result = await _lm!.generateEmbedding(text: text);
        return result.embeddings;
      });

      _isRAGInitialized = true;
      _notifyStatus('RAG initialized with LLM embeddings');
    } catch (e) {
      _notifyStatus('Failed to initialize RAG: $e');
      rethrow;
    }
  }

  /// Generate a completion (chat response)
  Future<CactusResult> generateCompletion({
    required String prompt,
    String? systemPrompt,
    List<Map<String, String>>? conversationHistory,
    CactusCompletionParams? params,
  }) async {
    if (!_isLMLoaded || _lm == null) {
      return CactusResult.error('LLM model not loaded');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Build messages list
      final messages = <ChatMessage>[];

      // Add system prompt
      if (systemPrompt != null) {
        messages.add(ChatMessage(content: systemPrompt, role: 'system'));
      } else {
        messages.add(ChatMessage(content: _clinixSystemPrompt, role: 'system'));
      }

      // Add conversation history
      if (conversationHistory != null) {
        for (final msg in conversationHistory) {
          messages.add(ChatMessage(
            content: msg['content'] ?? '',
            role: msg['role'] ?? 'user',
          ));
        }
      }

      // Add current prompt
      messages.add(ChatMessage(content: prompt, role: 'user'));

      // Generate completion
      final result = await _lm!.generateCompletion(
        messages: messages,
        params: params ?? CactusCompletionParams(
          temperature: _currentLMConfig?.temperature ?? 0.7,
          maxTokens: _currentLMConfig?.maxTokens ?? 512,
          topP: 0.9,
        ),
      );

      stopwatch.stop();

      return CactusResult(
        response: result.response,
        tokensGenerated: result.totalTokens,
        processingTime: stopwatch.elapsed,
        success: result.success,
      );
    } catch (e) {
      stopwatch.stop();
      return CactusResult.error('Completion failed: $e');
    }
  }

  /// Generate a streaming completion
  Stream<String> generateCompletionStream({
    required String prompt,
    String? systemPrompt,
    List<Map<String, String>>? conversationHistory,
    CactusCompletionParams? params,
  }) async* {
    if (!_isLMLoaded || _lm == null) {
      yield '[ERROR] LLM model not loaded';
      return;
    }

    try {
      // Build messages list
      final messages = <ChatMessage>[];

      if (systemPrompt != null) {
        messages.add(ChatMessage(content: systemPrompt, role: 'system'));
      } else {
        messages.add(ChatMessage(content: _clinixSystemPrompt, role: 'system'));
      }

      if (conversationHistory != null) {
        for (final msg in conversationHistory) {
          messages.add(ChatMessage(
            content: msg['content'] ?? '',
            role: msg['role'] ?? 'user',
          ));
        }
      }

      messages.add(ChatMessage(content: prompt, role: 'user'));

      // Get streamed result
      final streamedResult = await _lm!.generateCompletionStream(
        messages: messages,
        params: params ?? CactusCompletionParams(
          temperature: _currentLMConfig?.temperature ?? 0.7,
          maxTokens: _currentLMConfig?.maxTokens ?? 512,
          topP: 0.9,
        ),
      );

      // Yield tokens from stream
      await for (final token in streamedResult.stream) {
        yield token;
      }
    } catch (e) {
      yield '[ERROR] Streaming failed: $e';
    }
  }

  /// Analyze an image with the vision model
  Future<VisionResult> analyzeImage({
    required String imagePath,
    String? prompt,
    CactusModelConfig? visionConfig,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Load vision model if not already loaded or different
      final config = visionConfig ?? CactusModelConfig.lfm2Vision;
      if (_currentVisionConfig?.modelName != config.modelName) {
        await loadLLMModel(config);
        _currentVisionConfig = config;
      }

      // Create message with image
      final imagePrompt = prompt ?? 'Analyze this medical image and describe any visible conditions or symptoms. Be specific about what you observe.';
      
      final messages = [
        ChatMessage(
          content: 'You are a medical image analysis assistant. Analyze images carefully and provide clinical observations. Always note if professional medical consultation is recommended.',
          role: 'system',
        ),
        ChatMessage(
          content: imagePrompt,
          role: 'user',
          images: [imagePath],
        ),
      ];

      final result = await _lm!.generateCompletion(
        messages: messages,
        params: CactusCompletionParams(
          temperature: 0.3,
          maxTokens: 512,
        ),
      );

      stopwatch.stop();

      // Parse response for detected conditions
      final conditions = _extractConditions(result.response);

      return VisionResult(
        description: result.response,
        detectedConditions: conditions,
        confidence: 0.7, // Base confidence for local model
        processingTime: stopwatch.elapsed,
        success: result.success,
      );
    } catch (e) {
      stopwatch.stop();
      return VisionResult.error('Image analysis failed: $e');
    }
  }

  /// Transcribe audio to text
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    if (!_isSTTLoaded || _stt == null) {
      return TranscriptionResult.error('STT model not loaded');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final result = await _stt!.transcribe(audioFilePath: audioFilePath);

      stopwatch.stop();

      return TranscriptionResult(
        text: result.text,
        processingTime: stopwatch.elapsed,
        language: _currentSTTConfig?.language,
        success: result.success,
      );
    } catch (e) {
      stopwatch.stop();
      return TranscriptionResult.error('Transcription failed: $e');
    }
  }

  /// Add a document to the RAG knowledge base
  Future<bool> addRAGDocument({
    required String fileName,
    required String content,
    String? filePath,
  }) async {
    if (!_isRAGInitialized || _rag == null) {
      _notifyStatus('RAG not initialized');
      return false;
    }

    try {
      await _rag!.storeDocument(
        fileName: fileName,
        filePath: filePath ?? '',
        content: content,
        fileSize: content.length,
      );
      _notifyStatus('Document "$fileName" added to knowledge base');
      return true;
    } catch (e) {
      _notifyStatus('Failed to add document: $e');
      return false;
    }
  }

  /// Search the RAG knowledge base
  Future<List<String>> searchRAG(String query, {int limit = 5}) async {
    if (!_isRAGInitialized || _rag == null) {
      return [];
    }

    try {
      final results = await _rag!.search(text: query, limit: limit);
      return results.map((r) => r.chunk.content).toList();
    } catch (e) {
      _notifyStatus('RAG search failed: $e');
      return [];
    }
  }

  /// Generate a RAG-augmented response
  Future<CactusResult> generateRAGResponse({
    required String query,
    int contextLimit = 5,
    String? systemPrompt,
  }) async {
    if (!_isLMLoaded) {
      return CactusResult.error('LLM not loaded');
    }

    // Get relevant context from RAG
    final context = await searchRAG(query, limit: contextLimit);
    
    // Build augmented prompt
    String augmentedPrompt = query;
    if (context.isNotEmpty) {
      final contextText = context.join('\n\n---\n\n');
      augmentedPrompt = '''Based on the following medical knowledge:

$contextText

---

User question: $query

Please provide an accurate response based on the above context.''';
    }

    return generateCompletion(
      prompt: augmentedPrompt,
      systemPrompt: systemPrompt ?? _clinixRAGSystemPrompt,
    );
  }

  /// Generate embeddings for text
  Future<List<double>> generateEmbedding(String text) async {
    if (!_isLMLoaded || _lm == null) {
      throw StateError('LLM not loaded');
    }

    final result = await _lm!.generateEmbedding(text: text);
    return result.embeddings;
  }

  /// Unload the LLM model
  Future<void> unloadLLM() async {
    if (_lm != null && _isLMLoaded) {
      _lm!.unload();
      _isLMLoaded = false;
      _currentLMConfig = null;
      _currentVisionConfig = null;
      _notifyStatus('LLM unloaded');
    }
  }

  /// Unload the STT model
  Future<void> unloadSTT() async {
    if (_stt != null && _isSTTLoaded) {
      // CactusSTT doesn't have explicit cleanup - just null the reference
      _stt = null;
      _isSTTLoaded = false;
      _currentSTTConfig = null;
      _notifyStatus('STT unloaded');
    }
  }

  /// Close RAG
  Future<void> closeRAG() async {
    if (_rag != null && _isRAGInitialized) {
      await _rag!.close();
      _isRAGInitialized = false;
      _notifyStatus('RAG closed');
    }
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await unloadLLM();
    await unloadSTT();
    await closeRAG();
    _isInitialized = false;
    _notifyStatus('Cactus service disposed');
  }

  /// Test if the service is working
  Future<bool> testConnection() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Check if a model is available locally
  Future<bool> isModelAvailable(String modelName) async {
    // This would check if the model files exist
    // For now, return true as Cactus handles this internally
    return true;
  }

  // Helper to extract conditions from vision response
  List<String> _extractConditions(String response) {
    final conditions = <String>[];
    final keywords = [
      'rash', 'redness', 'swelling', 'inflammation',
      'wound', 'cut', 'bruise', 'burn', 'infection',
      'discoloration', 'lesion', 'mole', 'growth',
    ];
    
    final lowerResponse = response.toLowerCase();
    for (final keyword in keywords) {
      if (lowerResponse.contains(keyword)) {
        conditions.add(keyword);
      }
    }
    
    return conditions;
  }

  void _notifyStatus(String status) {
    onStatusChange?.call(status);
    debugPrint('[CactusService] $status');
  }

  // ClinixAI system prompts
  static const String _clinixSystemPrompt = '''You are ClinixAI, a medical triage assistant designed to help users in Africa with limited healthcare access. 

Your role is to:
1. Listen to symptoms and health concerns
2. Ask clarifying questions to better understand the situation
3. Provide preliminary guidance on symptom severity
4. Recommend appropriate next steps (home care, clinic visit, or emergency)
5. Never diagnose - always recommend professional consultation for serious symptoms

Be empathetic, clear, and considerate of the user's context. Use simple language.
If symptoms suggest an emergency (chest pain, difficulty breathing, severe bleeding, loss of consciousness), immediately recommend emergency care.''';

  static const String _clinixRAGSystemPrompt = '''You are ClinixAI, a medical triage assistant with access to a medical knowledge base.

Use the provided medical context to give accurate, evidence-based responses.
When citing information, be clear about its source.
Always recommend professional medical consultation for diagnosis and treatment.
Be empathetic and use clear, simple language appropriate for users with varying health literacy levels.''';
}

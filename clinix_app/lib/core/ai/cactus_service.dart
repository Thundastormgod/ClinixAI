// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Cactus Service - On-Device LLM Inference
// Using Cactus SDK v1.2.0 for LiquidAI LFM2 model inference
//
// Architecture:
// ┌─────────────────────────────────────────────────────────────────┐
// │                       CactusService                             │
// ├─────────────────────────────────────────────────────────────────┤
// │  MODELS                  │  CAPABILITIES                        │
// │  ├─ LFM2-1.2B-RAG       │  ├─ Text Generation (Chat)           │
// │  ├─ LFM2-VL-450M        │  ├─ Vision Analysis                  │
// │  └─ Qwen3-0.6B          │  ├─ Speech-to-Text (Whisper)         │
// │                          │  └─ RAG (Embeddings + Search)        │
// └─────────────────────────────────────────────────────────────────┘
//
// Design Patterns:
// - Singleton-ready: Can be used as singleton or instantiated
// - Callback-based: Progress and status via callbacks
// - Defensive: Null checks and error handling throughout

import 'dart:async';
import 'package:cactus/cactus.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

// ============================================================================
// MODEL CONFIGURATION
// ============================================================================

/// Configuration for local AI models.
///
/// Immutable configuration object that defines model parameters for
/// LiquidAI LFM2, Qwen, and other supported local LLMs.
///
/// Use the predefined configurations for common models:
/// - [CactusModelConfig.lfm2Rag] - Best for RAG-enhanced triage
/// - [CactusModelConfig.lfm2Vision] - For medical image analysis
/// - [CactusModelConfig.qwen3Small] - Lightweight general-purpose
@immutable
class CactusModelConfig {
  /// Internal model identifier used by Cactus SDK.
  final String modelName;

  /// Human-readable display name for UI.
  final String displayName;

  /// Maximum context window size in tokens.
  final int contextSize;

  /// Sampling temperature (0.0 = deterministic, 1.0 = creative).
  final double temperature;

  /// Maximum tokens to generate per completion.
  final int maxTokens;

  /// Whether this model supports RAG-enhanced inference.
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

// ============================================================================
// SPEECH-TO-TEXT CONFIGURATION
// ============================================================================

/// Configuration for speech-to-text (Whisper) models.
///
/// Immutable configuration for Whisper-based transcription models.
/// Use predefined configurations for common use cases:
/// - [STTModelConfig.whisperTiny] - Fast, lower accuracy
/// - [STTModelConfig.whisperBase] - Balanced speed/accuracy
@immutable
class STTModelConfig {
  /// Internal model identifier.
  final String modelName;

  /// Human-readable display name.
  final String displayName;

  /// ISO 639-1 language code for transcription.
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

// ============================================================================
// RESULT TYPES
// ============================================================================

/// Result of a local LLM inference.
///
/// Immutable result object containing the model's response along with
/// metadata about token generation and processing time.
@immutable
class CactusResult {
  /// The generated text response.
  final String response;

  /// Number of tokens generated (0 if unavailable).
  final int tokensGenerated;

  /// Time taken for inference.
  final Duration processingTime;

  /// Whether inference completed successfully.
  final bool success;

  /// Error message if inference failed.
  final String? error;

  const CactusResult({
    required this.response,
    this.tokensGenerated = 0,
    required this.processingTime,
    this.success = true,
    this.error,
  });

  /// Creates an error result with the given message.
  factory CactusResult.error(String message) {
    return CactusResult(
      response: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// Result of speech-to-text transcription.
///
/// Immutable result object containing the transcribed text and metadata.
@immutable
class TranscriptionResult {
  /// The transcribed text.
  final String text;

  /// Time taken for transcription.
  final Duration processingTime;

  /// Whether transcription completed successfully.
  final bool success;

  /// Error message if transcription failed.
  final String? error;

  /// Detected or configured language.
  final String? language;

  const TranscriptionResult({
    required this.text,
    required this.processingTime,
    this.success = true,
    this.error,
    this.language,
  });

  /// Creates an error result with the given message.
  factory TranscriptionResult.error(String message) {
    return TranscriptionResult(
      text: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// Result of vision (image) analysis.
///
/// Immutable result object containing the visual analysis description
/// and detected medical conditions with confidence scores.
@immutable
class VisionResult {
  /// Detailed description of the analyzed image.
  final String description;

  /// List of detected medical conditions (e.g., 'rash', 'swelling').
  final List<String> detectedConditions;

  /// Overall confidence score (0.0 - 1.0).
  final double confidence;

  /// Time taken for analysis.
  final Duration processingTime;

  /// Whether analysis completed successfully.
  final bool success;

  /// Error message if analysis failed.
  final String? error;

  const VisionResult({
    required this.description,
    this.detectedConditions = const [],
    this.confidence = 0.0,
    required this.processingTime,
    this.success = true,
    this.error,
  });

  /// Creates an error result with the given message.
  factory VisionResult.error(String message) {
    return VisionResult(
      description: '',
      processingTime: Duration.zero,
      success: false,
      error: message,
    );
  }
}

/// RAG document for medical knowledge.
///
/// Represents a document that can be added to the local RAG knowledge base
/// for retrieval-augmented generation.
@immutable
class RAGDocument {
  /// Unique identifier for the document.
  final String id;

  /// Original file name.
  final String fileName;

  /// Full text content of the document.
  final String content;

  /// Size in bytes.
  final int fileSize;

  /// When the document was added.
  final DateTime addedAt;

  RAGDocument({
    required this.id,
    required this.fileName,
    required this.content,
    required this.fileSize,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

// ============================================================================
// CACTUS SERVICE
// ============================================================================

/// ClinixAI on-device AI service using Cactus SDK v1.2.0.
///
/// Provides comprehensive on-device AI capabilities:
/// - **Text Generation**: Chat completions with LiquidAI LFM2
/// - **Vision Analysis**: Medical image analysis with LFM2-VL
/// - **Speech-to-Text**: Whisper-based transcription
/// - **RAG**: Retrieval-augmented generation with embeddings
///
/// ## Usage
/// ```dart
/// final cactus = CactusService();
/// await cactus.initialize();
/// await cactus.downloadLLMModel(CactusModelConfig.lfm2Rag);
/// await cactus.loadLLMModel(CactusModelConfig.lfm2Rag);
///
/// final result = await cactus.generateCompletion(
///   prompt: 'Patient has fever and headache',
/// );
/// ```
///
/// ## Error Handling
/// All methods return result objects with `success` flags and optional
/// `error` messages rather than throwing exceptions for inference errors.
class CactusService {
  // ──────────────────────────────────────────────────────────────────
  // CACTUS SDK INSTANCES
  // ──────────────────────────────────────────────────────────────────

  CactusLM? _lm;
  CactusSTT? _stt;
  CactusRAG? _rag;

  // ──────────────────────────────────────────────────────────────────
  // CURRENT CONFIGURATIONS
  // ──────────────────────────────────────────────────────────────────

  CactusModelConfig? _currentLMConfig;
  CactusModelConfig? _currentVisionConfig;
  STTModelConfig? _currentSTTConfig;

  // ──────────────────────────────────────────────────────────────────
  // STATE TRACKING
  // ──────────────────────────────────────────────────────────────────

  bool _isInitialized = false;
  bool _isLMLoaded = false;
  bool _isSTTLoaded = false;
  bool _isRAGInitialized = false;
  bool _isDownloading = false;

  // ──────────────────────────────────────────────────────────────────
  // CALLBACKS
  // ──────────────────────────────────────────────────────────────────

  /// Callback for download progress updates.
  void Function(double? progress, String status, bool isError)? onDownloadProgress;

  /// Callback for status change notifications.
  void Function(String status)? onStatusChange;

  // ──────────────────────────────────────────────────────────────────
  // PUBLIC GETTERS
  // ──────────────────────────────────────────────────────────────────

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Whether a language model is currently loaded.
  bool get isLMLoaded => _isLMLoaded;

  /// Whether the speech-to-text model is loaded.
  bool get isSTTLoaded => _isSTTLoaded;

  /// Whether RAG has been initialized.
  bool get isRAGInitialized => _isRAGInitialized;

  /// Whether a model download is in progress.
  bool get isDownloading => _isDownloading;

  /// Display name of the currently loaded model, or null if none.
  String? get currentModelName => _currentLMConfig?.displayName;

  // ──────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ──────────────────────────────────────────────────────────────────

  /// Initialize the Cactus service.
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

  // ──────────────────────────────────────────────────────────────────
  // MODEL DOWNLOAD
  // ──────────────────────────────────────────────────────────────────

  /// Downloads an LLM model from the Cactus model repository.
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

  // ──────────────────────────────────────────────────────────────────
  // MODEL LOADING
  // ──────────────────────────────────────────────────────────────────

  /// Loads an LLM model into memory for inference.
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

  // ──────────────────────────────────────────────────────────────────
  // TEXT GENERATION
  // ──────────────────────────────────────────────────────────────────

  /// Generates a text completion (chat response).
  ///
  /// Uses the currently loaded LLM to generate a response based on the
  /// provided prompt, optional system prompt, and conversation history.
  ///
  /// Returns a [CactusResult] with the generated text.
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

  // ──────────────────────────────────────────────────────────────────
  // VISION ANALYSIS
  // ──────────────────────────────────────────────────────────────────

  /// Analyzes an image using the vision model.
  ///
  /// Uses LFM2-VL to analyze medical images and detect visible conditions.
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

  // ──────────────────────────────────────────────────────────────────
  // SPEECH-TO-TEXT
  // ──────────────────────────────────────────────────────────────────

  /// Transcribes audio to text using Whisper.
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

  // ──────────────────────────────────────────────────────────────────
  // RAG OPERATIONS
  // ──────────────────────────────────────────────────────────────────

  /// Adds a document to the RAG knowledge base.
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

  // ──────────────────────────────────────────────────────────────────
  // LIFECYCLE MANAGEMENT
  // ──────────────────────────────────────────────────────────────────

  /// Unloads the LLM model from memory.
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

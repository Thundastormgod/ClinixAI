// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Mock Cactus Service - Web Demo Mode
// Provides mock responses for UI testing on web/desktop platforms
//
// This mock service simulates the Cactus SDK behavior for platforms
// where native binaries aren't available (web, desktop).

import 'dart:async';
import 'package:flutter/foundation.dart';

// Re-export config types that don't depend on native code
export '../cactus_service.dart' show 
    CactusModelConfig, 
    STTModelConfig, 
    CactusResult, 
    TranscriptionResult, 
    VisionResult, 
    RAGDocument;

import '../cactus_service.dart' show 
    CactusModelConfig, 
    STTModelConfig, 
    CactusResult, 
    TranscriptionResult, 
    VisionResult;

/// Mock CactusService for web demo mode.
/// 
/// Provides simulated responses for UI testing on platforms where
/// the native Cactus SDK isn't available.
class MockCactusService {
  // State tracking
  bool _isInitialized = false;
  bool _isLMLoaded = false;
  bool _isSTTLoaded = false;
  bool _isRAGInitialized = false;
  bool _isDownloading = false;

  CactusModelConfig? _currentLMConfig;
  STTModelConfig? _currentSTTConfig;

  // Callbacks
  void Function(double? progress, String status, bool isError)? onDownloadProgress;
  void Function(String status)? onStatusChange;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLMLoaded => _isLMLoaded;
  bool get isSTTLoaded => _isSTTLoaded;
  bool get isRAGInitialized => _isRAGInitialized;
  bool get isDownloading => _isDownloading;
  String? get currentModelName => _currentLMConfig?.displayName ?? 'Demo Mode (Cloud-Only)';

  /// Initialize the mock service.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
    _notifyStatus('Mock Cactus service initialized (Demo Mode)');
  }

  /// Simulate model download with progress.
  Future<bool> downloadLLMModel(CactusModelConfig config) async {
    if (_isDownloading) return false;
    
    _isDownloading = true;
    _notifyStatus('Simulating download of ${config.displayName}...');
    
    // Simulate download progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 50));
      onDownloadProgress?.call(i / 100.0, 'Downloading...', false);
    }
    
    _isDownloading = false;
    _notifyStatus('${config.displayName} download simulated (Demo Mode)');
    return true;
  }

  /// Simulate STT model download.
  Future<bool> downloadSTTModel(STTModelConfig config) async {
    if (_isDownloading) return false;
    
    _isDownloading = true;
    _notifyStatus('Simulating download of ${config.displayName}...');
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    _isDownloading = false;
    _notifyStatus('${config.displayName} download simulated (Demo Mode)');
    return true;
  }

  /// Simulate model loading.
  Future<bool> loadLLMModel(CactusModelConfig config) async {
    if (!_isInitialized) await initialize();
    
    _notifyStatus('Loading ${config.displayName} (Demo Mode)...');
    await Future.delayed(const Duration(milliseconds: 100));
    
    _currentLMConfig = config;
    _isLMLoaded = true;
    _notifyStatus('${config.displayName} loaded (Demo Mode)');
    
    return true;
  }

  /// Simulate STT model loading.
  Future<bool> loadSTTModel(STTModelConfig config) async {
    if (!_isInitialized) await initialize();
    
    _notifyStatus('Loading ${config.displayName} (Demo Mode)...');
    await Future.delayed(const Duration(milliseconds: 100));
    
    _currentSTTConfig = config;
    _isSTTLoaded = true;
    _notifyStatus('${config.displayName} loaded (Demo Mode)');
    
    return true;
  }

  /// Generate a mock completion response.
  /// 
  /// Returns a realistic-looking medical triage response for demo purposes.
  Future<CactusResult> generateCompletion({
    required String prompt,
    String? systemPrompt,
    List<Map<String, String>>? conversationHistory,
    dynamic params,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    // Simulate processing time
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate mock medical response based on keywords in prompt
    final mockResponse = _generateMockTriageResponse(prompt);
    
    stopwatch.stop();
    
    return CactusResult(
      response: mockResponse,
      tokensGenerated: mockResponse.length ~/ 4,
      processingTime: stopwatch.elapsed,
      success: true,
    );
  }

  /// Generate a streaming completion (mock).
  Stream<String> generateCompletionStream({
    required String prompt,
    String? systemPrompt,
    List<Map<String, String>>? conversationHistory,
    dynamic params,
  }) async* {
    final response = _generateMockTriageResponse(prompt);
    
    // Stream the response word by word
    for (final word in response.split(' ')) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield '$word ';
    }
  }

  /// Simulate image analysis.
  Future<VisionResult> analyzeImage({
    required String imagePath,
    String? prompt,
    CactusModelConfig? visionConfig,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    stopwatch.stop();
    
    return VisionResult(
      description: '[Demo Mode] Image analysis is not available on web. '
          'Please use a mobile device for actual image analysis.',
      detectedConditions: ['demo_condition'],
      confidence: 0.0,
      processingTime: stopwatch.elapsed,
      success: true,
    );
  }

  /// Simulate transcription.
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    final stopwatch = Stopwatch()..start();
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    stopwatch.stop();
    
    return TranscriptionResult(
      text: '[Demo Mode] Speech-to-text is not available on web. '
          'Please use a mobile device for voice input.',
      processingTime: stopwatch.elapsed,
      success: true,
      language: 'en',
    );
  }

  /// Simulate adding RAG document.
  Future<bool> addRAGDocument({
    required String fileName,
    required String content,
    String? filePath,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isRAGInitialized = true;
    _notifyStatus('Document "$fileName" added to mock knowledge base');
    return true;
  }

  /// Simulate RAG search.
  Future<List<String>> searchRAG(String query, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      '[Demo] Medical knowledge context would appear here.',
      '[Demo] Relevant treatment guidelines would be retrieved.',
    ];
  }

  /// Simulate RAG-enhanced response.
  Future<CactusResult> generateRAGResponse({
    required String query,
    int contextLimit = 5,
    String? systemPrompt,
  }) async {
    return generateCompletion(prompt: query, systemPrompt: systemPrompt);
  }

  /// Simulate embedding generation.
  Future<List<double>> generateEmbedding(String text) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // Return a mock 384-dimensional embedding (zeros)
    return List.filled(384, 0.0);
  }

  /// Unload LLM (no-op in mock).
  Future<void> unloadLLM() async {
    _isLMLoaded = false;
    _currentLMConfig = null;
    _notifyStatus('Mock LLM unloaded');
  }

  /// Unload STT (no-op in mock).
  Future<void> unloadSTT() async {
    _isSTTLoaded = false;
    _currentSTTConfig = null;
    _notifyStatus('Mock STT unloaded');
  }

  /// Close RAG (no-op in mock).
  Future<void> closeRAG() async {
    _isRAGInitialized = false;
    _notifyStatus('Mock RAG closed');
  }

  /// Dispose all resources (no-op in mock).
  Future<void> dispose() async {
    await unloadLLM();
    await unloadSTT();
    await closeRAG();
    _isInitialized = false;
    _notifyStatus('Mock Cactus service disposed');
  }

  /// Test connection (always succeeds in mock).
  Future<bool> testConnection() async {
    return true;
  }

  /// Check if model is available (always true in mock).
  Future<bool> isModelAvailable(String modelName) async {
    return true;
  }

  void _notifyStatus(String status) {
    onStatusChange?.call(status);
    debugPrint('[MockCactusService] $status');
  }

  /// Generate a mock triage response based on symptom keywords.
  String _generateMockTriageResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    // Determine urgency based on keywords
    String urgency = 'standard';
    double confidence = 0.75;
    String assessment = '';
    String action = '';
    List<String> redFlags = [];
    String referral = 'clinic';
    
    if (lowerPrompt.contains('chest pain') || 
        lowerPrompt.contains('heart') ||
        lowerPrompt.contains('stroke') ||
        lowerPrompt.contains('unconscious')) {
      urgency = 'critical';
      confidence = 0.92;
      assessment = '[DEMO] Potential cardiac or neurological emergency detected. '
          'This is a simulated response for UI testing.';
      action = 'Seek immediate emergency medical care. Call emergency services.';
      redFlags = ['chest pain', 'potential cardiac event'];
      referral = 'emergency';
    } else if (lowerPrompt.contains('fever') || 
               lowerPrompt.contains('headache') ||
               lowerPrompt.contains('pain')) {
      urgency = 'urgent';
      confidence = 0.82;
      assessment = '[DEMO] Symptoms suggest condition requiring medical attention. '
          'This is a simulated response for UI testing.';
      action = 'Visit healthcare facility within 24 hours for evaluation.';
      redFlags = [];
      referral = 'clinic';
    } else if (lowerPrompt.contains('malaria') ||
               lowerPrompt.contains('typhoid') ||
               lowerPrompt.contains('cholera')) {
      urgency = 'urgent';
      confidence = 0.88;
      assessment = '[DEMO] Potential endemic disease detected. '
          'This is a simulated response for UI testing.';
      action = 'Seek medical testing and treatment at healthcare facility.';
      redFlags = ['potential infectious disease'];
      referral = 'hospital';
    } else {
      urgency = 'standard';
      confidence = 0.70;
      assessment = '[DEMO] Symptoms appear non-urgent based on description. '
          'This is a simulated response for UI testing.';
      action = 'Monitor symptoms. Visit clinic if condition worsens.';
      redFlags = [];
      referral = 'self-care';
    }
    
    // Return JSON response
    return '''
{
  "urgency_level": "$urgency",
  "confidence": $confidence,
  "assessment": "$assessment",
  "recommended_action": "$action",
  "red_flags": ${redFlags.isEmpty ? '[]' : '["${redFlags.join('", "')}"]'},
  "referral_type": "$referral",
  "_demo_mode": true,
  "_note": "This is a simulated response for web demo mode. Use a mobile device for actual AI inference."
}'''.trim();
  }
}

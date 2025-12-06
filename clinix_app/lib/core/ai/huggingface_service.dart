import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// Supported model providers
enum ModelProvider {
  qwen('Qwen'),
  liquidAI('LiquidAI'),
  mistral('Mistral'),
  custom('Custom');

  final String displayName;
  const ModelProvider(this.displayName);
}

/// Configuration for HuggingFace Inference API
class HuggingFaceConfig {
  /// HuggingFace API token
  final String? apiToken;
  
  /// Inference API base URL
  final String inferenceUrl;
  
  /// Default model for text generation
  final String textGenerationModel;
  
  /// Model for zero-shot classification
  final String classificationModel;
  
  /// Qwen model endpoint (custom or default)
  final String qwenModel;
  
  /// Qwen custom endpoint URL (for HuggingFace Inference Endpoints)
  final String? qwenEndpointUrl;
  
  /// LiquidAI model endpoint (custom or default)
  final String liquidAIModel;
  
  /// LiquidAI custom endpoint URL
  final String? liquidAIEndpointUrl;
  
  /// Preferred provider for triage
  final ModelProvider preferredProvider;
  
  /// Request timeout
  final Duration timeout;

  const HuggingFaceConfig({
    this.apiToken,
    this.inferenceUrl = 'https://api-inference.huggingface.co/models',
    this.textGenerationModel = 'mistralai/Mistral-7B-Instruct-v0.2',
    this.classificationModel = 'facebook/bart-large-mnli',
    this.qwenModel = 'Qwen/Qwen2.5-7B-Instruct',
    this.qwenEndpointUrl,
    this.liquidAIModel = 'LiquidAI/LFM2-1.2B-Instruct',
    this.liquidAIEndpointUrl,
    this.preferredProvider = ModelProvider.qwen,
    this.timeout = const Duration(seconds: 120),
  });
  
  /// Copy with modifications
  HuggingFaceConfig copyWith({
    String? apiToken,
    String? inferenceUrl,
    String? textGenerationModel,
    String? classificationModel,
    String? qwenModel,
    String? qwenEndpointUrl,
    String? liquidAIModel,
    String? liquidAIEndpointUrl,
    ModelProvider? preferredProvider,
    Duration? timeout,
  }) {
    return HuggingFaceConfig(
      apiToken: apiToken ?? this.apiToken,
      inferenceUrl: inferenceUrl ?? this.inferenceUrl,
      textGenerationModel: textGenerationModel ?? this.textGenerationModel,
      classificationModel: classificationModel ?? this.classificationModel,
      qwenModel: qwenModel ?? this.qwenModel,
      qwenEndpointUrl: qwenEndpointUrl ?? this.qwenEndpointUrl,
      liquidAIModel: liquidAIModel ?? this.liquidAIModel,
      liquidAIEndpointUrl: liquidAIEndpointUrl ?? this.liquidAIEndpointUrl,
      preferredProvider: preferredProvider ?? this.preferredProvider,
      timeout: timeout ?? this.timeout,
    );
  }
}

/// Result from HuggingFace inference
class HuggingFaceResult {
  final bool success;
  final String? generatedText;
  final Map<String, double>? classifications;
  final String? error;
  final Duration inferenceTime;
  final ModelProvider? providerUsed;
  final String? modelUsed;

  const HuggingFaceResult({
    required this.success,
    this.generatedText,
    this.classifications,
    this.error,
    this.inferenceTime = Duration.zero,
    this.providerUsed,
    this.modelUsed,
  });
  
  factory HuggingFaceResult.failure(String error) {
    return HuggingFaceResult(
      success: false,
      error: error,
    );
  }
}

/// HuggingFace Service for Flutter
/// 
/// Provides direct access to HuggingFace Inference API for:
/// - Text generation (medical triage)
/// - Zero-shot classification
/// - Symptom analysis
class HuggingFaceService {
  static HuggingFaceService? _instance;
  static HuggingFaceService get instance => _instance ??= HuggingFaceService._();
  
  HuggingFaceService._();
  
  late Dio _dio;
  late HuggingFaceConfig _config;
  bool _isInitialized = false;
  
  /// Whether the service is ready
  bool get isReady => _isInitialized;
  
  /// Initialize with configuration
  Future<void> initialize({HuggingFaceConfig? config}) async {
    if (_isInitialized) return;
    
    _config = config ?? const HuggingFaceConfig();
    
    _dio = Dio(BaseOptions(
      baseUrl: _config.inferenceUrl,
      connectTimeout: _config.timeout,
      receiveTimeout: _config.timeout,
      headers: {
        'Content-Type': 'application/json',
        if (_config.apiToken != null) 
          'Authorization': 'Bearer ${_config.apiToken}',
      },
    ));
    
    _isInitialized = true;
  }
  
  /// Generate medical triage response
  /// Tries providers in order: preferred -> Qwen -> LiquidAI -> Mistral
  Future<HuggingFaceResult> generateTriageResponse({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    ModelProvider? provider,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_config.apiToken == null) {
      return HuggingFaceResult.failure('HuggingFace API token not configured');
    }
    
    final stopwatch = Stopwatch()..start();
    
    // Build provider fallback chain
    final providers = <ModelProvider>[
      provider ?? _config.preferredProvider,
      ModelProvider.qwen,
      ModelProvider.liquidAI,
      ModelProvider.mistral,
    ].toSet().toList(); // Remove duplicates
    
    // Try each provider
    for (final currentProvider in providers) {
      try {
        final result = await _tryProvider(
          provider: currentProvider,
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          stopwatch: stopwatch,
        );
        
        if (result.success) {
          return result;
        }
      } catch (e) {
        // Try next provider
        continue;
      }
    }
    
    stopwatch.stop();
    return HuggingFaceResult.failure(
      'All providers failed. Please check your connection.',
    );
  }
  
  /// Try a specific provider
  Future<HuggingFaceResult> _tryProvider({
    required ModelProvider provider,
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    required Stopwatch stopwatch,
  }) async {
    // Build provider-specific prompt
    final prompt = _buildMedicalPrompt(
      symptoms: symptoms,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      provider: provider,
    );
    
    // Get endpoint URL
    String url;
    String model;
    
    switch (provider) {
      case ModelProvider.qwen:
        url = _config.qwenEndpointUrl ?? 
              '${_config.inferenceUrl}/${_config.qwenModel}';
        model = _config.qwenModel;
        break;
      case ModelProvider.liquidAI:
        url = _config.liquidAIEndpointUrl ??
              '${_config.inferenceUrl}/${_config.liquidAIModel}';
        model = _config.liquidAIModel;
        break;
      case ModelProvider.mistral:
        url = '${_config.inferenceUrl}/${_config.textGenerationModel}';
        model = _config.textGenerationModel;
        break;
      case ModelProvider.custom:
        url = '${_config.inferenceUrl}/${_config.textGenerationModel}';
        model = _config.textGenerationModel;
        break;
    }
    
    try {
      final response = await _dio.post(
        url.startsWith('http') ? '' : '/$url',
        options: url.startsWith('http') 
            ? Options(extra: {'baseUrl': url})
            : null,
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 512,
            'temperature': 0.3,
            'top_p': 0.9,
            'do_sample': true,
            'return_full_text': false,
          },
          'options': {
            'wait_for_model': true,
          },
        },
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final data = response.data;
        String generatedText = '';
        
        if (data is List && data.isNotEmpty) {
          generatedText = data[0]['generated_text'] ?? '';
        } else if (data is Map) {
          generatedText = data['generated_text'] ?? '';
        }
        
        return HuggingFaceResult(
          success: true,
          generatedText: generatedText,
          inferenceTime: stopwatch.elapsed,
          providerUsed: provider,
          modelUsed: model,
        );
      } else {
        return HuggingFaceResult.failure(
          'Request failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle model loading
      if (e.response?.statusCode == 503) {
        // Wait and retry once
        await Future.delayed(const Duration(seconds: 20));
        return _tryProvider(
          provider: provider,
          symptoms: symptoms,
          patientAge: patientAge,
          patientGender: patientGender,
          medicalHistory: medicalHistory,
          stopwatch: stopwatch,
        );
      }
      rethrow;
    }
  }
  
  /// Classify symptoms using zero-shot classification
  Future<HuggingFaceResult> classifySymptoms(String symptoms) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_config.apiToken == null) {
      return HuggingFaceResult.failure('HuggingFace API token not configured');
    }
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _dio.post(
        '/${_config.classificationModel}',
        data: {
          'inputs': symptoms,
          'parameters': {
            'candidate_labels': [
              'life-threatening emergency',
              'urgent medical attention needed',
              'moderate condition requiring care',
              'minor condition for self-care',
            ],
          },
          'options': {
            'wait_for_model': true,
          },
        },
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final labels = data['labels'] as List<dynamic>? ?? [];
        final scores = data['scores'] as List<dynamic>? ?? [];
        
        final classifications = <String, double>{};
        for (var i = 0; i < labels.length && i < scores.length; i++) {
          classifications[labels[i].toString()] = 
              (scores[i] as num).toDouble();
        }
        
        return HuggingFaceResult(
          success: true,
          classifications: classifications,
          inferenceTime: stopwatch.elapsed,
        );
      } else {
        return HuggingFaceResult.failure(
          'Classification failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      stopwatch.stop();
      return HuggingFaceResult.failure('Network error: ${e.message}');
    } catch (e) {
      stopwatch.stop();
      return HuggingFaceResult.failure('Error: $e');
    }
  }
  
  /// Build a medical triage prompt for the model
  String _buildMedicalPrompt({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    ModelProvider provider = ModelProvider.qwen,
  }) {
    final systemPrompt = '''You are ClinixAI, an advanced AI medical triage assistant for healthcare in Africa.

CRITICAL GUIDELINES:
1. Patient safety is the top priority
2. Consider Africa-specific diseases: malaria, typhoid, cholera, TB, HIV
3. Account for resource-limited settings
4. NEVER diagnose - only provide triage guidance

URGENCY LEVELS:
- CRITICAL: Life-threatening, immediate emergency care
- URGENT: Serious, care within 2-4 hours  
- STANDARD: Non-emergency, care within 24-48 hours
- NON-URGENT: Minor, self-care appropriate''';

    final patientInfo = StringBuffer();
    patientInfo.writeln('PATIENT INFORMATION:');
    if (patientAge != null) patientInfo.writeln('- Age: $patientAge years');
    if (patientGender != null) patientInfo.writeln('- Gender: $patientGender');
    if (medicalHistory != null && medicalHistory.isNotEmpty) {
      patientInfo.writeln('- Medical History: ${medicalHistory.join(", ")}');
    }

    final userPrompt = '''$patientInfo

SYMPTOMS:
$symptoms

Respond with JSON ONLY:
{"urgency_level":"critical|urgent|standard|non-urgent","confidence":0.0-1.0,"assessment":"brief assessment","action":"recommended action","conditions":[{"name":"condition","probability":0.0-1.0}],"red_flags":["warning signs"]}''';

    // Apply chat template based on provider
    switch (provider) {
      case ModelProvider.qwen:
        return '''<|im_start|>system
$systemPrompt<|im_end|>
<|im_start|>user
$userPrompt<|im_end|>
<|im_start|>assistant
''';
      case ModelProvider.liquidAI:
        return '''<|system|>
$systemPrompt
<|user|>
$userPrompt
<|assistant|>
''';
      case ModelProvider.mistral:
        return '''<s>[INST]$systemPrompt

$userPrompt[/INST]''';
      case ModelProvider.custom:
        return '''$systemPrompt

$userPrompt''';
    }
  }
  
  /// Check API health
  Future<bool> checkHealth() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_config.apiToken == null) {
      return false;
    }
    
    try {
      final response = await Dio().get(
        'https://huggingface.co/api/whoami',
        options: Options(
          headers: {'Authorization': 'Bearer ${_config.apiToken}'},
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _dio.close();
    _isInitialized = false;
  }
}

/// Extension for parsing triage result from HuggingFace response
extension HuggingFaceResultParsing on HuggingFaceResult {
  /// Try to parse JSON triage result from generated text
  Map<String, dynamic>? parseTriageResult() {
    if (!success || generatedText == null) return null;
    
    try {
      // Try direct parse
      return jsonDecode(generatedText!) as Map<String, dynamic>;
    } catch (_) {}
    
    // Try to extract JSON from text
    try {
      final text = generatedText!;
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}') + 1;
      
      if (start != -1 && end > start) {
        final jsonStr = text.substring(start, end);
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    
    return null;
  }
  
  /// Convert classification result to urgency level
  String? getUrgencyFromClassification() {
    if (classifications == null || classifications!.isEmpty) return null;
    
    // Find highest scoring label
    final sorted = classifications!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topLabel = sorted.first.key.toLowerCase();
    
    if (topLabel.contains('life-threatening') || topLabel.contains('emergency')) {
      return 'critical';
    } else if (topLabel.contains('urgent')) {
      return 'urgent';
    } else if (topLabel.contains('moderate')) {
      return 'standard';
    } else {
      return 'non-urgent';
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OpenRouter Cloud AI Service
/// 
/// Provides access to multiple cloud LLM providers through OpenRouter API.
/// Used for complex triage cases that exceed local model capabilities.
/// 
/// Model Selection Rules:
/// - Critical cases: Use most capable model (Claude 3.5 Sonnet, GPT-4o)
/// - Complex differential: Use medical-tuned model (Med-PaLM, GPT-4o)
/// - Standard cases: Use cost-effective model (Mistral, Claude Haiku)
/// - Fallback chain: Primary → Secondary → Tertiary

/// Available OpenRouter models for medical triage
enum OpenRouterModel {
  // Tier 1: Most Capable (Critical Cases)
  claude35Sonnet('anthropic/claude-3.5-sonnet', 'Claude 3.5 Sonnet', 0.003, 0.015),
  gpt4o('openai/gpt-4o', 'GPT-4o', 0.005, 0.015),
  gpt4oMini('openai/gpt-4o-mini', 'GPT-4o Mini', 0.00015, 0.0006),
  
  // Tier 2: Balanced (Complex Cases)
  claude3Haiku('anthropic/claude-3-haiku', 'Claude 3 Haiku', 0.00025, 0.00125),
  gemini15Pro('google/gemini-pro-1.5', 'Gemini 1.5 Pro', 0.00125, 0.005),
  
  // Tier 3: Cost-Effective (Standard Cases)
  mistralLarge('mistralai/mistral-large', 'Mistral Large', 0.003, 0.009),
  mistral7b('mistralai/mistral-7b-instruct', 'Mistral 7B', 0.00006, 0.00006),
  llama370b('meta-llama/llama-3-70b-instruct', 'Llama 3 70B', 0.00059, 0.00079),
  
  // Tier 4: Free/Very Cheap (Fallback)
  llama38b('meta-llama/llama-3-8b-instruct', 'Llama 3 8B', 0.00006, 0.00006),
  phi3('microsoft/phi-3-mini-128k-instruct', 'Phi-3 Mini', 0.0001, 0.0001);

  final String modelId;
  final String displayName;
  final double inputCostPer1k;
  final double outputCostPer1k;
  
  const OpenRouterModel(this.modelId, this.displayName, this.inputCostPer1k, this.outputCostPer1k);
}

/// Model selection tier based on case complexity
enum ModelTier {
  /// Critical/Emergency cases - use best available
  critical,
  /// Complex differential diagnosis
  complex,
  /// Standard triage
  standard,
  /// Simple/Non-urgent cases
  simple,
}

/// Result from OpenRouter API call
class OpenRouterResult {
  final String response;
  final bool success;
  final String? error;
  final String modelUsed;
  final Duration? latency;
  final int? promptTokens;
  final int? completionTokens;
  final double? estimatedCost;

  const OpenRouterResult({
    required this.response,
    required this.success,
    required this.modelUsed,
    this.error,
    this.latency,
    this.promptTokens,
    this.completionTokens,
    this.estimatedCost,
  });

  factory OpenRouterResult.failure(String error, {String modelUsed = 'none'}) {
    return OpenRouterResult(
      response: '',
      success: false,
      error: error,
      modelUsed: modelUsed,
    );
  }

  /// Parse the response as JSON
  Map<String, dynamic>? parseAsJson() {
    if (!success || response.isEmpty) return null;
    
    try {
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (_) {}
    
    // Try to extract JSON from response
    try {
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}') + 1;
      if (start != -1 && end > start) {
        return jsonDecode(response.substring(start, end)) as Map<String, dynamic>;
      }
    } catch (_) {}
    
    return null;
  }
}

/// OpenRouter cloud AI service for hybrid inference
class OpenRouterService {
  // Singleton pattern
  static OpenRouterService? _instance;
  static OpenRouterService get instance => _instance ??= OpenRouterService._();
  
  OpenRouterService._();

  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  
  String? _apiKey;
  bool _isConfigured = false;
  
  /// Model selection rules for each tier
  final Map<ModelTier, List<OpenRouterModel>> _tierModels = {
    ModelTier.critical: [
      OpenRouterModel.claude35Sonnet,
      OpenRouterModel.gpt4o,
      OpenRouterModel.gemini15Pro,
    ],
    ModelTier.complex: [
      OpenRouterModel.gpt4oMini,
      OpenRouterModel.claude3Haiku,
      OpenRouterModel.mistralLarge,
    ],
    ModelTier.standard: [
      OpenRouterModel.mistral7b,
      OpenRouterModel.llama370b,
      OpenRouterModel.phi3,
    ],
    ModelTier.simple: [
      OpenRouterModel.llama38b,
      OpenRouterModel.phi3,
      OpenRouterModel.mistral7b,
    ],
  };

  /// Check if service is configured
  bool get isConfigured => _isConfigured && _apiKey != null;

  /// Get the current default model
  String get currentModel => OpenRouterModel.gpt4oMini.displayName;

  /// Configure the service with API key
  void configure({required String apiKey}) {
    _apiKey = apiKey;
    _isConfigured = apiKey.isNotEmpty;
    debugPrint('[OpenRouter] Service configured: $_isConfigured');
  }

  /// Get models for a specific tier
  List<OpenRouterModel> getModelsForTier(ModelTier tier) {
    return _tierModels[tier] ?? _tierModels[ModelTier.standard]!;
  }

  /// Run triage inference with automatic model selection and fallback
  /// 
  /// Selects model based on tier, attempts fallback on failure.
  /// Pass [riskScore] and [complexityScore] to give the model context about why it was called.
  Future<OpenRouterResult> runTriageInference({
    required String symptoms,
    required ModelTier tier,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    OpenRouterModel? forceModel,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    if (!_isConfigured || _apiKey == null) {
      return OpenRouterResult.failure('OpenRouter not configured. Call configure() first.');
    }

    final modelsToTry = forceModel != null 
        ? [forceModel] 
        : getModelsForTier(tier);

    for (final model in modelsToTry) {
      debugPrint('[OpenRouter] Trying model: ${model.displayName}');
      
      final result = await _callModel(
        model: model,
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        riskScore: riskScore,
        complexityScore: complexityScore,
        escalationReason: escalationReason,
      );

      if (result.success) {
        debugPrint('[OpenRouter] Success with ${model.displayName}');
        return result;
      }

      debugPrint('[OpenRouter] Failed with ${model.displayName}: ${result.error}');
    }

    return OpenRouterResult.failure(
      'All models failed. Last error: Unable to get response.',
      modelUsed: modelsToTry.last.modelId,
    );
  }

  /// Call a specific model
  Future<OpenRouterResult> _callModel({
    required OpenRouterModel model,
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final messages = _buildTriageMessages(
        symptoms: symptoms,
        patientAge: patientAge,
        patientGender: patientGender,
        medicalHistory: medicalHistory,
        vitalSigns: vitalSigns,
        riskScore: riskScore,
        complexityScore: complexityScore,
        escalationReason: escalationReason,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://clinixai.health',
          'X-Title': 'ClinixAI Medical Triage',
        },
        body: jsonEncode({
          'model': model.modelId,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.3, // Lower temp for medical accuracy
          'response_format': {'type': 'json_object'},
        }),
      );

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final usage = data['usage'] as Map<String, dynamic>?;
        
        final promptTokens = usage?['prompt_tokens'] as int?;
        final completionTokens = usage?['completion_tokens'] as int?;
        
        double? estimatedCost;
        if (promptTokens != null && completionTokens != null) {
          estimatedCost = (promptTokens / 1000 * model.inputCostPer1k) +
                         (completionTokens / 1000 * model.outputCostPer1k);
        }

        return OpenRouterResult(
          response: content,
          success: true,
          modelUsed: model.modelId,
          latency: stopwatch.elapsed,
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          estimatedCost: estimatedCost,
        );
      } else {
        final error = jsonDecode(response.body);
        return OpenRouterResult.failure(
          'API error: ${error['error']?['message'] ?? response.statusCode}',
          modelUsed: model.modelId,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return OpenRouterResult.failure(
        'Request failed: $e',
        modelUsed: model.modelId,
      );
    }
  }

  /// Build messages for triage prompt
  List<Map<String, String>> _buildTriageMessages({
    required String symptoms,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) {
    // Build context-aware system prompt based on risk/complexity
    final contextBuffer = StringBuffer();
    contextBuffer.writeln('You are ClinixAI, an expert medical triage AI assistant for healthcare in Africa.');
    contextBuffer.writeln('Your role is to analyze symptoms and provide accurate triage assessment.');
    
    // Add risk/complexity context if provided
    if (riskScore != null || complexityScore != null || escalationReason != null) {
      contextBuffer.writeln();
      contextBuffer.writeln('⚠️ ROUTING CONTEXT (This case was escalated to you because):');
      if (riskScore != null) {
        final riskLevel = riskScore >= 0.8 ? 'CRITICAL' : 
                         riskScore >= 0.6 ? 'HIGH' : 
                         riskScore >= 0.4 ? 'MODERATE' : 'LOW';
        contextBuffer.writeln('- Risk Score: ${(riskScore * 100).toInt()}% ($riskLevel)');
      }
      if (complexityScore != null) {
        final complexityLevel = complexityScore >= 0.7 ? 'VERY COMPLEX' : 
                               complexityScore >= 0.5 ? 'COMPLEX' : 
                               complexityScore >= 0.3 ? 'MODERATE' : 'SIMPLE';
        contextBuffer.writeln('- Complexity Score: ${(complexityScore * 100).toInt()}% ($complexityLevel)');
      }
      if (escalationReason != null) {
        contextBuffer.writeln('- Escalation Reason: $escalationReason');
      }
      contextBuffer.writeln();
      contextBuffer.writeln('Given the elevated risk/complexity, provide EXTRA THOROUGH analysis:');
      contextBuffer.writeln('- Consider ALL possible serious conditions');
      contextBuffer.writeln('- Err strongly on the side of caution');
      contextBuffer.writeln('- Provide detailed reasoning for your assessment');
      contextBuffer.writeln('- Flag ANY concerning patterns');
    }
    
    contextBuffer.writeln();
    contextBuffer.writeln('''URGENCY LEVELS (use exactly these values):
- "critical": Life-threatening emergency, immediate care needed (e.g., stroke, heart attack, severe trauma)
- "urgent": Serious condition, needs care within 2-4 hours (e.g., high fever, severe pain)
- "standard": Non-emergency, care within 24-48 hours (e.g., persistent symptoms, infections)
- "non-urgent": Minor issue, self-care appropriate (e.g., mild cold, minor cuts)

IMPORTANT CONSIDERATIONS FOR AFRICA:
- Endemic diseases: malaria, typhoid, cholera, TB, yellow fever, dengue
- Resource limitations: Consider what tests/treatments are available
- Climate factors: Heat-related illness, waterborne diseases
- Seasonal patterns: Rainy season increases mosquito-borne diseases

RULES:
1. NEVER provide a diagnosis - only triage level and recommended action
2. Always err on the side of caution for ambiguous symptoms
3. Flag red flag symptoms that require immediate attention
4. Consider patient age, gender, and medical history in assessment
5. Provide confidence score based on symptom clarity

Respond ONLY in valid JSON format:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence": 0.0-1.0,
  "assessment": "brief clinical assessment",
  "recommended_action": "specific recommended action",
  "conditions": [
    {"name": "possible condition", "probability": 0.0-1.0}
  ],
  "red_flags": ["list of warning signs if any"],
  "follow_up_hours": 24,
  "referral_type": "emergency|hospital|clinic|pharmacy|self-care",
  "reasoning": "explanation of key factors in this assessment"
}''');

    final systemPrompt = contextBuffer.toString();

    final buffer = StringBuffer();
    buffer.writeln('PATIENT INFORMATION:');
    if (patientAge != null) buffer.writeln('- Age: $patientAge years');
    if (patientGender != null) buffer.writeln('- Gender: $patientGender');
    if (medicalHistory != null && medicalHistory.isNotEmpty) {
      buffer.writeln('- Medical History: ${medicalHistory.join(", ")}');
    }
    
    if (vitalSigns != null && vitalSigns.isNotEmpty) {
      buffer.writeln('\nVITAL SIGNS:');
      vitalSigns.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
    }
    
    buffer.writeln('\nCURRENT SYMPTOMS:');
    buffer.writeln(symptoms);
    buffer.writeln('\nProvide triage assessment in JSON format.');

    return [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': buffer.toString()},
    ];
  }

  /// General chat completion (non-triage)
  Future<OpenRouterResult> chat({
    required String message,
    OpenRouterModel model = OpenRouterModel.gpt4oMini,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (!_isConfigured || _apiKey == null) {
      return OpenRouterResult.failure('OpenRouter not configured');
    }

    final stopwatch = Stopwatch()..start();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://clinixai.health',
          'X-Title': 'ClinixAI',
        },
        body: jsonEncode({
          'model': model.modelId,
          'messages': [
            {'role': 'user', 'content': message},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        return OpenRouterResult(
          response: content,
          success: true,
          modelUsed: model.modelId,
          latency: stopwatch.elapsed,
        );
      } else {
        return OpenRouterResult.failure(
          'API error: ${response.statusCode}',
          modelUsed: model.modelId,
        );
      }
    } catch (e) {
      stopwatch.stop();
      return OpenRouterResult.failure(
        'Request failed: $e',
        modelUsed: model.modelId,
      );
    }
  }

  /// Check API health and available credits
  Future<Map<String, dynamic>> checkHealth() async {
    if (!_isConfigured || _apiKey == null) {
      return {'status': 'not_configured', 'error': 'API key not set'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/key'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'healthy',
          'credits': data['data']?['limit'],
          'usage': data['data']?['usage'],
        };
      } else {
        return {
          'status': 'error',
          'error': 'API returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Test connection to OpenRouter API
  Future<bool> testConnection() async {
    if (!_isConfigured || _apiKey == null) {
      return false;
    }

    try {
      final health = await checkHealth();
      return health['status'] == 'healthy';
    } catch (e) {
      debugPrint('[OpenRouter] Connection test failed: $e');
      return false;
    }
  }
}

// ClinixAI Backend AI Service - Web-Compatible API Client
// Connects to the llama.cpp backend via FastAPI triage service

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configuration for backend AI service
class BackendAIConfig {
  /// Base URL for the triage service API
  final String baseUrl;
  
  /// Timeout for API requests
  final Duration timeout;
  
  /// Whether to use RAG by default
  final bool useRag;

  const BackendAIConfig({
    this.baseUrl = 'http://localhost:8000',
    this.timeout = const Duration(seconds: 120),
    this.useRag = true,
  });
}

/// Result from backend AI inference
class BackendAIResult {
  final String response;
  final bool success;
  final String? error;
  final String model;
  final String backend;
  final int responseTimeMs;
  final bool ragContextUsed;
  final int sourcesCount;

  const BackendAIResult({
    required this.response,
    required this.success,
    this.error,
    this.model = 'unknown',
    this.backend = 'unknown',
    this.responseTimeMs = 0,
    this.ragContextUsed = false,
    this.sourcesCount = 0,
  });

  factory BackendAIResult.fromJson(Map<String, dynamic> json) {
    return BackendAIResult(
      response: json['response'] ?? '',
      success: json['success'] ?? false,
      error: json['error'],
      model: json['model'] ?? 'unknown',
      backend: json['backend'] ?? 'unknown',
      responseTimeMs: json['response_time_ms'] ?? 0,
      ragContextUsed: json['rag_context_used'] ?? false,
      sourcesCount: json['sources_count'] ?? 0,
    );
  }

  factory BackendAIResult.error(String message) {
    return BackendAIResult(
      response: '',
      success: false,
      error: message,
    );
  }
}

/// Triage result from the analyze endpoint
class TriageAnalysisResult {
  final String sessionId;
  final String urgencyLevel;
  final double riskScore;
  final String recommendation;
  final List<String> possibleConditions;
  final List<String> immediateActions;
  final bool seekEmergencyCare;
  final String reasoning;
  final String modelUsed;
  final String ragContext;
  final bool success;
  final String? error;

  const TriageAnalysisResult({
    required this.sessionId,
    required this.urgencyLevel,
    required this.riskScore,
    required this.recommendation,
    required this.possibleConditions,
    required this.immediateActions,
    required this.seekEmergencyCare,
    required this.reasoning,
    this.modelUsed = 'unknown',
    this.ragContext = '',
    this.success = true,
    this.error,
  });

  factory TriageAnalysisResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;
    return TriageAnalysisResult(
      sessionId: json['session_id'] ?? '',
      urgencyLevel: result['urgency_level'] ?? 'non-urgent',
      riskScore: (result['risk_score'] ?? 0.0).toDouble(),
      recommendation: result['recommendation'] ?? '',
      possibleConditions: List<String>.from(result['possible_conditions'] ?? []),
      immediateActions: List<String>.from(result['immediate_actions'] ?? []),
      seekEmergencyCare: result['seek_emergency_care'] ?? false,
      reasoning: result['reasoning'] ?? '',
      modelUsed: json['model_used'] ?? 'unknown',
      ragContext: json['rag_context'] ?? '',
      success: true,
    );
  }

  factory TriageAnalysisResult.error(String message) {
    return TriageAnalysisResult(
      sessionId: '',
      urgencyLevel: 'unknown',
      riskScore: 0.0,
      recommendation: 'Unable to analyze symptoms. Please try again.',
      possibleConditions: [],
      immediateActions: [],
      seekEmergencyCare: false,
      reasoning: '',
      success: false,
      error: message,
    );
  }
}

/// Backend health status
class BackendHealthStatus {
  final bool isHealthy;
  final String status;
  final String? llamaCppStatus;
  final String? version;
  final DateTime? timestamp;

  const BackendHealthStatus({
    required this.isHealthy,
    required this.status,
    this.llamaCppStatus,
    this.version,
    this.timestamp,
  });

  factory BackendHealthStatus.fromJson(Map<String, dynamic> json) {
    return BackendHealthStatus(
      isHealthy: json['status'] == 'healthy',
      status: json['status'] ?? 'unknown',
      llamaCppStatus: json['llama_cpp'],
      version: json['version'],
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp']) 
          : null,
    );
  }

  factory BackendHealthStatus.error(String message) {
    return BackendHealthStatus(
      isHealthy: false,
      status: message,
    );
  }
}

/// Backend AI Service - Connects to llama.cpp via FastAPI
/// 
/// This service provides web-compatible AI inference by calling
/// the backend triage service which uses llama.cpp for local LLM
/// and OpenRouter for cloud escalation.
class BackendAIService {
  // Singleton pattern
  static BackendAIService? _instance;
  static BackendAIService get instance => _instance ??= BackendAIService._();
  
  BackendAIService._();

  late Dio _dio;
  BackendAIConfig _config = const BackendAIConfig();
  bool _isInitialized = false;
  bool _isBackendHealthy = false;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Whether the backend is healthy and responding
  bool get isBackendHealthy => _isBackendHealthy;

  /// Current configuration
  BackendAIConfig get config => _config;

  /// Initialize the service with optional configuration
  Future<void> initialize({BackendAIConfig? config}) async {
    if (_isInitialized) return;

    _config = config ?? const BackendAIConfig();
    
    _dio = Dio(BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.timeout,
      receiveTimeout: _config.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[BackendAI] $obj'),
      ));
    }

    _isInitialized = true;
    
    // Check backend health
    await checkHealth();
    
    debugPrint('✅ BackendAIService initialized');
    debugPrint('   - Base URL: ${_config.baseUrl}');
    debugPrint('   - Backend healthy: $_isBackendHealthy');
  }

  /// Check backend health status
  Future<BackendHealthStatus> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      final status = BackendHealthStatus.fromJson(response.data);
      _isBackendHealthy = status.isHealthy;
      return status;
    } catch (e) {
      _isBackendHealthy = false;
      debugPrint('⚠️ Backend health check failed: $e');
      return BackendHealthStatus.error('Failed to connect: $e');
    }
  }

  /// Send a chat message to the backend
  /// 
  /// Uses the /chat endpoint which connects to llama.cpp
  /// with optional RAG context from Neo4j
  Future<BackendAIResult> chat({
    required String message,
    bool useRag = true,
    bool forceCloud = false,
    double temperature = 0.3,
    int maxTokens = 512,
  }) async {
    if (!_isInitialized) {
      return BackendAIResult.error('Service not initialized');
    }

    try {
      final response = await _dio.post('/chat', data: {
        'message': message,
        'use_rag': useRag,
        'force_cloud': forceCloud,
        'temperature': temperature,
        'max_tokens': maxTokens,
      });

      return BackendAIResult.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      return BackendAIResult.error(errorMsg);
    } catch (e) {
      return BackendAIResult.error('Unexpected error: $e');
    }
  }

  /// Analyze symptoms for triage
  /// 
  /// Uses the /analyze endpoint for full triage analysis
  Future<TriageAnalysisResult> analyzeSymptomsForTriage({
    required List<Map<String, dynamic>> symptoms,
    String? userId,
    String? sessionId,
    bool enableRag = true,
  }) async {
    if (!_isInitialized) {
      return TriageAnalysisResult.error('Service not initialized');
    }

    try {
      final response = await _dio.post('/analyze', data: {
        'symptoms': symptoms,
        'user_id': userId ?? 'web-user',
        'session_id': sessionId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'enable_rag': enableRag,
      });

      return TriageAnalysisResult.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      return TriageAnalysisResult.error(errorMsg);
    } catch (e) {
      return TriageAnalysisResult.error('Unexpected error: $e');
    }
  }

  /// Simple medical question/answer
  /// 
  /// Convenience method for quick medical questions
  Future<String> askMedicalQuestion(String question) async {
    final result = await chat(message: question, useRag: true);
    if (result.success) {
      return result.response;
    } else {
      return 'Unable to get answer: ${result.error}';
    }
  }

  /// Handle Dio errors with user-friendly messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your network.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The AI is taking too long.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to backend. Make sure the server is running.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['detail'] ?? e.message;
        return 'Server error ($statusCode): $message';
      default:
        return 'Network error: ${e.message}';
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
    _isInitialized = false;
    _isBackendHealthy = false;
  }
}

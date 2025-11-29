import 'dart:async';

import 'package:dio/dio.dart';

/// Configuration for AI services
class AIServiceConfig {
  /// Cloud triage service URL
  final String cloudServiceUrl;
  
  /// Timeout for cloud requests
  final Duration cloudTimeout;
  
  /// Whether to prefer local inference
  final bool preferLocalInference;
  
  /// Minimum confidence threshold for local inference
  final double localConfidenceThreshold;
  
  /// API key for cloud service (if required)
  final String? apiKey;

  const AIServiceConfig({
    this.cloudServiceUrl = 'http://localhost:8000',
    this.cloudTimeout = const Duration(seconds: 30),
    this.preferLocalInference = true,
    this.localConfidenceThreshold = 0.7,
    this.apiKey,
  });
  
  /// Production configuration
  factory AIServiceConfig.production() {
    return const AIServiceConfig(
      cloudServiceUrl: 'https://api.clinixai.com/triage',
      cloudTimeout: Duration(seconds: 45),
      preferLocalInference: true,
      localConfidenceThreshold: 0.75,
    );
  }
  
  /// Development configuration
  factory AIServiceConfig.development() {
    return const AIServiceConfig(
      cloudServiceUrl: 'http://localhost:8000',
      cloudTimeout: Duration(seconds: 30),
      preferLocalInference: false,
      localConfidenceThreshold: 0.6,
    );
  }
}

/// Symptom input for triage
class SymptomInput {
  final String description;
  final int? severity;
  final int? durationHours;
  final String? bodyLocation;

  const SymptomInput({
    required this.description,
    this.severity,
    this.durationHours,
    this.bodyLocation,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    if (severity != null) 'severity': severity,
    if (durationHours != null) 'duration_hours': durationHours,
    if (bodyLocation != null) 'body_location': bodyLocation,
  };
}

/// Vital signs input
class VitalSignsInput {
  final double? temperature;
  final int? heartRate;
  final String? bloodPressure;
  final int? oxygenSaturation;
  final int? respiratoryRate;

  const VitalSignsInput({
    this.temperature,
    this.heartRate,
    this.bloodPressure,
    this.oxygenSaturation,
    this.respiratoryRate,
  });

  Map<String, dynamic> toJson() => {
    if (temperature != null) 'temperature': temperature,
    if (heartRate != null) 'heart_rate': heartRate,
    if (bloodPressure != null) 'blood_pressure': bloodPressure,
    if (oxygenSaturation != null) 'oxygen_saturation': oxygenSaturation,
    if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
  };
  
  bool get isEmpty => 
    temperature == null && 
    heartRate == null && 
    bloodPressure == null && 
    oxygenSaturation == null &&
    respiratoryRate == null;
}

/// Differential diagnosis result
class DifferentialDiagnosis {
  final String condition;
  final double probability;
  final String? icdCode;
  final String? reasoning;

  const DifferentialDiagnosis({
    required this.condition,
    required this.probability,
    this.icdCode,
    this.reasoning,
  });

  factory DifferentialDiagnosis.fromJson(Map<String, dynamic> json) {
    return DifferentialDiagnosis(
      condition: json['condition'] as String? ?? 'Unknown',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.5,
      icdCode: json['icd_code'] as String?,
      reasoning: json['reasoning'] as String?,
    );
  }
}

/// Urgency level enum
enum UrgencyLevel {
  critical,
  urgent,
  standard,
  nonUrgent;
  
  static UrgencyLevel fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '').replaceAll('_', '')) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'urgent':
        return UrgencyLevel.urgent;
      case 'standard':
        return UrgencyLevel.standard;
      case 'nonurgent':
        return UrgencyLevel.nonUrgent;
      default:
        return UrgencyLevel.standard;
    }
  }
  
  String get displayName {
    switch (this) {
      case UrgencyLevel.critical:
        return 'Critical';
      case UrgencyLevel.urgent:
        return 'Urgent';
      case UrgencyLevel.standard:
        return 'Standard';
      case UrgencyLevel.nonUrgent:
        return 'Non-Urgent';
    }
  }
  
  /// Color for UI display
  int get colorValue {
    switch (this) {
      case UrgencyLevel.critical:
        return 0xFFD32F2F; // Red
      case UrgencyLevel.urgent:
        return 0xFFF57C00; // Orange
      case UrgencyLevel.standard:
        return 0xFFFBC02D; // Yellow
      case UrgencyLevel.nonUrgent:
        return 0xFF388E3C; // Green
    }
  }
}

/// Complete triage result
class TriageResult {
  final String sessionId;
  final UrgencyLevel urgencyLevel;
  final double confidenceScore;
  final String primaryAssessment;
  final String recommendedAction;
  final List<DifferentialDiagnosis> differentialDiagnoses;
  final List<String> redFlags;
  final List<String> followUpQuestions;
  final bool escalatedToCloud;
  final String providerUsed;
  final int inferenceTimeMs;
  final String disclaimer;
  final DateTime timestamp;

  const TriageResult({
    required this.sessionId,
    required this.urgencyLevel,
    required this.confidenceScore,
    required this.primaryAssessment,
    required this.recommendedAction,
    required this.differentialDiagnoses,
    required this.redFlags,
    required this.followUpQuestions,
    required this.escalatedToCloud,
    required this.providerUsed,
    required this.inferenceTimeMs,
    required this.disclaimer,
    required this.timestamp,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      sessionId: json['session_id'] as String? ?? '',
      urgencyLevel: UrgencyLevel.fromString(json['urgency_level'] as String? ?? 'standard'),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.5,
      primaryAssessment: json['primary_assessment'] as String? ?? 'Assessment unavailable',
      recommendedAction: json['recommended_action'] as String? ?? 'Consult healthcare provider',
      differentialDiagnoses: (json['differential_diagnoses'] as List<dynamic>?)
          ?.map((d) => DifferentialDiagnosis.fromJson(d as Map<String, dynamic>))
          .toList() ?? [],
      redFlags: (json['red_flags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      escalatedToCloud: json['escalated_to_cloud'] as bool? ?? false,
      providerUsed: json['provider_used'] as String? ?? 'unknown',
      inferenceTimeMs: json['inference_time_ms'] as int? ?? 0,
      disclaimer: json['disclaimer'] as String? ?? 
        'This is an AI-assisted assessment. Always consult a healthcare professional.',
      timestamp: json['timestamp'] != null 
        ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
        : DateTime.now(),
    );
  }
  
  /// Check if this is a high priority case
  bool get isHighPriority => 
    urgencyLevel == UrgencyLevel.critical || 
    urgencyLevel == UrgencyLevel.urgent;
    
  /// Get formatted inference time
  String get formattedInferenceTime {
    if (inferenceTimeMs < 1000) {
      return '${inferenceTimeMs}ms';
    }
    return '${(inferenceTimeMs / 1000).toStringAsFixed(1)}s';
  }
}

/// AI Service exception
class AIServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AIServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AIServiceException: $message';
}

/// Main AI Service for ClinixAI
/// 
/// This service orchestrates AI inference for medical triage.
/// It supports both local (Cactus SDK) and cloud (LangGraph) inference.
class ClinixAIService {
  static ClinixAIService? _instance;
  static ClinixAIService get instance => _instance ??= ClinixAIService._();
  
  ClinixAIService._();
  
  late Dio _dio;
  late AIServiceConfig _config;
  bool _isInitialized = false;
  
  /// Whether the service is ready
  bool get isReady => _isInitialized;
  
  /// Initialize the AI service
  Future<void> initialize({AIServiceConfig? config}) async {
    if (_isInitialized) return;
    
    _config = config ?? AIServiceConfig.development();
    
    _dio = Dio(BaseOptions(
      baseUrl: _config.cloudServiceUrl,
      connectTimeout: _config.cloudTimeout,
      receiveTimeout: _config.cloudTimeout,
      headers: {
        'Content-Type': 'application/json',
        if (_config.apiKey != null) 'Authorization': 'Bearer ${_config.apiKey}',
      },
    ));
    
    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    _isInitialized = true;
  }
  
  /// Check cloud service health
  Future<bool> checkCloudHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Perform triage analysis
  /// 
  /// This method orchestrates the triage analysis:
  /// 1. If preferLocalInference is true, tries local inference first
  /// 2. Falls back to cloud if local confidence is below threshold
  /// 3. Returns the result with provider information
  Future<TriageResult> analyzeTriage({
    required String sessionId,
    required List<SymptomInput> symptoms,
    VitalSignsInput? vitalSigns,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Build request payload
    final payload = {
      'session_id': sessionId,
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      if (vitalSigns != null && !vitalSigns.isEmpty) 
        'vital_signs': vitalSigns.toJson(),
      if (patientAge != null) 'patient_age': patientAge,
      if (patientGender != null) 'patient_gender': patientGender,
      if (medicalHistory != null && medicalHistory.isNotEmpty) 
        'medical_history': medicalHistory,
    };
    
    try {
      // Call cloud LangGraph service
      final response = await _dio.post('/analyze', data: payload);
      
      if (response.statusCode == 200) {
        return TriageResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw AIServiceException(
          'Triage analysis failed with status ${response.statusCode}',
          code: 'HTTP_ERROR',
        );
      }
    } on DioException catch (e) {
      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        // Try local fallback
        return _localFallbackAnalysis(
          sessionId: sessionId,
          symptoms: symptoms,
          vitalSigns: vitalSigns,
          patientAge: patientAge,
        );
      }
      
      throw AIServiceException(
        'Network error: ${e.message}',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } catch (e) {
      throw AIServiceException(
        'Triage analysis failed: $e',
        originalError: e,
      );
    }
  }
  
  /// Local fallback analysis when cloud is unavailable
  Future<TriageResult> _localFallbackAnalysis({
    required String sessionId,
    required List<SymptomInput> symptoms,
    VitalSignsInput? vitalSigns,
    int? patientAge,
  }) async {
    // Simple rule-based analysis
    final symptomText = symptoms.map((s) => s.description.toLowerCase()).join(' ');
    final maxSeverity = symptoms
        .map((s) => s.severity ?? 5)
        .reduce((a, b) => a > b ? a : b);
    
    UrgencyLevel urgency = UrgencyLevel.standard;
    String assessment = 'General symptoms requiring evaluation';
    String action = 'Schedule medical appointment within 24-48 hours';
    
    // Critical keywords
    final criticalKeywords = [
      'chest pain', 'difficulty breathing', 'unconscious',
      'severe bleeding', 'seizure', 'stroke'
    ];
    
    final urgentKeywords = [
      'high fever', 'severe pain', 'vomiting blood',
      'head injury', 'broken bone', 'fracture'
    ];
    
    for (final keyword in criticalKeywords) {
      if (symptomText.contains(keyword)) {
        urgency = UrgencyLevel.critical;
        assessment = 'Critical symptom detected: $keyword';
        action = 'Seek emergency care immediately';
        break;
      }
    }
    
    if (urgency != UrgencyLevel.critical) {
      for (final keyword in urgentKeywords) {
        if (symptomText.contains(keyword)) {
          urgency = UrgencyLevel.urgent;
          assessment = 'Urgent symptom detected: $keyword';
          action = 'Visit healthcare facility within 2-4 hours';
          break;
        }
      }
    }
    
    // Adjust for severity
    if (maxSeverity >= 8 && urgency == UrgencyLevel.standard) {
      urgency = UrgencyLevel.urgent;
    }
    
    return TriageResult(
      sessionId: sessionId,
      urgencyLevel: urgency,
      confidenceScore: 0.6, // Lower confidence for local
      primaryAssessment: assessment,
      recommendedAction: action,
      differentialDiagnoses: [
        const DifferentialDiagnosis(
          condition: 'Requires clinical evaluation',
          probability: 0.8,
        ),
      ],
      redFlags: [],
      followUpQuestions: [
        'How long have you had these symptoms?',
        'Have the symptoms gotten worse?',
      ],
      escalatedToCloud: false,
      providerUsed: 'local_fallback',
      inferenceTimeMs: 50,
      disclaimer: 'This is a basic assessment. Cloud AI unavailable. Please consult a healthcare professional.',
      timestamp: DateTime.now(),
    );
  }
  
  /// Get provider status from cloud service
  Future<Map<String, dynamic>> getProvidersStatus() async {
    try {
      final response = await _dio.get('/providers');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {
        'status': 'unavailable',
        'error': e.toString(),
      };
    }
  }
  
  /// Get the LangGraph visualization
  Future<String?> getGraphVisualization() async {
    try {
      final response = await _dio.get('/graph');
      return response.data['mermaid_diagram'] as String?;
    } catch (e) {
      return null;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _dio.close();
    _isInitialized = false;
  }
}

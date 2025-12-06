import 'dart:convert';
import 'package:isar/isar.dart';

part 'local_triage_result.g.dart';

/// Urgency levels for triage
enum UrgencyLevel {
  critical,   // Life-threatening - immediate care needed
  urgent,     // Serious - care needed within hours
  standard,   // Moderate - care needed within 24-48 hours
  nonUrgent,  // Minor - can wait for scheduled appointment
}

/// Local Triage Result
/// 
/// Stores the AI-generated triage assessment.
/// Linked to a LocalTriageSession by sessionId.

@collection
class LocalTriageResult {
  LocalTriageResult();
  
  Id id = Isar.autoIncrement;

  /// Reference to the parent triage session
  @Index(unique: true)
  late int sessionId;

  /// Urgency classification
  @Enumerated(EnumType.name)
  late UrgencyLevel urgencyLevel;

  /// AI confidence score (0.0 - 1.0)
  late double confidenceScore;

  /// Version of AI model used
  String? aiModelVersion;

  /// Primary assessment text
  late String primaryAssessment;

  /// Recommended action for patient
  late String recommendedAction;

  /// JSON string of differential diagnoses
  /// Format: [{"condition": "Malaria", "probability": 0.65, "icdCode": "B50.9"}]
  String? differentialDiagnosesJson;

  /// Should patient follow up?
  bool followUpRequired = false;

  /// Was this escalated to cloud AI?
  bool escalatedToCloud = false;

  /// Glyph signal to display (for Nothing Phone)
  String? glyphSignal; // 'critical_flash', 'urgent_pulse', 'standard_glow'

  /// JSON string of source attributions from knowledge base
  /// Format: ["WHO Emergency Triage Guidelines", "Common Symptoms Guide"]
  String? sourceAttributionsJson;

  /// Disclaimer text
  String disclaimer = 'This is an AI-assisted assessment. Always consult a healthcare professional for medical advice.';

  /// When was this result generated
  DateTime createdAt = DateTime.now();

  /// Parse source attributions from JSON
  @ignore
  List<String> get sourceAttributions {
    if (sourceAttributionsJson == null) return [];
    try {
      final list = jsonDecode(sourceAttributionsJson!) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Set source attributions as JSON
  set sourceAttributions(List<String> attributions) {
    sourceAttributionsJson = jsonEncode(attributions);
  }

  /// Parse differential diagnoses from JSON
  @ignore
  List<DifferentialDiagnosis> get differentialDiagnoses {
    if (differentialDiagnosesJson == null) return [];
    try {
      final list = jsonDecode(differentialDiagnosesJson!) as List;
      return list.map((e) => DifferentialDiagnosis.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Set differential diagnoses as JSON
  set differentialDiagnoses(List<DifferentialDiagnosis> diagnoses) {
    differentialDiagnosesJson = jsonEncode(diagnoses.map((d) => d.toJson()).toList());
  }

  /// Get urgency color (for UI)
  @ignore
  String get urgencyColor {
    switch (urgencyLevel) {
      case UrgencyLevel.critical:
        return '#FF0000'; // Red
      case UrgencyLevel.urgent:
        return '#FFA500'; // Orange/Amber
      case UrgencyLevel.standard:
        return '#FFFF00'; // Yellow
      case UrgencyLevel.nonUrgent:
        return '#00FF00'; // Green
    }
  }

  /// Get urgency display text
  String get urgencyDisplayText {
    switch (urgencyLevel) {
      case UrgencyLevel.critical:
        return 'CRITICAL - Seek Emergency Care Immediately';
      case UrgencyLevel.urgent:
        return 'URGENT - Visit Healthcare Facility Soon';
      case UrgencyLevel.standard:
        return 'STANDARD - Schedule an Appointment';
      case UrgencyLevel.nonUrgent:
        return 'NON-URGENT - Monitor & Self-Care';
    }
  }

  /// Get Glyph signal based on urgency
  String getGlyphSignal() {
    switch (urgencyLevel) {
      case UrgencyLevel.critical:
        return 'critical_flash';
      case UrgencyLevel.urgent:
        return 'urgent_pulse';
      case UrgencyLevel.standard:
        return 'standard_glow';
      case UrgencyLevel.nonUrgent:
        return 'none';
    }
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'urgencyLevel': urgencyLevel.name,
      'confidenceScore': confidenceScore,
      'aiModelVersion': aiModelVersion,
      'primaryAssessment': primaryAssessment,
      'recommendedAction': recommendedAction,
      'differentialDiagnoses': differentialDiagnoses.map((d) => d.toJson()).toList(),
      'followUpRequired': followUpRequired,
      'escalatedToCloud': escalatedToCloud,
      'glyphSignal': glyphSignal,
      'disclaimer': disclaimer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (typically from AI response)
  factory LocalTriageResult.fromJson(Map<String, dynamic> json, int sessionId) {
    final result = LocalTriageResult()
      ..sessionId = sessionId
      ..urgencyLevel = _parseUrgencyLevel(json['urgency_level'] ?? json['urgencyLevel'])
      ..confidenceScore = (json['confidence'] ?? json['confidenceScore'] ?? 0.5).toDouble()
      ..aiModelVersion = json['aiModelVersion'] ?? 'LFM2-1.2B-RAG'
      ..primaryAssessment = json['assessment'] ?? json['primaryAssessment'] ?? ''
      ..recommendedAction = json['recommended_action'] ?? json['recommendedAction'] ?? ''
      ..followUpRequired = json['followUpRequired'] ?? false
      ..escalatedToCloud = json['escalatedToCloud'] ?? false
      ..createdAt = DateTime.now();

    // Parse differential diagnoses
    if (json['possible_conditions'] != null) {
      final conditions = json['possible_conditions'] as List;
      result.differentialDiagnoses = conditions
          .map((c) => DifferentialDiagnosis(condition: c.toString()))
          .toList();
    } else if (json['differentialDiagnoses'] != null) {
      final diagnoses = json['differentialDiagnoses'] as List;
      result.differentialDiagnoses = diagnoses
          .map((d) => DifferentialDiagnosis.fromJson(d))
          .toList();
    }

    // Set Glyph signal
    result.glyphSignal = result.getGlyphSignal();

    return result;
  }

  /// Parse urgency level from string
  static UrgencyLevel _parseUrgencyLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'critical':
        return UrgencyLevel.critical;
      case 'urgent':
        return UrgencyLevel.urgent;
      case 'standard':
        return UrgencyLevel.standard;
      case 'non-urgent':
      case 'nonurgent':
      case 'non_urgent':
        return UrgencyLevel.nonUrgent;
      default:
        return UrgencyLevel.standard;
    }
  }
}

/// Differential diagnosis with probability
class DifferentialDiagnosis {
  final String condition;
  final double? probability;
  final String? icdCode;

  DifferentialDiagnosis({
    required this.condition,
    this.probability,
    this.icdCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'probability': probability,
      'icdCode': icdCode,
    };
  }

  factory DifferentialDiagnosis.fromJson(Map<String, dynamic> json) {
    return DifferentialDiagnosis(
      condition: json['condition'] ?? '',
      probability: json['probability']?.toDouble(),
      icdCode: json['icdCode'],
    );
  }
}

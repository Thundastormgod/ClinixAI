// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Demo Mode Collections
// Simple data classes for web/desktop demo mode without Isar dependencies

import 'dart:convert';

/// Urgency levels for triage
enum UrgencyLevel {
  critical,   // Life-threatening - immediate care needed
  urgent,     // Serious - care needed within hours
  standard,   // Moderate - care needed within 24-48 hours
  nonUrgent,  // Minor - can wait for scheduled appointment
}

/// Patient profile for demo mode
class DemoPatientProfile {
  int id = 0;
  String? fullName;
  int? age;
  String? gender;
  DateTime? dateOfBirth;
  String? bloodType;
  List<String> allergies = [];
  List<String> chronicConditions = [];
  List<String> currentMedications = [];
  DateTime lastUpdated = DateTime.now();
  DateTime createdAt = DateTime.now();
}

/// Triage session for demo mode
class DemoTriageSession {
  int id = 0;
  String sessionUuid = '';
  DateTime sessionStart = DateTime.now();
  DateTime? sessionEnd;
  String inputMethod = 'text';
  String? deviceId;
  bool isComplete = false;
  bool isSynced = false;
  DateTime? syncedAt;
  
  static DemoTriageSession create({String? deviceId}) {
    return DemoTriageSession()
      ..sessionUuid = DateTime.now().millisecondsSinceEpoch.toString()
      ..deviceId = deviceId;
  }
}

/// Symptom entry for demo mode
class DemoSymptom {
  int id = 0;
  int sessionId = 0;
  String description = '';
  int? severity;
  String? duration;
  String? location;
  DateTime recordedAt = DateTime.now();
}

/// Triage result for demo mode
class DemoTriageResult {
  int id = 0;
  int sessionId = 0;
  UrgencyLevel urgencyLevel = UrgencyLevel.standard;
  double confidenceScore = 0.0;
  String? aiModelVersion;
  String primaryAssessment = '';
  String recommendedAction = '';
  String? differentialDiagnosesJson;
  bool followUpRequired = false;
  bool escalatedToCloud = false;
  String? glyphSignal;
  String? sourceAttributionsJson;
  String disclaimer = 'This is an AI-assisted assessment. Always consult a healthcare professional.';
  DateTime createdAt = DateTime.now();

  List<String> get sourceAttributions {
    if (sourceAttributionsJson == null) return [];
    try {
      final list = jsonDecode(sourceAttributionsJson!) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  set sourceAttributions(List<String> attributions) {
    sourceAttributionsJson = jsonEncode(attributions);
  }

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

  String get urgencyColor {
    switch (urgencyLevel) {
      case UrgencyLevel.critical:
        return '#FF0000';
      case UrgencyLevel.urgent:
        return '#FFA500';
      case UrgencyLevel.standard:
        return '#FFFF00';
      case UrgencyLevel.nonUrgent:
        return '#00FF00';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'urgencyLevel': urgencyLevel.name,
      'confidenceScore': confidenceScore,
      'aiModelVersion': aiModelVersion,
      'primaryAssessment': primaryAssessment,
      'recommendedAction': recommendedAction,
      'followUpRequired': followUpRequired,
      'escalatedToCloud': escalatedToCloud,
      'glyphSignal': glyphSignal,
      'disclaimer': disclaimer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DemoTriageResult.fromJson(Map<String, dynamic> json, int sessionId) {
    return DemoTriageResult()
      ..sessionId = sessionId
      ..urgencyLevel = _parseUrgencyLevel(json['urgency_level'] ?? json['urgencyLevel'])
      ..confidenceScore = (json['confidence'] ?? json['confidenceScore'] ?? 0.5).toDouble()
      ..aiModelVersion = json['aiModelVersion'] ?? 'Demo Mode'
      ..primaryAssessment = json['assessment'] ?? json['primaryAssessment'] ?? ''
      ..recommendedAction = json['recommended_action'] ?? json['recommendedAction'] ?? ''
      ..followUpRequired = json['followUpRequired'] ?? false
      ..escalatedToCloud = json['escalatedToCloud'] ?? false
      ..createdAt = DateTime.now();
  }

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

/// RAG Document for demo mode
class DemoRAGDocument {
  int id = 0;
  String documentId = '';
  String fileName = '';
  int fileSize = 0;
  int chunkCount = 0;
  DateTime addedAt = DateTime.now();
  bool isIndexed = false;
}

/// RAG Chunk for demo mode
class DemoRAGChunk {
  int id = 0;
  int documentId = 0;
  int chunkIndex = 0;
  String content = '';
  String? embeddingJson;
}

/// Differential diagnosis
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

// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Symptom Collection
// Stores individual symptoms reported during triage
// Linked to triage sessions via sessionId

import 'package:isar/isar.dart';

part 'local_symptom.g.dart';

/// Local Symptom Record
/// 
/// Stores individual symptoms reported during a triage session.
/// Linked to a LocalTriageSession by sessionId.

@collection
class LocalSymptom {
  LocalSymptom();
  
  Id id = Isar.autoIncrement;

  /// Reference to the parent triage session
  @Index()
  late int sessionId;

  /// Symptom code (ICD-10 or SNOMED CT) - populated after AI analysis
  String? symptomCode;

  /// Free-text description from user
  late String description;

  /// Severity (1-10 scale)
  int? severity;

  /// Duration in hours
  int? durationHours;

  /// Body location (head, chest, abdomen, etc.)
  String? bodyLocation;

  /// URL to symptom image (local file path or S3 URL after sync)
  String? imageUrl;

  /// When was this symptom first noticed by patient
  DateTime? onsetTime;

  /// Is this symptom getting worse, better, or staying same
  String? progression; // 'worsening', 'improving', 'stable'

  /// Additional notes
  String? notes;

  /// When was this symptom recorded in the app
  DateTime recordedAt = DateTime.now();

  /// Get severity description
  String get severityDescription {
    if (severity == null) return 'Not specified';
    if (severity! <= 3) return 'Mild';
    if (severity! <= 6) return 'Moderate';
    if (severity! <= 8) return 'Severe';
    return 'Critical';
  }

  /// Get duration description
  String get durationDescription {
    if (durationHours == null) return 'Not specified';
    if (durationHours! < 1) return 'Less than an hour';
    if (durationHours! < 24) return '$durationHours hours';
    if (durationHours! < 48) return '1 day';
    if (durationHours! < 168) return '${durationHours! ~/ 24} days';
    return '${durationHours! ~/ 168} weeks';
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'symptomCode': symptomCode,
      'description': description,
      'severity': severity,
      'durationHours': durationHours,
      'bodyLocation': bodyLocation,
      'imageUrl': imageUrl,
      'onsetTime': onsetTime?.toIso8601String(),
      'progression': progression,
      'notes': notes,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LocalSymptom.fromJson(Map<String, dynamic> json) {
    return LocalSymptom()
      ..sessionId = json['sessionId']
      ..symptomCode = json['symptomCode']
      ..description = json['description']
      ..severity = json['severity']
      ..durationHours = json['durationHours']
      ..bodyLocation = json['bodyLocation']
      ..imageUrl = json['imageUrl']
      ..onsetTime = json['onsetTime'] != null 
          ? DateTime.parse(json['onsetTime']) 
          : null
      ..progression = json['progression']
      ..notes = json['notes']
      ..recordedAt = json['recordedAt'] != null 
          ? DateTime.parse(json['recordedAt']) 
          : DateTime.now();
  }

  /// Create a new symptom for a session
  factory LocalSymptom.create({
    required int sessionId,
    required String description,
    int? severity,
    int? durationHours,
    String? bodyLocation,
    String? imageUrl,
  }) {
    return LocalSymptom()
      ..sessionId = sessionId
      ..description = description
      ..severity = severity
      ..durationHours = durationHours
      ..bodyLocation = bodyLocation
      ..imageUrl = imageUrl
      ..recordedAt = DateTime.now();
  }
}

// ClinixAI Web Database Stub - In-Memory Storage for Web Platform
// Replaces Isar database for web compatibility

import 'dart:async';
import 'package:flutter/foundation.dart';

// ============================================================
// DATA MODELS (Simplified for web)
// ============================================================

/// Patient profile for web storage
class WebPatientProfile {
  String id;
  String? name;
  int? age;
  String? gender;
  List<String> medicalConditions;
  List<String> allergies;
  List<String> medications;
  String? bloodType;
  String? emergencyContact;
  DateTime createdAt;
  DateTime lastUpdated;

  WebPatientProfile({
    String? id,
    this.name,
    this.age,
    this.gender,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? medications,
    this.bloodType,
    this.emergencyContact,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       medicalConditions = medicalConditions ?? [],
       allergies = allergies ?? [],
       medications = medications ?? [],
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'medical_conditions': medicalConditions,
    'allergies': allergies,
    'medications': medications,
    'blood_type': bloodType,
    'emergency_contact': emergencyContact,
    'created_at': createdAt.toIso8601String(),
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory WebPatientProfile.fromJson(Map<String, dynamic> json) => WebPatientProfile(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    gender: json['gender'],
    medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
    allergies: List<String>.from(json['allergies'] ?? []),
    medications: List<String>.from(json['medications'] ?? []),
    bloodType: json['blood_type'],
    emergencyContact: json['emergency_contact'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated']) : DateTime.now(),
  );
}

/// Triage session for web storage
class WebTriageSession {
  String id;
  String? userId;
  List<WebSymptom> symptoms;
  WebTriageResult? result;
  String status;
  DateTime createdAt;
  DateTime? completedAt;
  bool syncedToCloud;

  WebTriageSession({
    String? id,
    this.userId,
    List<WebSymptom>? symptoms,
    this.result,
    this.status = 'pending',
    DateTime? createdAt,
    this.completedAt,
    this.syncedToCloud = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       symptoms = symptoms ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'symptoms': symptoms.map((s) => s.toJson()).toList(),
    'result': result?.toJson(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'synced_to_cloud': syncedToCloud,
  };
}

/// Symptom for web storage
class WebSymptom {
  String id;
  String description;
  int severity;
  String? duration;
  String? location;
  DateTime reportedAt;

  WebSymptom({
    String? id,
    required this.description,
    this.severity = 5,
    this.duration,
    this.location,
    DateTime? reportedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       reportedAt = reportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'severity': severity,
    'duration': duration,
    'location': location,
    'reported_at': reportedAt.toIso8601String(),
  };

  factory WebSymptom.fromJson(Map<String, dynamic> json) => WebSymptom(
    id: json['id'],
    description: json['description'] ?? '',
    severity: json['severity'] ?? 5,
    duration: json['duration'],
    location: json['location'],
    reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : DateTime.now(),
  );
}

/// Triage result for web storage
class WebTriageResult {
  String urgencyLevel;
  double riskScore;
  String recommendation;
  List<String> possibleConditions;
  List<String> immediateActions;
  bool seekEmergencyCare;
  String reasoning;
  String modelUsed;

  WebTriageResult({
    required this.urgencyLevel,
    required this.riskScore,
    required this.recommendation,
    List<String>? possibleConditions,
    List<String>? immediateActions,
    this.seekEmergencyCare = false,
    this.reasoning = '',
    this.modelUsed = 'unknown',
  }) : possibleConditions = possibleConditions ?? [],
       immediateActions = immediateActions ?? [];

  Map<String, dynamic> toJson() => {
    'urgency_level': urgencyLevel,
    'risk_score': riskScore,
    'recommendation': recommendation,
    'possible_conditions': possibleConditions,
    'immediate_actions': immediateActions,
    'seek_emergency_care': seekEmergencyCare,
    'reasoning': reasoning,
    'model_used': modelUsed,
  };

  factory WebTriageResult.fromJson(Map<String, dynamic> json) => WebTriageResult(
    urgencyLevel: json['urgency_level'] ?? 'unknown',
    riskScore: (json['risk_score'] ?? 0.0).toDouble(),
    recommendation: json['recommendation'] ?? '',
    possibleConditions: List<String>.from(json['possible_conditions'] ?? []),
    immediateActions: List<String>.from(json['immediate_actions'] ?? []),
    seekEmergencyCare: json['seek_emergency_care'] ?? false,
    reasoning: json['reasoning'] ?? '',
    modelUsed: json['model_used'] ?? 'unknown',
  );
}

// ============================================================
// WEB DATABASE SERVICE
// ============================================================

/// Web-compatible in-memory database
/// 
/// This replaces Isar database for web platform.
/// Data is stored in memory and persisted to localStorage where possible.
class WebDatabase {
  // Singleton pattern
  static WebDatabase? _instance;
  static WebDatabase get instance => _instance ??= WebDatabase._();
  
  WebDatabase._();

  bool _isInitialized = false;
  
  // In-memory storage
  WebPatientProfile? _patientProfile;
  final List<WebTriageSession> _triageSessions = [];

  /// Check if database is ready
  bool get isReady => _isInitialized;

  /// Initialize the web database
  Future<void> initialize() async {
    if (_isInitialized) return;

    // For web, we use in-memory storage
    // TODO: Add localStorage persistence for web
    _isInitialized = true;
    debugPrint('✅ WebDatabase initialized (in-memory)');
  }

  // ==================== PATIENT PROFILE ====================

  /// Save or update the patient profile
  Future<void> savePatientProfile(WebPatientProfile profile) async {
    profile.lastUpdated = DateTime.now();
    _patientProfile = profile;
  }

  /// Get the current patient profile
  Future<WebPatientProfile?> getPatientProfile() async {
    return _patientProfile;
  }

  /// Delete the patient profile
  Future<bool> deletePatientProfile() async {
    if (_patientProfile == null) return false;
    _patientProfile = null;
    return true;
  }

  // ==================== TRIAGE SESSIONS ====================

  /// Create a new triage session
  Future<WebTriageSession> createTriageSession({String? userId}) async {
    final session = WebTriageSession(userId: userId);
    _triageSessions.add(session);
    return session;
  }

  /// Get a triage session by ID
  Future<WebTriageSession?> getTriageSession(String sessionId) async {
    try {
      return _triageSessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Get all triage sessions
  Future<List<WebTriageSession>> getAllTriageSessions() async {
    return List.from(_triageSessions);
  }

  /// Get recent triage sessions (last N)
  Future<List<WebTriageSession>> getRecentTriageSessions({int limit = 10}) async {
    final sorted = List.from(_triageSessions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  /// Update a triage session
  Future<void> updateTriageSession(WebTriageSession session) async {
    final index = _triageSessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _triageSessions[index] = session;
    }
  }

  /// Add symptom to a session
  Future<void> addSymptomToSession(String sessionId, WebSymptom symptom) async {
    final session = await getTriageSession(sessionId);
    if (session != null) {
      session.symptoms.add(symptom);
    }
  }

  /// Set result for a session
  Future<void> setTriageResult(String sessionId, WebTriageResult result) async {
    final session = await getTriageSession(sessionId);
    if (session != null) {
      session.result = result;
      session.status = 'completed';
      session.completedAt = DateTime.now();
    }
  }

  /// Delete a triage session
  Future<bool> deleteTriageSession(String sessionId) async {
    final lengthBefore = _triageSessions.length;
    _triageSessions.removeWhere((s) => s.id == sessionId);
    return _triageSessions.length < lengthBefore;
  }

  /// Clear all data
  Future<void> clearAll() async {
    _patientProfile = null;
    _triageSessions.clear();
  }

  /// Get session count
  int get sessionCount => _triageSessions.length;
}

/// Database exception for web
class WebDatabaseException implements Exception {
  final String message;
  WebDatabaseException(this.message);
  
  @override
  String toString() => 'WebDatabaseException: $message';
}

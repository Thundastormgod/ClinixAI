// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Mock Database Service - Web Demo Mode
// Provides in-memory storage for UI testing on web/desktop platforms
//
// This mock service simulates the Isar database behavior for platforms
// where native binaries aren't available (web, desktop).

import 'dart:async';
import 'package:flutter/foundation.dart';

// Import demo collection types (no Isar dependency)
import 'demo_collections.dart';

// Re-export demo collection types
export 'demo_collections.dart';

/// Mock LocalDatabase for web demo mode.
/// 
/// Provides in-memory storage for UI testing on platforms where
/// the native Isar database isn't available.
class MockLocalDatabase {
  // Singleton pattern
  static MockLocalDatabase? _instance;
  static MockLocalDatabase get instance => _instance ??= MockLocalDatabase._();
  
  MockLocalDatabase._();

  bool _isInitialized = false;

  // In-memory storage using demo types
  DemoPatientProfile? _patientProfile;
  final Map<int, DemoTriageSession> _sessions = {};
  final Map<int, List<DemoSymptom>> _symptoms = {};
  final Map<int, DemoTriageResult> _results = {};
  
  int _nextSessionId = 1;
  int _nextSymptomId = 1;
  int _nextResultId = 1;

  /// Check if database is ready
  bool get isReady => _isInitialized;

  /// Initialize the mock database
  Future<void> initialize({String? encryptionKey}) async {
    if (_isInitialized) return;
    
    await Future.delayed(const Duration(milliseconds: 50));
    _isInitialized = true;
    debugPrint('[MockLocalDatabase] In-memory database initialized (Demo Mode)');
  }

  // ===========================================================================
  // PATIENT PROFILE OPERATIONS
  // ===========================================================================

  /// Save or update the local patient profile.
  Future<int> savePatientProfile(DemoPatientProfile profile) async {
    _patientProfile = profile;
    _patientProfile!.lastUpdated = DateTime.now();
    return 1;
  }

  /// Get the current patient profile
  Future<DemoPatientProfile?> getPatientProfile() async {
    return _patientProfile;
  }

  /// Delete the patient profile
  Future<bool> deletePatientProfile() async {
    if (_patientProfile == null) return false;
    _patientProfile = null;
    return true;
  }

  // ===========================================================================
  // TRIAGE SESSION OPERATIONS
  // ===========================================================================

  /// Create a new triage session.
  Future<int> createTriageSession(DemoTriageSession session) async {
    final id = _nextSessionId++;
    _sessions[id] = session;
    return id;
  }

  /// Get a triage session by ID
  Future<DemoTriageSession?> getTriageSession(int id) async {
    return _sessions[id];
  }

  /// Get a triage session by UUID
  Future<DemoTriageSession?> getTriageSessionByUuid(String uuid) async {
    try {
      return _sessions.values.firstWhere((s) => s.sessionUuid == uuid);
    } catch (_) {
      return null;
    }
  }

  /// Get all triage sessions (most recent first)
  Future<List<DemoTriageSession>> getAllTriageSessions() async {
    final sessions = _sessions.values.toList();
    sessions.sort((a, b) => b.sessionStart.compareTo(a.sessionStart));
    return sessions;
  }

  /// Get unsynced triage sessions
  Future<List<DemoTriageSession>> getUnsyncedSessions() async {
    return _sessions.values.where((s) => !s.isSynced).toList();
  }

  /// Update a triage session
  Future<int> updateTriageSession(DemoTriageSession session) async {
    // Find by UUID and update
    final entry = _sessions.entries.firstWhere(
      (e) => e.value.sessionUuid == session.sessionUuid,
      orElse: () => MapEntry(_nextSessionId++, session),
    );
    _sessions[entry.key] = session;
    return entry.key;
  }

  /// Mark a session as synced
  Future<void> markSessionSynced(int sessionId) async {
    final session = _sessions[sessionId];
    if (session != null) {
      session.isSynced = true;
      session.syncedAt = DateTime.now();
    }
  }

  /// Delete a triage session and related data
  Future<bool> deleteTriageSession(int id) async {
    _symptoms.remove(id);
    _results.remove(id);
    return _sessions.remove(id) != null;
  }

  // ===========================================================================
  // SYMPTOM OPERATIONS
  // ===========================================================================

  /// Add symptoms to a session.
  Future<List<int>> addSymptoms(List<DemoSymptom> symptoms) async {
    final ids = <int>[];
    for (final symptom in symptoms) {
      final id = _nextSymptomId++;
      final sessionSymptoms = _symptoms.putIfAbsent(symptom.sessionId, () => []);
      sessionSymptoms.add(symptom);
      ids.add(id);
    }
    return ids;
  }

  /// Get symptoms for a session
  Future<List<DemoSymptom>> getSymptomsForSession(int sessionId) async {
    return _symptoms[sessionId] ?? [];
  }

  // ===========================================================================
  // TRIAGE RESULT OPERATIONS
  // ===========================================================================

  /// Save a triage result.
  Future<int> saveTriageResult(DemoTriageResult result) async {
    final id = _nextResultId++;
    _results[result.sessionId] = result;
    return id;
  }

  /// Get the result for a session
  Future<DemoTriageResult?> getResultForSession(int sessionId) async {
    return _results[sessionId];
  }

  // ===========================================================================
  // STATISTICS & ANALYTICS
  // ===========================================================================

  /// Get count of all triage sessions.
  Future<int> getTotalSessionCount() async {
    return _sessions.length;
  }

  /// Get count of unsynced sessions
  Future<int> getUnsyncedSessionCount() async {
    return _sessions.values.where((s) => !s.isSynced).length;
  }

  /// Get sessions by urgency level
  Future<List<DemoTriageSession>> getSessionsByUrgency(UrgencyLevel urgencyLevel) async {
    final sessionIds = _results.entries
        .where((e) => e.value.urgencyLevel == urgencyLevel)
        .map((e) => e.value.sessionId)
        .toSet();
    
    return _sessions.entries
        .where((e) => sessionIds.contains(e.key))
        .map((e) => e.value)
        .toList();
  }

  // ===========================================================================
  // LIFECYCLE & CLEANUP
  // ===========================================================================

  /// Clear all data.
  Future<void> clearAllData() async {
    _patientProfile = null;
    _sessions.clear();
    _symptoms.clear();
    _results.clear();
  }

  /// Close the database
  Future<void> close() async {
    _isInitialized = false;
    debugPrint('[MockLocalDatabase] Mock database closed');
  }
}

/// Exception thrown by mock database operations.
class MockDatabaseException implements Exception {
  final String message;
  MockDatabaseException(this.message);

  @override
  String toString() => 'MockDatabaseException: $message';
}

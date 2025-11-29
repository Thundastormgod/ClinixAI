import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Import all collections
import 'collections/local_patient_profile.dart';
import 'collections/local_triage_session.dart';
import 'collections/local_symptom.dart';
import 'collections/local_triage_result.dart';

export 'collections/local_patient_profile.dart';
export 'collections/local_triage_session.dart';
export 'collections/local_symptom.dart';
export 'collections/local_triage_result.dart';

/// ClinixAI Local Database Service
/// 
/// Manages all on-device data storage using Isar (NoSQL).
/// This is the foundation of the offline-first architecture.
/// 
/// Key Features:
/// - Fast binary storage optimized for mobile
/// - Full encryption support for PHI
/// - Works completely offline
/// - Sync queue for cloud upload when online

class LocalDatabase {
  // Singleton pattern
  static LocalDatabase? _instance;
  static LocalDatabase get instance => _instance ??= LocalDatabase._();
  
  LocalDatabase._();

  late Isar _isar;
  bool _isInitialized = false;

  /// Check if database is ready
  bool get isReady => _isInitialized;

  /// Get the Isar instance for direct queries
  Isar get isar {
    if (!_isInitialized) {
      throw DatabaseException('Database not initialized. Call initialize() first.');
    }
    return _isar;
  }

  /// Initialize the local database
  Future<void> initialize({String? encryptionKey}) async {
    if (_isInitialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      
      _isar = await Isar.open(
        [
          LocalPatientProfileSchema,
          LocalTriageSessionSchema,
          LocalSymptomSchema,
          LocalTriageResultSchema,
        ],
        directory: dir.path,
        name: 'clinixai_local',
        // TODO: Enable encryption in production
        // encryptionKey: encryptionKey,
      );

      _isInitialized = true;
    } catch (e) {
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  // ==================== PATIENT PROFILE ====================

  /// Save or update the local patient profile
  Future<int> savePatientProfile(LocalPatientProfile profile) async {
    return await _isar.writeTxn(() async {
      profile.lastUpdated = DateTime.now();
      return await _isar.localPatientProfiles.put(profile);
    });
  }

  /// Get the current patient profile (only one per device)
  Future<LocalPatientProfile?> getPatientProfile() async {
    return await _isar.localPatientProfiles.where().findFirst();
  }

  /// Delete the patient profile
  Future<bool> deletePatientProfile() async {
    final profile = await getPatientProfile();
    if (profile == null) return false;
    
    return await _isar.writeTxn(() async {
      return await _isar.localPatientProfiles.delete(profile.id);
    });
  }

  // ==================== TRIAGE SESSIONS ====================

  /// Create a new triage session
  Future<int> createTriageSession(LocalTriageSession session) async {
    return await _isar.writeTxn(() async {
      return await _isar.localTriageSessions.put(session);
    });
  }

  /// Get a triage session by ID
  Future<LocalTriageSession?> getTriageSession(int id) async {
    return await _isar.localTriageSessions.get(id);
  }

  /// Get a triage session by UUID
  Future<LocalTriageSession?> getTriageSessionByUuid(String uuid) async {
    return await _isar.localTriageSessions
        .filter()
        .sessionUuidEqualTo(uuid)
        .findFirst();
  }

  /// Get all triage sessions (most recent first)
  Future<List<LocalTriageSession>> getAllTriageSessions() async {
    return await _isar.localTriageSessions
        .where()
        .sortBySessionStartDesc()
        .findAll();
  }

  /// Get unsynced triage sessions (for cloud upload queue)
  Future<List<LocalTriageSession>> getUnsyncedSessions() async {
    return await _isar.localTriageSessions
        .filter()
        .isSyncedEqualTo(false)
        .sortBySessionStart()
        .findAll();
  }

  /// Update a triage session
  Future<int> updateTriageSession(LocalTriageSession session) async {
    return await _isar.writeTxn(() async {
      return await _isar.localTriageSessions.put(session);
    });
  }

  /// Mark a session as synced
  Future<void> markSessionSynced(int sessionId) async {
    final session = await getTriageSession(sessionId);
    if (session != null) {
      session.isSynced = true;
      session.syncedAt = DateTime.now();
      await updateTriageSession(session);
    }
  }

  /// Delete a triage session and related data
  Future<bool> deleteTriageSession(int id) async {
    return await _isar.writeTxn(() async {
      // Delete related symptoms
      await _isar.localSymptoms
          .filter()
          .sessionIdEqualTo(id)
          .deleteAll();
      
      // Delete related result
      await _isar.localTriageResults
          .filter()
          .sessionIdEqualTo(id)
          .deleteAll();
      
      // Delete the session
      return await _isar.localTriageSessions.delete(id);
    });
  }

  // ==================== SYMPTOMS ====================

  /// Add symptoms to a session
  Future<List<int>> addSymptoms(List<LocalSymptom> symptoms) async {
    return await _isar.writeTxn(() async {
      return await _isar.localSymptoms.putAll(symptoms);
    });
  }

  /// Get symptoms for a session
  Future<List<LocalSymptom>> getSymptomsForSession(int sessionId) async {
    return await _isar.localSymptoms
        .filter()
        .sessionIdEqualTo(sessionId)
        .findAll();
  }

  // ==================== TRIAGE RESULTS ====================

  /// Save a triage result
  Future<int> saveTriageResult(LocalTriageResult result) async {
    return await _isar.writeTxn(() async {
      return await _isar.localTriageResults.put(result);
    });
  }

  /// Get the result for a session
  Future<LocalTriageResult?> getResultForSession(int sessionId) async {
    return await _isar.localTriageResults
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
  }

  // ==================== STATISTICS ====================

  /// Get count of all triage sessions
  Future<int> getTotalSessionCount() async {
    return await _isar.localTriageSessions.count();
  }

  /// Get count of unsynced sessions
  Future<int> getUnsyncedSessionCount() async {
    return await _isar.localTriageSessions
        .filter()
        .isSyncedEqualTo(false)
        .count();
  }

  /// Get sessions by urgency level
  Future<List<LocalTriageSession>> getSessionsByUrgency(UrgencyLevel urgencyLevel) async {
    // This requires joining with results - simplified version
    final results = await _isar.localTriageResults
        .filter()
        .urgencyLevelEqualTo(urgencyLevel)
        .findAll();
    
    final sessionIds = results.map((r) => r.sessionId).toSet();
    final sessions = <LocalTriageSession>[];
    
    for (final id in sessionIds) {
      final session = await getTriageSession(id);
      if (session != null) sessions.add(session);
    }
    
    return sessions;
  }

  // ==================== CLEANUP ====================

  /// Clear all data (for logout or data reset)
  Future<void> clearAllData() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }

  /// Close the database
  Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
    }
  }
}

/// Custom exception for database errors
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

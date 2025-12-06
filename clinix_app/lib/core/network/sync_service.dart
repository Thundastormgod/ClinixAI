import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

import '../database/local_database.dart';
import 'api_service.dart';
import 'triage_service.dart';

/// Sync service for handling offline data synchronization
class SyncService {
  final ApiService _apiService;
  final Connectivity _connectivity;
  final LocalDatabase _localDatabase;

  SyncService(this._apiService)
      : _connectivity = Connectivity(),
        _localDatabase = LocalDatabase.instance;

  /// Check if device is online
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Sync pending triage sessions to server
  Future<SyncResult> syncPendingSessions() async {
    if (!(await isOnline)) {
      return SyncResult.offline();
    }

    if (!_localDatabase.isReady) {
      return SyncResult.failure(error: 'Local database not ready');
    }

    try {
      // Get unsynced sessions from local DB
      final unsyncedSessions = await _localDatabase.getUnsyncedSessions();
      if (unsyncedSessions.isEmpty) {
        return SyncResult.success(synced: 0, failed: 0, timestamp: DateTime.now());
      }

      // Prepare sync data
      final sessionsToSync = <Map<String, dynamic>>[];
      for (final session in unsyncedSessions) {
        final symptoms = await _localDatabase.getSymptomsForSession(session.id);
        
        // Mapping local entities to API format
        sessionsToSync.add({
          'sessionId': session.sessionUuid,
          'deviceId': session.deviceId,
          'deviceModel': session.deviceModel,
          'appVersion': session.appVersion,
          'location': session.location,
          'symptoms': symptoms.map((s) => {
            'description': s.description,
            'severity': s.severity,
            'durationHours': s.durationHours,
            'bodyLocation': s.bodyLocation,
          }).toList(),
          // Note: Vital signs, patient info, etc. would need to be fetched from related local tables
          'timestamp': session.sessionStart.toIso8601String(),
        });
      }

      if (sessionsToSync.isEmpty) {
        return SyncResult.success(synced: 0, failed: 0, timestamp: DateTime.now());
      }

      // Send to backend
      final response = await _apiService.post(
        '/sync/batch',
        data: {'sessions': sessionsToSync},
      );

      final data = response.data['data'];
      final syncedCount = data['synced'] ?? 0;

      // Mark as synced in local DB
      // In a real scenario, the backend should return IDs of successfully synced sessions
      // For now, we assume all sent were synced if the batch call succeeded
      for (final session in unsyncedSessions) {
        await _localDatabase.markSessionSynced(session.id);
      }

      return SyncResult.success(
        synced: syncedCount,
        failed: data['failed'] ?? 0,
        timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      return SyncResult.failure(error: e.toString());
    }
  }

  /// Sync user profile changes
  Future<bool> syncUserProfile(Map<String, dynamic> profileData) async {
    if (!(await isOnline)) {
      return false;
    }

    try {
      await _apiService.put('/users/profile', data: profileData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    if (!_localDatabase.isReady) {
       return const SyncStatus(
        isOnline: false,
        pendingSessions: 0,
        failedSessions: 0,
      );
    }

    final unsyncedCount = await _localDatabase.getUnsyncedSessionCount();
    
    if (!(await isOnline)) {
      return SyncStatus(
        isOnline: false,
        pendingSessions: unsyncedCount,
        failedSessions: 0,
      );
    }

    try {
      final response = await _apiService.get('/sync/status');
      final data = response.data['data'];
      // Merge local pending count with server status
      return SyncStatus(
        isOnline: true,
        lastSync: data['lastSync'] != null ? DateTime.parse(data['lastSync']) : null,
        pendingSessions: unsyncedCount, // Use local count as truth for pending upload
        failedSessions: data['failedSessions'] ?? 0,
        serverVersion: data['serverVersion'],
      );
    } catch (e) {
      return SyncStatus(
        isOnline: false,
        pendingSessions: unsyncedCount,
        failedSessions: 0,
      );
    }
  }

  /// Download latest knowledge base updates
  Future<KnowledgeBaseUpdate> checkKnowledgeBaseUpdates() async {
    if (!(await isOnline)) {
      return KnowledgeBaseUpdate.noUpdates();
    }

    try {
      final response = await _apiService.get('/sync/knowledge-updates');
      final data = response.data['data'];
      return KnowledgeBaseUpdate.fromJson(data);
    } catch (e) {
      return KnowledgeBaseUpdate.noUpdates();
    }
  }

  /// Download knowledge base content
  Future<bool> downloadKnowledgeBase(String version) async {
    if (!(await isOnline)) {
      return false;
    }

    try {
      final response = await _apiService.get(
        '/sync/knowledge-download',
        queryParameters: {'version': version},
      );

      // Handle file download - this would need to be implemented
      // based on how the backend serves knowledge base files
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// ... [Rest of the classes remain unchanged: PendingSession, SyncResult, SyncStatus, KnowledgeBaseUpdate]
// Copying them here to ensure file completeness

/// Pending session data for sync
class PendingSession extends Equatable {
  final String sessionId;
  final String deviceId;
  final String deviceModel;
  final String appVersion;
  final String? location;
  final List<Symptom> symptoms;
  final List<VitalSign>? vitalSigns;
  final int? patientAge;
  final String? patientGender;
  final List<String>? medicalHistory;
  final DateTime timestamp;

  const PendingSession({
    required this.sessionId,
    required this.deviceId,
    required this.deviceModel,
    required this.appVersion,
    this.location,
    required this.symptoms,
    this.vitalSigns,
    this.patientAge,
    this.patientGender,
    this.medicalHistory,
    required this.timestamp,
  });

  factory PendingSession.fromJson(Map<String, dynamic> json) {
    return PendingSession(
      sessionId: json['sessionId'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceModel: json['deviceModel'] ?? '',
      appVersion: json['appVersion'] ?? '',
      location: json['location'],
      symptoms: (json['symptoms'] ?? []).map<Symptom>((s) => Symptom.fromJson(s)).toList(),
      vitalSigns: json['vitalSigns'] != null
          ? (json['vitalSigns'] as List).map((v) => VitalSign.fromJson(v)).toList()
          : null,
      patientAge: json['patientAge'],
      patientGender: json['patientGender'],
      medicalHistory: json['medicalHistory']?.cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'appVersion': appVersion,
      if (location != null) 'location': location,
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      if (vitalSigns != null) 'vitalSigns': vitalSigns!.map((v) => v.toJson()).toList(),
      if (patientAge != null) 'patientAge': patientAge,
      if (patientGender != null) 'patientGender': patientGender,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        sessionId,
        deviceId,
        deviceModel,
        appVersion,
        location,
        symptoms,
        vitalSigns,
        patientAge,
        patientGender,
        medicalHistory,
        timestamp,
      ];
}

/// Sync operation result
class SyncResult {
  final bool success;
  final bool isOnline;
  final int? synced;
  final int? failed;
  final DateTime? timestamp;
  final String? error;

  SyncResult._({
    required this.success,
    required this.isOnline,
    this.synced,
    this.failed,
    this.timestamp,
    this.error,
  });

  factory SyncResult.success({
    required int synced,
    required int failed,
    required DateTime timestamp,
  }) {
    return SyncResult._(
      success: true,
      isOnline: true,
      synced: synced,
      failed: failed,
      timestamp: timestamp,
    );
  }

  factory SyncResult.failure({required String error}) {
    return SyncResult._(
      success: false,
      isOnline: true,
      error: error,
    );
  }

  factory SyncResult.offline() {
    return SyncResult._(
      success: false,
      isOnline: false,
    );
  }
}

/// Sync status information
class SyncStatus extends Equatable {
  final bool isOnline;
  final DateTime? lastSync;
  final int pendingSessions;
  final int failedSessions;
  final String? serverVersion;

  const SyncStatus({
    required this.isOnline,
    this.lastSync,
    required this.pendingSessions,
    required this.failedSessions,
    this.serverVersion,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      isOnline: true,
      lastSync: json['lastSync'] != null ? DateTime.parse(json['lastSync']) : null,
      pendingSessions: json['pendingSessions'] ?? 0,
      failedSessions: json['failedSessions'] ?? 0,
      serverVersion: json['serverVersion'],
    );
  }

  factory SyncStatus.offline() {
    return const SyncStatus(
      isOnline: false,
      pendingSessions: 0,
      failedSessions: 0,
    );
  }

  @override
  List<Object?> get props => [isOnline, lastSync, pendingSessions, failedSessions, serverVersion];
}

/// Knowledge base update information
class KnowledgeBaseUpdate extends Equatable {
  final bool hasUpdates;
  final String? currentVersion;
  final String? latestVersion;
  final int? updateSize;
  final String? changelog;
  final bool isOnline;

  const KnowledgeBaseUpdate({
    required this.hasUpdates,
    this.currentVersion,
    this.latestVersion,
    this.updateSize,
    this.changelog,
    required this.isOnline,
  });

  factory KnowledgeBaseUpdate.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseUpdate(
      hasUpdates: json['hasUpdates'] ?? false,
      currentVersion: json['currentVersion'],
      latestVersion: json['latestVersion'],
      updateSize: json['updateSize'],
      changelog: json['changelog'],
      isOnline: true,
    );
  }

  factory KnowledgeBaseUpdate.noUpdates() {
    return const KnowledgeBaseUpdate(
      hasUpdates: false,
      isOnline: false,
    );
  }

  @override
  List<Object?> get props => [
        hasUpdates,
        currentVersion,
        latestVersion,
        updateSize,
        changelog,
        isOnline,
      ];
}
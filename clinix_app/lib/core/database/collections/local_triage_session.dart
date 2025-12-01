// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Triage Session Collection
// Represents a single triage interaction with metadata
// Supports offline-first with cloud sync queue

import 'package:isar/isar.dart';

part 'local_triage_session.g.dart';

/// Processing mode for triage
enum ProcessingMode {
  local,      // Processed entirely on-device
  cloud,      // Processed in the cloud
  hybrid,     // Started local, escalated to cloud
  pendingSync // Processed locally, waiting for cloud sync
}

/// Local Triage Session
/// 
/// Represents a single triage interaction.
/// Contains metadata about the session and links to symptoms/results.

@collection
class LocalTriageSession {
  LocalTriageSession();
  
  Id id = Isar.autoIncrement;

  /// Unique identifier for cloud sync (UUID v4)
  @Index(unique: true)
  late String sessionUuid;

  /// When the session started
  @Index()
  DateTime sessionStart = DateTime.now();

  /// When the session ended (null if ongoing)
  DateTime? sessionEnd;

  /// How was this session processed
  @Enumerated(EnumType.name)
  ProcessingMode processingMode = ProcessingMode.local;

  /// Device identifier (for multi-device tracking)
  String? deviceId;

  /// Device model (e.g., "Nothing Phone (2a)")
  String? deviceModel;

  /// App version at time of session
  String? appVersion;

  /// Location latitude (optional, requires consent)
  double? locationLat;

  /// Location longitude (optional, requires consent)
  double? locationLng;

  /// Free-text notes from user
  String? userNotes;

  /// Has this session been synced to cloud?
  @Index()
  bool isSynced = false;

  /// When was it synced
  DateTime? syncedAt;

  /// Number of sync retry attempts
  int syncRetryCount = 0;

  /// Last sync error message (if any)
  String? lastSyncError;

  /// Calculate session duration
  @ignore
  Duration? get duration {
    if (sessionEnd == null) return null;
    return sessionEnd!.difference(sessionStart);
  }

  /// Check if session is complete
  @ignore
  bool get isComplete => sessionEnd != null;

  /// Check if session needs sync
  @ignore
  bool get needsSync => !isSynced && isComplete;

  /// Mark session as complete
  void complete() {
    sessionEnd = DateTime.now();
    if (processingMode == ProcessingMode.local) {
      processingMode = ProcessingMode.pendingSync;
    }
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionUuid': sessionUuid,
      'sessionStart': sessionStart.toIso8601String(),
      'sessionEnd': sessionEnd?.toIso8601String(),
      'processingMode': processingMode.name,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'appVersion': appVersion,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'userNotes': userNotes,
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
      'syncRetryCount': syncRetryCount,
    };
  }

  /// Create from JSON
  factory LocalTriageSession.fromJson(Map<String, dynamic> json) {
    return LocalTriageSession()
      ..sessionUuid = json['sessionUuid']
      ..sessionStart = DateTime.parse(json['sessionStart'])
      ..sessionEnd = json['sessionEnd'] != null 
          ? DateTime.parse(json['sessionEnd']) 
          : null
      ..processingMode = ProcessingMode.values.firstWhere(
          (e) => e.name == json['processingMode'],
          orElse: () => ProcessingMode.local)
      ..deviceId = json['deviceId']
      ..deviceModel = json['deviceModel']
      ..appVersion = json['appVersion']
      ..locationLat = json['locationLat']
      ..locationLng = json['locationLng']
      ..userNotes = json['userNotes']
      ..isSynced = json['isSynced'] ?? false
      ..syncedAt = json['syncedAt'] != null 
          ? DateTime.parse(json['syncedAt']) 
          : null
      ..syncRetryCount = json['syncRetryCount'] ?? 0;
  }

  /// Create a new session with UUID
  factory LocalTriageSession.create({
    String? deviceId,
    String? deviceModel,
    String? appVersion,
  }) {
    // Generate UUID v4
    final uuid = _generateUuid();
    
    return LocalTriageSession()
      ..sessionUuid = uuid
      ..sessionStart = DateTime.now()
      ..deviceId = deviceId
      ..deviceModel = deviceModel
      ..appVersion = appVersion;
  }

  /// Simple UUID v4 generator
  static String _generateUuid() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(
      RegExp(r'[xy]'),
      (match) {
        final r = (random + (DateTime.now().microsecond % 16)) % 16;
        final v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
        return v.toRadixString(16);
      },
    );
  }
}

// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Patient Profile Collection
// Stores device owner's personal health information (PHI)
// Data never leaves device without explicit consent

import 'package:isar/isar.dart';

part 'local_patient_profile.g.dart';

/// Local Patient Profile
/// 
/// Stores the device owner's personal health information.
/// This data never leaves the device without explicit consent.
/// Only ONE profile exists per device.

@collection
class LocalPatientProfile {
  LocalPatientProfile();
  
  Id id = Isar.autoIncrement;

  /// Patient's full name
  String? fullName;

  /// Date of birth for age calculation
  DateTime? dateOfBirth;

  /// Gender (male, female, other)
  String? gender;

  /// Blood type (A+, A-, B+, B-, AB+, AB-, O+, O-)
  String? bloodType;

  /// Known allergies
  List<String>? allergies;

  /// Current medications
  List<String>? currentMedications;

  /// Chronic conditions (diabetes, hypertension, etc.)
  List<String>? chronicConditions;

  /// Emergency contact name
  String? emergencyContactName;

  /// Emergency contact phone
  String? emergencyContactPhone;

  /// Language preference
  String? preferredLanguage;

  /// Has user given consent for data collection
  bool consentGiven = false;

  /// When consent was given
  DateTime? consentTimestamp;

  /// Last profile update
  DateTime lastUpdated = DateTime.now();

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if profile has critical info for triage
  bool get hasMinimalInfo => fullName != null && dateOfBirth != null;

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'chronicConditions': chronicConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'preferredLanguage': preferredLanguage,
      'consentGiven': consentGiven,
      'consentTimestamp': consentTimestamp?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LocalPatientProfile.fromJson(Map<String, dynamic> json) {
    return LocalPatientProfile()
      ..fullName = json['fullName']
      ..dateOfBirth = json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null
      ..gender = json['gender']
      ..bloodType = json['bloodType']
      ..allergies = json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null
      ..currentMedications = json['currentMedications'] != null 
          ? List<String>.from(json['currentMedications']) 
          : null
      ..chronicConditions = json['chronicConditions'] != null 
          ? List<String>.from(json['chronicConditions']) 
          : null
      ..emergencyContactName = json['emergencyContactName']
      ..emergencyContactPhone = json['emergencyContactPhone']
      ..preferredLanguage = json['preferredLanguage']
      ..consentGiven = json['consentGiven'] ?? false
      ..consentTimestamp = json['consentTimestamp'] != null 
          ? DateTime.parse(json['consentTimestamp']) 
          : null
      ..lastUpdated = json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : DateTime.now();
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

/// Authentication service for user login/register operations
class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  static const String _userProfileKey = 'user_profile';

  AuthService(this._apiService, {FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Register a new user
  Future<AuthResult> register({
    required String phoneNumber,
    required String fullName,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'phoneNumber': phoneNumber,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0], // YYYY-MM-DD format
          'gender': gender,
        },
      );

      final data = response.data['data'];
      final user = UserProfile.fromJson(data);

      // Store user profile
      await _secureStorage.write(
        key: _userProfileKey,
        value: jsonEncode(user.toJson()),
      );

      return AuthResult.success(user: user);
    } catch (e) {
      return AuthResult.failure(error: e.toString());
    }
  }

  /// Login with phone number and OTP
  Future<AuthResult> login({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );

      final data = response.data['data'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      // Store tokens
      await _apiService.setTokens(accessToken, refreshToken);

      // Try to get user profile if not stored
      UserProfile? user = await getStoredUserProfile();
      if (user == null) {
        // Fetch user profile from API (assuming there's an endpoint for this)
        try {
          final profileResponse = await _apiService.get('/users/profile');
          user = UserProfile.fromJson(profileResponse.data['data']);

          await _secureStorage.write(
            key: _userProfileKey,
            value: jsonEncode(user.toJson()),
          );
        } catch (_) {
          // If profile fetch fails, create basic profile
          user = UserProfile(
            userId: 'unknown',
            phoneNumber: phoneNumber,
            fullName: 'Unknown User',
            dateOfBirth: null,
            gender: null,
          );
        }
      }

      return AuthResult.success(user: user);
    } catch (e) {
      return AuthResult.failure(error: e.toString());
    }
  }

  /// Request OTP for phone number
  Future<bool> requestOtp(String phoneNumber) async {
    try {
      await _apiService.post(
        '/auth/request-otp',
        data: {'phoneNumber': phoneNumber},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _apiService.clearTokens();
    await _secureStorage.delete(key: _userProfileKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored user profile
  Future<UserProfile?> getStoredUserProfile() async {
    final profileJson = await _secureStorage.read(key: _userProfileKey);
    if (profileJson != null) {
      try {
        final profileMap = jsonDecode(profileJson);
        return UserProfile.fromJson(profileMap);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Refresh user profile from server
  Future<UserProfile?> refreshUserProfile() async {
    try {
      final response = await _apiService.get('/users/profile');
      final user = UserProfile.fromJson(response.data['data']);

      await _secureStorage.write(
        key: _userProfileKey,
        value: jsonEncode(user.toJson()),
      );

      return user;
    } catch (_) {
      return null;
    }
  }
}

/// User profile model
class UserProfile extends Equatable {
  final String userId;
  final String phoneNumber;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? gender;

  const UserProfile({
    required this.userId,
    required this.phoneNumber,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
    };
  }

  @override
  List<Object?> get props => [userId, phoneNumber, fullName, dateOfBirth, gender];
}

/// Authentication result
class AuthResult {
  final bool success;
  final UserProfile? user;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
  });

  factory AuthResult.success({required UserProfile user}) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure({required String error}) {
    return AuthResult._(success: false, error: error);
  }
}

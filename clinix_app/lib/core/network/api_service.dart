import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Base API service with Dio configuration and interceptors
class ApiService {
  late final Dio _dio;
  late final FlutterSecureStorage _secureStorage;
  late final Connectivity _connectivity;

  static const String _baseUrlKey = 'BASE_URL';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService() {
    _secureStorage = const FlutterSecureStorage();
    _connectivity = Connectivity();

    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env[_baseUrlKey] ?? 'http://localhost:3000/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add access token to requests
          final token = await _secureStorage.read(key: _accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add device info
          options.headers['X-Device-Platform'] = Platform.operatingSystem;
          options.headers['X-App-Version'] = '1.0.0';

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
            if (refreshToken != null) {
              try {
                // Attempt token refresh
                final newTokens = await _refreshAccessToken(refreshToken);
                if (newTokens != null) {
                  // Retry the original request with new token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';
                  final response = await _dio.fetch(options);
                  return handler.resolve(response);
                }
              } catch (e) {
                // Refresh failed, clear tokens
                await _clearTokens();
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (debug only)
    if (dotenv.env['ENVIRONMENT'] == 'development') {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  Future<Map<String, String>?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final data = response.data['data'];
      final newAccessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: newRefreshToken);

      return {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Generic HTTP methods with error handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkTimeoutException('Request timed out. Please try again.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkConnectionException('No internet connection. Working offline.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return ApiException('Invalid request: ${data['error'] ?? 'Bad request'}');
        case 401:
          return AuthenticationException('Authentication required. Please log in again.');
        case 403:
          return AuthorizationException('Access denied. Insufficient permissions.');
        case 404:
          return NotFoundException('Resource not found.');
        case 422:
          return ValidationException('Validation failed: ${data['error'] ?? 'Invalid data'}');
        case 429:
          return RateLimitException('Too many requests. Please wait and try again.');
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException('Server error. Please try again later.');
        default:
          return ApiException('API error (${statusCode}): ${data['error'] ?? 'Unknown error'}');
      }
    }

    return UnknownException('An unexpected error occurred: ${error.message}');
  }
}

// Custom exceptions for better error handling
class NetworkTimeoutException implements Exception {
  final String message;
  NetworkTimeoutException(this.message);

  @override
  String toString() => message;
}

class NetworkConnectionException implements Exception {
  final String message;
  NetworkConnectionException(this.message);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => message;
}

class AuthorizationException implements Exception {
  final String message;
  AuthorizationException(this.message);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);

  @override
  String toString() => message;
}

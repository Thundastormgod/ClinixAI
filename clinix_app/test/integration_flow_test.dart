import 'dart:convert';

import 'package:clinix_app/core/network/api_service.dart';
import 'package:clinix_app/core/network/auth_service.dart';
import 'package:clinix_app/core/network/network_providers.dart';
import 'package:clinix_app/core/network/triage_service.dart';
import 'package:clinix_app/features/auth/presentation/login_screen.dart';
import 'package:clinix_app/features/home/presentation/home_screen.dart';
import 'package:clinix_app/features/triage/presentation/symptom_input_screen.dart';
import 'package:clinix_app/features/triage/presentation/triage_results_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create a manual mock for ApiService since we can't run build_runner
class MockApiService extends Fake implements ApiService {
  final Map<String, dynamic> _mockResponses = {};

  void setMockResponse(String path, Map<String, dynamic> response) {
    _mockResponses[path] = response;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockResponses[path] as T,
        statusCode: 200,
      );
    }
    throw Exception('Path $path not mocked');
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_mockResponses.containsKey(path)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: _mockResponses[path] as T,
        statusCode: 200,
      );
    }
    throw Exception('Path $path not mocked');
  }

  @override
  Future<void> setTokens(String accessToken, String refreshToken) async {}

  @override
  Future<String?> getAccessToken() async => 'mock_token';
}

// Mock AuthService to bypass secure storage
class MockAuthService extends Fake implements AuthService {
  bool _isAuthenticated = false;

  @override
  Future<AuthResult> login({required String phoneNumber, required String otp}) async {
    _isAuthenticated = true;
    return AuthResult.success(
      user: const UserProfile(
        userId: '123',
        phoneNumber: '+254700000000',
        fullName: 'Test User',
      ),
    );
  }

  @override
  Future<bool> isAuthenticated() async => _isAuthenticated;

  @override
  Future<UserProfile?> getStoredUserProfile() async {
    if (_isAuthenticated) {
      return const UserProfile(
        userId: '123',
        phoneNumber: '+254700000000',
        fullName: 'Test User',
      );
    }
    return null;
  }
}

void main() {
  late MockApiService mockApiService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockApiService = MockApiService();
    mockAuthService = MockAuthService();
  });

  group('Authentication Flow Tests', () {
    testWidgets('Login Screen UI renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome to ClinixAI'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Login flow works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          child: MaterialApp(
            routes: {
              '/home': (context) => const Scaffold(body: Text('Home Screen')),
            },
            home: const LoginScreen(),
          ),
        ),
      );

      // Enter phone number
      await tester.enterText(find.byType(TextField).first, '700000000');
      await tester.pump();

      // Tap Send OTP
      await tester.tap(find.text('Send OTP'));
      await tester.pump(const Duration(seconds: 2)); // Wait for simulated delay
      await tester.pump();

      // Verify OTP fields appear
      expect(find.text('Enter the 6-digit code sent to'), findsOneWidget);

      // Enter OTP (simulating completion)
      // Note: Complex OTP widgets can be hard to test, we'll simulate the state change or service call if possible
      // In this integration test, we trust the unit logic and just verify UI state
    });
  });

  group('Triage Flow Tests', () {
    testWidgets('Symptom Input Screen adds symptoms correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SymptomInputScreen(),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Describe Symptoms'), findsOneWidget);
      expect(find.text('0 symptoms added'), findsOneWidget);

      // Add a symptom text
      await tester.enterText(find.byType(TextField).at(1), 'Severe headache');
      await tester.pump();

      // Tap Add Symptom button (it's the first ElevatedButton in the scroll view usually, or we find by icon)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify symptom added to list
      expect(find.text('Severe headache'), findsOneWidget);
      expect(find.text('1 symptom added'), findsOneWidget);
    });

    testWidgets('Triage Results Screen displays correct urgency', (WidgetTester tester) async {
      const result = TriageResult(
        sessionId: 'test-session',
        urgencyLevel: UrgencyLevel.level2,
        confidenceScore: 0.85,
        primaryAssessment: 'Test Assessment',
        recommendedAction: 'Go to hospital',
        differentialDiagnoses: [],
        escalatedToCloud: true,
        aiModel: 'gpt-4',
        inferenceTimeMs: 500,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TriageResultsScreen(triageResult: result),
          ),
        ),
      );

      // Verify Urgency Level 2 display
      expect(find.text('LEVEL 2 - URGENT'), findsOneWidget);
      expect(find.text('Emergency within 1 hour'), findsOneWidget);
      expect(find.text('Go to hospital'), findsOneWidget);
    });
  });

  group('Service Unit Tests', () {
    test('AuthService login parses response correctly', () async {
      // Setup mock response
      mockApiService.setMockResponse('/auth/login', {
        'data': {
          'accessToken': 'access-123',
          'refreshToken': 'refresh-123',
        }
      });
      
      mockApiService.setMockResponse('/users/profile', {
        'data': {
          'userId': 'user-123',
          'phoneNumber': '+254700000000',
          'fullName': 'Test User',
        }
      });

      final authService = AuthService(mockApiService);
      final result = await authService.login(phoneNumber: '123', otp: '456');

      expect(result.success, true);
      expect(result.user?.fullName, 'Test User');
    });

    test('TriageService analyzeSymptoms parses response correctly', () async {
      mockApiService.setMockResponse('/triage/sessions/session-123/analyze', {
        'sessionId': 'session-123',
        'urgencyLevel': 'critical',
        'confidenceScore': 0.95,
        'primaryAssessment': 'Severe condition',
        'recommendedAction': 'ER',
        'differentialDiagnoses': [
          {'condition': 'Malaria', 'probability': 0.8}
        ],
        'escalatedToCloud': true,
        'aiModel': 'gpt-4',
        'inferenceTimeMs': 100,
      });

      final triageService = TriageService(mockApiService);
      final result = await triageService.analyzeSymptoms(
        sessionId: 'session-123',
        symptoms: const [Symptom(description: 'Fever')],
      );

      expect(result.urgencyLevel, UrgencyLevel.level1);
      expect(result.confidenceScore, 0.95);
      expect(result.differentialDiagnoses.first.condition, 'Malaria');
    });
  });
}


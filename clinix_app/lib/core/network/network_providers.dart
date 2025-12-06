import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';
import 'auth_service.dart';
import 'sync_service.dart';
import 'triage_service.dart';

/// Core API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

/// Triage service provider
final triageServiceProvider = Provider<TriageService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TriageService(apiService);
});

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SyncService(apiService);
});

/// Connectivity status provider
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

/// Network status provider (combines connectivity and API reachability)
final networkStatusProvider = Provider<Future<NetworkStatus>>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  final apiService = ref.watch(apiServiceProvider);

  return connectivityAsync.when(
    data: (connectivity) async {
      final isConnected = connectivity != ConnectivityResult.none;
      if (!isConnected) {
        return NetworkStatus.offline();
      }

      // Test API reachability
      try {
        await apiService.get('/health');
        return NetworkStatus.online();
      } catch (e) {
        return NetworkStatus.onlineButApiUnreachable();
      }
    },
    loading: () => Future.value(NetworkStatus.connecting()),
    error: (error, stack) => Future.value(NetworkStatus.error(error.toString())),
  );
});

/// Network status model
class NetworkStatus {
  final bool isOnline;
  final bool apiReachable;
  final String? errorMessage;
  final NetworkStatusType type;

  const NetworkStatus._({
    required this.isOnline,
    required this.apiReachable,
    this.errorMessage,
    required this.type,
  });

  factory NetworkStatus.online() {
    return const NetworkStatus._(
      isOnline: true,
      apiReachable: true,
      type: NetworkStatusType.online,
    );
  }

  factory NetworkStatus.onlineButApiUnreachable() {
    return const NetworkStatus._(
      isOnline: true,
      apiReachable: false,
      type: NetworkStatusType.apiUnreachable,
    );
  }

  factory NetworkStatus.offline() {
    return const NetworkStatus._(
      isOnline: false,
      apiReachable: false,
      type: NetworkStatusType.offline,
    );
  }

  factory NetworkStatus.connecting() {
    return const NetworkStatus._(
      isOnline: false,
      apiReachable: false,
      type: NetworkStatusType.connecting,
    );
  }

  factory NetworkStatus.error(String message) {
    return NetworkStatus._(
      isOnline: false,
      apiReachable: false,
      errorMessage: message,
      type: NetworkStatusType.error,
    );
  }

  bool get canSync => isOnline && apiReachable;
  bool get canUseOfflineFeatures => true; // Local AI is always available
}

/// Network status types
enum NetworkStatusType {
  online,
  offline,
  apiUnreachable,
  connecting,
  error,
}

/// Authentication state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

/// Authentication state
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final UserProfile? user;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.user,
    this.error,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthState.authenticated(UserProfile user) {
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      user: user,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: true,
    );
  }

  factory AuthState.error(String error) {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      error: error,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserProfile? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, isLoading, user, error];
}

/// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = AuthState.loading();

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authService.getStoredUserProfile();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.initial();
        }
      } else {
        state = AuthState.initial();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register({
    required String phoneNumber,
    required String fullName,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    state = AuthState.loading();

    final result = await _authService.register(
      phoneNumber: phoneNumber,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );

    if (result.success && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = AuthState.error(result.error ?? 'Registration failed');
    }
  }

  Future<void> login({
    required String phoneNumber,
    required String otp,
  }) async {
    state = AuthState.loading();

    final result = await _authService.login(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    if (result.success && result.user != null) {
      state = AuthState.authenticated(result.user!);
    } else {
      state = AuthState.error(result.error ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await _authService.refreshUserProfile();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      // Keep current state if refresh fails
    }
  }
}

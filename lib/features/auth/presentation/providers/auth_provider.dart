import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Check if Firebase is initialized before using FirebaseAuthRepository
  if (FirebaseService.isInitialized) {
    try {
      AppLogger.info('Using Firebase authentication repository');
      return FirebaseAuthRepository();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create FirebaseAuthRepository, falling back to DummyAuthRepository',
        e,
        stackTrace,
      );
      return DummyAuthRepository();
    }
  } else {
    AppLogger.warning(
      'Firebase not initialized, using DummyAuthRepository for testing',
    );
    return DummyAuthRepository();
  }
});

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState();
}

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription? _authStateSubscription;

  @override
  AuthState build() {
    // Initialize auth state and listen to changes
    _initializeAuth();
    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });
    return AuthState.initial();
  }

  void _initializeAuth() {
    // Use Future.microtask to avoid calling async operations during build
    Future.microtask(() {
      try {
        AppLogger.auth('Initializing authentication...');
        final repository = ref.read(authRepositoryProvider);
        if (repository is FirebaseAuthRepository) {
          AppLogger.auth('Using Firebase authentication');
          _listenToAuthChanges();
        } else {
          AppLogger.auth('Using dummy authentication');
          _checkAuth();
        }
      } catch (e, stackTrace) {
        // Handle initialization errors gracefully
        AppLogger.error('Failed to initialize auth', e, stackTrace);
        state = state.copyWith(
          error: 'Failed to initialize authentication. Please try again.',
        );
      }
    });
  }

  void _listenToAuthChanges() {
    final repository =
        ref.read(authRepositoryProvider) as FirebaseAuthRepository;
    _authStateSubscription = repository.authStateChanges.listen(
      (firebaseUser) async {
        if (firebaseUser != null) {
          try {
            AppLogger.auth(
              'Auth state changed: User signed in (${firebaseUser.uid})',
            );
            final user = await repository.getCurrentUser();
            if (user != null) {
              AppLogger.auth('User data retrieved successfully: ${user.email}');
              state = state.copyWith(
                user: user,
                isAuthenticated: true,
                error: null,
              );
            }
          } catch (e, stackTrace) {
            AppLogger.error('Failed to get user data', e, stackTrace);
            state = state.copyWith(
              error: 'Failed to retrieve user information. Please try again.',
            );
          }
        } else {
          AppLogger.auth('Auth state changed: User signed out');
          state = AuthState.initial();
        }
      },
      onError: (error, stackTrace) {
        AppLogger.error('Auth state stream error', error, stackTrace);
        state = state.copyWith(
          error: 'Authentication error occurred. Please try again.',
        );
      },
    );
  }

  Future<void> _checkAuth() async {
    try {
      AppLogger.auth('Checking authentication status...');
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser();
      if (user != null) {
        AppLogger.auth('User is authenticated: ${user.email}');
        state = state.copyWith(user: user, isAuthenticated: true, error: null);
      } else {
        AppLogger.auth('No authenticated user found');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error checking auth status', e, stackTrace);
    }
  }

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Check for common Firebase Auth error patterns
    if (errorString.contains('user-not-found') ||
        errorString.contains('no user found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (errorString.contains('wrong-password') ||
        errorString.contains('invalid-credential') ||
        errorString.contains('wrong password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorString.contains('email-already-in-use') ||
        errorString.contains('account already exists')) {
      return 'An account with this email already exists.';
    } else if (errorString.contains('invalid-email') ||
        errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (errorString.contains('weak-password') ||
        errorString.contains('password is too weak')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Too many login attempts. Please try again later.';
    } else if (errorString.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (errorString.contains('operation-not-allowed')) {
      return 'This operation is not allowed. Please contact support.';
    }

    // Extract message from exception if it's user-friendly
    final errorMessage = error.toString();
    if (errorMessage.contains('Exception: ')) {
      return errorMessage.split('Exception: ').last;
    }

    // Default fallback
    return 'Login failed. Please check your credentials and try again.';
  }

  Future<void> login(String email, String password) async {
    AppLogger.auth('Login attempt for email: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);

      if (user != null) {
        AppLogger.auth('Login successful for user: ${user.email}');
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
      } else {
        AppLogger.warning('Login returned null user');
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('Login failed for email: $email', e, stackTrace);
      state = state.copyWith(isLoading: false, error: errorMessage);
      // Re-throw to allow UI to handle it if needed
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String displayName) async {
    AppLogger.auth(
      'Signup attempt for email: $email, displayName: $displayName',
    );
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signup(email, password, displayName);

      AppLogger.auth('Signup successful for user: ${user.email}');
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('Signup failed for email: $email', e, stackTrace);
      state = state.copyWith(isLoading: false, error: errorMessage);
      // Re-throw to allow UI to handle it if needed
      rethrow;
    }
  }

  Future<void> logout() async {
    AppLogger.auth('Logout attempt');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      AppLogger.auth('Logout successful');
      state = AuthState.initial();
    } catch (e, stackTrace) {
      AppLogger.error('Logout failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to logout. Please try again.',
      );
    }
  }

  Future<void> deleteAccount(String password) async {
    AppLogger.auth('Delete account attempt');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.deleteAccount(password);
      AppLogger.auth('Account deleted successfully');
      // Sign out and reset state after account deletion
      await repository.logout();
      state = AuthState.initial();
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('Delete account failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage.isNotEmpty
            ? errorMessage
            : 'Failed to delete account. Please try again.',
      );
      // Re-throw to allow UI to handle it if needed
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

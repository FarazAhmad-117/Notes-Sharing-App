import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DummyAuthRepository();
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
  @override
  AuthState build() {
    _checkAuth();
    return AuthState.initial();
  }

  Future<void> _checkAuth() async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: user != null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signup(email, password, displayName);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

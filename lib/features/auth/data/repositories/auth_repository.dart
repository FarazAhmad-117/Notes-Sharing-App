import '../models/user_model.dart';

// Abstract repository - will be implemented with Firebase later
abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User> signup(String email, String password, String displayName);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}

// Dummy implementation for UI development
class DummyAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Dummy login - accept any email/password
    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        uid: 'user_123',
        email: email,
        displayName: email.split('@')[0],
        isEmailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return _currentUser;
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<User> signup(String email, String password, String displayName) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = User(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      isEmailVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Dummy - always succeeds
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isEmailVerified: true);
    }
  }
}


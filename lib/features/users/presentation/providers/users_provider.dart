import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/users_repository.dart';
import '../../data/repositories/firebase_users_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/logger.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  // Check if Firebase is initialized before using FirebaseUsersRepository
  if (FirebaseService.isInitialized) {
    try {
      AppLogger.info('Using Firebase users repository');
      return FirebaseUsersRepository();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create FirebaseUsersRepository, falling back to DummyUsersRepository',
        e,
        stackTrace,
      );
      return DummyUsersRepository();
    }
  } else {
    AppLogger.warning(
      'Firebase not initialized, using DummyUsersRepository for testing',
    );
    return DummyUsersRepository();
  }
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.read(usersRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.getAllUsers(authState.user!.uid);
});

final searchUsersProvider = FutureProvider.family<List<User>, String>((
  ref,
  query,
) async {
  final repository = ref.read(usersRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.searchUsers(query, authState.user!.uid);
});

final userDetailProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  final repository = ref.read(usersRepositoryProvider);
  return repository.getUserById(userId);
});

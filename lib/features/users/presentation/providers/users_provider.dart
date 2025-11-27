import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/users_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return DummyUsersRepository();
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

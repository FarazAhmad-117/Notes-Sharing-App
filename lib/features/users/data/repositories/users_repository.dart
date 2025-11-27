import 'package:notes_sharing_app/features/auth/data/models/user_model.dart';

// Abstract repository - will be implemented with Firebase later
abstract class UsersRepository {
  Future<List<User>> getAllUsers(String currentUserId);
  Future<List<User>> searchUsers(String query, String currentUserId);
  Future<User?> getUserById(String userId);
}

// Dummy implementation for UI development
class DummyUsersRepository implements UsersRepository {
  // Generate dummy users
  List<User> _generateDummyUsers(String currentUserId) {
    final now = DateTime.now();
    return [
      User(
        uid: 'user_1',
        email: 'alice@example.com',
        displayName: 'Alice Johnson',
        photoUrl: null,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
        lastSeen: now.subtract(const Duration(minutes: 5)),
      ),
      User(
        uid: 'user_2',
        email: 'bob@example.com',
        displayName: 'Bob Smith',
        photoUrl: null,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 2)),
        lastSeen: now.subtract(const Duration(hours: 2)),
      ),
      User(
        uid: 'user_3',
        email: 'charlie@example.com',
        displayName: 'Charlie Brown',
        photoUrl: null,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
        lastSeen: now.subtract(const Duration(days: 1)),
      ),
      User(
        uid: 'user_4',
        email: 'diana@example.com',
        displayName: 'Diana Prince',
        photoUrl: null,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        lastSeen: now.subtract(const Duration(minutes: 30)),
      ),
      User(
        uid: 'user_5',
        email: 'eve@example.com',
        displayName: 'Eve Williams',
        photoUrl: null,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        lastSeen: now.subtract(const Duration(minutes: 10)),
      ),
    ].where((user) => user.uid != currentUserId).toList();
  }

  @override
  Future<List<User>> getAllUsers(String currentUserId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _generateDummyUsers(currentUserId);
  }

  @override
  Future<List<User>> searchUsers(String query, String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allUsers = _generateDummyUsers(currentUserId);
    if (query.isEmpty) return allUsers;

    final lowerQuery = query.toLowerCase();
    return allUsers.where((user) {
      return user.displayName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<User?> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final allUsers = await getAllUsers(userId);
    try {
      return allUsers.firstWhere((user) => user.uid == userId);
    } catch (e) {
      return null;
    }
  }
}

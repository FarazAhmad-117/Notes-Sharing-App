import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../repositories/users_repository.dart';
import '../../../auth/data/models/user_model.dart';

class FirebaseUsersRepository implements UsersRepository {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  /// Convert Firestore document to User model
  User _firestoreDocToUser(firestore.DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Unknown User',
      photoUrl: data['photoUrl'] as String?,
      fcmToken: data['fcmToken'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      theme: data['theme'] as String? ?? 'light',
      language: data['language'] as String? ?? 'en',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as firestore.Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as firestore.Timestamp).toDate()
          : DateTime.now(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as firestore.Timestamp).toDate()
          : null,
    );
  }

  @override
  Future<List<User>> getAllUsers(String currentUserId) async {
    try {
      final snapshot = await _firestore.collection('users').get();

      return snapshot.docs
          .map((doc) => _firestoreDocToUser(doc))
          .where((user) => user.uid != currentUserId)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Future<List<User>> searchUsers(String query, String currentUserId) async {
    try {
      if (query.isEmpty) {
        return getAllUsers(currentUserId);
      }

      final lowerQuery = query.toLowerCase();
      final snapshot = await _firestore.collection('users').get();

      final allUsers = snapshot.docs
          .map((doc) => _firestoreDocToUser(doc))
          .where((user) => user.uid != currentUserId)
          .toList();

      // Filter users by search query
      return allUsers.where((user) {
        return user.displayName.toLowerCase().contains(lowerQuery) ||
            user.email.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return _firestoreDocToUser(doc);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }
}

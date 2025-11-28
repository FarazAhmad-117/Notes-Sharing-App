import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/user_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  /// Convert Firebase User to app User model
  Future<User?> _firebaseUserToAppUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    // Get user data from Firestore
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    final userData = userDoc.data();

    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName:
          userData?['displayName'] as String? ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@')[0] ??
          'User',
      photoUrl: userData?['photoUrl'] as String? ?? firebaseUser.photoURL,
      fcmToken: userData?['fcmToken'] as String?,
      isEmailVerified: firebaseUser.emailVerified,
      theme: userData?['theme'] as String? ?? 'light',
      language: userData?['language'] as String? ?? 'en',
      createdAt: userData?['createdAt'] != null
          ? (userData!['createdAt'] as firestore.Timestamp).toDate()
          : firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: userData?['updatedAt'] != null
          ? (userData!['updatedAt'] as firestore.Timestamp).toDate()
          : DateTime.now(),
      lastSeen: userData?['lastSeen'] != null
          ? (userData!['lastSeen'] as firestore.Timestamp).toDate()
          : null,
    );
  }

  /// Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'fcmToken': user.fcmToken,
      'isEmailVerified': user.isEmailVerified,
      'theme': user.theme,
      'language': user.language,
      'createdAt': firestore.Timestamp.fromDate(user.createdAt),
      'updatedAt': firestore.Timestamp.fromDate(user.updatedAt),
      'lastSeen': user.lastSeen != null
          ? firestore.Timestamp.fromDate(user.lastSeen!)
          : null,
    }, firestore.SetOptions(merge: true));
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed: User is null');
      }

      // Update last seen
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastSeen': firestore.Timestamp.now(),
      });

      return await _firebaseUserToAppUser(credential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> signup(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Signup failed: User is null');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final now = DateTime.now();
      final user = User(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        isEmailVerified: false,
        createdAt: now,
        updatedAt: now,
      );

      await _createOrUpdateUserDocument(user);

      // Send email verification
      await credential.user!.sendEmailVerification();

      return await _firebaseUserToAppUser(credential.user) ?? user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update last seen before logout
        await _firestore.collection('users').doc(currentUser.uid).update({
          'lastSeen': firestore.Timestamp.now(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      return await _firebaseUserToAppUser(firebaseUser);
    } catch (e) {
      throw Exception('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Send password reset email failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified');
      }

      await user.sendEmailVerification();

      // Reload user to get updated email verification status
      await user.reload();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Send email verification failed: ${e.toString()}');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      if (currentUser.email == null) {
        throw Exception('User email is not available');
      }

      // Re-authenticate the user with their password before deletion
      // This is required by Firebase for security-sensitive operations
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Delete user document from Firestore first
      try {
        await _firestore.collection('users').doc(currentUser.uid).delete();
      } catch (e) {
        // Log but don't fail if Firestore delete fails
        // The user might not have a document yet
      }

      // Delete the Firebase Auth account
      await currentUser.delete();

      // Sign out after deletion
      await _auth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Delete account failed: ${e.toString()}');
    }
  }

  /// Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Update FCM token for user
  Future<void> updateFcmToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'updatedAt': firestore.Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }
}

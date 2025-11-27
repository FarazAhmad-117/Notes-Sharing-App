import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _initializationFailed = false;

  /// Initialize Firebase
  static Future<void> initialize() async {
    if (_initialized) return;
    if (_initializationFailed) {
      throw Exception('Firebase initialization previously failed');
    }

    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Enable Firestore persistence
      firestore.FirebaseFirestore.instance.settings = const firestore.Settings(
        persistenceEnabled: true,
        cacheSizeBytes: firestore.Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
    } catch (e) {
      _initializationFailed = true;
      // If firebase_options.dart doesn't exist, provide helpful error
      if (e.toString().contains('firebase_options')) {
        throw Exception(
          'Firebase not configured. Please run: flutterfire configure',
        );
      }
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized {
    // Check both our flag and if Firebase apps actually exist
    try {
      if (_initialized) {
        // Double-check that Firebase apps exist
        return Firebase.apps.isNotEmpty;
      }
      // Even if our flag is false, check if Firebase was initialized elsewhere
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      // If we can't check Firebase.apps, assume not initialized
      return false;
    }
  }
}

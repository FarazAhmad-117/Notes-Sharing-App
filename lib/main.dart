import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - this must complete before the app runs
  try {
    AppLogger.info('Initializing Firebase...');
    await FirebaseService.initialize();
    AppLogger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    // Log the error but don't crash the app
    AppLogger.error('Firebase initialization failed', e, stackTrace);
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please run: flutterfire configure to set up Firebase');
    // Continue anyway - the app will use DummyAuthRepository if Firebase fails
  }

  runApp(const ProviderScope(child: App()));
}

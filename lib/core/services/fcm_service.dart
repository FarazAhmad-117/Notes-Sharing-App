import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/logger.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request notification permissions and get FCM token
  static Future<String?> getToken() async {
    try {
      AppLogger.info('Requesting FCM token...');
      
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        AppLogger.info('Notification permission granted');
        
        // Get FCM token
        final token = await _messaging.getToken();
        AppLogger.info('FCM token retrieved: ${token?.substring(0, 20)}...');
        return token;
      } else {
        AppLogger.warning('Notification permission denied');
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get FCM token', e, stackTrace);
      return null;
    }
  }

  /// Refresh FCM token
  static Future<String?> refreshToken() async {
    try {
      AppLogger.info('Refreshing FCM token...');
      final token = await _messaging.getToken();
      AppLogger.info('FCM token refreshed');
      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to refresh FCM token', e, stackTrace);
      return null;
    }
  }

  /// Listen for token refresh
  static void onTokenRefresh(Function(String) onTokenRefreshed) {
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM token refreshed: ${newToken.substring(0, 20)}...');
      onTokenRefreshed(newToken);
    });
  }

  /// Initialize FCM and set up message handlers
  static Future<void> initialize() async {
    try {
      AppLogger.info('Initializing FCM...');
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.info('Foreground message received: ${message.notification?.title}');
        // Handle foreground notification here
      });

      // Handle background messages (when app is terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.info('Notification opened app: ${message.notification?.title}');
        // Handle notification tap here
      });

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info('App opened from notification: ${initialMessage.notification?.title}');
        // Handle initial notification here
      }

      AppLogger.info('FCM initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize FCM', e, stackTrace);
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message here
  AppLogger.info('Background message received: ${message.notification?.title}');
}

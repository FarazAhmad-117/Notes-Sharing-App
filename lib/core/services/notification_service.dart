import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/logger.dart';

class NotificationService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  /// Send push notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) {
      AppLogger.warning('No FCM tokens provided for notification');
      return;
    }

    try {
      AppLogger.info('Sending notification to ${fcmTokens.length} users');

      // For each token, send a notification
      // Note: In production, you might want to use Firebase Cloud Functions
      // or a backend service to send notifications
      for (final token in fcmTokens) {
        if (token.isNotEmpty) {
          await _sendFcmNotification(
            fcmToken: token,
            title: title,
            body: body,
            data: data,
          );
        }
      }

      AppLogger.info('Notifications sent successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send notifications', e, stackTrace);
      // Don't rethrow - notifications are not critical
    }
  }

  /// Send FCM notification using Firebase Cloud Messaging HTTP API
  Future<void> _sendFcmNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Note: This requires a server key from Firebase Console
      // For production, use Firebase Cloud Functions instead
      // This is a placeholder implementation

      const serverKey = 'YOUR_FIREBASE_SERVER_KEY'; // Get from Firebase Console
      if (serverKey == 'YOUR_FIREBASE_SERVER_KEY') {
        AppLogger.warning(
          'Firebase server key not configured. Skipping notification.',
        );
        return;
      }

      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final payload = {
        'to': fcmToken,
        'notification': {'title': title, 'body': body},
        'data': data ?? {},
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        AppLogger.info(
          'Notification sent to token: ${fcmToken.substring(0, 20)}...',
        );
      } else {
        AppLogger.error('Failed to send notification: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error sending FCM notification', e, stackTrace);
    }
  }

  /// Get FCM tokens for multiple users
  Future<List<String>> getFcmTokensForUsers(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final tokens = <String>[];
      for (final userId in userIds) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final fcmToken = userDoc.data()?['fcmToken'] as String?;
          if (fcmToken != null && fcmToken.isNotEmpty) {
            tokens.add(fcmToken);
          }
        }
      }
      return tokens;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get FCM tokens', e, stackTrace);
      return [];
    }
  }
}

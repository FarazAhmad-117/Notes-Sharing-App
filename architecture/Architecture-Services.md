# ⚙️ Notes Sharing App - Services Architecture

> **Cloudinary integration, PDF generation, messaging, and notification services**

---

## 📑 Table of Contents

1. [Services Overview](#services-overview)
2. [Cloudinary Service](#cloudinary-service)
3. [PDF Service](#pdf-service)
4. [Messaging Service](#messaging-service)
5. [Notification Service](#notification-service)
6. [Firebase Service](#firebase-service)
7. [Service Best Practices](#service-best-practices)

---

## 🎯 Services Overview

### Service Architecture

Services are **singleton providers** that handle:

- External API integrations (Cloudinary)
- Complex operations (PDF generation)
- Real-time features (messaging, notifications)
- Firebase initialization

### Service Location

All services are in `services/` directory:

```
services/
├── firebase_service.dart
├── cloudinary_service.dart
├── pdf_service.dart
├── notification_service.dart
└── analytics_service.dart
```

---

## ☁️ Cloudinary Service

### Purpose

Handle image and file uploads to Cloudinary:

- User profile images
- Note images
- PDF files
- Attachments

### Setup

**Dependencies:**

```yaml
dependencies:
  cloudinary_flutter: ^1.0.0
  http: ^1.2.0
```

**Cloudinary Configuration:**

```dart
// core/constants/cloudinary_constants.dart
class CloudinaryConstants {
  static const String cloudName = 'your-cloud-name';
  static const String apiKey = 'your-api-key';
  static const String apiSecret = 'your-api-secret';
  static const String uploadPreset = 'your-upload-preset';
}
```

### Service Implementation

```dart
// services/cloudinary_service.dart

import 'package:cloudinary_flutter/cloudinary_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

class CloudinaryService {
  late final Cloudinary _cloudinary;

  CloudinaryService() {
    _cloudinary = Cloudinary(
      CloudinaryConstants.cloudName,
      apiKey: CloudinaryConstants.apiKey,
      apiSecret: CloudinaryConstants.apiSecret,
    );
  }

  // Upload image
  Future<String> uploadImage(File imageFile, {String? folder}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder ?? 'notes',
        ),
      );

      return response.secureUrl ?? response.url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    String? folder,
  }) async {
    final urls = <String>[];

    for (final file in imageFiles) {
      final url = await uploadImage(file, folder: folder);
      urls.add(url);
    }

    return urls;
  }

  // Upload PDF
  Future<String> uploadPdf(File pdfFile, {String? folder}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          pdfFile.path,
          resourceType: CloudinaryResourceType.Raw,
          folder: folder ?? 'pdfs',
        ),
      );

      return response.secureUrl ?? response.url;
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  // Upload file (generic)
  Future<String> uploadFile(File file, {String? folder}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Auto,
          folder: folder ?? 'files',
        ),
      );

      return response.secureUrl ?? response.url;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String publicId) async {
    try {
      await _cloudinary.deleteResource(
        publicId: publicId,
        resourceType: CloudinaryResourceType.Image,
      );
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get optimized image URL
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String? format,
  }) {
    // Cloudinary URL transformation
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) return originalUrl;

    final transformations = <String>[];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (format != null) transformations.add('f_$format');
    transformations.add('q_auto'); // Auto quality

    final transformString = transformations.join(',');
    final newPath = '/${pathSegments[0]}/image/upload/$transformString/${pathSegments.sublist(1).join('/')}';

    return '${uri.scheme}://${uri.host}$newPath${uri.query.isNotEmpty ? '?${uri.query}' : ''}';
  }
}
```

### Usage

```dart
// In a provider or widget
final cloudinaryService = ref.read(cloudinaryServiceProvider);

// Upload image
final imageFile = File('path/to/image.jpg');
final imageUrl = await cloudinaryService.uploadImage(imageFile);

// Upload multiple images
final imageFiles = [File('path1.jpg'), File('path2.jpg')];
final imageUrls = await cloudinaryService.uploadImages(imageFiles);

// Upload PDF
final pdfFile = File('path/to/document.pdf');
final pdfUrl = await cloudinaryService.uploadPdf(pdfFile);

// Get optimized URL
final optimizedUrl = cloudinaryService.getOptimizedImageUrl(
  originalUrl,
  width: 800,
  height: 600,
);
```

---

## 📄 PDF Service

### Purpose

Generate PDFs from:

- Text content
- Images
- Combination of text and images

### Setup

**Dependencies:**

```yaml
dependencies:
  pdf: ^3.11.1
  printing: ^5.13.3
  path_provider: ^2.1.2
  image: ^4.2.0
```

### Service Implementation

```dart
// services/pdf_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

class PdfService {
  // Generate PDF from text
  Future<File> generateFromText(
    String text, {
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          if (title != null)
            pw.Header(
              level: 0,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          pw.SizedBox(height: 20),
          pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    return await _savePdf(pdf, title ?? 'document');
  }

  // Generate PDF from images
  Future<File> generateFromImages(
    List<String> imageUrls, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    for (final imageUrl in imageUrls) {
      final image = await _loadImage(imageUrl);
      if (image != null) {
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (context) => pw.Center(
              child: pw.Image(image),
            ),
          ),
        );
      }
    }

    return await _savePdf(pdf, 'images');
  }

  // Generate PDF from text and images
  Future<File> generateFromTextAndImages({
    String? text,
    List<String>? imageUrls,
    String? title,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) {
          final widgets = <pw.Widget>[];

          if (title != null) {
            widgets.add(
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          if (text != null && text.isNotEmpty) {
            widgets.add(
              pw.Text(
                text,
                style: const pw.TextStyle(fontSize: 12),
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          if (imageUrls != null && imageUrls.isNotEmpty) {
            for (final imageUrl in imageUrls) {
              final image = await _loadImage(imageUrl);
              if (image != null) {
                widgets.add(pw.Image(image));
                widgets.add(pw.SizedBox(height: 20));
              }
            }
          }

          return widgets;
        },
      ),
    );

    return await _savePdf(pdf, title ?? 'document');
  }

  // Preview PDF
  Future<void> previewPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }

  // Share PDF
  Future<void> sharePdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.sharePdf(
      bytes: bytes,
      filename: pdfFile.path.split('/').last,
    );
  }

  // Save PDF to device
  Future<File> _savePdf(pw.Document pdf, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Load image from URL
  Future<pw.MemoryImage?> _loadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final image = img.decodeImage(imageBytes);
        if (image != null) {
          return pw.MemoryImage(imageBytes);
        }
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }
}
```

### Usage

```dart
// In a provider
final pdfService = ref.read(pdfServiceProvider);

// Generate from text
final pdfFile = await pdfService.generateFromText(
  'This is my note content',
  title: 'My Note',
);

// Generate from images
final imageUrls = ['https://...', 'https://...'];
final pdfFile = await pdfService.generateFromImages(imageUrls);

// Preview PDF
await pdfService.previewPdf(pdfFile);

// Share PDF
await pdfService.sharePdf(pdfFile);
```

---

## 💬 Messaging Service

### Purpose

Handle real-time messaging between users:

- Send messages
- Receive messages
- Mark as read
- Get conversations

### Service Implementation

```dart
// services/messaging_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/messaging/data/models/message_model.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send message
  Future<Message> sendMessage({
    required String receiverId,
    required String text,
    String? noteId,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) throw Exception('User not authenticated');

    final message = Message(
      id: '', // Will be set by Firestore
      noteId: noteId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore.collection('messages').add(
      message.toFirestore(),
    );

    return message.copyWith(id: docRef.id);
  }

  // Watch messages for a conversation
  Stream<List<Message>> watchMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [currentUserId, otherUserId])
        .where('receiverId', whereIn: [currentUserId, otherUserId])
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark all messages as read
  Future<void> markAllAsRead(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final messages = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // Get unread count
  Stream<int> watchUnreadCount() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value(0);

    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
```

---

## 🔔 Notification Service

### Purpose

Handle push notifications and in-app notifications:

- Send FCM notifications
- Handle notification taps
- Manage notification state

### Service Implementation

```dart
// services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/notifications/data/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize
  Future<void> initialize() async {
    // Request permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Setup local notifications
      await _setupLocalNotifications();

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  // Setup local notifications
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Save FCM token
  Future<void> _saveFcmToken(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  // Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'notes_channel',
      'Notes Notifications',
      channelDescription: 'Notifications for notes sharing app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    // Navigate based on notification type
    // This should be handled by the router
  }

  // On notification tapped (local)
  void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    String? actionUrl,
  }) async {
    // Get user's FCM token
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final fcmToken = userDoc.data()?['fcmToken'] as String?;

    if (fcmToken == null) return;

    // Send via FCM (requires backend or Cloud Functions)
    // For now, create in-app notification
    await _createInAppNotification(
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      actionUrl: actionUrl,
    );
  }

  // Create in-app notification
  Future<void> _createInAppNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    String? actionUrl,
  }) async {
    final notification = AppNotification(
      id: '', // Will be set by Firestore
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      actionUrl: actionUrl,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .add(notification.toFirestore());
  }
}
```

---

## 🔥 Firebase Service

### Purpose

Initialize and configure Firebase services

### Service Implementation

```dart
// services/firebase_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_firestore/firebase_firestore.dart';
import 'firebase_options.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class FirebaseService {
  // Initialize Firebase
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore persistence
    await FirebaseFirestore.instance.enablePersistence();

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
```

---

## ✅ Service Best Practices

### 1. Singleton Pattern

Use Riverpod providers for singletons:

```dart
final serviceProvider = Provider<Service>((ref) {
  return Service();
});
```

### 2. Error Handling

Always handle errors in services:

```dart
try {
  // Service operation
} catch (e) {
  throw Exception('Service error: $e');
}
```

### 3. Async Operations

Use `Future` for async operations:

```dart
Future<String> uploadFile(File file) async {
  // Async operation
}
```

### 4. Stream Operations

Use `Stream` for real-time data:

```dart
Stream<List<Message>> watchMessages() {
  // Stream operation
}
```

### 5. Dependency Injection

Inject dependencies via constructor:

```dart
class Service {
  final FirebaseFirestore firestore;

  Service(this.firestore);
}
```

---

This services architecture ensures:

- ✅ Clean separation of concerns
- ✅ Reusable services
- ✅ Easy testing
- ✅ Maintainable code

Follow these patterns for all services! ⚙️

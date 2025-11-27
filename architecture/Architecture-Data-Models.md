# 📊 Notes Sharing App - Data Models

> **Complete data models using Freezed for immutability and JSON serialization**

---

## 📑 Table of Contents

1. [Model Architecture](#model-architecture)
2. [User Model](#user-model)
3. [Note Model](#note-model)
4. [Shared Note Model](#shared-note-model)
5. [Message Model](#message-model)
6. [Notification Model](#notification-model)
7. [Dashboard Stats Model](#dashboard-stats-model)
8. [Model Best Practices](#model-best-practices)

---

## 🎯 Model Architecture

### Why Freezed?

✅ **Immutability** - Models are immutable by default  
✅ **copyWith** - Easy to create modified copies  
✅ **Value equality** - Automatic equality comparison  
✅ **JSON serialization** - Auto-generated from/to JSON  
✅ **Union types** - Support for sealed classes  
✅ **Pattern matching** - Exhaustive switch expressions

### Dependencies

```yaml
dependencies:
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.14
  freezed: ^2.5.7
  json_serializable: ^6.9.2
```

---

## 👤 User Model

```dart
// features/auth/data/models/user_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String? fcmToken,
    @Default(false) bool isEmailVerified,
    @Default('light') String theme,
    @Default('en') String language,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastSeen,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Firestore Conversion

```dart
extension UserFirestore on User {
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'isEmailVerified': isEmailVerified,
      'theme': theme,
      'language': language,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
      fcmToken: data['fcmToken'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      theme: data['theme'] as String? ?? 'light',
      language: data['language'] as String? ?? 'en',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }
}
```

---

## 📝 Note Model

```dart
// features/notes/data/models/note_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String userId,
    required String title,
    required String content,
    String? category,
    @Default([]) List<String> tags,
    @Default([]) List<String> images,
    @Default([]) List<String> attachments,
    @Default(false) bool isPinned,
    String? color,
    @Default(false) bool isArchived,
    String? pdfUrl,
    @Default(false) bool hasPdf,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastAccessedAt,
    @Default(false) bool isShared,
    @Default(0) int sharedWithCount,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
```

### Firestore Conversion

```dart
extension NoteFirestore on Note {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'images': images,
      'attachments': attachments,
      'isPinned': isPinned,
      'color': color,
      'isArchived': isArchived,
      'pdfUrl': pdfUrl,
      'hasPdf': hasPdf,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastAccessedAt': lastAccessedAt != null
          ? Timestamp.fromDate(lastAccessedAt!)
          : null,
      'isShared': isShared,
      'sharedWithCount': sharedWithCount,
    };
  }

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      category: data['category'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      images: List<String>.from(data['images'] as List? ?? []),
      attachments: List<String>.from(data['attachments'] as List? ?? []),
      isPinned: data['isPinned'] as bool? ?? false,
      color: data['color'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      pdfUrl: data['pdfUrl'] as String?,
      hasPdf: data['hasPdf'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastAccessedAt: data['lastAccessedAt'] != null
          ? (data['lastAccessedAt'] as Timestamp).toDate()
          : null,
      isShared: data['isShared'] as bool? ?? false,
      sharedWithCount: data['sharedWithCount'] as int? ?? 0,
    );
  }
}
```

---

## 🔗 Shared Note Model

```dart
// features/sharing/data/models/shared_note_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shared_note_model.freezed.dart';
part 'shared_note_model.g.dart';

enum SharePermission {
  view,
  edit,
}

@freezed
class SharedNote with _$SharedNote {
  const factory SharedNote({
    required String id,
    required String noteId,
    required String ownerId,
    required String sharedWithId,
    required SharePermission permission,
    required String noteTitle,
    required String noteContent,
    required String ownerName,
    required String ownerEmail,
    @Default(false) bool isAccepted,
    @Default(true) bool isActive,
    required DateTime sharedAt,
    DateTime? acceptedAt,
    DateTime? lastAccessedAt,
  }) = _SharedNote;

  factory SharedNote.fromJson(Map<String, dynamic> json) =>
      _$SharedNoteFromJson(json);
}
```

### Firestore Conversion

```dart
extension SharedNoteFirestore on SharedNote {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'noteId': noteId,
      'ownerId': ownerId,
      'sharedWithId': sharedWithId,
      'permission': permission.name, // 'view' or 'edit'
      'noteTitle': noteTitle,
      'noteContent': noteContent,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'isAccepted': isAccepted,
      'isActive': isActive,
      'sharedAt': Timestamp.fromDate(sharedAt),
      'acceptedAt': acceptedAt != null
          ? Timestamp.fromDate(acceptedAt!)
          : null,
      'lastAccessedAt': lastAccessedAt != null
          ? Timestamp.fromDate(lastAccessedAt!)
          : null,
    };
  }

  factory SharedNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedNote(
      id: doc.id,
      noteId: data['noteId'] as String,
      ownerId: data['ownerId'] as String,
      sharedWithId: data['sharedWithId'] as String,
      permission: SharePermission.values.firstWhere(
        (e) => e.name == data['permission'],
        orElse: () => SharePermission.view,
      ),
      noteTitle: data['noteTitle'] as String,
      noteContent: data['noteContent'] as String,
      ownerName: data['ownerName'] as String,
      ownerEmail: data['ownerEmail'] as String,
      isAccepted: data['isAccepted'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      sharedAt: (data['sharedAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      lastAccessedAt: data['lastAccessedAt'] != null
          ? (data['lastAccessedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
```

---

## 💬 Message Model

```dart
// features/messaging/data/models/message_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType {
  text,
  image,
  file,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    String? noteId,
    required String senderId,
    required String receiverId,
    required String text,
    @Default(MessageType.text) MessageType type,
    String? mediaUrl,
    @Default(false) bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
```

### Firestore Conversion

```dart
extension MessageFirestore on Message {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'noteId': noteId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      noteId: data['noteId'] as String?,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      text: data['text'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      mediaUrl: data['mediaUrl'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

### Conversation Model

```dart
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String userId,
    required String otherUserId,
    required String otherUserName,
    String? otherUserPhotoUrl,
    required String lastMessage,
    required DateTime lastMessageAt,
    @Default(0) int unreadCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
```

---

## 🔔 Notification Model

```dart
// features/notifications/data/models/notification_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  noteShared,
  noteUpdated,
  messageReceived,
  pdfGenerated,
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    String? relatedType,
    @Default(false) bool isRead,
    DateTime? readAt,
    String? actionUrl,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
```

### Firestore Conversion

```dart
extension NotificationFirestore on AppNotification {
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionUrl': actionUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      body: data['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.noteShared,
      ),
      relatedId: data['relatedId'] as String?,
      relatedType: data['relatedType'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      actionUrl: data['actionUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

---

## 📊 Dashboard Stats Model

```dart
// features/home/data/models/dashboard_stats.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int totalNotes,
    @Default(0) int sharedNotes,
    @Default(0) int recentUpdates,
    @Default(0) int unreadMessages,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
```

---

## 🎯 Model Best Practices

### 1. Use Freezed for All Models

```dart
// ✅ Good
@freezed
class Note with _$Note {
  const factory Note({...}) = _Note;
  factory Note.fromJson(...) => _$NoteFromJson(...);
}

// ❌ Bad
class Note {
  final String id;
  Note({required this.id});
}
```

### 2. Default Values

Use `@Default()` for optional fields with defaults:

```dart
@Default([]) List<String> tags,
@Default(false) bool isPinned,
```

### 3. Nullable vs Non-nullable

- Use nullable (`String?`) when field might not exist
- Use non-nullable (`String`) when field is required
- Use `@Default()` for optional fields with defaults

### 4. Enums for Type Safety

```dart
enum SharePermission { view, edit }
enum MessageType { text, image, file }
enum NotificationType { noteShared, noteUpdated, ... }
```

### 5. Firestore Extensions

Create extension methods for Firestore conversion:

```dart
extension NoteFirestore on Note {
  Map<String, dynamic> toFirestore() { ... }
  factory Note.fromFirestore(DocumentSnapshot doc) { ... }
}
```

### 6. Timestamp Handling

Always convert Firestore Timestamps to DateTime:

```dart
createdAt: (data['createdAt'] as Timestamp).toDate(),
```

### 7. List Handling

Handle nullable lists safely:

```dart
tags: List<String>.from(data['tags'] as List? ?? []),
```

### 8. Model Validation

Add validation methods if needed:

```dart
extension NoteValidation on Note {
  bool get isValid => title.isNotEmpty;

  String? validate() {
    if (title.isEmpty) return 'Title is required';
    if (content.isEmpty) return 'Content is required';
    return null;
  }
}
```

---

## 🔧 Code Generation

### Running Code Generation

```bash
# Generate Freezed and JSON code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch
```

### Generated Files

- `*.freezed.dart` - Freezed implementation
- `*.g.dart` - JSON serialization

### Import Generated Code

```dart
part 'note_model.freezed.dart';
part 'note_model.g.dart';
```

---

## 📝 Model Usage Examples

### Creating a Note

```dart
final note = Note(
  id: 'note123',
  userId: 'user456',
  title: 'My Note',
  content: 'Note content',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Updating a Note

```dart
final updatedNote = note.copyWith(
  title: 'Updated Title',
  updatedAt: DateTime.now(),
);
```

### Converting to Firestore

```dart
final firestoreData = note.toFirestore();
await firestore.collection('notes').doc(note.id).set(firestoreData);
```

### Converting from Firestore

```dart
final doc = await firestore.collection('notes').doc('note123').get();
final note = Note.fromFirestore(doc);
```

### JSON Serialization

```dart
// To JSON
final json = note.toJson();

// From JSON
final note = Note.fromJson(json);
```

---

## ✅ Model Checklist

For each model:

- [ ] Uses `@freezed` annotation
- [ ] Has `fromJson` factory
- [ ] Has Firestore extension methods
- [ ] Uses appropriate types (nullable/non-nullable)
- [ ] Has default values where needed
- [ ] Uses enums for type safety
- [ ] Handles Timestamps correctly
- [ ] Handles lists safely
- [ ] Code generation runs successfully

---

This data model architecture ensures:

- ✅ Type safety
- ✅ Immutability
- ✅ Easy serialization
- ✅ Firestore compatibility
- ✅ Maintainability

Follow these patterns for all data models! 📊

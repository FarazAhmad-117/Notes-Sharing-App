import '../models/message_model.dart';
import '../models/conversation_model.dart';

// Abstract repository - will be implemented with Firebase later
abstract class MessagingRepository {
  Future<List<Conversation>> getConversations(String userId);
  Future<List<Message>> getMessages(String userId, String otherUserId);
  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? noteId,
  });
  Future<void> markMessagesAsRead(String userId, String otherUserId);
}

// Dummy implementation for UI development
class DummyMessagingRepository implements MessagingRepository {
  final Map<String, List<Message>> _messagesByUser = {};

  void _initializeDummyDataForUser(String currentUserId) {
    if (_messagesByUser.containsKey(currentUserId)) {
      return; // Already initialized
    }

    final now = DateTime.now();
    final List<Message> messages = [];

    // Conversation 1: Alice
    messages.addAll([
      Message(
        id: 'msg_1',
        senderId: 'user_1',
        receiverId: currentUserId,
        text: 'Hi! How are you?',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg_2',
        senderId: currentUserId,
        receiverId: 'user_1',
        text: 'I am doing great, thanks!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 50)),
      ),
      Message(
        id: 'msg_3',
        senderId: 'user_1',
        receiverId: currentUserId,
        text: 'That\'s wonderful to hear!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
    ]);

    // Conversation 2: Bob
    messages.addAll([
      Message(
        id: 'msg_4',
        senderId: currentUserId,
        receiverId: 'user_2',
        text: 'Hey Bob, can you review my notes?',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      Message(
        id: 'msg_5',
        senderId: 'user_2',
        receiverId: currentUserId,
        text: 'Sure, I\'ll take a look!',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);

    // Conversation 3: Charlie
    messages.addAll([
      Message(
        id: 'msg_6',
        senderId: 'user_3',
        receiverId: currentUserId,
        text: 'Hello there!',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    _messagesByUser[currentUserId] = messages;
  }

  List<Message> _getMessagesForUser(String userId) {
    _initializeDummyDataForUser(userId);
    return _messagesByUser[userId] ?? [];
  }

  @override
  Future<List<Conversation>> getConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final messages = _getMessagesForUser(userId);

    // Group messages by other user
    final Map<String, List<Message>> conversationsMap = {};

    for (final message in messages) {
      String? otherUserId;
      if (message.senderId == userId) {
        otherUserId = message.receiverId;
      } else if (message.receiverId == userId) {
        otherUserId = message.senderId;
      }

      if (otherUserId != null) {
        conversationsMap.putIfAbsent(otherUserId, () => []).add(message);
      }
    }

    final List<Conversation> conversations = [];

    // Create conversation for each user
    conversationsMap.forEach((otherUserId, messages) {
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastMessage = messages.first;

      // Get other user name (dummy data)
      String otherUserName;
      switch (otherUserId) {
        case 'user_1':
          otherUserName = 'Alice Johnson';
          break;
        case 'user_2':
          otherUserName = 'Bob Smith';
          break;
        case 'user_3':
          otherUserName = 'Charlie Brown';
          break;
        case 'user_4':
          otherUserName = 'Diana Prince';
          break;
        case 'user_5':
          otherUserName = 'Eve Williams';
          break;
        default:
          otherUserName = 'Unknown User';
      }

      // Count unread messages
      final unreadCount = messages
          .where((m) => m.receiverId == userId && !m.isRead)
          .length;

      conversations.add(
        Conversation(
          id: 'conv_$otherUserId',
          userId: userId,
          otherUserId: otherUserId,
          otherUserName: otherUserName,
          lastMessage: lastMessage.text,
          lastMessageAt: lastMessage.createdAt,
          unreadCount: unreadCount,
        ),
      );
    });

    // Sort by last message time
    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return conversations;
  }

  @override
  Future<List<Message>> getMessages(String userId, String otherUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final messages = _getMessagesForUser(userId);
    return messages.where((message) {
      return (message.senderId == userId &&
              message.receiverId == otherUserId) ||
          (message.senderId == otherUserId && message.receiverId == userId);
    }).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? noteId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      noteId: noteId,
      createdAt: DateTime.now(),
    );

    final messages = _getMessagesForUser(senderId);
    messages.add(message);

    // Bot auto-reply
    await Future.delayed(const Duration(milliseconds: 500));
    final botMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
      senderId: receiverId,
      receiverId: senderId,
      text: "You said '$text'",
      createdAt: DateTime.now(),
    );

    messages.add(botMessage);

    return message;
  }

  @override
  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final messages = _getMessagesForUser(userId);
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].receiverId == userId &&
          messages[i].senderId == otherUserId &&
          !messages[i].isRead) {
        messages[i] = messages[i].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }
}

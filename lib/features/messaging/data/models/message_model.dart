enum MessageType { text, image, file }

class Message {
  final String id;
  final String? noteId;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    this.noteId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.type = MessageType.text,
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? noteId,
    String? senderId,
    String? receiverId,
    String? text,
    MessageType? type,
    String? mediaUrl,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

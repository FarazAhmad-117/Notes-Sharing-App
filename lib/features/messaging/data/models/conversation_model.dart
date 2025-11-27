class Conversation {
  final String id;
  final String userId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.userId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  Conversation copyWith({
    String? id,
    String? userId,
    String? otherUserId,
    String? otherUserName,
    String? otherUserPhotoUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

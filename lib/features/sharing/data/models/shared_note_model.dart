enum SharePermission { view, edit }

class SharedNote {
  final String id;
  final String noteId;
  final String ownerId;
  final String sharedWithId;
  final SharePermission permission;
  final String noteTitle;
  final String noteContent;
  final String ownerName;
  final String ownerEmail;
  final bool isAccepted;
  final bool isActive;
  final DateTime sharedAt;
  final DateTime? acceptedAt;
  final DateTime? lastAccessedAt;

  const SharedNote({
    required this.id,
    required this.noteId,
    required this.ownerId,
    required this.sharedWithId,
    required this.permission,
    required this.noteTitle,
    required this.noteContent,
    required this.ownerName,
    required this.ownerEmail,
    this.isAccepted = false,
    this.isActive = true,
    required this.sharedAt,
    this.acceptedAt,
    this.lastAccessedAt,
  });

  SharedNote copyWith({
    String? id,
    String? noteId,
    String? ownerId,
    String? sharedWithId,
    SharePermission? permission,
    String? noteTitle,
    String? noteContent,
    String? ownerName,
    String? ownerEmail,
    bool? isAccepted,
    bool? isActive,
    DateTime? sharedAt,
    DateTime? acceptedAt,
    DateTime? lastAccessedAt,
  }) {
    return SharedNote(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      ownerId: ownerId ?? this.ownerId,
      sharedWithId: sharedWithId ?? this.sharedWithId,
      permission: permission ?? this.permission,
      noteTitle: noteTitle ?? this.noteTitle,
      noteContent: noteContent ?? this.noteContent,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      isAccepted: isAccepted ?? this.isAccepted,
      isActive: isActive ?? this.isActive,
      sharedAt: sharedAt ?? this.sharedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}

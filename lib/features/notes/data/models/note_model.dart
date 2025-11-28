class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? category;
  final List<String> tags;
  final List<String> images;
  final List<String> attachments;
  final bool isPinned;
  final String? color;
  final bool isArchived;
  final String? pdfUrl;
  final bool hasPdf;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  final bool isShared;
  final int sharedWithCount;
  final List<String> sharedWith; // List of user IDs this note is shared with
  final String?
  sharedBy; // User ID who shared this note (if it's a shared note)

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    this.tags = const [],
    this.images = const [],
    this.attachments = const [],
    this.isPinned = false,
    this.color,
    this.isArchived = false,
    this.pdfUrl,
    this.hasPdf = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    this.isShared = false,
    this.sharedWithCount = 0,
    this.sharedWith = const [],
    this.sharedBy,
  });

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    List<String>? images,
    List<String>? attachments,
    bool? isPinned,
    String? color,
    bool? isArchived,
    String? pdfUrl,
    bool? hasPdf,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    bool? isShared,
    int? sharedWithCount,
    List<String>? sharedWith,
    String? sharedBy,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      attachments: attachments ?? this.attachments,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      hasPdf: hasPdf ?? this.hasPdf,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isShared: isShared ?? this.isShared,
      sharedWithCount: sharedWithCount ?? this.sharedWithCount,
      sharedWith: sharedWith ?? this.sharedWith,
      sharedBy: sharedBy ?? this.sharedBy,
    );
  }
}

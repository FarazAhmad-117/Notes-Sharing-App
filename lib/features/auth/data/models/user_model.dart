class User {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? fcmToken;
  final bool isEmailVerified;
  final String theme;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.fcmToken,
    this.isEmailVerified = false,
    this.theme = 'light',
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
  });

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    bool? isEmailVerified,
    String? theme,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}


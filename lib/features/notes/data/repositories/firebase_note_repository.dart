import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../../core/utils/logger.dart';
import '../models/note_model.dart';
import 'note_repository.dart';

class FirebaseNoteRepository implements NoteRepository {
  final firestore.FirebaseFirestore _firestore;

  FirebaseNoteRepository() : _firestore = firestore.FirebaseFirestore.instance;

  /// Convert Note to Firestore map
  Map<String, dynamic> _noteToFirestore(Note note) {
    return {
      'userId': note.userId,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'tags': note.tags,
      'images': note.images,
      'attachments': note.attachments,
      'isPinned': note.isPinned,
      'color': note.color,
      'isArchived': note.isArchived,
      'pdfUrl': note.pdfUrl,
      'hasPdf': note.hasPdf,
      'createdAt': firestore.Timestamp.fromDate(note.createdAt),
      'updatedAt': firestore.Timestamp.fromDate(note.updatedAt),
      'lastAccessedAt': note.lastAccessedAt != null
          ? firestore.Timestamp.fromDate(note.lastAccessedAt!)
          : null,
      'isShared': note.isShared,
      'sharedWithCount': note.sharedWithCount,
    };
  }

  /// Convert Firestore document to Note
  Note _firestoreToNote(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      category: data['category'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? []),
      images: List<String>.from(data['images'] as List? ?? []),
      attachments: List<String>.from(data['attachments'] as List? ?? []),
      isPinned: data['isPinned'] as bool? ?? false,
      color: data['color'] as String?,
      isArchived: data['isArchived'] as bool? ?? false,
      pdfUrl: data['pdfUrl'] as String?,
      hasPdf: data['hasPdf'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as firestore.Timestamp?)?.toDate() ??
          DateTime.now(),
      updatedAt:
          (data['updatedAt'] as firestore.Timestamp?)?.toDate() ??
          DateTime.now(),
      lastAccessedAt: (data['lastAccessedAt'] as firestore.Timestamp?)
          ?.toDate(),
      isShared: data['isShared'] as bool? ?? false,
      sharedWithCount: data['sharedWithCount'] as int? ?? 0,
    );
  }

  @override
  Future<List<Note>> getNotes(String userId) async {
    try {
      AppLogger.info('Fetching notes for user: $userId');
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .get();

      // Sort in memory to avoid Firestore index requirement
      final notes =
          snapshot.docs
              .map((doc) => _firestoreToNote(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      AppLogger.info('Retrieved ${notes.length} notes for user: $userId');
      return notes;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch notes', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Note> getNoteById(String noteId) async {
    try {
      AppLogger.info('Fetching note: $noteId');
      final doc = await _firestore.collection('notes').doc(noteId).get();

      if (!doc.exists) {
        throw Exception('Note not found');
      }

      final note = _firestoreToNote(doc.id, doc.data()!);

      // Update lastAccessedAt
      await _firestore.collection('notes').doc(noteId).update({
        'lastAccessedAt': firestore.Timestamp.now(),
      });

      AppLogger.info('Retrieved note: $noteId');
      return note.copyWith(lastAccessedAt: DateTime.now());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch note: $noteId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Note> createNote(Note note) async {
    try {
      AppLogger.info('Creating note: ${note.title}');

      final now = DateTime.now();
      final noteData = _noteToFirestore(
        note.copyWith(createdAt: now, updatedAt: now),
      );

      // Remove id from data (it will be the document ID)
      final docRef = _firestore.collection('notes').doc();
      await docRef.set(noteData);

      final createdNote = _firestoreToNote(docRef.id, noteData);
      AppLogger.info('Note created successfully: ${docRef.id}');
      return createdNote;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create note', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Note> updateNote(Note note) async {
    try {
      AppLogger.info('Updating note: ${note.id}');

      final noteData = _noteToFirestore(
        note.copyWith(updatedAt: DateTime.now()),
      );

      await _firestore.collection('notes').doc(note.id).update(noteData);

      final updatedNote = _firestoreToNote(note.id, noteData);
      AppLogger.info('Note updated successfully: ${note.id}');
      return updatedNote;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update note: ${note.id}', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    try {
      AppLogger.info('Deleting note: $noteId');
      await _firestore.collection('notes').doc(noteId).delete();
      AppLogger.info('Note deleted successfully: $noteId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete note: $noteId', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Note>> searchNotes(String userId, String query) async {
    try {
      AppLogger.info('Searching notes for user: $userId, query: $query');

      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .get();

      final lowerQuery = query.toLowerCase();
      final notes = snapshot.docs
          .map((doc) => _firestoreToNote(doc.id, doc.data()))
          .where((note) {
            final titleMatch = note.title.toLowerCase().contains(lowerQuery);
            final contentMatch = note.content.toLowerCase().contains(
              lowerQuery,
            );
            final tagMatch = note.tags.any(
              (tag) => tag.toLowerCase().contains(lowerQuery),
            );
            return titleMatch || contentMatch || tagMatch;
          })
          .toList();

      AppLogger.info('Found ${notes.length} notes matching query: $query');
      return notes;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to search notes', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Note>> getRecentNotes(String userId, {int limit = 5}) async {
    try {
      AppLogger.info('Fetching recent notes for user: $userId, limit: $limit');
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .get();

      // Sort in memory and take limit to avoid Firestore index requirement
      final notes =
          snapshot.docs
              .map((doc) => _firestoreToNote(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final limitedNotes = notes.take(limit).toList();

      AppLogger.info('Retrieved ${limitedNotes.length} recent notes');
      return limitedNotes;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch recent notes', e, stackTrace);
      rethrow;
    }
  }
}

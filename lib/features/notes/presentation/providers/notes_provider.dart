import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/repositories/firebase_note_repository.dart';
import '../../data/models/note_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/logger.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  // Check if Firebase is initialized before using FirebaseNoteRepository
  if (FirebaseService.isInitialized) {
    try {
      AppLogger.info('Using Firebase note repository');
      return FirebaseNoteRepository();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create FirebaseNoteRepository, falling back to DummyNoteRepository',
        e,
        stackTrace,
      );
      return DummyNoteRepository();
    }
  } else {
    AppLogger.warning(
      'Firebase not initialized, using DummyNoteRepository for testing',
    );
    return DummyNoteRepository();
  }
});

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.read(noteRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.getNotes(authState.user!.uid);
});

final noteDetailProvider = FutureProvider.family<Note, String>((
  ref,
  noteId,
) async {
  final repository = ref.read(noteRepositoryProvider);
  return repository.getNoteById(noteId);
});

final recentNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.read(noteRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) return [];
  return repository.getRecentNotes(authState.user!.uid, limit: 5);
});

// Provider for deleting a note
final deleteNoteProvider = FutureProvider.family<void, String>((
  ref,
  noteId,
) async {
  final repository = ref.read(noteRepositoryProvider);
  await repository.deleteNote(noteId);
  // Invalidate related providers
  ref.invalidate(notesProvider);
  ref.invalidate(recentNotesProvider);
  ref.invalidate(noteDetailProvider(noteId));
});

class NoteFormNotifier extends Notifier<NoteFormState> {
  @override
  NoteFormState build() => NoteFormState.initial();

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void addTag(String tag) {
    if (!state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
  }

  void setNoteType(NoteType type) {
    state = state.copyWith(noteType: type);
  }

  void setImageUrls(List<String> urls) {
    state = state.copyWith(imageUrls: urls);
  }

  void setFileUrl(String? url) {
    state = state.copyWith(fileUrl: url);
  }

  void setPdfUrl(String? url) {
    state = state.copyWith(pdfUrl: url);
  }

  String? _editingNoteId;

  void setEditingNoteId(String? noteId) {
    _editingNoteId = noteId;
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final repository = ref.read(noteRepositoryProvider);
      final authState = ref.read(authProvider);
      if (authState.user == null) throw Exception('User not authenticated');

      if (_editingNoteId != null) {
        // Update existing note
        final existingNote = await repository.getNoteById(_editingNoteId!);
        final updatedNote = existingNote.copyWith(
          title: state.title,
          content: state.content,
          category: state.category,
          tags: state.tags,
          images: state.imageUrls,
          attachments: state.fileUrl != null ? [state.fileUrl!] : [],
          pdfUrl: state.pdfUrl,
          hasPdf: state.pdfUrl != null,
          updatedAt: DateTime.now(),
        );
        await repository.updateNote(updatedNote);
        // Clear editing note ID after successful update
        _editingNoteId = null;
      } else {
        // Create new note
        final note = Note(
          id: '',
          userId: authState.user!.uid,
          title: state.title,
          content: state.content,
          category: state.category,
          tags: state.tags,
          images: state.imageUrls,
          attachments: state.fileUrl != null ? [state.fileUrl!] : [],
          pdfUrl: state.pdfUrl,
          hasPdf: state.pdfUrl != null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.createNote(note);
      }
      state = state.copyWith(isSaving: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void reset() {
    _editingNoteId = null;
    state = NoteFormState.initial();
  }
}

enum NoteType { text, file }

class NoteFormState {
  final String title;
  final String content;
  final String? category;
  final List<String> tags;
  final NoteType noteType;
  final List<String> imageUrls; // For PDF generation from images
  final String? fileUrl; // For uploaded files
  final String? pdfUrl; // For generated PDFs
  final bool isSaving;
  final bool isSuccess;
  final String? error;

  const NoteFormState({
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    this.noteType = NoteType.text,
    this.imageUrls = const [],
    this.fileUrl,
    this.pdfUrl,
    required this.isSaving,
    required this.isSuccess,
    this.error,
  });

  NoteFormState copyWith({
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    NoteType? noteType,
    List<String>? imageUrls,
    String? fileUrl,
    String? pdfUrl,
    bool? isSaving,
    bool? isSuccess,
    String? error,
  }) {
    return NoteFormState(
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      noteType: noteType ?? this.noteType,
      imageUrls: imageUrls ?? this.imageUrls,
      fileUrl: fileUrl ?? this.fileUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  factory NoteFormState.initial() => const NoteFormState(
    title: '',
    content: '',
    tags: [],
    noteType: NoteType.text,
    imageUrls: [],
    isSaving: false,
    isSuccess: false,
  );
}

final noteFormProvider = NotifierProvider<NoteFormNotifier, NoteFormState>(() {
  return NoteFormNotifier();
});

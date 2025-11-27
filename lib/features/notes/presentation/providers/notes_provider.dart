import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/note_repository.dart';
import '../../data/models/note_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return DummyNoteRepository();
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

  Future<void> save() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final repository = ref.read(noteRepositoryProvider);
      final authState = ref.read(authProvider);
      if (authState.user == null) throw Exception('User not authenticated');

      final note = Note(
        id: '',
        userId: authState.user!.uid,
        title: state.title,
        content: state.content,
        category: state.category,
        tags: state.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createNote(note);
      state = state.copyWith(isSaving: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  void reset() {
    state = NoteFormState.initial();
  }
}

class NoteFormState {
  final String title;
  final String content;
  final String? category;
  final List<String> tags;
  final bool isSaving;
  final bool isSuccess;
  final String? error;

  const NoteFormState({
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    required this.isSaving,
    required this.isSuccess,
    this.error,
  });

  NoteFormState copyWith({
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isSaving,
    bool? isSuccess,
    String? error,
  }) {
    return NoteFormState(
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  factory NoteFormState.initial() => const NoteFormState(
    title: '',
    content: '',
    tags: [],
    isSaving: false,
    isSuccess: false,
  );
}

final noteFormProvider = NotifierProvider<NoteFormNotifier, NoteFormState>(() {
  return NoteFormNotifier();
});

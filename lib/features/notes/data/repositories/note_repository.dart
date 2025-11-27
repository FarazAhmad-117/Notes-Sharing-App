import '../models/note_model.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes(String userId);
  Future<Note> getNoteById(String noteId);
  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(String noteId);
  Future<List<Note>> searchNotes(String userId, String query);
  Future<List<Note>> getRecentNotes(String userId, {int limit = 5});
}

class DummyNoteRepository implements NoteRepository {
  final List<Note> _notes = [
    Note(
      id: 'note_1',
      userId: 'user_123',
      title: 'Meeting Notes - Project Planning',
      content: '# Project Planning Meeting\n\n## Agenda\n- Discuss project timeline\n- Review requirements\n- Assign tasks\n\n## Action Items\n- [ ] Create wireframes\n- [ ] Setup development environment\n- [ ] Schedule follow-up meeting',
      category: 'work',
      tags: ['meeting', 'project', 'planning'],
      isPinned: true,
      color: '#6366F1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Note(
      id: 'note_2',
      userId: 'user_123',
      title: 'Shopping List',
      content: '- Milk\n- Bread\n- Eggs\n- Butter\n- Cheese\n- Vegetables',
      category: 'personal',
      tags: ['shopping', 'groceries'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Note(
      id: 'note_3',
      userId: 'user_123',
      title: 'Flutter Learning Resources',
      content: '## Best Resources for Flutter\n\n1. Official Flutter Documentation\n2. Flutter YouTube Channel\n3. DartPad for practice\n4. Flutter Community',
      category: 'learning',
      tags: ['flutter', 'programming', 'learning'],
      isPinned: false,
      color: '#10B981',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: 'note_4',
      userId: 'user_123',
      title: 'Recipe: Chocolate Cake',
      content: '## Ingredients\n- 2 cups flour\n- 1 cup sugar\n- 1/2 cup cocoa\n- 2 eggs\n\n## Instructions\n1. Mix dry ingredients\n2. Add eggs\n3. Bake at 350°F for 30 minutes',
      category: 'personal',
      tags: ['recipe', 'cooking', 'dessert'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Note(
      id: 'note_5',
      userId: 'user_123',
      title: 'Book Recommendations',
      content: '1. Clean Code by Robert Martin\n2. Design Patterns by Gang of Four\n3. The Pragmatic Programmer',
      category: 'learning',
      tags: ['books', 'reading'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Future<List<Note>> getNotes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _notes.where((note) => note.userId == userId && !note.isArchived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<Note> getNoteById(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final note = _notes.firstWhere(
      (note) => note.id == noteId,
      orElse: () => throw Exception('Note not found'),
    );
    return note.copyWith(
      lastAccessedAt: DateTime.now(),
    );
  }

  @override
  Future<Note> createNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newNote = note.copyWith(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.add(newNote);
    return newNote;
  }

  @override
  Future<Note> updateNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) throw Exception('Note not found');
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    _notes[index] = updatedNote;
    return updatedNote;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notes.removeWhere((note) => note.id == noteId);
  }

  @override
  Future<List<Note>> searchNotes(String userId, String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) {
      if (note.userId != userId || note.isArchived) return false;
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<Note>> getRecentNotes(String userId, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _notes
        .where((note) => note.userId == userId && !note.isArchived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt))
      ..take(limit);
  }
}


# 🔄 Notes Sharing App - State Management

> **Riverpod 2.x state management patterns, providers, and best practices**

---

## 📑 Table of Contents

1. [State Management Strategy](#state-management-strategy)
2. [Riverpod Setup](#riverpod-setup)
3. [Provider Types](#provider-types)
4. [Feature Providers](#feature-providers)
5. [Best Practices](#best-practices)
6. [Code Generation](#code-generation)

---

## 🎯 State Management Strategy

### Why Riverpod 2.x?

✅ **Compile-time safety** - Catches errors at compile time  
✅ **No context required** - Access providers anywhere  
✅ **Easy testing** - Mock providers easily  
✅ **Auto-dispose** - Prevents memory leaks  
✅ **Code generation** - Reduces boilerplate  
✅ **Type-safe** - Full type safety  
✅ **Performance** - Optimized rebuilds

### Architecture Pattern

**MVVM with Riverpod:**

- **Model:** Data models (Freezed)
- **View:** Flutter widgets
- **ViewModel:** Riverpod providers

---

## ⚙️ Riverpod Setup

### Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.20.5

dev_dependencies:
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.5
  riverpod_lint: ^2.6.3
  custom_lint: ^0.7.0
```

### App Setup

```dart
// main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

## 📦 Provider Types

### 1. State Provider

**Use Case:** Simple state that doesn't need complex logic

```dart
// Simple counter example
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state = state + 1;
  void decrement() => state = state - 1;
}
```

**Usage:**

```dart
final counter = ref.watch(counterProvider);
ref.read(counterProvider.notifier).increment();
```

---

### 2. Future Provider

**Use Case:** Async data that loads once

```dart
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
}
```

**Usage:**

```dart
final userAsync = ref.watch(currentUserProvider);

userAsync.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

---

### 3. Stream Provider

**Use Case:** Real-time data (Firestore streams)

```dart
@riverpod
Stream<List<Note>> userNotes(UserNotesRef ref, String userId) {
  final noteRepository = ref.watch(noteRepositoryProvider);
  return noteRepository.watchUserNotes(userId);
}
```

**Usage:**

```dart
final notesStream = ref.watch(userNotesProvider(userId));

notesStream.when(
  data: (notes) => NotesList(notes: notes),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

---

### 4. Notifier Provider

**Use Case:** Complex state with multiple methods

```dart
@riverpod
class NoteForm extends _$NoteForm {
  @override
  NoteFormState build() => NoteFormState.initial();

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateContent(String content) {
    state = state.copyWith(content: content);
  }

  void addImage(String imageUrl) {
    state = state.copyWith(
      images: [...state.images, imageUrl],
    );
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true);
    try {
      final noteRepository = ref.read(noteRepositoryProvider);
      await noteRepository.createNote(state.toNote());
      state = state.copyWith(isSaving: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}
```

**State Class:**

```dart
@freezed
class NoteFormState with _$NoteFormState {
  const factory NoteFormState({
    required String title,
    required String content,
    required List<String> images,
    required String? category,
    required List<String> tags,
    required bool isSaving,
    required bool isSuccess,
    required String? error,
  }) = _NoteFormState;

  factory NoteFormState.initial() => const NoteFormState(
    title: '',
    content: '',
    images: [],
    category: null,
    tags: [],
    isSaving: false,
    isSuccess: false,
    error: null,
  );
}
```

---

## 🎯 Feature Providers

### Authentication Providers

```dart
// auth/providers/auth_provider.dart

// Auth state provider
@riverpod
class AuthState extends _$AuthState {
  @override
  AuthState build() {
    // Listen to auth state changes
    ref.listenSelf((previous, next) {
      // Handle auth state changes
    });

    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> signup(String email, String password, String displayName) async {
    // Similar implementation
  }

  Future<void> logout() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.logout();
    state = AuthState.initial();
  }
}

// Current user provider
@riverpod
Future<User?> currentUser(CurrentUserRef ref) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated) return null;

  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
}
```

---

### Notes Providers

```dart
// notes/providers/notes_provider.dart

// Notes list provider
@riverpod
Stream<List<Note>> userNotes(UserNotesRef ref, String userId) {
  final noteRepository = ref.watch(noteRepositoryProvider);
  return noteRepository.watchUserNotes(userId);
}

// Note detail provider
@riverpod
Future<Note> noteDetail(NoteDetailRef ref, String noteId) async {
  final noteRepository = ref.watch(noteRepositoryProvider);
  return noteRepository.getNoteById(noteId);
}

// Notes filter provider
@riverpod
class NotesFilter extends _$NotesFilter {
  @override
  NotesFilterState build() => NotesFilterState.initial();

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setTag(String tag) {
    state = state.copyWith(selectedTag: tag);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = NotesFilterState.initial();
  }
}

// Filtered notes provider
@riverpod
Stream<List<Note>> filteredNotes(FilteredNotesRef ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) return Stream.value([]);

  final notesStream = ref.watch(userNotesProvider(userId));
  final filter = ref.watch(notesFilterProvider);

  return notesStream.map((notes) {
    var filtered = notes;

    if (filter.category != null) {
      filtered = filtered.where((n) => n.category == filter.category).toList();
    }

    if (filter.selectedTag != null) {
      filtered = filtered.where((n) => n.tags.contains(filter.selectedTag)).toList();
    }

    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered.where((n) {
        return n.title.toLowerCase().contains(query) ||
               n.content.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  });
}
```

---

### PDF Provider

```dart
// pdf/providers/pdf_provider.dart

@riverpod
class PdfGenerator extends _$PdfGenerator {
  @override
  PdfGeneratorState build() => PdfGeneratorState.initial();

  void setMode(PdfMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setText(String text) {
    state = state.copyWith(text: text);
  }

  void addImage(String imageUrl) {
    state = state.copyWith(images: [...state.images, imageUrl]);
  }

  void removeImage(int index) {
    final images = List<String>.from(state.images);
    images.removeAt(index);
    state = state.copyWith(images: images);
  }

  Future<void> generatePdf() async {
    state = state.copyWith(isGenerating: true);
    try {
      final pdfService = ref.read(pdfServiceProvider);
      final pdfUrl = state.mode == PdfMode.text
          ? await pdfService.generateFromText(state.text)
          : await pdfService.generateFromImages(state.images);

      state = state.copyWith(
        isGenerating: false,
        pdfUrl: pdfUrl,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }
}
```

---

### Sharing Provider

```dart
// sharing/providers/sharing_provider.dart

@riverpod
Stream<List<SharedNote>> sharedNotes(SharedNotesRef ref, String userId) {
  final sharingRepository = ref.watch(sharingRepositoryProvider);
  return sharingRepository.watchSharedNotes(userId);
}

@riverpod
class ShareNote extends _$ShareNote {
  @override
  ShareNoteState build() => ShareNoteState.initial();

  void selectUser(String userId) {
    final selected = List<String>.from(state.selectedUserIds);
    if (selected.contains(userId)) {
      selected.remove(userId);
    } else {
      selected.add(userId);
    }
    state = state.copyWith(selectedUserIds: selected);
  }

  void setPermission(SharePermission permission) {
    state = state.copyWith(permission: permission);
  }

  Future<void> shareNote(String noteId) async {
    state = state.copyWith(isSharing: true);
    try {
      final sharingRepository = ref.read(sharingRepositoryProvider);
      await sharingRepository.shareNote(
        noteId: noteId,
        userIds: state.selectedUserIds,
        permission: state.permission,
      );
      state = state.copyWith(isSharing: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSharing: false, error: e.toString());
    }
  }
}
```

---

### Messaging Provider

```dart
// messaging/providers/messaging_provider.dart

@riverpod
Stream<List<Message>> messages(MessagesRef ref, String conversationId) {
  final messagingRepository = ref.watch(messagingRepositoryProvider);
  return messagingRepository.watchMessages(conversationId);
}

@riverpod
Stream<List<Conversation>> conversations(ConversationsRef ref, String userId) {
  final messagingRepository = ref.watch(messagingRepositoryProvider);
  return messagingRepository.watchConversations(userId);
}

@riverpod
class Chat extends _$Chat {
  @override
  ChatState build() => ChatState.initial();

  void updateMessage(String text) {
    state = state.copyWith(messageText: text);
  }

  Future<void> sendMessage(String receiverId, String? noteId) async {
    if (state.messageText.isEmpty) return;

    state = state.copyWith(isSending: true);
    try {
      final messagingRepository = ref.read(messagingRepositoryProvider);
      await messagingRepository.sendMessage(
        receiverId: receiverId,
        text: state.messageText,
        noteId: noteId,
      );
      state = state.copyWith(
        isSending: false,
        messageText: '',
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }
}
```

---

### Dashboard Provider

```dart
// home/providers/dashboard_provider.dart

@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) throw Exception('User not authenticated');

  final dashboardRepository = ref.watch(dashboardRepositoryProvider);
  return dashboardRepository.getStats(userId);
}

@riverpod
Stream<List<Note>> recentNotes(RecentNotesRef ref, String userId) {
  final noteRepository = ref.watch(noteRepositoryProvider);
  return noteRepository.watchRecentNotes(userId, limit: 5);
}

@riverpod
Stream<List<SharedNote>> recentSharedNotes(RecentSharedNotesRef ref, String userId) {
  final sharingRepository = ref.watch(sharingRepositoryProvider);
  return sharingRepository.watchRecentSharedNotes(userId, limit: 5);
}
```

---

## ✅ Best Practices

### 1. Use Code Generation

Always use `@riverpod` annotation for code generation:

```dart
// ✅ Good
@riverpod
class MyProvider extends _$MyProvider { ... }

// ❌ Bad
final myProvider = StateNotifierProvider<...>(...);
```

### 2. Watch vs Read

**Use `ref.watch()`** when you want the widget to rebuild when the provider changes:

```dart
final notes = ref.watch(notesProvider); // Widget rebuilds when notes change
```

**Use `ref.read()`** for one-time access or in callbacks:

```dart
onPressed: () {
  ref.read(notesProvider.notifier).refresh(); // One-time action
}
```

### 3. Provider Dependencies

Use `ref.watch()` to depend on other providers:

```dart
@riverpod
Stream<List<Note>> filteredNotes(FilteredNotesRef ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  final filter = ref.watch(notesFilterProvider);
  // Use userId and filter
}
```

### 4. Error Handling

Handle errors gracefully:

```dart
final notesAsync = ref.watch(notesProvider);

notesAsync.when(
  data: (notes) => NotesList(notes: notes),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

### 5. Auto-dispose

Providers auto-dispose when not watched. For providers that should persist:

```dart
@Riverpod(keepAlive: true)
class PersistentProvider extends _$PersistentProvider { ... }
```

### 6. Family Providers

Use family for parameterized providers:

```dart
@riverpod
Future<Note> noteDetail(NoteDetailRef ref, String noteId) async {
  // noteId is the parameter
}
```

Usage:

```dart
final note = ref.watch(noteDetailProvider('note123'));
```

### 7. State Updates

Always use `copyWith` for immutable state:

```dart
state = state.copyWith(title: newTitle);
```

### 8. AsyncValue

Use `AsyncValue` for async providers:

```dart
@riverpod
Future<List<Note>> notes(NotesRef ref) async { ... }

// Usage
final notesAsync = ref.watch(notesProvider);
notesAsync.when(
  data: (notes) => ...,
  loading: () => ...,
  error: (error, stack) => ...,
);
```

---

## 🔧 Code Generation

### Running Code Generation

```bash
# One-time generation
flutter pub run build_runner build

# Watch mode (auto-generate on save)
flutter pub run build_runner watch

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generated Files

- `*.g.dart` - Generated provider code
- Keep these files in version control

### Import Generated Code

```dart
import 'package:notes_sharing_app/features/notes/providers/notes_provider.dart';
// This also imports the generated .g.dart file
```

---

## 📝 Provider Naming Conventions

### Provider Names

- Use descriptive names: `userNotesProvider`, not `notesProvider`
- Suffix with `Provider`: `authStateProvider`
- For families, include parameter: `noteDetailProvider(noteId)`

### State Classes

- Use descriptive names: `NoteFormState`, `AuthState`
- Suffix with `State`: `PdfGeneratorState`

### Notifier Classes

- Match provider name: `NoteForm` for `noteFormProvider`
- Use PascalCase: `AuthState`, `NoteForm`

---

## 🎯 Provider Organization

### File Structure

```
features/notes/presentation/providers/
├── notes_provider.dart          # Main notes provider
├── note_detail_provider.dart    # Note detail provider
├── note_form_provider.dart      # Note form state
└── notes_filter_provider.dart    # Filter state
```

### One Provider Per File

```dart
// ✅ Good
// notes_provider.dart
@riverpod
Stream<List<Note>> userNotes(...) { ... }

// ❌ Bad
// providers.dart
@riverpod
Stream<List<Note>> userNotes(...) { ... }
@riverpod
Future<Note> noteDetail(...) { ... }
```

---

## 🚀 Performance Tips

1. **Use `select` for granular updates:**

```dart
final title = ref.watch(noteFormProvider.select((state) => state.title));
// Only rebuilds when title changes
```

2. **Use `family` for parameterized providers:**

```dart
@riverpod
Future<Note> noteDetail(NoteDetailRef ref, String noteId) async { ... }
```

3. **Avoid unnecessary watches:**

```dart
// ✅ Good - only watch what you need
final title = ref.watch(noteFormProvider.select((s) => s.title));

// ❌ Bad - watches entire state
final formState = ref.watch(noteFormProvider);
final title = formState.title;
```

4. **Use `keepAlive` sparingly:**

```dart
@Riverpod(keepAlive: true) // Only if provider should persist
class PersistentProvider extends _$PersistentProvider { ... }
```

---

This state management architecture ensures:

- ✅ Type safety
- ✅ Performance
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability

Follow these patterns for all state management! 🔄

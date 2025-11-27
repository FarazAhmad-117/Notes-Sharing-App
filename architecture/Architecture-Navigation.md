# 🗺️ Notes Sharing App - Navigation & Routing

> **GoRouter configuration, route guards, and navigation patterns**

---

## 📑 Table of Contents

1. [Navigation Strategy](#navigation-strategy)
2. [Route Structure](#route-structure)
3. [GoRouter Setup](#gorouter-setup)
4. [Route Guards](#route-guards)
5. [Navigation Patterns](#navigation-patterns)
6. [Deep Linking](#deep-linking)

---

## 🎯 Navigation Strategy

### Why GoRouter?

✅ **Declarative routing** - Type-safe routes  
✅ **Deep linking** - Handle URLs and deep links  
✅ **Nested navigation** - Shell routes for bottom nav  
✅ **Route guards** - Authentication and permission checks  
✅ **Route transitions** - Custom page transitions  
✅ **URL-based** - Web-friendly routing

---

## 📊 Route Structure

### Complete Route Tree

```
/ (Splash/Initial)
│
├── /onboarding
│
├── /auth
│   ├── /login
│   ├── /signup
│   ├── /forgot-password
│   └── /email-verification
│
└── /app (ShellRoute - Bottom Navigation)
    ├── /home
    ├── /notes
    │   ├── /notes/:id (note detail)
    │   ├── /notes/create
    │   └── /notes/:id/edit
    ├── /shared-notes
    ├── /pdf
    │   ├── /pdf/generator
    │   └── /pdf/preview
    ├── /messages
    │   └── /messages/:userId (chat)
    ├── /search
    └── /profile
        ├── /profile/edit
        └── /profile/settings
```

---

## ⚙️ GoRouter Setup

### Dependencies

```yaml
dependencies:
  go_router: ^14.6.2
  flutter_riverpod: ^2.6.1
```

### Router Configuration

```dart
// app/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage = state.location.startsWith('/auth');
      final isOnOnboarding = state.location == '/onboarding';

      // If not authenticated and not on auth/onboarding page
      if (!isAuthenticated && !isOnAuthPage && !isOnOnboarding) {
        return '/auth/login';
      }

      // If authenticated and on auth page
      if (isAuthenticated && isOnAuthPage) {
        return '/app/home';
      }

      return null; // No redirect
    },
    routes: [
      // Splash/Initial
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/auth',
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: 'email-verification',
            builder: (context, state) => const EmailVerificationScreen(),
          ),
        ],
      ),

      // Main app (ShellRoute for bottom navigation)
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/app/notes',
            builder: (context, state) => const NotesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final noteId = state.pathParameters['id']!;
                  return NoteDetailScreen(noteId: noteId);
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateNoteScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) {
                  final noteId = state.pathParameters['id']!;
                  return EditNoteScreen(noteId: noteId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/app/shared-notes',
            builder: (context, state) => const SharedNotesScreen(),
          ),
          GoRoute(
            path: '/app/pdf',
            routes: [
              GoRoute(
                path: 'generator',
                builder: (context, state) => const PdfGeneratorScreen(),
              ),
              GoRoute(
                path: 'preview',
                builder: (context, state) {
                  final pdfUrl = state.uri.queryParameters['url'];
                  return PdfPreviewScreen(pdfUrl: pdfUrl);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/app/messages',
            builder: (context, state) => const MessagesScreen(),
            routes: [
              GoRoute(
                path: ':userId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return ChatScreen(userId: userId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/app/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
```

---

## 🔒 Route Guards

### Authentication Guard

```dart
// app/router/route_guards.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool authGuard(BuildContext context, GoRouterState state, WidgetRef ref) {
  final authState = ref.read(authStateProvider);
  final isAuthenticated = authState.isAuthenticated;
  final isOnAuthPage = state.location.startsWith('/auth');

  if (!isAuthenticated && !isOnAuthPage) {
    return false; // Will redirect to login
  }

  return true;
}
```

### Email Verification Guard

```dart
bool emailVerificationGuard(BuildContext context, GoRouterState state, WidgetRef ref) {
  final user = ref.read(currentUserProvider).value;
  final isEmailVerified = user?.isEmailVerified ?? false;
  final isOnVerificationPage = state.location == '/auth/email-verification';

  if (!isEmailVerified && !isOnVerificationPage && state.location.startsWith('/app')) {
    return false; // Redirect to verification
  }

  return true;
}
```

### Combined Guard

```dart
// In router configuration
redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final isAuthenticated = authState.isAuthenticated;
  final isOnAuthPage = state.location.startsWith('/auth');
  final isOnOnboarding = state.location == '/onboarding';

  // Check authentication
  if (!isAuthenticated && !isOnAuthPage && !isOnOnboarding) {
    return '/auth/login';
  }

  // Check email verification
  if (isAuthenticated) {
    final user = ref.read(currentUserProvider).value;
    final isEmailVerified = user?.isEmailVerified ?? false;
    final isOnVerificationPage = state.location == '/auth/email-verification';

    if (!isEmailVerified && !isOnVerificationPage && state.location.startsWith('/app')) {
      return '/auth/email-verification';
    }
  }

  // Redirect authenticated users away from auth pages
  if (isAuthenticated && isOnAuthPage) {
    return '/app/home';
  }

  return null; // No redirect needed
},
```

---

## 🎨 Navigation Patterns

### Basic Navigation

```dart
// Navigate to a route
context.go('/app/notes');

// Navigate with parameters
context.go('/app/notes/note123');

// Navigate with query parameters
context.go('/app/pdf/preview?url=https://...');

// Push (add to stack)
context.push('/app/notes/create');

// Pop (go back)
context.pop();

// Pop with result
context.pop('result_data');
```

### Navigation with Data

```dart
// Using extra parameter
context.go(
  '/app/notes/note123',
  extra: {'note': noteObject},
);

// Access in screen
final note = GoRouterState.of(context).extra as Map<String, dynamic>;
```

### Navigation Helpers

```dart
// core/extensions/navigation_extensions.dart
extension NavigationExtensions on BuildContext {
  void goToNoteDetail(String noteId) {
    go('/app/notes/$noteId');
  }

  void goToCreateNote() {
    push('/app/notes/create');
  }

  void goToChat(String userId) {
    push('/app/messages/$userId');
  }

  void goToPdfPreview(String pdfUrl) {
    push('/app/pdf/preview?url=${Uri.encodeComponent(pdfUrl)}');
  }
}
```

---

## 📱 App Shell (Bottom Navigation)

### App Shell Widget

```dart
// app/router/app_shell.dart
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(currentLocation),
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Shared',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/app/home')) return 0;
    if (location.startsWith('/app/notes') || location.startsWith('/app/shared-notes')) return 1;
    if (location.startsWith('/app/shared-notes')) return 2;
    if (location.startsWith('/app/messages')) return 3;
    if (location.startsWith('/app/profile')) return 4;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/app/home');
        break;
      case 1:
        context.go('/app/notes');
        break;
      case 2:
        context.go('/app/shared-notes');
        break;
      case 3:
        context.go('/app/messages');
        break;
      case 4:
        context.go('/app/profile');
        break;
    }
  }
}
```

---

## 🔗 Deep Linking

### Handling Deep Links

```dart
// In router configuration
GoRouter(
  // ... other config
  routes: [
    // ... other routes
    GoRoute(
      path: '/notes/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return NoteDetailScreen(noteId: noteId);
      },
    ),
  ],
);
```

### Deep Link Examples

```
# Open specific note
notes-sharing-app://notes/note123

# Open chat
notes-sharing-app://messages/user456

# Open PDF preview
notes-sharing-app://pdf/preview?url=https://...
```

### Handling Notification Deep Links

```dart
// When notification is tapped
void handleNotificationTap(Map<String, dynamic> data) {
  final type = data['type'];
  final id = data['id'];

  switch (type) {
    case 'note_shared':
      context.go('/app/notes/$id');
      break;
    case 'message_received':
      final userId = data['userId'];
      context.go('/app/messages/$userId');
      break;
    // ... other cases
  }
}
```

---

## 🎯 Route Transitions

### Custom Page Transitions

```dart
GoRoute(
  path: '/app/notes/create',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const CreateNoteScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);
```

### Slide Transition

```dart
GoRoute(
  path: '/app/notes/:id',
  pageBuilder: (context, state) {
    final noteId = state.pathParameters['id']!;
    return CustomTransitionPage(
      key: state.pageKey,
      child: NoteDetailScreen(noteId: noteId),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  },
);
```

---

## 📝 Route Naming

### Route Name Constants

```dart
// core/constants/route_constants.dart
class AppRoutes {
  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String emailVerification = '/auth/email-verification';

  // App
  static const String home = '/app/home';
  static const String notes = '/app/notes';
  static const String sharedNotes = '/app/shared-notes';
  static const String messages = '/app/messages';
  static const String profile = '/app/profile';

  // Helper methods
  static String noteDetail(String noteId) => '/app/notes/$noteId';
  static String chat(String userId) => '/app/messages/$userId';
  static String pdfPreview(String url) => '/app/pdf/preview?url=${Uri.encodeComponent(url)}';
}
```

### Usage

```dart
context.go(AppRoutes.home);
context.go(AppRoutes.noteDetail('note123'));
context.go(AppRoutes.chat('user456'));
```

---

## ✅ Best Practices

### 1. Use Named Routes

```dart
// ✅ Good
context.go(AppRoutes.home);

// ❌ Bad
context.go('/app/home');
```

### 2. Handle Route Parameters Safely

```dart
GoRoute(
  path: ':id',
  builder: (context, state) {
    final id = state.pathParameters['id'];
    if (id == null) {
      return const ErrorScreen(message: 'Note ID is required');
    }
    return NoteDetailScreen(noteId: id);
  },
);
```

### 3. Use Query Parameters for Optional Data

```dart
// For optional parameters
GoRoute(
  path: '/pdf/preview',
  builder: (context, state) {
    final pdfUrl = state.uri.queryParameters['url'];
    if (pdfUrl == null) {
      return const ErrorScreen(message: 'PDF URL is required');
    }
    return PdfPreviewScreen(pdfUrl: pdfUrl);
  },
);
```

### 4. Handle Navigation Errors

```dart
GoRouter(
  errorBuilder: (context, state) => ErrorScreen(
    message: 'Page not found: ${state.uri}',
  ),
  // ... other config
);
```

### 5. Use ShellRoute for Shared UI

```dart
// Use ShellRoute for bottom navigation, drawer, etc.
ShellRoute(
  builder: (context, state, child) => AppShell(child: child),
  routes: [/* nested routes */],
);
```

---

## 🚀 Navigation Flow Examples

### Login Flow

```dart
1. User opens app → Splash screen
2. Check auth state
3. If not authenticated → Login screen
4. User logs in → Home screen
5. If email not verified → Email verification screen
```

### Create Note Flow

```dart
1. User on Notes screen
2. Tap FAB → Push to Create Note screen
3. User creates note → Pop back to Notes screen
4. Notes screen refreshes to show new note
```

### Share Note Flow

```dart
1. User on Note Detail screen
2. Tap Share button → Push to Share Note screen
3. User selects users and shares → Pop back
4. Show success snackbar
```

---

This navigation architecture ensures:

- ✅ Type-safe routing
- ✅ Deep linking support
- ✅ Authentication guards
- ✅ Clean navigation patterns
- ✅ Maintainable route structure

Follow these patterns for all navigation! 🗺️

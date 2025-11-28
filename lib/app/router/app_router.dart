import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/notes/presentation/screens/create_note_screen.dart';
import '../../features/notes/presentation/screens/note_detail_screen.dart';
import '../../features/notes/presentation/screens/share_note_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/messaging/presentation/screens/messages_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../shared/widgets/layouts/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state so router redirects when auth state changes
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/auth/login',
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      try {
        final isAuthenticated = authState.isAuthenticated;
        final path = state.uri.path;
        final isOnAuthPage = path.startsWith('/auth');

        // If not authenticated and not on auth page, redirect to login
        if (!isAuthenticated && !isOnAuthPage) {
          return '/auth/login';
        }

        // If authenticated and on auth page, redirect to home
        if (isAuthenticated && isOnAuthPage) {
          return '/app/home';
        }
      } catch (e) {
        // If auth provider is not ready, default to login
        return '/auth/login';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // App routes with bottom navigation
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
          ),
          GoRoute(
            path: '/app/messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/app/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Nested routes (without bottom nav)
      GoRoute(
        path: '/app/notes/create',
        builder: (context, state) => const CreateNoteScreen(),
      ),
      GoRoute(
        path: '/app/notes/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return NoteDetailScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/app/notes/:id/edit',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return CreateNoteScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/app/notes/:id/share',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          final noteTitle = state.uri.queryParameters['title'] ?? 'Note';
          return ShareNoteScreen(noteId: noteId, noteTitle: noteTitle);
        },
      ),
      GoRoute(
        path: '/app/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/app/messages/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatScreen(otherUserId: userId);
        },
      ),
      GoRoute(
        path: '/app/pdf/generator',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('PDF Generator')),
          body: const Center(child: Text('PDF Generator coming soon')),
        ),
      ),
    ],
  );
});

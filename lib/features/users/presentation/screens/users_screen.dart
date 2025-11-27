import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/radius.dart';
import '../providers/users_provider.dart';
import '../../../auth/data/models/user_model.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showShareNoteDialog(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Note with ${user.displayName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Select a note to share with ${user.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to notes screen to select a note
                context.go('/app/notes');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Note sharing feature coming soon')),
                );
              },
              icon: const Icon(Icons.note),
              label: const Text('Select Note to Share'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _startConversation(User user) {
    // Navigate to messages or create a new conversation
    context.go('/app/messages');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting conversation with ${user.displayName}')),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = _searchQuery.isEmpty
        ? ref.watch(usersProvider)
        : ref.watch(searchUsersProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) => users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match your search',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Users will appear here'
                                : 'Try a different search term',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(usersProvider);
                        if (_searchQuery.isNotEmpty) {
                          ref.invalidate(searchUsersProvider(_searchQuery));
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                child: user.photoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user.photoUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Text(
                                        user.displayName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              title: Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Last seen: ${_formatLastSeen(user.lastSeen)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    tooltip: 'Share Note',
                                    onPressed: () => _showShareNoteDialog(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.message),
                                    tooltip: 'Start Conversation',
                                    onPressed: () => _startConversation(user),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Error loading users',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(usersProvider);
                        if (_searchQuery.isNotEmpty) {
                          ref.invalidate(searchUsersProvider(_searchQuery));
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

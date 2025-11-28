import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/notes_provider.dart';

class ShareNoteScreen extends ConsumerStatefulWidget {
  final String noteId;
  final String noteTitle;

  const ShareNoteScreen({
    required this.noteId,
    required this.noteTitle,
    super.key,
  });

  @override
  ConsumerState<ShareNoteScreen> createState() => _ShareNoteScreenState();
}

class _ShareNoteScreenState extends ConsumerState<ShareNoteScreen> {
  final _searchController = TextEditingController();
  final _notificationService = NotificationService();
  final Set<String> _selectedUserIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    if (_selectedUserIds.isEmpty) {
      ToastService.showError('Please select at least one user to share with');
      return;
    }

    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        ToastService.showError('User not authenticated');
        return;
      }

      final repository = ref.read(noteRepositoryProvider);
      await repository.shareNote(
        widget.noteId,
        authState.user!.uid,
        _selectedUserIds.toList(),
      );

      // Get FCM tokens for selected users and send notifications
      final fcmTokens = await _notificationService.getFcmTokensForUsers(
        _selectedUserIds.toList(),
      );

      if (fcmTokens.isNotEmpty) {
        await _notificationService.sendNotificationToUsers(
          fcmTokens: fcmTokens,
          title: 'New Note Shared',
          body:
              '${authState.user!.displayName} shared "${widget.noteTitle}" with you',
          data: {
            'type': 'note_shared',
            'noteId': widget.noteId,
            'sharedBy': authState.user!.uid,
            'sharedByName': authState.user!.displayName,
          },
        );
      }

      ToastService.showSuccess(
        'Note shared with ${_selectedUserIds.length} user(s)',
      );

      // Invalidate notes provider to refresh the list
      ref.invalidate(notesProvider);
      ref.invalidate(recentNotesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ToastService.showError('Failed to share note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final usersAsync = ref.watch(searchUsersProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Note'),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: _handleShare,
              child: Text(
                'Share (${_selectedUserIds.length})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: CustomTextField(
              label: 'Search users',
              hint: 'Search by name or email',
              controller: _searchController,
              suffixIcon: const Icon(Icons.search),
              onChanged: (value) {
                // Trigger search by invalidating provider
                ref.invalidate(searchUsersProvider(value));
              },
            ),
          ),

          // Selected users count
          if (_selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_selectedUserIds.length} user(s) selected',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          searchQuery.isEmpty
                              ? 'Start typing to search users'
                              : 'No users found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.uid);

                    return Card(
                      child: CheckboxListTile(
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedUserIds.add(user.uid);
                            } else {
                              _selectedUserIds.remove(user.uid);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(searchUsersProvider(searchQuery));
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

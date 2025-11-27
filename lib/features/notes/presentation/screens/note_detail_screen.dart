import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/spacing.dart';
import '../providers/notes_provider.dart';

class NoteDetailScreen extends ConsumerWidget {
  final String noteId;

  const NoteDetailScreen({
    required this.noteId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/app/notes/$noteId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon')),
              );
            },
          ),
        ],
      ),
      body: noteAsync.when(
        data: (note) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.isPinned)
                    const Icon(Icons.push_pin, color: Colors.orange),
                  if (note.isPinned) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (note.category != null || note.tags.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (note.category != null)
                      Chip(
                        label: Text(note.category!),
                        avatar: const Icon(Icons.category, size: 18),
                      ),
                    ...note.tags.map(
                      (tag) => Chip(
                        label: Text(tag),
                        avatar: const Icon(Icons.tag, size: 18),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Created: ${DateFormat('MMM d, y • h:mm a').format(note.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
              if (note.updatedAt != note.createdAt)
                Text(
                  'Updated: ${DateFormat('MMM d, y • h:mm a').format(note.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              const Divider(height: AppSpacing.xl),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(noteDetailProvider(noteId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


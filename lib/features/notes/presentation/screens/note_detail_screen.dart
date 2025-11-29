import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../core/utils/toast_service.dart';
import '../providers/notes_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NoteDetailScreen extends ConsumerWidget {
  final String noteId;

  const NoteDetailScreen({required this.noteId, super.key});

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
            tooltip: 'Edit note',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context, ref, noteId),
            tooltip: 'Delete note',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing coming soon')),
              );
            },
            tooltip: 'Share note',
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (note.updatedAt != note.createdAt)
                Text(
                  'Updated: ${DateFormat('MMM d, y • h:mm a').format(note.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              const Divider(height: AppSpacing.xl),

              // Text(note.content, style: Theme.of(context).textTheme.bodyLarge),
              if (note.pdfUrl != null ||
                  (note.attachments.isNotEmpty &&
                      note.attachments.first.toLowerCase().endsWith('.pdf')))
                SizedBox(
                  height: 500, // adjust as you like
                  child: SfPdfViewer.network(
                    note.pdfUrl ?? note.attachments.first,
                  ),
                )
              else
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

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String noteId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteNoteProvider(noteId).future);
        ToastService.showSuccess('Note deleted successfully');
        if (context.mounted) {
          context.pop(); // Go back to notes list
        }
      } catch (e) {
        ToastService.showError('Failed to delete note: $e');
      }
    }
  }
}

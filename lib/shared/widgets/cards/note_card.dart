import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/radius.dart';
import '../../../features/notes/data/models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final String? sharerName; // Name of the user who shared this note

  const NoteCard({
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.sharerName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.orange),
                  if (note.isPinned) const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Action Icons
                  if (onEdit != null ||
                      onDelete != null ||
                      onShare != null) ...[
                    if (onShare != null)
                      IconButton(
                        icon: const Icon(Icons.share, size: 18),
                        onPressed: () {
                          onShare?.call();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Share note',
                      ),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          onEdit?.call();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Edit note',
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () {
                          onDelete?.call();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Theme.of(context).colorScheme.error,
                        tooltip: 'Delete note',
                      ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: note.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              // Sharer info (if note is shared with current user)
              if (note.sharedBy != null && sharerName != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Shared by $sharerName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (note.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        note.category!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  if (note.isShared && note.sharedWithCount > 0) ...[
                    if (note.category != null)
                      const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            size: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${note.sharedWithCount}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

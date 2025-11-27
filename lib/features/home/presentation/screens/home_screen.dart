import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/color_schemes.dart';
import '../../../../shared/widgets/cards/note_card.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../notes/data/models/note_model.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentNotesAsync = ref.watch(recentNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Sharing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/app/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/app/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentNotesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: statsAsync.when(
                  data: (stats) => _buildStatsGrid(context, stats),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ),
              const Divider(),
              // Quick Actions
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/app/notes/create'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Note'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/app/pdf/generator'),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generate PDF'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Recent Notes
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.push('/app/notes'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              recentNotesAsync.when(
                data: (notes) => notes.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.note_add,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No notes yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Create your first note to get started',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: NoteCard(
                              note: notes[index],
                              onTap: () =>
                                  context.push('/app/notes/${notes[index].id}'),
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Error: $error'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Total Notes',
          stats.totalNotes.toString(),
          Icons.note,
          Colors.blue,
        ),
        _buildStatCard(
          context,
          'Shared Notes',
          stats.sharedNotes.toString(),
          Icons.share,
          Colors.purple,
        ),
        _buildStatCard(
          context,
          'Recent Updates',
          stats.recentUpdates.toString(),
          Icons.update,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Unread Messages',
          stats.unreadMessages.toString(),
          Icons.message,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

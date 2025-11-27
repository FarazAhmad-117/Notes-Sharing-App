import '../models/dashboard_stats.dart';
import '../../../notes/data/repositories/note_repository.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats(String userId);
}

class DummyDashboardRepository implements DashboardRepository {
  final NoteRepository noteRepository;

  DummyDashboardRepository(this.noteRepository);

  @override
  Future<DashboardStats> getStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final notes = await noteRepository.getNotes(userId);

    return DashboardStats(
      totalNotes: notes.length,
      sharedNotes: notes.where((n) => n.isShared).length,
      recentUpdates: notes
          .where(
            (n) => n.updatedAt.isAfter(
              DateTime.now().subtract(const Duration(days: 7)),
            ),
          )
          .length,
      unreadMessages: 3, // Dummy value
    );
  }
}

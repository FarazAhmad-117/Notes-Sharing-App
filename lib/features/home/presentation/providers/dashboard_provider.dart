import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/models/dashboard_stats.dart';
import '../../../notes/data/repositories/note_repository.dart';
import '../../../notes/presentation/providers/notes_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final noteRepository = ref.read(noteRepositoryProvider);
  return DummyDashboardRepository(noteRepository);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.read(dashboardRepositoryProvider);
  final authState = ref.watch(authProvider);
  if (authState.user == null) {
    return const DashboardStats();
  }
  return repository.getStats(authState.user!.uid);
});

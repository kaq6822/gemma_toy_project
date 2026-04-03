import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../data/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

final sessionsProvider = StreamProvider<List<ChatSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchSessions();
});

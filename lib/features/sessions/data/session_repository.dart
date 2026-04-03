import '../../../core/database/app_database.dart';

class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  Stream<List<ChatSession>> watchSessions() => _db.watchAllSessions();

  Future<List<ChatSession>> getSessions() => _db.getAllSessions();

  Future<ChatSession> getSession(int id) => _db.getSession(id);

  Future<int> createSession({required String modelName}) =>
      _db.createSession(modelName: modelName);

  Future<void> deleteSession(int id) => _db.deleteSession(id);

  Future<void> updateTitle(int id, String title) =>
      _db.updateSessionTitle(id, title);
}

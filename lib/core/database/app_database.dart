import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('새 대화'))();
  TextColumn get modelName => text().withDefault(const Constant('gemma-3-1b'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ChatSessions, #id)();
  TextColumn get role => text()(); // 'user' or 'assistant'
  TextColumn get content => text()();
  TextColumn get attachmentPath => text().nullable()();
  TextColumn get attachmentType => text().nullable()(); // 'image' or 'file'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ChatSessions, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'gemma_chat_db');
  }

  // Chat Sessions
  Future<List<ChatSession>> getAllSessions() =>
      (select(chatSessions)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Stream<List<ChatSession>> watchAllSessions() =>
      (select(chatSessions)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  Future<ChatSession> getSession(int id) =>
      (select(chatSessions)..where((t) => t.id.equals(id))).getSingle();

  Future<int> createSession({String? title, required String modelName}) =>
      into(chatSessions).insert(ChatSessionsCompanion.insert(
        title: Value(title ?? '새 대화'),
        modelName: Value(modelName),
      ));

  Future<void> updateSessionTitle(int id, String title) =>
      (update(chatSessions)..where((t) => t.id.equals(id))).write(
        ChatSessionsCompanion(
          title: Value(title),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> updateSessionTimestamp(int id) =>
      (update(chatSessions)..where((t) => t.id.equals(id))).write(
        ChatSessionsCompanion(updatedAt: Value(DateTime.now())),
      );

  Future<void> deleteSession(int id) async {
    await (delete(messages)..where((t) => t.sessionId.equals(id))).go();
    await (delete(chatSessions)..where((t) => t.id.equals(id))).go();
  }

  // Messages
  Future<List<Message>> getMessagesForSession(int sessionId) =>
      (select(messages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Stream<List<Message>> watchMessagesForSession(int sessionId) =>
      (select(messages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<int> insertMessage({
    required int sessionId,
    required String role,
    required String content,
    String? attachmentPath,
    String? attachmentType,
  }) =>
      into(messages).insert(MessagesCompanion.insert(
        sessionId: sessionId,
        role: role,
        content: content,
        attachmentPath: Value(attachmentPath),
        attachmentType: Value(attachmentType),
      ));

  Future<void> updateMessageContent(int id, String content) =>
      (update(messages)..where((t) => t.id.equals(id))).write(
        MessagesCompanion(content: Value(content)),
      );
}

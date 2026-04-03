import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:flutter_gemma/flutter_gemma.dart' show FlutterGemma;
import '../../model_manager/data/model_repository.dart';
import '../../../core/database/app_database.dart' as db;

class ChatRepository {
  final db.AppDatabase _db;

  ChatRepository(this._db);

  Future<List<db.Message>> getMessages(int sessionId) =>
      _db.getMessagesForSession(sessionId);

  Stream<List<db.Message>> watchMessages(int sessionId) =>
      _db.watchMessagesForSession(sessionId);

  Future<int> addUserMessage({
    required int sessionId,
    required String content,
    String? attachmentPath,
    String? attachmentType,
  }) async {
    final msgId = await _db.insertMessage(
      sessionId: sessionId,
      role: 'user',
      content: content,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );
    await _db.updateSessionTimestamp(sessionId);
    return msgId;
  }

  Future<int> addAssistantMessage({
    required int sessionId,
    required String content,
  }) async {
    final msgId = await _db.insertMessage(
      sessionId: sessionId,
      role: 'assistant',
      content: content,
    );
    await _db.updateSessionTimestamp(sessionId);
    return msgId;
  }

  Future<void> updateMessageContent(int messageId, String content) =>
      _db.updateMessageContent(messageId, content);

  Stream<String> sendMessageStream({
    required List<db.Message> history,
    required String userMessage,
    required String modelId,
    required int maxTokens,
    Uint8List? imageBytes,
  }) async* {
    final modelInfo = ModelRepository.getModelById(modelId);
    final isMultimodal = modelInfo?.isMultimodal ?? false;

    final model = await FlutterGemma.getActiveModel(
      maxTokens: maxTokens,
      supportImage: isMultimodal && imageBytes != null,
    );
    final chat = await model.createChat(
      supportImage: isMultimodal && imageBytes != null,
    );

    // Replay history
    for (final msg in history) {
      final gemmaMsg = gemma.Message.text(
        text: msg.content,
        isUser: msg.role == 'user',
      );
      await chat.addQueryChunk(gemmaMsg);
    }

    // Add new user message
    gemma.Message userMsg;
    if (imageBytes != null && isMultimodal) {
      userMsg = gemma.Message.withImage(
        text: userMessage,
        imageBytes: imageBytes,
        isUser: true,
      );
    } else {
      userMsg = gemma.Message.text(text: userMessage, isUser: true);
    }
    await chat.addQueryChunk(userMsg);

    // Stream response
    await for (final response in chat.generateChatResponseAsync()) {
      if (response is gemma.TextResponse) {
        yield response.token;
      }
    }

    await chat.close();
  }

  Future<void> autoGenerateSessionTitle(int sessionId) async {
    final messages = await _db.getMessagesForSession(sessionId);
    if (messages.isNotEmpty && messages.first.role == 'user') {
      String title = messages.first.content;
      if (title.length > 30) {
        title = '${title.substring(0, 30)}...';
      }
      await _db.updateSessionTitle(sessionId, title);
    }
  }

  Future<Uint8List?> loadImageBytes(String? path) async {
    if (path == null) return null;
    final file = File(path);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }
}

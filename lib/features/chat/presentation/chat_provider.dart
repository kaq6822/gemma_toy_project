import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/providers/database_provider.dart';
import '../data/chat_repository.dart';
import '../../settings/presentation/settings_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(databaseProvider));
});

final messagesProvider =
    StreamProvider.family<List<db.Message>, int>((ref, sessionId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(sessionId);
});

class ChatState {
  final bool isGenerating;
  final String streamingText;
  final String? error;

  const ChatState({
    this.isGenerating = false,
    this.streamingText = '',
    this.error,
  });

  ChatState copyWith({
    bool? isGenerating,
    String? streamingText,
    String? error,
  }) {
    return ChatState(
      isGenerating: isGenerating ?? this.isGenerating,
      streamingText: streamingText ?? this.streamingText,
      error: error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return const ChatState();
  }

  Future<void> sendMessage({
    required int sessionId,
    required String content,
    String? attachmentPath,
    String? attachmentType,
  }) async {
    if (state.isGenerating) return;

    final repo = ref.read(chatRepositoryProvider);
    final modelId = ref.read(selectedModelProvider);
    final maxTokens = ref.read(maxTokensProvider);

    // Save user message
    await repo.addUserMessage(
      sessionId: sessionId,
      content: content,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );

    // Auto-generate title on first message
    final messages = await repo.getMessages(sessionId);
    if (messages.length == 1) {
      await repo.autoGenerateSessionTitle(sessionId);
    }

    state = const ChatState(isGenerating: true, streamingText: '');

    try {
      final history = await repo.getMessages(sessionId);

      // Load image bytes if attachment is an image
      final imageBytes = attachmentType == 'image'
          ? await repo.loadImageBytes(attachmentPath)
          : null;

      // Create placeholder assistant message
      final assistantMsgId = await repo.addAssistantMessage(
        sessionId: sessionId,
        content: '',
      );

      final buffer = StringBuffer();

      await for (final chunk in repo.sendMessageStream(
        history: history.sublist(0, history.length - 1),
        userMessage: content,
        modelId: modelId,
        maxTokens: maxTokens,
        imageBytes: imageBytes,
      )) {
        buffer.write(chunk);
        state = ChatState(
          isGenerating: true,
          streamingText: buffer.toString(),
        );
        await repo.updateMessageContent(assistantMsgId, buffer.toString());
      }

      state = const ChatState();
    } catch (e) {
      state = ChatState(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final chatStateProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

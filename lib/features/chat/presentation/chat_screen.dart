import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../model_manager/data/model_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import 'chat_provider.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const ChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _attachmentPath;
  String? _attachmentType;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _attachmentPath = image.path;
        _attachmentType = 'image';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachmentPath = result.files.single.path;
        _attachmentType = 'file';
      });
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachmentPath = null;
      _attachmentType = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachmentPath == null) return;

    final content = text.isEmpty ? '[첨부파일]' : text;
    _textController.clear();
    final attachPath = _attachmentPath;
    final attachType = _attachmentType;
    _clearAttachment();

    await ref.read(chatStateProvider.notifier).sendMessage(
          sessionId: widget.sessionId,
          content: content,
          attachmentPath: attachPath,
          attachmentType: attachType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.sessionId));
    final chatState = ref.watch(chatStateProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final isMultimodal =
        ModelRepository.getModelById(selectedModel)?.isMultimodal ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemma Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: messages.length +
                      (chatState.isGenerating ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < messages.length) {
                      return MessageBubble(
                        message: messages[index],
                        onCopy: () {
                          Clipboard.setData(
                              ClipboardData(text: messages[index].content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('복사됨')),
                          );
                        },
                      );
                    }
                    // Streaming message
                    return _StreamingBubble(text: chatState.streamingText);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Text(
                chatState.error!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          if (_attachmentPath != null) _buildAttachmentPreview(),
          _buildInputBar(isMultimodal, chatState.isGenerating),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          if (_attachmentType == 'image')
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_attachmentPath!),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.insert_drive_file),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _attachmentPath!.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearAttachment,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isMultimodal, bool isGenerating) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isMultimodal)
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: isGenerating ? null : _pickImage,
                tooltip: '이미지 첨부',
              ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: isGenerating ? null : _pickFile,
              tooltip: '파일 첨부',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !isGenerating,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              onPressed: isGenerating ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamingBubble extends StatelessWidget {
  final String text;
  const _StreamingBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: text.isEmpty
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              )
            : SelectableText(
                text,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
      ),
    );
  }
}

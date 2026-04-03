import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart' as db;

class MessageBubble extends StatelessWidget {
  final db.Message message;
  final VoidCallback? onCopy;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
  });

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onCopy,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? colorScheme.primaryContainer
                : colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: !isUser ? const Radius.circular(4) : null,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.attachmentPath != null) ...[
                _buildAttachment(context),
                const SizedBox(height: 8),
              ],
              SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context) {
    if (message.attachmentType == 'image' && message.attachmentPath != null) {
      final file = File(message.attachmentPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.attachmentPath?.split('/').last ?? '파일',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

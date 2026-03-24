import 'package:flutter/material.dart';

enum MessageSender { me, ai }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final Widget? richWidget; // Render widgets instead of text if present

  ChatMessage({
    required this.text,
    required this.sender,
    this.richWidget,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.sender == MessageSender.me;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(message.richWidget != null ? 0 : 16.0), // No padding for rich widgets
              decoration: BoxDecoration(
                color: isMe ? theme.primaryColor : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: message.richWidget ?? 
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

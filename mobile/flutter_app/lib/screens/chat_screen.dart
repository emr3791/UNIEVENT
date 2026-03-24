import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatProvider chatProvider, String userId, String userName) {
    if (_messageController.text.isNotEmpty) {
      chatProvider.sendMessage(
        _messageController.text,
        userId,
        userName,
      );
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destek ve İletişim'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isCurrentUser = message.senderId == 'user1';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isCurrentUser) ...[
                            CircleAvatar(
                              backgroundColor: const Color(0xFF6366F1),
                              child: Text(
                                message.senderName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    Text(
                                      message.senderName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  if (!isCurrentUser) const SizedBox(height: 4),
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isCurrentUser
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              backgroundColor: Color(0xFF6366F1),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final authProvider = Provider.of<AuthProvider>(context);
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Mesajınızı yazın...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          _sendMessage(
                            chatProvider,
                            'user1',
                            authProvider.currentUser?.username ?? 'Kullanıcı',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF6366F1),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          _sendMessage(
                            chatProvider,
                            'user1',
                            authProvider.currentUser?.username ?? 'Kullanıcı',
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

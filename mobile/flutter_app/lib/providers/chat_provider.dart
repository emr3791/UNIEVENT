import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      senderId: 'user1',
      senderName: 'Ali Yılmaz',
      content: 'Merhaba! Yaklaşan etkinlikler hakkında bilgi almak istiyorum.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      id: '2',
      senderId: 'support',
      senderName: 'Support',
      content: 'Merhaba Ali! Size nasıl yardımcı olabilirim?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
    ),
    ChatMessage(
      id: '3',
      senderId: 'user1',
      senderName: 'Ali Yılmaz',
      content: 'Yazılım geliştirme seminerleri var mı?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
  ];

  List<ChatMessage> get messages => _messages;

  int get unreadCount => _messages.where((m) => !m.isRead).length;

  void sendMessage(String content, String userId, String userName) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _messages.add(newMessage);
    notifyListeners();
  }

  void markAsRead(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = ChatMessage(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        content: message.content,
        timestamp: message.timestamp,
        isRead: true,
        attachmentUrl: message.attachmentUrl,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _messages.length; i++) {
      final message = _messages[i];
      if (!message.isRead) {
        _messages[i] = ChatMessage(
          id: message.id,
          senderId: message.senderId,
          senderName: message.senderName,
          content: message.content,
          timestamp: message.timestamp,
          isRead: true,
          attachmentUrl: message.attachmentUrl,
        );
      }
    }
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }
}

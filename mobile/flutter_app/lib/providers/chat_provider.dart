import 'package:flutter/material.dart';
import '../models/chat_message.dart';

// This file has been optimized

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

  // Counts directly without creating an intermediate list
  int get unreadCount => _messages.where((m) => !m.isRead).length;

  void sendMessage(String content, String userId, String userName) {
    if (content.trim().isEmpty) return; // guard against empty messages
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      content: content.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }

  void markAsRead(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1 && !_messages[index].isRead) { // no-op if already read
      _messages[index] = _messages[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _messages.length; i++) {
      if (!_messages[i].isRead) {
        _messages[i] = _messages[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners(); // only notify if something actually changed
  }

  void deleteMessage(String messageId) {
    final before = _messages.length;
    _messages.removeWhere((m) => m.id == messageId);
    if (_messages.length != before) notifyListeners(); // only notify if removed
  }
}
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _backgroundDeliveryEnabled = true;

  List<NotificationItem> get notifications => _notifications;

  bool get backgroundDeliveryEnabled => _backgroundDeliveryEnabled;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    _notifications.add(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );
    notifyListeners();
  }

  void setBackgroundDeliveryEnabled(bool enabled) {
    _backgroundDeliveryEnabled = enabled;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });
}

enum NotificationType { event, reminder, recommendation, message, system }

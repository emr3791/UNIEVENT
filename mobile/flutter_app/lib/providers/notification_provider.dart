import 'package:flutter/material.dart';

// This file has been optimized
/*
1. NotificationItem.isRead was mutable (var) before — if any screen does notification.isRead = true directly, it will now be a compile error. All reads must go through provider.markAsRead(id) instead.
2. notifications getter now returns List.unmodifiable — if any screen calls provider.notifications.add(...) or provider.notifications.remove(...) directly, it will throw at runtime. All mutations must go through the provider methods.
3. addNotification no longer requires isRead — it defaults to false. If any call site was explicitly passing isRead: false, it still works. If it was passing isRead: true, that argument is now ignored and needs to be removed.
*/

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  bool _backgroundDeliveryEnabled = true;

  List<NotificationItem> get notifications =>
      List.unmodifiable(_notifications); // prevent external mutation

  bool get backgroundDeliveryEnabled => _backgroundDeliveryEnabled;

  // Counts directly — no intermediate list created
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
      ),
    );
    notifyListeners();
  }

  void setBackgroundDeliveryEnabled(bool enabled) {
    if (_backgroundDeliveryEnabled == enabled) return; // no-op if unchanged
    _backgroundDeliveryEnabled = enabled;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) { // no-op if already read
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners(); // only notify if something changed
  }

  void removeNotification(String id) {
    final before = _notifications.length;
    _notifications.removeWhere((n) => n.id == id);
    if (_notifications.length != before) notifyListeners(); // only notify if removed
  }

  void clearAllNotifications() {
    if (_notifications.isEmpty) return; // no-op if already empty
    _notifications.clear();
    notifyListeners();
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead; // now final — mutation goes through copyWith

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false, // defaults to false — no need to pass it on creation
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType { event, reminder, recommendation, message, system }
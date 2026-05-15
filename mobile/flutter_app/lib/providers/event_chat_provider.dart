import 'package:flutter/material.dart';

// This file has been optimized

enum ChatMessageType { text, announcement, system }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime sentAt;
  final ChatMessageType type;
  final bool isAdmin;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.sentAt,
    this.type = ChatMessageType.text,
    this.isAdmin = false,
  });
}

class EventChatRoom {
  final String eventId;
  final String eventTitle;
  final List<ChatMessage> messages;
  final Set<String> memberIds;
  final Set<String> adminIds;
  bool isMessagingRestricted;

  EventChatRoom({
    required this.eventId,
    required this.eventTitle,
    List<ChatMessage>? messages,
    Set<String>? memberIds,
    Set<String>? adminIds,
    this.isMessagingRestricted = false,
  })  : messages = messages ?? [],
        memberIds = memberIds ?? {},
        adminIds = adminIds ??
            {'dev_admin', 'dev_sevval', 'dev_esad', 'dev_emin', 'dev_emrullah'};
}

class EventChatProvider extends ChangeNotifier {
  final Map<String, EventChatRoom> _rooms = {};

  // Developer/admin IDs that always have full control
  static const Set<String> developerAdmins = {
    'dev_admin',
    'dev_sevval',
    'dev_esad',
    'dev_emin',
    'dev_emrullah',
  };

  EventChatProvider() {
    _rooms['1'] = EventChatRoom(
      eventId: '1',
      eventTitle: 'Yapay Zeka Semineri',
      memberIds: {'u1', 'u3'},
      messages: [
        ChatMessage(
          id: 'sys_welcome',
          senderId: 'system',
          senderName: 'Sistem',
          text:
              '🎉 "Yapay Zeka Semineri" etkinlik sohbet odası oluşturuldu. Hoş geldiniz!',
          sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
          type: ChatMessageType.system,
          isAdmin: true,
        ),
        ChatMessage(
          id: 'admin_welcome',
          senderId: 'dev_admin',
          senderName: 'UniEvent Admin',
          text:
              'Etkinliğe hoş geldiniz! Sorularınızı buradan paylaşabilirsiniz.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 10)),
          type: ChatMessageType.announcement,
          isAdmin: true,
        ),
        ChatMessage(
          id: 'msg1',
          senderId: 'u1',
          senderName: 'Ayşe Kaya',
          text: 'Herkese merhaba, bu konudan sonra kahve içmek isteyen var mı?',
          sentAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
      ],
    );
  }

  EventChatRoom getOrCreateRoom(String eventId, String eventTitle) {
    if (!_rooms.containsKey(eventId)) {
      _rooms[eventId] = EventChatRoom(
        eventId: eventId,
        eventTitle: eventTitle,
        messages: [
          ChatMessage(
            id: 'sys_0',
            senderId: 'system',
            senderName: 'Sistem',
            text:
                '🎉 "$eventTitle" etkinlik sohbet odası oluşturuldu! Hoş geldiniz.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
            type: ChatMessageType.system,
            isAdmin: true,
          ),
          ChatMessage(
            id: 'admin_0',
            senderId: 'dev_admin',
            senderName: '👑 UniEvent Admin',
            text:
                'Etkinliğimize katıldığınız için teşekkürler! Sorularınız için buradayız.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 4)),
            type: ChatMessageType.announcement,
            isAdmin: true,
          ),
        ],
      );
    }
    return _rooms[eventId]!;
  }

  void joinEvent(String eventId, String eventTitle, String userId) {
    final room = getOrCreateRoom(eventId, eventTitle);
    if (room.memberIds.contains(userId)) return; // no-op if already a member
    room.memberIds.add(userId);
    room.messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      senderName: 'Sistem',
      text: '👋 Yeni bir katılımcı gruba katıldı.',
      sentAt: DateTime.now(),
      type: ChatMessageType.system,
      isAdmin: false,
    ));
    notifyListeners();
  }

  void sendMessage(
    String eventId,
    String userId,
    String senderName,
    String text, {
    bool isAdmin = false,
  }) {
    if (text.trim().isEmpty) return; // guard against empty messages
    final room = _rooms[eventId];
    if (room == null) return;
    if (room.isMessagingRestricted &&
        !isAdmin &&
        !developerAdmins.contains(userId)) {
      return;
    }

    room.messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: senderName,
      text: text.trim(),
      sentAt: DateTime.now(),
      isAdmin: isAdmin || developerAdmins.contains(userId),
    ));
    notifyListeners();
  }

  void toggleMessagingRestriction(String eventId, String userId) {
    if (!developerAdmins.contains(userId)) return;
    final room = _rooms[eventId];
    if (room == null) return;
    room.isMessagingRestricted = !room.isMessagingRestricted;
    room.messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      senderName: 'Sistem',
      text: room.isMessagingRestricted
          ? '🔒 Sohbet kısıtlandı. Yalnızca adminler mesaj gönderebilir.'
          : '🔓 Sohbet kısıtlaması kaldırıldı.',
      sentAt: DateTime.now(),
      type: ChatMessageType.system,
      isAdmin: true,
    ));
    notifyListeners();
  }

  // Short-circuits for dev admins without room lookup
  bool isAdmin(String eventId, String userId) {
    if (developerAdmins.contains(userId)) return true;
    return _rooms[eventId]?.adminIds.contains(userId) ?? false;
  }

  // Returns an iterable view — no new list created on every call
  // ⚠️ If anything in your UI calls allRooms and expects a List
  // (e.g. allRooms[0] or allRooms.length) change this back to .toList()
  Iterable<EventChatRoom> get allRooms => _rooms.values;
}

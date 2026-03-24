import 'package:flutter/material.dart';
import '../models/user.dart';

class SocialUser {
  final String id;
  final String fullName;
  final String username;
  final String? university;
  final String? avatarSkinTone;
  final String? avatarHairStyle;
  final bool isOnline;

  SocialUser({
    required this.id,
    required this.fullName,
    required this.username,
    this.university,
    this.avatarSkinTone,
    this.avatarHairStyle,
    this.isOnline = false,
  });
}

class ChatRequest {
  final String fromUserId;
  final String fromUserName;
  final DateTime sentAt;
  bool accepted;

  ChatRequest({
    required this.fromUserId,
    required this.fromUserName,
    required this.sentAt,
    this.accepted = false,
  });
}

class DirectMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });
}

class DirectConversation {
  final String peerId;
  final String peerName;
  final String? peerUniversity;
  final List<DirectMessage> messages;
  bool chatRequestAccepted;
  bool chatRequestSent;
  bool chatRequestReceived;

  DirectConversation({
    required this.peerId,
    required this.peerName,
    this.peerUniversity,
    List<DirectMessage>? messages,
    this.chatRequestAccepted = false,
    this.chatRequestSent = false,
    this.chatRequestReceived = false,
  }) : messages = messages ?? [];
}

class SocialProvider extends ChangeNotifier {
  // Mock data: followers/following by userId
  final Map<String, Set<String>> _following = {};
  final Map<String, Set<String>> _followers = {};
  final List<SocialUser> _allUsers = [];
  final Map<String, DirectConversation> _conversations = {};
  String? _currentUserId;

  static final List<SocialUser> _mockUsers = [
    SocialUser(id: 'u1', fullName: 'Ayşe Kaya', username: 'aysekaya', university: 'İstanbul Teknik Üniversitesi', isOnline: true, avatarSkinTone: 'light', avatarHairStyle: 'default'),
    SocialUser(id: 'u2', fullName: 'Mehmet Demir', username: 'mehmetdemir', university: 'İstanbul Teknik Üniversitesi', isOnline: false, avatarSkinTone: 'medium', avatarHairStyle: 'curly'),
    SocialUser(id: 'u3', fullName: 'Zeynep Arslan', username: 'zeyneparslan', university: 'Boğaziçi Üniversitesi', isOnline: true, avatarSkinTone: 'dark', avatarHairStyle: 'default'),
    SocialUser(id: 'u4', fullName: 'Ali Çelik', username: 'alicelik', university: 'Boğaziçi Üniversitesi', isOnline: false, avatarSkinTone: 'medium', avatarHairStyle: 'bald'),
    SocialUser(id: 'u5', fullName: 'Fatma Yıldız', username: 'fatmayildiz', university: 'İstanbul Üniversitesi', isOnline: true, avatarSkinTone: 'light', avatarHairStyle: 'white'),
  ];

  List<SocialUser> get allUsers => List.unmodifiable(_allUsers);

  void initForUser(User user) {
    _currentUserId = user.id;
    _allUsers
      ..clear()
      ..addAll(_mockUsers);

    // Auto-follow users from the same university
    final sameUni = _mockUsers.where((u) =>
        u.id != user.id &&
        u.university != null &&
        user.university != null &&
        u.university!.toLowerCase().trim() ==
            user.university!.toLowerCase().trim());

    for (final peer in sameUni) {
      _addFollow(user.id, peer.id);
      _addFollow(peer.id, user.id);
    }

    notifyListeners();
  }

  void _addFollow(String followerId, String followeeId) {
    _following.putIfAbsent(followerId, () => {}).add(followeeId);
    _followers.putIfAbsent(followeeId, () => {}).add(followerId);
  }

  bool isFollowing(String fromUserId, String toUserId) {
    return _following[fromUserId]?.contains(toUserId) ?? false;
  }

  void toggleFollow(String currentUserId, String targetUserId) {
    if (isFollowing(currentUserId, targetUserId)) {
      _following[currentUserId]?.remove(targetUserId);
      _followers[targetUserId]?.remove(currentUserId);
    } else {
      _addFollow(currentUserId, targetUserId);
    }
    notifyListeners();
  }

  List<SocialUser> getFollowing(String userId) {
    final ids = _following[userId] ?? {};
    return _allUsers.where((u) => ids.contains(u.id)).toList();
  }

  List<SocialUser> getFollowers(String userId) {
    final ids = _followers[userId] ?? {};
    return _allUsers.where((u) => ids.contains(u.id)).toList();
  }

  // Direct Messages
  bool canMessageDirectly(String currentUserId, String peerId) {
    final peerUser = _allUsers.firstWhere((u) => u.id == peerId, orElse: () => SocialUser(id: '', fullName: '', username: ''));
    if (peerUser.id.isEmpty) return false;

    // Find current user's university (pass it separately in practice)
    // For mock: same uni = can message directly
    return isFollowing(currentUserId, peerId) && isFollowing(peerId, currentUserId);
  }

  DirectConversation getOrCreateConversation(String currentUserId, SocialUser peer, bool sameUni) {
    if (!_conversations.containsKey(peer.id)) {
      _conversations[peer.id] = DirectConversation(
        peerId: peer.id,
        peerName: peer.fullName,
        peerUniversity: peer.university,
        chatRequestAccepted: sameUni,
        // Pre-populate with mock messages for same-uni
        messages: sameUni
            ? [
                DirectMessage(id: 'm1', senderId: peer.id, text: 'Merhaba! Aynı üniversitedeyiz 🎓', sentAt: DateTime.now().subtract(const Duration(hours: 2))),
              ]
            : [],
      );
    }
    return _conversations[peer.id]!;
  }

  void sendMessage(String peerId, String text, String currentUserId) {
    final conv = _conversations[peerId];
    if (conv == null) return;
    conv.messages.add(DirectMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      text: text,
      sentAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void sendChatRequest(String peerId, String peerName, String fromUserId, String fromName) {
    final conv = _conversations.putIfAbsent(
      peerId,
      () => DirectConversation(
        peerId: peerId,
        peerName: peerName,
        chatRequestSent: true,
        chatRequestAccepted: false,
      ),
    );
    conv.chatRequestSent = true;
    notifyListeners();
  }

  void acceptChatRequest(String fromUserId) {
    final conv = _conversations[fromUserId];
    if (conv != null) {
      conv.chatRequestAccepted = true;
      conv.chatRequestReceived = false;
      notifyListeners();
    }
  }

  List<DirectConversation> get conversations => _conversations.values.toList();
}

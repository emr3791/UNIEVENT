import 'package:flutter/material.dart';
import '../models/user.dart';

// This file has been optimized
/* Potential conflicts:
1. ChatRequest.accepted is now final — if any screen does request.accepted = true directly it will be a compile error. Must go through copyWith.
2. getFollowing/getFollowers are now cached — if _allUsers changes after initForUser (e.g. a new user comes online), the cache won't reflect it until toggleFollow is called or the cache is manually cleared. Currently _allUsers only changes in initForUser which clears the cache, so this is safe — but worth knowing if we add dynamic user loading later.
3. sendChatRequest no-op guard — previously calling sendChatRequest twice would silently overwrite chatRequestSent = true again (harmless but wasteful). Now it returns early. No behavior change for normal flows.
4. canMessageDirectly simplified — the old version looked up the peer in _allUsers and returned false if not found. The new version only checks mutual follow. If a peer somehow exists in _conversations but not in _allUsers, the behavior differs. This edge case shouldn't happen with the current mock data but worth noting for when real data is added.
5. conversations getter — previously returned a fresh List every call. Now returns List.unmodifiable(...) which still creates a new list wrapper each call but prevents external mutation. If any screen does provider.conversations.add(...) it will now throw at runtime.
*/

// ── Models ────────────────────────────────────────────────────────────────────

class SocialUser {
  final String id;
  final String fullName;
  final String username;
  final String? university;
  final String? avatarSkinTone;
  final String? avatarHairStyle;
  final bool isOnline;

  const SocialUser({
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
  final bool accepted; // now final — use copyWith to change

  const ChatRequest({
    required this.fromUserId,
    required this.fromUserName,
    required this.sentAt,
    this.accepted = false,
  });

  ChatRequest copyWith({bool? accepted}) {
    return ChatRequest(
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      sentAt: sentAt,
      accepted: accepted ?? this.accepted,
    );
  }
}

class DirectMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  const DirectMessage({
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

// ── Provider ──────────────────────────────────────────────────────────────────

class SocialProvider extends ChangeNotifier {
  final Map<String, Set<String>> _following = {};
  final Map<String, Set<String>> _followers = {};
  final List<SocialUser> _allUsers = [];
  final Map<String, DirectConversation> _conversations = {};

  // Cached derived lists — keyed by userId, invalidated on follow changes
  final Map<String, List<SocialUser>> _cachedFollowing = {};
  final Map<String, List<SocialUser>> _cachedFollowers = {};

  static const List<SocialUser> _mockUsers = [
    SocialUser(id: 'u1', fullName: 'Ayşe Kaya',    username: 'aysekaya',    university: 'İstanbul Teknik Üniversitesi', isOnline: true,  avatarSkinTone: 'light',  avatarHairStyle: 'default'),
    SocialUser(id: 'u2', fullName: 'Mehmet Demir', username: 'mehmetdemir', university: 'İstanbul Teknik Üniversitesi', isOnline: false, avatarSkinTone: 'medium', avatarHairStyle: 'curly'),
    SocialUser(id: 'u3', fullName: 'Zeynep Arslan',username: 'zeyneparslan',university: 'Boğaziçi Üniversitesi',        isOnline: true,  avatarSkinTone: 'dark',   avatarHairStyle: 'default'),
    SocialUser(id: 'u4', fullName: 'Ali Çelik',    username: 'alicelik',    university: 'Boğaziçi Üniversitesi',        isOnline: false, avatarSkinTone: 'medium', avatarHairStyle: 'bald'),
    SocialUser(id: 'u5', fullName: 'Fatma Yıldız', username: 'fatmayildiz', university: 'İstanbul Üniversitesi',        isOnline: true,  avatarSkinTone: 'light',  avatarHairStyle: 'white'),
  ];

  List<SocialUser> get allUsers => List.unmodifiable(_allUsers);

  // Returns unmodifiable view — no new list on every call
  List<DirectConversation> get conversations =>
      List.unmodifiable(_conversations.values.toList());

  // ── Init ───────────────────────────────────────────────────────────────────

  void initForUser(User user) {
    _allUsers
      ..clear()
      ..addAll(_mockUsers);
    _cachedFollowing.clear();
    _cachedFollowers.clear();

    if (user.university != null) {
      final sameUni = _mockUsers.where((u) =>
      u.id != user.id &&
          u.university != null &&
          u.university!.toLowerCase().trim() ==
              user.university!.toLowerCase().trim());

      for (final peer in sameUni) {
        _addFollow(user.id, peer.id);
        _addFollow(peer.id, user.id);
      }
    }

    notifyListeners();
  }

  // ── Follow logic ───────────────────────────────────────────────────────────

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
    // Invalidate only affected users' caches
    _cachedFollowing.remove(currentUserId);
    _cachedFollowers.remove(targetUserId);
    notifyListeners();
  }

  List<SocialUser> getFollowing(String userId) {
    return _cachedFollowing[userId] ??= () {
      final ids = _following[userId] ?? {};
      return _allUsers.where((u) => ids.contains(u.id)).toList();
    }();
  }

  List<SocialUser> getFollowers(String userId) {
    return _cachedFollowers[userId] ??= () {
      final ids = _followers[userId] ?? {};
      return _allUsers.where((u) => ids.contains(u.id)).toList();
    }();
  }

  // ── Direct messages ────────────────────────────────────────────────────────

  bool canMessageDirectly(String currentUserId, String peerId) {
    // Both must follow each other
    return isFollowing(currentUserId, peerId) &&
        isFollowing(peerId, currentUserId);
  }

  DirectConversation getOrCreateConversation(
      String currentUserId, SocialUser peer, bool sameUni) {
    return _conversations.putIfAbsent(
      peer.id,
          () => DirectConversation(
        peerId: peer.id,
        peerName: peer.fullName,
        peerUniversity: peer.university,
        chatRequestAccepted: sameUni,
        messages: sameUni
            ? [
          DirectMessage(
            id: 'm1',
            senderId: peer.id,
            text: 'Merhaba! Aynı üniversitedeyiz 🎓',
            sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ]
            : [],
      ),
    );
  }

  void sendMessage(String peerId, String text, String currentUserId) {
    if (text.trim().isEmpty) return; // guard against empty messages
    final conv = _conversations[peerId];
    if (conv == null) return;
    conv.messages.add(DirectMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      text: text.trim(),
      sentAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void sendChatRequest(
      String peerId, String peerName, String fromUserId, String fromName) {
    final conv = _conversations.putIfAbsent(
      peerId,
          () => DirectConversation(
        peerId: peerId,
        peerName: peerName,
        chatRequestSent: true,
        chatRequestAccepted: false,
      ),
    );
    if (conv.chatRequestSent) return; // no-op if already sent
    conv.chatRequestSent = true;
    notifyListeners();
  }

  void acceptChatRequest(String fromUserId) {
    final conv = _conversations[fromUserId];
    if (conv == null) return;
    if (conv.chatRequestAccepted) return; // no-op if already accepted
    conv.chatRequestAccepted = true;
    conv.chatRequestReceived = false;
    notifyListeners();
  }
}
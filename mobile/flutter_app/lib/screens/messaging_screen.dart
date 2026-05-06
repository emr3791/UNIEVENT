import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/event_chat_provider.dart';
import 'event_chat_screen.dart';

// This file has been optimized

// ── Constants ─────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF6366F1);
const _kBgColor = Color(0xFFF7F7F9);

// ── MessagingScreen ───────────────────────────────────────────────────────────
class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.read for AuthProvider — we don't need to rebuild when auth changes
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Giriş yapmanız gerekiyor.'));
    }

    // context.watch only for providers whose changes should rebuild this screen
    final socialProvider = context.watch<SocialProvider>();
    final eventRooms = context.watch<EventChatProvider>().allRooms.toList();
    final conversations = socialProvider.conversations;
    final following = socialProvider.getFollowing(currentUser.id);

    return Scaffold(
      backgroundColor: _kBgColor,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        title: const Text(
          'Mesajlar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Following horizontal list ────────────────────────────────────
          if (following.isNotEmpty)
            _FollowingBar(
              following: following,
              currentUser: currentUser,
              socialProvider: socialProvider,
            ),
          const Divider(height: 1),

          // ── Event chat rooms ─────────────────────────────────────────────
          if (eventRooms.isNotEmpty)
            _EventRoomsSection(eventRooms: eventRooms),

          // ── Conversations list ───────────────────────────────────────────
          Expanded(
            child: conversations.isEmpty
                ? const _EmptyConversations()
                : _ConversationsList(
              conversations: conversations,
              currentUser: currentUser,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Following bar ─────────────────────────────────────────────────────────────
class _FollowingBar extends StatelessWidget {
  final List<SocialUser> following;
  final dynamic currentUser;
  final SocialProvider socialProvider;

  const _FollowingBar({
    required this.following,
    required this.currentUser,
    required this.socialProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: following.length,
        itemBuilder: (context, i) {
          final user = following[i];
          return _FollowingAvatar(
            user: user,
            currentUser: currentUser,
            socialProvider: socialProvider,
          );
        },
      ),
    );
  }
}

// ── Following avatar item — extracted so each rebuilds independently ──────────
class _FollowingAvatar extends StatelessWidget {
  final SocialUser user;
  final dynamic currentUser;
  final SocialProvider socialProvider;

  const _FollowingAvatar({
    required this.user,
    required this.currentUser,
    required this.socialProvider,
  });

  bool _isSameUni() {
    return user.university != null &&
        currentUser.university != null &&
        user.university!.toLowerCase() == currentUser.university!.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sameUni = _isSameUni();
        socialProvider.getOrCreateConversation(currentUser.id, user, sameUni);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DirectChatScreen(
              peerId: user.id,
              peerName: user.fullName,
              currentUserId: currentUser.id,
              sameUniversity: sameUni,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _kPrimary.withAlpha(38),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : '?',
                    style: const TextStyle(fontSize: 20, color: _kPrimary),
                  ),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              user.username.length > 8
                  ? '${user.username.substring(0, 7)}...'
                  : user.username,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event rooms section ───────────────────────────────────────────────────────
class _EventRoomsSection extends StatelessWidget {
  final List<dynamic> eventRooms;

  const _EventRoomsSection({required this.eventRooms});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Etkinlik Sohbetleri',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${eventRooms.length}'),
              ],
            ),
          ),
          // shrinkWrap inside a Column is fine here since the list is
          // bounded by the Column — not inside a scrollable parent
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: eventRooms.length,
            itemBuilder: (context, i) {
              final room = eventRooms[i];
              final last = room.messages.isNotEmpty
                  ? room.messages.last.text
                  : 'Henüz mesaj yok';
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF6366F1), // withAlpha on const — use solid
                  child: Icon(Icons.event_note, color: Colors.white),
                ),
                title: Text(room.eventTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                Text(last, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text('${room.memberIds.length}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventChatScreen(
                        eventId: room.eventId,
                        eventTitle: room.eventTitle,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Henüz sohbet yok',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Aynı üniversitedeki kullanıcıları takip ettiğinde\notomatik olarak mesajlaşabilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Conversations list ────────────────────────────────────────────────────────
class _ConversationsList extends StatelessWidget {
  final List<dynamic> conversations;
  final dynamic currentUser;

  const _ConversationsList({
    required this.conversations,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, i) {
        final conv = conversations[i];
        final lastMsg = conv.messages.isNotEmpty
            ? conv.messages.last.text
            : 'Henüz mesaj yok';
        final hasRequest = conv.chatRequestSent && !conv.chatRequestAccepted;
        final sameUni = conv.peerUniversity != null &&
            currentUser.university != null &&
            conv.peerUniversity!.toLowerCase() ==
                currentUser.university!.toLowerCase();

        return ListTile(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: _kPrimary.withAlpha(38),
            child: Text(
              conv.peerName.isNotEmpty ? conv.peerName[0] : '?',
              style: const TextStyle(fontSize: 18, color: _kPrimary),
            ),
          ),
          title: Text(conv.peerName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            hasRequest ? '⏳ Sohbet isteği gönderildi' : lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: hasRequest ? Colors.orange : Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DirectChatScreen(
                  peerId: conv.peerId,
                  peerName: conv.peerName,
                  currentUserId: currentUser.id,
                  sameUniversity: sameUni,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── DirectChatScreen ──────────────────────────────────────────────────────────
class DirectChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String currentUserId;
  final bool sameUniversity;

  const DirectChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.currentUserId,
    required this.sameUniversity,
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(SocialProvider socialProvider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    socialProvider.sendMessage(widget.peerId, text, widget.currentUserId);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = context.watch<SocialProvider>();
    final peer = socialProvider.allUsers.firstWhere(
          (u) => u.id == widget.peerId,
      orElse: () =>
          SocialUser(id: widget.peerId, fullName: widget.peerName, username: ''),
    );

    final conv = socialProvider.getOrCreateConversation(
      widget.currentUserId,
      peer,
      widget.sameUniversity,
    );

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _kPrimary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withAlpha(64),
              child: Text(
                widget.peerName.isNotEmpty ? widget.peerName[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName,
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
                if (peer.university != null)
                  Text(peer.university!,
                      style: const TextStyle(
                          fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!conv.chatRequestAccepted && !widget.sameUniversity)
            _ChatRequestBanner(
              peerName: widget.peerName,
              conv: conv,
              onSendRequest: () => socialProvider.sendChatRequest(
                widget.peerId,
                widget.peerName,
                widget.currentUserId,
                'Ben',
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: conv.messages.length,
              itemBuilder: (context, index) {
                final msg = conv.messages[index];
                final isMe = msg.senderId == widget.currentUserId;
                return _MessageBubble(msg: msg, isMe: isMe);
              },
            ),
          ),
          if (conv.chatRequestAccepted || widget.sameUniversity)
            _InputBar(
              controller: _controller,
              onSend: () => _sendMessage(socialProvider),
            ),
        ],
      ),
    );
  }
}

// ── Chat request banner ───────────────────────────────────────────────────────
class _ChatRequestBanner extends StatelessWidget {
  final String peerName;
  final dynamic conv;
  final VoidCallback onSendRequest;

  const _ChatRequestBanner({
    required this.peerName,
    required this.conv,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.amber.shade50,
      child: Column(
        children: [
          const Icon(Icons.lock_clock, color: Colors.amber, size: 28),
          const SizedBox(height: 8),
          Text('$peerName farklı bir üniversiteden.',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            'Mesaj göndermeden önce sohbet isteği göndermeniz gerekiyor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (!conv.chatRequestSent)
            ElevatedButton.icon(
              onPressed: onSendRequest,
              icon: const Icon(Icons.send, size: 18, color: Colors.white),
              label: const Text('Sohbet İsteği Gönder',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                SizedBox(width: 6),
                Text('İstek gönderildi, bekleniyor...',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Message bubble — extracted so each message rebuilds independently ─────────
class _MessageBubble extends StatelessWidget {
  final dynamic msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 3,
        bottom: 3,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    hintText: 'Mesaj yaz...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: _kPrimary,
                child: Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
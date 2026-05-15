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

    final theme = Theme.of(context);
    // context.watch only for providers whose changes should rebuild this screen
    final socialProvider = context.watch<SocialProvider>();
    final eventRooms = context.watch<EventChatProvider>().allRooms.toList();
    final conversations = socialProvider.conversations;
    final following = socialProvider.getFollowing(currentUser.id);
    final hasEventRooms = eventRooms.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Mesajlar',
          style: TextStyle(
              color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
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
          if (eventRooms.isNotEmpty) _EventRoomsSection(eventRooms: eventRooms),

          // ── Conversations list ───────────────────────────────────────────
          Expanded(
            child: conversations.isEmpty
                ? _EmptyConversations(hasEventRooms: hasEventRooms)
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
    final theme = Theme.of(context);
    return Container(
      height: 90,
      color: theme.colorScheme.surface,
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
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(38),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : '?',
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary),
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
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Etkinlik Sohbetleri',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface),
                ),
                Text('${eventRooms.length}',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
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
                  backgroundColor:
                      Color(0xFF6366F1), // withAlpha on const — use solid
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
  final bool hasEventRooms;

  const _EmptyConversations({required this.hasEventRooms});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: theme.colorScheme.onSurface.withOpacity(0.24)),
            const SizedBox(height: 16),
            Text(
              hasEventRooms
                  ? 'Sohbetleriniz burada listeleniyor.'
                  : 'Henüz sohbet yok',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.78),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              hasEventRooms
                  ? 'Etkinlik sohbetleri sekmesinden bir etkinliğe katılarak daha fazla mesajlaşabilirsiniz.'
                  : 'Daha fazla sohbet için etkinliklere katılın ve yeni sohbetlere dahil olun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.60),
                  fontSize: 13),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
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
            backgroundColor: theme.colorScheme.primary.withAlpha(38),
            child: Text(
              conv.peerName.isNotEmpty ? conv.peerName[0] : '?',
              style: TextStyle(fontSize: 18, color: theme.colorScheme.primary),
            ),
          ),
          title: Text(conv.peerName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(
            hasRequest ? '⏳ Sohbet isteği gönderildi' : lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: hasRequest
                    ? Colors.orange
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.78)),
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
    final theme = Theme.of(context);
    final socialProvider = context.watch<SocialProvider>();
    final peer = socialProvider.allUsers.firstWhere(
      (u) => u.id == widget.peerId,
      orElse: () => SocialUser(
          id: widget.peerId, fullName: widget.peerName, username: ''),
    );

    final conv = socialProvider.getOrCreateConversation(
      widget.currentUserId,
      peer,
      widget.sameUniversity,
    );

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.onPrimary.withAlpha(64),
              child: Text(
                widget.peerName.isNotEmpty ? widget.peerName[0] : '?',
                style:
                    TextStyle(color: theme.colorScheme.primary, fontSize: 14),
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
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white70)),
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
            child: conv.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message_outlined,
                              size: 72,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.20)),
                          const SizedBox(height: 18),
                          Text(
                            'Henüz mesaj yok',
                            style: TextStyle(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.78),
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yeni bir mesaj göndermek için aşağıdaki kutuyu kullanın.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: theme.colorScheme.onBackground
                                    .withOpacity(0.60),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_clock, color: theme.colorScheme.secondary, size: 28),
          const SizedBox(height: 8),
          Text('$peerName farklı bir üniversiteden.',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer)),
          const SizedBox(height: 4),
          Text(
            'Mesaj göndermeden önce sohbet isteği göndermeniz gerekiyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color:
                    theme.colorScheme.onSecondaryContainer.withOpacity(0.88)),
          ),
          const SizedBox(height: 12),
          if (!conv.chatRequestSent)
            ElevatedButton.icon(
              onPressed: onSendRequest,
              icon: Icon(Icons.send,
                  size: 18, color: theme.colorScheme.onSecondary),
              label: Text('Sohbet İsteği Gönder',
                  style: TextStyle(color: theme.colorScheme.onSecondary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
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
    final theme = Theme.of(context);
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
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
                  color: isMe
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.56)),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  color: theme.colorScheme.background,
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
              child: CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.send,
                    color: theme.colorScheme.onPrimary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

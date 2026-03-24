import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_chat_provider.dart';
import '../providers/auth_provider.dart';

class EventChatScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const EventChatScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<EventChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final currentUserId = currentUser?.id ?? 'guest';
    final currentUserName = currentUser?.fullName ?? 'Kullanıcı';

    final room = chatProvider.getOrCreateRoom(widget.eventId, widget.eventTitle);
    final isAdm = chatProvider.isAdmin(widget.eventId, currentUserId);

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.eventTitle, style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(
              '${room.memberIds.length} katılımcı',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (isAdm)
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onSelected: (val) {
                if (val == 'toggle_restrict') {
                  chatProvider.toggleMessagingRestriction(widget.eventId, currentUserId);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle_restrict',
                  child: Row(
                    children: [
                      Icon(room.isMessagingRestricted ? Icons.lock_open : Icons.lock, size: 20),
                      const SizedBox(width: 8),
                      Text(room.isMessagingRestricted ? 'Kısıtlamayı Kaldır' : 'Sohbeti Kısıtla'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          if (room.isMessagingRestricted && !isAdm)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sohbet yalnızca adminler tarafından kullanılabilir.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: room.messages.length,
              itemBuilder: (context, index) {
                final msg = room.messages[index];
                final isMe = msg.senderId == currentUserId;
                final isSystem = msg.type == ChatMessageType.system;
                final isAnnouncement = msg.type == ChatMessageType.announcement;

                if (isSystem) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(msg.text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                  );
                }

                if (isAnnouncement) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.campaign, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(msg.senderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  );
                }

                return _buildMessageBubble(msg, isMe);
              },
            ),
          ),
          _buildInput(room, isAdm, currentUserId, currentUserName, chatProvider),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.15),
              child: Text(msg.senderName.isNotEmpty ? msg.senderName[0] : '?',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1))),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(msg.senderName, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                        if (msg.isAdmin) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 13, color: Color(0xFF6366F1)),
                        ],
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF6366F1) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
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
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInput(EventChatRoom room, bool isAdmin, String userId, String userName, EventChatProvider chatProvider) {
    final canSend = isAdmin || !room.isMessagingRestricted;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, -2))],
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
                  controller: _textController,
                  enabled: canSend,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: canSend ? 'Mesaj yaz...' : 'Sohbet kısıtlandı',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: canSend
                  ? () {
                      final text = _textController.text.trim();
                      if (text.isEmpty) return;
                      chatProvider.sendMessage(widget.eventId, userId, userName, text, isAdmin: isAdmin);
                      _textController.clear();
                    }
                  : null,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: canSend ? const Color(0xFF6366F1) : Colors.grey.shade300,
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

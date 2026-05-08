// This file has been revised
/* Potential conflicts:
1. Anything that constructs ChatMessage manually and expects a crash on bad data
Previously bad JSON would throw immediately, making bugs obvious. Now it silently uses fallbacks.
2. copyWith cannot set nullable fields back to null
attachmentUrl is nullable, but calling message.copyWith(attachmentUrl: null) won't clear it — null is treated as "no change". If any screen needs to remove an attachment from an existing message, it needs a workaround.
3. timestamp fallback is DateTime.now()
If a message arrives from the backend with a missing or malformed timestamp, it will silently show the current time instead of the actual send time. Messages could appear out of order in the chat UI. Worth adding a debugPrint warning
*/

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
    };
  }
}
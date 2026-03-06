class Conversation {
  final String id;
  final String? orderId;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;

  // Frontend convenience field for who they are talking to
  final String? otherUserName;
  final String? otherUserAvatar;

  Conversation({
    required this.id,
    this.orderId,
    this.lastMessage,
    required this.unreadCount,
    this.updatedAt,
    this.otherUserName,
    this.otherUserAvatar,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String?,
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      otherUserName: json['other_user_name'] as String?,
      otherUserAvatar: json['other_user_avatar'] as String?,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

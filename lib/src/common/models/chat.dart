import 'user.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['id'].toString(),
      senderId: json['sender_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      isMe: json['sender_id'] == currentUserId,
    );
  }
}

class Chat {
  final String id;
  final List<User>? participants;
  final List<Message> messages;
  final String lastMessage;
  final DateTime lastUpdated;

  Chat({
    required this.id,
    this.participants,
    required this.messages,
    required this.lastMessage,
    required this.lastUpdated,
  });

  factory Chat.fromJson(Map<String, dynamic> json, String currentUserId) {
    final messagesJson = json['messages'] as List? ?? [];
    final messages = messagesJson
        .map((m) => Message.fromJson(m, currentUserId))
        .toList();
    
    return Chat(
      id: json['id'],
      messages: messages,
      lastMessage: messages.isNotEmpty ? messages.last.content : '',
      lastUpdated: DateTime.parse(json['created_at']),
    );
  }
}


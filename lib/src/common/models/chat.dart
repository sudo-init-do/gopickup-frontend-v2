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
}

class Chat {
  final String id;
  final List<User> participants;
  final List<Message> messages;
  final String lastMessage;
  final DateTime lastUpdated;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
    required this.lastMessage,
    required this.lastUpdated,
  });
}

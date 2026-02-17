import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/chat.dart';
import '../../../common/models/user.dart';

class ChatRepository {
  final List<Chat> _chats = [
    Chat(
      id: 'chat-1',
      participants: [
        User(id: 'me', name: 'Me', role: UserRole.client),
        User(
          id: 'v1',
          name: 'BuildMart Supplies',
          role: UserRole.vendor,
          avatarUrl: '',
        ),
      ],
      messages: [
        Message(
          id: 'm1',
          senderId: 'v1',
          content: 'Your order has been shipped!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isMe: false,
        ),
      ],
      lastMessage: 'Your order has been shipped!',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    Chat(
      id: 'chat-2',
      participants: [
        User(id: 'me', name: 'Me', role: UserRole.client),
        User(
          id: 'd1',
          name: 'John Driver',
          role: UserRole.driver,
          avatarUrl: '',
        ),
      ],
      messages: [
        Message(
          id: 'm1',
          senderId: 'd1',
          content: "I'll be there in 15 minutes",
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isMe: false,
        ),
      ],
      lastMessage: "I'll be there in 15 minutes",
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Chat(
      id: 'chat-3',
      participants: [
        User(id: 'me', name: 'Me', role: UserRole.client),
        User(
          id: 'v2',
          name: 'Steel Works Co.',
          role: UserRole.vendor,
          avatarUrl: '',
        ),
      ],
      messages: [
        Message(
          id: 'm1',
          senderId: 'v2',
          content: 'Thank you for your order!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isMe: false,
        ),
      ],
      lastMessage: 'Thank you for your order!',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Chat> getChats() {
    return _chats;
  }

  Chat getChat(String id) {
    return _chats.firstWhere((c) => c.id == id);
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatsProvider = Provider<List<Chat>>((ref) {
  return ref.watch(chatRepositoryProvider).getChats();
});

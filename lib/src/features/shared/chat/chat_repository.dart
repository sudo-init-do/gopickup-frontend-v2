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
          content: 'I will be there in 10 mins.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isMe: false,
        ),
        Message(
          id: 'm2',
          senderId: 'me',
          content: 'Great, see you then.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          isMe: true,
        ),
      ],
      lastMessage: 'Great, see you then.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Chat(
      id: 'chat-2',
      participants: [
        User(id: 'me', name: 'Me', role: UserRole.client),
        User(
          id: 'v1',
          name: 'Cement Supplier',
          role: UserRole.vendor,
          avatarUrl: '',
        ),
      ],
      messages: [
        Message(
          id: 'm1',
          senderId: 'v1',
          content: 'Your order is ready for pickup.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isMe: false,
        ),
      ],
      lastMessage: 'Your order is ready for pickup.',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
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

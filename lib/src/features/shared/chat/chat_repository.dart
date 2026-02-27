import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/chat.dart';

class ChatRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  ChatRepository(this._apiClient);

  Future<String?> _getCurrentUserId() async {
    // We might want to store user_id in secure storage upon login
    // For now, let's assume it's there or we provide it
    return await _storage.read(key: 'user_id');
  }

  Future<List<Chat>> getChats() async {
    try {
      final userId = await _getCurrentUserId() ?? '';
      final response = await _apiClient.get('/chats');
      final List<dynamic> data = response.data;
      return data.map((json) => Chat.fromJson(json, userId)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Chat?> getChat(String id) async {
    try {
      final userId = await _getCurrentUserId() ?? '';
      final response = await _apiClient.get('/chats/$id/messages');
      // Backend returns a conversation object which we can parse as Chat
      return Chat.fromJson(response.data, userId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final response = await _apiClient.post('/chats/message', data: {
        'conversation_id': conversationId,
        'content': content,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

final chatsProvider = FutureProvider<List<Chat>>((ref) {
  return ref.watch(chatRepositoryProvider).getChats();
});


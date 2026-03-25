import 'package:dio/dio.dart';
import '../models/chat_models.dart';
import 'api_client.dart';

class ChatApi {
  Future<Conversation> initiateChat({
    required String recipientUserId,
    String? orderId,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        'chats/initiate',
        data: {'recipient_user_id': recipientUserId, 'order_id': ?orderId},
      );
      return Conversation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to initiate chat');
    }
  }

  Future<List<Conversation>> getChats() async {
    try {
      final response = await ApiClient.dio.get('chats');
      return (response.data as List)
          .map((c) => Conversation.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get chats');
    }
  }

  Future<Map<String, dynamic>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'chats/$chatId/messages',
        queryParameters: {'page': page, 'limit': limit},
      );
      List<Message> messages = (response.data['data'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
      return {'messages': messages, 'meta': response.data['meta']};
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get messages');
    }
  }

  Future<void> markRead(String chatId) async {
    try {
      await ApiClient.dio.patch('chats/$chatId/read');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to mark chat as read',
      );
    }
  }
}

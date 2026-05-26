import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../api/chat_api.dart';
import '../realtime/websocket_service.dart';
import 'auth_provider.dart';
import 'order_provider.dart';

class ChatState {
  final List<Conversation> conversations;
  final List<Message> currentMessages;
  final bool isLoading;
  final String? error;

  ChatState({
    required this.conversations,
    required this.currentMessages,
    required this.isLoading,
    this.error,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    List<Message>? currentMessages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final _chatApi = ChatApi();
  // Use the single shared WebSocket connection (opened on login) so chat
  // events arrive on the same authenticated socket as order events.
  WebSocketService get _wsService => ref.read(websocketServiceProvider);

  String? _currentChatId;

  @override
  ChatState build() {
    _init();
    return ChatState(conversations: [], currentMessages: [], isLoading: false);
  }

  void _init() {
    _wsService.onNewMessage.listen((payload) {
      _handleIncomingMessage(payload);
    });

    fetchConversations();
  }

  void _handleIncomingMessage(Map<String, dynamic> payload) {
    try {
      final message = Message.fromJson(payload);
      if (message.chatId == _currentChatId) {
        state = state.copyWith(
          currentMessages: [...state.currentMessages, message],
        );
      }
      _updateConversationLastMessage(message.chatId, message.content);
    } catch (e) {
      // ignore parsing error for now
    }
  }

  void _updateConversationLastMessage(String chatId, String content) {
    final updated = state.conversations.map((c) {
      if (c.id == chatId) {
        return Conversation(
          id: c.id,
          orderId: c.orderId,
          lastMessage: content,
          unreadCount: c.id == _currentChatId
              ? c.unreadCount
              : c.unreadCount + 1,
          updatedAt: DateTime.now(),
          otherUserName: c.otherUserName,
          otherUserAvatar: c.otherUserAvatar,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(conversations: updated);
  }

  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversations = await _chatApi.getChats();
      state = state.copyWith(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMessages(String chatId) async {
    _currentChatId = chatId;
    state = state.copyWith(isLoading: true, error: null, currentMessages: []);
    try {
      final data = await _chatApi.getMessages(chatId);
      final messages = data['messages'] as List<Message>? ?? [];

      state = state.copyWith(currentMessages: messages, isLoading: false);

      _wsService.joinChatRoom(chatId);

      try {
        await _chatApi.markRead(chatId);
      } catch (e) {
        // fail silently if marking read fails
      }

      final updated = state.conversations.map((c) {
        if (c.id == chatId) {
          return Conversation(
            id: c.id,
            orderId: c.orderId,
            lastMessage: c.lastMessage,
            unreadCount: 0,
            updatedAt: c.updatedAt,
            otherUserName: c.otherUserName,
            otherUserAvatar: c.otherUserAvatar,
          );
        }
        return c;
      }).toList();
      state = state.copyWith(conversations: updated);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void leaveChat() {
    if (_currentChatId != null) {
      _currentChatId = null;
    }
    state = state.copyWith(currentMessages: []);
  }

  Future<void> sendMessage(String text) async {
    if (_currentChatId == null) return;

    _wsService.sendChatMessage(_currentChatId!, text);

    final user = ref.read(authProvider).user;
    if (user != null) {
      final tempMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: _currentChatId!,
        senderId: user.id,
        content: text,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        currentMessages: [...state.currentMessages, tempMessage],
      );
      _updateConversationLastMessage(_currentChatId!, text);
    }
  }

  Future<Conversation?> initiateChat(
    String recipientId, {
    String? orderId,
  }) async {
    try {
      final conv = await _chatApi.initiateChat(
        recipientUserId: recipientId,
        orderId: orderId,
      );
      final exists = state.conversations.any((c) => c.id == conv.id);
      if (!exists) {
        state = state.copyWith(conversations: [conv, ...state.conversations]);
      }
      return conv;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});

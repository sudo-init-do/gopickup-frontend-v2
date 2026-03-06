import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String wsUrl = 'wss://backend.gopickup.com.ng/api/v1/ws';
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Connection State
  bool get isConnected => _channel != null;

  // Event Streams for the UI to listen to
  final _orderStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _newBidController = StreamController<Map<String, dynamic>>.broadcast();
  final _bidAcceptedController = StreamController<Map<String, dynamic>>.broadcast();
  final _driverMovedController = StreamController<Map<String, dynamic>>.broadcast();
  final _newMessageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOrderStatusUpdated => _orderStatusController.stream;
  Stream<Map<String, dynamic>> get onNewBid => _newBidController.stream;
  Stream<Map<String, dynamic>> get onBidAccepted => _bidAcceptedController.stream;
  Stream<Map<String, dynamic>> get onDriverMoved => _driverMovedController.stream;
  Stream<Map<String, dynamic>> get onNewMessage => _newMessageController.stream;

  void connect(String token) {
    if (_channel != null) return;
    
    try {
      final uri = Uri.parse('$wsUrl?token=$token');
      _channel = WebSocketChannel.connect(uri);
      
      _subscription = _channel?.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _reconnect(token);
        },
        onError: (err) {
          debugPrint('WebSocket error: $err');
          _reconnect(token);
        },
      );
    } catch (e) {
      debugPrint('Connection error: $e');
    }
  }

  void _reconnect(String token) {
    disconnect();
    Future.delayed(const Duration(seconds: 5), () {
      connect(token);
    });
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data as String) as Map<String, dynamic>;
      final event = decoded['event'] as String?;
      final payload = decoded['payload'] as Map<String, dynamic>?;

      if (event == null || payload == null) return;

      switch (event) {
        case 'order_status_updated':
          _orderStatusController.add(payload);
          break;
        case 'new_bid':
          _newBidController.add(payload);
          break;
        case 'bid_accepted':
          _bidAcceptedController.add(payload);
          break;
        case 'driver_moved':
          _driverMovedController.add(payload);
          break;
        case 'new_message':
          _newMessageController.add(payload);
          break;
        case 'notification':
          // Handle general notification event if needed
          break;
        default:
          debugPrint('Unknown WS event: $event');
      }
    } catch (e) {
      debugPrint('Error parsing WS message: $e');
    }
  }

  void _sendEvent(String event, Map<String, dynamic> payload) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'event': event,
        'payload': payload,
      }));
    } else {
      debugPrint('Attempted to send over WS while disconnected: $event');
    }
  }

  // --- Client -> Server Events ---

  void joinOrderRoom(String orderId) {
    _sendEvent('join_order_room', {'order_id': orderId});
  }

  void leaveOrderRoom(String orderId) {
    _sendEvent('leave_order_room', {'order_id': orderId});
  }

  void joinChatRoom(String chatId) {
    _sendEvent('join_chat_room', {'chat_id': chatId});
  }

  void sendChatMessage(String chatId, String text) {
    _sendEvent('chat_message', {
      'chat_id': chatId,
      'text': text,
    });
  }

  void sendDriverLocationUpdate(String orderId, double lat, double lng) {
    _sendEvent('driver_location_update', {
      'order_id': orderId,
      'lat': lat,
      'lng': lng,
    });
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/orders_api.dart';
import '../models/order_models.dart';
import '../realtime/websocket_service.dart';

final ordersApiProvider = Provider((ref) => OrdersApi());

final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class OrderNotifier extends Notifier<OrderState> {
  OrdersApi get _api => ref.read(ordersApiProvider);
  WebSocketService get _wsService => ref.read(websocketServiceProvider);

  @override
  OrderState build() {
    // Listen to websocket events to naturally update order state
    _wsService.onOrderStatusUpdated.listen((payload) {
      final orderId = payload['order_id'];
      final newStatus = payload['status'];
      updateOrderStatusInState(orderId, newStatus);
    });

    return OrderState();
  }

  void updateOrderStatusInState(String orderId, String status) {
    if (state.orders.isEmpty) return;
    
    final updatedList = state.orders.map((order) {
      if (order.id == orderId) {
        // Simple immutable state update simulating an update
        return Order(
          id: order.id,
          clientId: order.clientId,
          vendorId: order.vendorId,
          driverId: order.driverId,
          items: order.items,
          totalProductAmount: order.totalProductAmount,
          status: status,
          pickupAddress: order.pickupAddress,
          deliveryAddress: order.deliveryAddress,
          createdAt: order.createdAt,
          deliveryLat: order.deliveryLat,
          deliveryLng: order.deliveryLng,
        );
      }
      return order;
    }).toList();

    state = state.copyWith(orders: updatedList);
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.getOrders();
      state = state.copyWith(
        orders: response['orders'] as List<Order>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Order?> checkout({
    required List<OrderItem> items,
    required String paymentMethod,
    required String pickupAddress,
    required String deliveryAddress,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newOrder = await _api.checkout(
        items: items,
        paymentMethod: paymentMethod,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
      );
      // Fetch fresh orders
      await fetchOrders();
      return newOrder;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});

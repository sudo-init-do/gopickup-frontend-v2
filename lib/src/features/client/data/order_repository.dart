import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/order.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository(this._apiClient);

  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiClient.get('orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> getOrder(String id) async {
    final response = await _apiClient.get('orders/$id');
    return Order.fromJson(response.data);
  }

  Future<Order?> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        '/orders/checkout',
        data: {
          'items': items,
          'delivery_address': deliveryAddress,
          'payment_method': paymentMethod,
        },
      );

      if (response.statusCode == 201) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});

final ordersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});

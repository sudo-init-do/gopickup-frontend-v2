import 'package:dio/dio.dart';
import '../models/order_models.dart';
import 'api_client.dart';

class OrdersApi {
  Future<Order> checkout({
    required List<OrderItem> items,
    required String paymentMethod,
    required String pickupAddress,
    required String deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        'orders/checkout',
        data: {
          'items': items.map((i) => i.toJson()).toList(),
          'payment_method': paymentMethod,
          'pickup_address': pickupAddress,
          'delivery_address': deliveryAddress,
          'delivery_lat': ?deliveryLat,
          'delivery_lng': ?deliveryLng,
        },
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Checkout failed');
    }
  }

  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 10}) async {
    try {
      final response = await ApiClient.dio.get(
        'orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      List<Order> orders = (response.data['data'] as List)
          .map((o) => Order.fromJson(o))
          .toList();
      return {'orders': orders, 'meta': response.data['meta']};
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get orders');
    }
  }

  Future<Order> getOrderDetails(String id) async {
    try {
      final response = await ApiClient.dio.get('orders/$id');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get order details',
      );
    }
  }

  Future<List<JobBid>> getBids(String orderId) async {
    try {
      final response = await ApiClient.dio.get('orders/$orderId/bids');
      return (response.data as List).map((b) => JobBid.fromJson(b)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get bids');
    }
  }

  Future<Order> acceptBid(String orderId, String bidId) async {
    try {
      final response = await ApiClient.dio.post(
        'orders/$orderId/bids/$bidId/accept',
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to accept bid');
    }
  }

  Future<List<Order>> getDriverOrders() async {
    try {
      final response = await ApiClient.dio.get('driver/jobs');
      return (response.data as List).map((o) => Order.fromJson(o)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['error'] ?? 'Failed to get driver orders',
      );
    }
  }
}

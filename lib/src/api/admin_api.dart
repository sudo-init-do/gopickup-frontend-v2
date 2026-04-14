import 'package:dio/dio.dart';
import '../features/admin/domain/admin_stats.dart';
import '../models/order_models.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class AdminApi {
  Future<AdminStats> getStats() async {
    try {
      final response = await ApiClient.dio.get('admin/stats');
      return AdminStats.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load stats');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    try {
      final queryParams = role != null ? {'role': role} : <String, dynamic>{};
      final response = await ApiClient.dio.get('admin/users', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load users');
    }
  }

  Future<void> approveDriver(String userId) async {
    try {
      await ApiClient.dio.patch('admin/drivers/$userId/approve');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to approve driver');
    }
  }

  Future<void> approveVendor(String userId) async {
    try {
      await ApiClient.dio.patch('admin/vendors/$userId/approve');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to approve vendor');
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await ApiClient.dio.get('admin/orders');
      final List<dynamic> ordersJson = response.data;
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load orders');
    }
  }

  Future<void> assignDriver({
    required String orderId,
    required String driverId,
    required double agreedPrice,
    required double deliveryFee,
  }) async {
    try {
      await ApiClient.dio.post(
        'admin/orders/assign-driver',
        data: {
          'order_id': orderId,
          'driver_id': driverId,
          'agreed_price': agreedPrice,
          'delivery_fee': deliveryFee,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to assign driver');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ApiClient.dio.patch(
        'admin/orders/status',
        data: {'order_id': orderId, 'status': status},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update status');
    }
  }

  Future<void> confirmPayment(String orderId) async {
    try {
      await ApiClient.dio.post('vendor/orders/$orderId/confirm-payment');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to confirm payment');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await ApiClient.dio.delete('admin/users/$userId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to delete user');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await ApiClient.dio.delete('admin/products/$productId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to delete product');
    }
  }

  Future<void> verifyPayment({
    required String orderId,
    required double agreedPrice,
  }) async {
    try {
      await ApiClient.dio.post(
        'admin/orders/$orderId/verify-payment',
        data: {'agreed_price': agreedPrice},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to verify payment');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await ApiClient.dio.get('admin/users/recent', queryParameters: {'limit': limit});
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to load recent users');
    }
  }
}

import 'package:dio/dio.dart';
import '../models/order_models.dart';
import '../models/product_models.dart';
import 'api_client.dart';

class VendorApi {
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await ApiClient.dio.post('/vendor/products', data: productData);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to create product');
    }
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final response = await ApiClient.dio.put('/vendor/products/$id', data: productData);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ApiClient.dio.delete('/vendor/products/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to delete product');
    }
  }

  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await ApiClient.dio.patch('/vendor/orders/$orderId/status', data: {
        'status': status,
      });
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to update order status');
    }
  }

  Future<Order> markOrderReady(String orderId) async {
    try {
      final response = await ApiClient.dio.patch('/vendor/orders/$orderId/ready');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to mark order ready');
    }
  }

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await ApiClient.dio.get('/vendor/dashboard');
      return response.data; // { "total_sales": 100.0, "active_orders": 5 }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get vendor dashboard');
    }
  }
}

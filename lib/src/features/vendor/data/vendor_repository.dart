import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/product.dart';
import '../../../common/models/order.dart';
import 'package:dio/dio.dart';

class VendorRepository {
  final ApiClient _apiClient;

  VendorRepository(this._apiClient);

  Future<(bool, String?)> addProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
    required int moq,
    String? imageUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'moq': moq, // Sending both to avoid compatibility issues
        'minimum_order_quantity': moq, 
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['image_url'] = imageUrl;
      }

      final response = await _apiClient.post(
        'vendor/products', // Removed leading slash for consistency
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return (true, null);
      }
      return (false, 'Server returned ${response.statusCode}');
    } on DioException catch (e) {
      final msg = e.response?.data is Map 
          ? (e.response?.data['error'] ?? e.response?.data['message'] ?? e.message)
          : e.message;
      return (false, msg.toString());
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<String?> uploadProductImage(Uint8List bytes, String fileName) async {
    try {
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
      final response = await _apiClient.uploadImage('upload', file: multipartFile);
      if (response.statusCode == 200) {
        return response.data['image_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> getInventory() async {
    try {
      final response = await _apiClient.get('products/vendor/me');
      if (response.statusCode == 200) {
        final dynamic respData = response.data;
        if (respData is List) {
          return respData.map((json) => Product.fromJson(json)).toList();
        } else if (respData is Map && respData['products'] is List) {
          return (respData['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        } else if (respData is Map && respData['data'] is List) {
          return (respData['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiClient.get('orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _apiClient.patch(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(ref.watch(apiClientProvider));
});

final vendorOrdersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(vendorRepositoryProvider).getOrders();
});

final vendorInventoryProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(vendorRepositoryProvider).getInventory();
});

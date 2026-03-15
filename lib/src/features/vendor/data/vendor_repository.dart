import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/product.dart';
import '../../../common/models/order.dart';
import 'package:dio/dio.dart';

class VendorRepository {
  final ApiClient _apiClient;

  VendorRepository(this._apiClient);

  Future<bool> addProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
    required int moq,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiClient.post(
        '/vendor/products',
        data: {
          'name': name,
          'description': description,
          'category': category,
          'price': price,
          'stock': stock,
          'moq': moq,
          'image_url': imageUrl ?? '',
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadProductImage(String filePath, String fileName) async {
    try {
      final multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      final response = await _apiClient.uploadImage('/upload', file: multipartFile);
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
      final response = await _apiClient.get('/products/vendor/me');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');
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

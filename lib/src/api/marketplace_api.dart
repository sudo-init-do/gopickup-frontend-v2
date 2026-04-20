import 'package:dio/dio.dart';
import '../models/product_models.dart';
import '../models/user_models.dart';
import 'api_client.dart';

class MarketplaceApi {
  Future<Map<String, dynamic>> getProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? vendorId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'products',
        queryParameters: {
          if (category != null) 'category': category,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (vendorId != null) 'vendor_id': vendorId,
          if (search != null) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      // Assuming response format: { "data": [...], "meta": {...} }
      List<Product> products = (response.data['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
      return {'products': products, 'meta': response.data['meta']};
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get products');
    }
  }

  Future<Product> getProductDetails(String id) async {
    try {
      final response = await ApiClient.dio.get('products/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get product');
    }
  }

  Future<Map<String, dynamic>> getVendors({
    String? businessType,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        'vendors',
        queryParameters: {
          if (businessType != null) 'business_type': businessType,
          if (search != null) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      List<VendorProfile> vendors = (response.data['data'] as List)
          .map((v) => VendorProfile.fromJson(v))
          .toList();
      return {'vendors': vendors, 'meta': response.data['meta']};
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to get vendors');
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/api/api_client.dart';
import '../../../common/api/api_providers.dart';
import '../../../common/models/product.dart';

class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository(this._apiClient);

  Future<List<Product>> getProducts({String? category, String? query}) async {
    try {
      final response = await _apiClient.get(
        'products',
        queryParameters: {
          'unique_vendors': 'true',
          'page': 1,
          'limit': 50,
          if (category != null && category != 'All') 'category': category,
          if (query != null && query.isNotEmpty) 'search': query,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['items'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> getProduct(String id) async {
    final response = await _apiClient.get('products/$id');
    return Product.fromJson(response.data);
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});

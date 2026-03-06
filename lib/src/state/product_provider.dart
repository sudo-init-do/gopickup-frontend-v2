import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/marketplace_api.dart';
import '../models/product_models.dart';

final marketplaceApiProvider = Provider((ref) => MarketplaceApi());

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ProductState({this.products = const [], this.isLoading = false, this.error});

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ProductNotifier extends Notifier<ProductState> {
  MarketplaceApi get _api => ref.read(marketplaceApiProvider);

  @override
  ProductState build() {
    return ProductState();
  }

  Future<void> fetchProducts({String? category, String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.getProducts(
        category: category,
        search: search,
      );
      state = state.copyWith(
        products: response['products'] as List<Product>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productProvider = NotifierProvider<ProductNotifier, ProductState>(() {
  return ProductNotifier();
});

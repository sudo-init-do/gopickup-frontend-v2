import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/vendor_api.dart';
import '../models/product_models.dart';

final vendorApiProvider = Provider((ref) => VendorApi());

class VendorProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  VendorProductState({this.products = const [], this.isLoading = false, this.error});

  VendorProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return VendorProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VendorProductNotifier extends StateNotifier<VendorProductState> {
  final VendorApi _api;

  VendorProductNotifier(this._api) : super(VendorProductState());

  Future<void> fetchMyProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _api.getMyProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _api.deleteProduct(id);
      state = state.copyWith(
        products: state.products.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final vendorProductProvider = StateNotifierProvider<VendorProductNotifier, VendorProductState>((ref) {
  final api = ref.watch(vendorApiProvider);
  return VendorProductNotifier(api);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_models.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() {
    return {};
  }

  void addItem(Product product) {
    final current = state;
    
    // As per specs: All items must belong to the same Vendor
    if (current.isNotEmpty && current.values.first.product.vendorId != product.vendorId) {
      state = {
        product.id: CartItem(product: product, quantity: 1),
      };
      return;
    }

    if (current.containsKey(product.id)) {
      state = {
        ...current,
        product.id: current[product.id]!.copyWith(
          quantity: current[product.id]!.quantity + 1,
        ),
      };
    } else {
      state = {
        ...current,
        product.id: CartItem(product: product, quantity: 1),
      };
    }
  }

  void removeItem(String productId) {
    final current = state;
    if (!current.containsKey(productId)) return;

    final item = current[productId]!;
    if (item.quantity <= 1) {
      final newState = Map<String, CartItem>.from(current);
      newState.remove(productId);
      state = newState;
    } else {
      state = {
        ...current,
        productId: item.copyWith(quantity: item.quantity - 1),
      };
    }
  }

  void clear() {
    state = {};
  }

  int get totalItems => state.values.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemsCount => state.length;
  double get totalPrice => state.values.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(() {
  return CartNotifier();
});

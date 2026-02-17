import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/product.dart';

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
    final currentState = state;
    if (currentState.containsKey(product.id)) {
      state = {
        ...currentState,
        product.id: currentState[product.id]!.copyWith(
          quantity: currentState[product.id]!.quantity + 1,
        ),
      };
    } else {
      state = {
        ...currentState,
        product.id: CartItem(product: product, quantity: product.moq),
      };
    }
  }

  void removeItem(String productId) {
    final currentState = state;
    if (!currentState.containsKey(productId)) return;

    final currentItem = currentState[productId]!;
    if (currentItem.quantity <= currentItem.product.moq) {
      final newState = Map<String, CartItem>.from(currentState);
      newState.remove(productId);
      state = newState;
    } else {
      state = {
        ...currentState,
        productId: currentItem.copyWith(quantity: currentItem.quantity - 1),
      };
    }
  }

  void updateQuantity(String productId, int quantity) {
    final currentState = state;
    if (!currentState.containsKey(productId)) return;
    
    if (quantity <= 0) {
      final newState = Map<String, CartItem>.from(currentState);
      newState.remove(productId);
      state = newState;
    } else {
      state = {
        ...currentState,
        productId: currentState[productId]!.copyWith(quantity: quantity),
      };
    }
  }

  int get totalItems => state.values.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemsCount => state.length;
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(() {
  return CartNotifier();
});

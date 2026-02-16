import 'product.dart';

enum OrderStatus { processing, transit, delivered }

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});
}

class Order {
  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime placedAt;
  final String clientId;
  final String driverId;

  Order({
    required this.id,
    required this.status,
    required this.items,
    required this.placedAt,
    required this.clientId,
    this.driverId = '',
  });

  double get total =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
}

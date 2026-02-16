import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/order.dart';
import '../../../common/models/product.dart';

class OrderRepository {
  final List<Order> _orders = [
    Order(
      id: 'ORD-12345',
      status: OrderStatus.processing,
      items: [
        OrderItem(
          product: Product(
            id: '1',
            name: 'Portland Cement (50kg)',
            price: 8.50,
            moq: 10,
            vendorId: 'v1',
            imageUrl: '',
          ),
          quantity: 20,
        ),
      ],
      placedAt: DateTime.now().subtract(const Duration(hours: 2)),
      clientId: 'c1',
    ),
    Order(
      id: 'ORD-67890',
      status: OrderStatus.transit,
      items: [
        OrderItem(
          product: Product(
            id: '2',
            name: 'Steel Rebar (12mm)',
            price: 12.00,
            moq: 50,
            vendorId: 'v1',
            imageUrl: '',
          ),
          quantity: 100,
        ),
      ],
      placedAt: DateTime.now().subtract(const Duration(days: 1)),
      clientId: 'c1',
    ),
    Order(
      id: 'ORD-11223',
      status: OrderStatus.delivered,
      items: [
        OrderItem(
          product: Product(
            id: '5',
            name: 'Plywood Sheet (18mm)',
            price: 35.00,
            moq: 10,
            vendorId: 'v3',
            imageUrl: '',
          ),
          quantity: 15,
        ),
      ],
      placedAt: DateTime.now().subtract(const Duration(days: 5)),
      clientId: 'c1',
    ),
  ];

  List<Order> getOrders() {
    return _orders;
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final ordersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});

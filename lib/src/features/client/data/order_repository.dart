import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/order.dart';
import '../../../common/models/product.dart';

class OrderRepository {
  final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      status: OrderStatus.transit,
      items: List.generate(5, (index) => OrderItem(
        product: Product(
          id: 'p$index',
          name: 'Material $index',
          price: 85.00,
          moq: 1,
          vendorId: 'v1',
          category: 'Cement',
          imageUrl: '',
        ),
        quantity: 1,
      )),
      placedAt: DateTime(2026, 2, 6),
      clientId: 'c1',
    ),
    Order(
      id: 'ORD-002',
      status: OrderStatus.delivered,
      items: List.generate(2, (index) => OrderItem(
        product: Product(
          id: 's$index',
          name: 'Steel Item $index',
          price: 620.00,
          moq: 1,
          vendorId: 'v2',
          category: 'Steel',
          imageUrl: '',
        ),
        quantity: 1,
      )),
      placedAt: DateTime(2026, 2, 4),
      clientId: 'c1',
    ),
    Order(
      id: 'ORD-003',
      status: OrderStatus.processing,
      items: List.generate(8, (index) => OrderItem(
        product: Product(
          id: 'l$index',
          name: 'Lumber $index',
          price: 111.25,
          moq: 1,
          vendorId: 'v3',
          category: 'Wood',
          imageUrl: '',
        ),
        quantity: 1,
      )),
      placedAt: DateTime(2026, 2, 5),
      clientId: 'c1',
    ),
    Order(
      id: 'ORD-004',
      status: OrderStatus.delivered,
      items: List.generate(4, (index) => OrderItem(
        product: Product(
          id: 'c$index',
          name: 'Paint $index',
          price: 96.80,
          moq: 1,
          vendorId: 'v4',
          category: 'Other',
          imageUrl: '',
        ),
        quantity: 1,
      )),
      placedAt: DateTime(2026, 2, 1),
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

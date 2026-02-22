import 'package:flutter/material.dart';
import 'product.dart';

enum OrderStatus { processing, transit, delivered }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.transit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFF15803D);
      case OrderStatus.transit:
        return const Color(0xFF92400E);
      case OrderStatus.delivered:
        return const Color(0xFF166534);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.processing:
        return const Color(0xFFF0FDF4);
      case OrderStatus.transit:
        return const Color(0xFFFEF3C7);
      case OrderStatus.delivered:
        return const Color(0xFFDCFCE7);
    }
  }
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().contains(json['status']),
        orElse: () => OrderStatus.processing,
      ),
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList(),
      placedAt: DateTime.parse(json['placed_at']),
      clientId: json['client_id'],
      driverId: json['driver_id'] ?? '',
    );
  }

  double get total =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
}

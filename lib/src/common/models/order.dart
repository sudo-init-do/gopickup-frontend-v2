import 'package:flutter/material.dart';
import 'product.dart';

enum OrderStatus {
  pending,
  searching_driver,
  bidding_open,
  assigned,
  in_transit,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.searching_driver:
        return 'Searching Driver';
      case OrderStatus.bidding_open:
        return 'Bidding Open';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.in_transit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF6B7280);
      case OrderStatus.searching_driver:
        return const Color(0xFF9333EA);
      case OrderStatus.bidding_open:
        return const Color(0xFF2563EB);
      case OrderStatus.assigned:
        return const Color(0xFF0D9488);
      case OrderStatus.in_transit:
        return const Color(0xFFD97706);
      case OrderStatus.delivered:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF3F4FB);
      case OrderStatus.searching_driver:
        return const Color(0xFFF5F3FF);
      case OrderStatus.bidding_open:
        return const Color(0xFFEFF6FF);
      case OrderStatus.assigned:
        return const Color(0xFFF0FDFA);
      case OrderStatus.in_transit:
        return const Color(0xFFFFFBEB);
      case OrderStatus.delivered:
        return const Color(0xFFECFDF5);
      case OrderStatus.cancelled:
        return const Color(0xFFFEF2F2);
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
    OrderStatus status = OrderStatus.pending;
    final statusStr = json['status'] as String? ?? 'pending';
    
    try {
      status = OrderStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => OrderStatus.pending,
      );
    } catch (_) {
      status = OrderStatus.pending;
    }

    return Order(
      id: json['id'],
      status: status,
      items: (json['items'] as List?)
          ?.map((i) => OrderItem.fromJson(i))
          .toList() ?? [],
      placedAt: DateTime.parse(json['created_at']),
      clientId: json['client_id'] ?? '',
      driverId: json['driver_id'] ?? '',
    );
  }

  String get shortId => id.length > 8 ? 'ORD-${id.substring(0, 8).toUpperCase()}' : id;


  double get total =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
}

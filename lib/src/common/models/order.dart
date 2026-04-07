// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';
import 'product.dart';

enum OrderStatus {
  pending,
  awaiting_payment,
  payment_made,
  processing,
  assigned,
  ready,
  in_progress,
  picked_up,
  on_the_way,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.awaiting_payment:
        return 'Negotiating on WhatsApp';
      case OrderStatus.payment_made:
        return 'Awaiting Verification';
      case OrderStatus.processing:
        return 'Finding Driver';
      case OrderStatus.assigned:
        return 'Assigned to Driver';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.in_progress:
        return 'In Transit';
      case OrderStatus.picked_up:
        return 'Picked Up';
      case OrderStatus.on_the_way:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.awaiting_payment:
        return const Color(0xFFEAB308); // Yellow
      case OrderStatus.payment_made:
        return const Color(0xFF3B82F6); // Blue
      case OrderStatus.processing:
        return const Color(0xFF8B5CF6); // Purple
      case OrderStatus.assigned:
        return const Color(0xFF14B8A6); // Teal
      case OrderStatus.ready:
        return const Color(0xFF45A225);
      case OrderStatus.in_progress:
        return const Color(0xFF10B981); // Green
      case OrderStatus.picked_up:
        return const Color(0xFFD97706);
      case OrderStatus.on_the_way:
        return const Color(0xFFF59E0B);
      case OrderStatus.delivered:
        return const Color(0xFF059669);
      case OrderStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.awaiting_payment:
        return const Color(0xFFFEF9C3);
      case OrderStatus.payment_made:
        return const Color(0xFFEFF6FF);
      case OrderStatus.processing:
        return const Color(0xFFF5F3FF);
      case OrderStatus.assigned:
        return const Color(0xFFF0FDFA);
      case OrderStatus.ready:
        return const Color(0xFFF0FDF4);
      case OrderStatus.in_progress:
        return const Color(0xFFECFDF5);
      case OrderStatus.picked_up:
        return const Color(0xFFFFFBEB);
      case OrderStatus.on_the_way:
        return const Color(0xFFFEF3C7);
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

class OrderVendor {
  final String id;
  final String storeName;
  final String? bannerUrl;

  OrderVendor({
    required this.id,
    required this.storeName,
    this.bannerUrl,
  });

  factory OrderVendor.fromJson(Map<String, dynamic> json) {
    return OrderVendor(
      id: json['id'] ?? json['vendor_id'] ?? '',
      storeName: json['store_name'] ?? 'GoPickup Store',
      bannerUrl: json['store_banner_url'] ?? json['banner_url'],
    );
  }
}

class Order {
  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime placedAt;
  final String clientId;
  final String? driverId;
  final double? agreedPrice;
  final double? agreedDeliveryFee;
  final OrderVendor? vendor;
  final String? whatsappUrl;

  Order({
    required this.id,
    required this.status,
    required this.items,
    required this.placedAt,
    required this.clientId,
    this.driverId,
    this.agreedPrice,
    this.agreedDeliveryFee,
    this.vendor,
    this.whatsappUrl,
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
      id: json['id'] ?? '',
      status: status,
      items:
          (json['items'] as List?)
              ?.map((i) => OrderItem.fromJson(i))
              .toList() ??
          [],
      placedAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      clientId: json['client_id'] ?? '',
      driverId: json['driver_id'] ?? json['pilot_id'],
      agreedPrice: (json['agreed_price'] as num?)?.toDouble(),
      agreedDeliveryFee: (json['agreed_delivery_fee'] as num?)?.toDouble(),
      vendor: json['vendor'] != null ? OrderVendor.fromJson(json['vendor']) : null,
      whatsappUrl: json['whatsapp_url'],
    );
  }

  String get shortId =>
      id.length > 8 ? 'ORD-${id.substring(0, 8).toUpperCase()}' : id;

  double get total =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
}

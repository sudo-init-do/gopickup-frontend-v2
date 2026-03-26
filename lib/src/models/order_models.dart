class OrderItem {
  final String productId;
  final int quantity;

  // Adding UI fields you might want back from the API (product details)
  final String? name;
  final double? price;

  OrderItem({
    required this.productId,
    required this.quantity,
    this.name,
    this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String? ?? json['id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}

class JobBid {
  final String id;
  final String orderId;
  final String driverId;
  final double amount;
  final String status; // pending, accepted, rejected

  JobBid({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.amount,
    required this.status,
  });

  factory JobBid.fromJson(Map<String, dynamic> json) {
    return JobBid(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class Order {
  final String id;
  final String clientId;
  final String vendorId;
  final String? driverId;
  final List<OrderItem> items;
  final double totalProductAmount;
  final String status; // pending, processing, assigned, in_progress, picked_up, on_the_way, delivered, cancelled
  final String pickupAddress;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? agreedPrice;
  final double? agreedDeliveryFee;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.clientId,
    required this.vendorId,
    this.driverId,
    required this.items,
    required this.totalProductAmount,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.agreedPrice,
    this.agreedDeliveryFee,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = [];
    if (json['items'] != null) {
      itemsList = json['items'] as List<dynamic>;
    }

    return Order(
      id: json['id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      driverId: json['driver_id'] as String?,
      items: itemsList
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalProductAmount:
          (json['total_product_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      pickupAddress: json['pickup_address'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      agreedPrice: (json['agreed_price'] as num?)?.toDouble(),
      agreedDeliveryFee: (json['agreed_delivery_fee'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

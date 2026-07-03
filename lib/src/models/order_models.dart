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

class OrderVendor {
  final String id;
  final String storeName;

  OrderVendor({required this.id, required this.storeName});
}

class Order {
  final String id;
  final String clientId;
  final String vendorId;
  final String? driverId;
  final List<OrderItem> items;
  final double totalProductAmount;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? agreedPrice;
  final double? agreedDeliveryFee;
  final DateTime createdAt;
  final String? whatsappNotifyVendorUrl;
  final String? whatsappUrl;

  // Nested client info (from admin API)
  final String? clientName;
  final String? clientPhone;
  final String? clientEmail;

  // Nested vendor info (from admin API)
  final String? vendorStoreName;
  final String? vendorPhone;

  // Nested assigned-driver info (from driver.driver_profile), when preloaded.
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String? driverPlate;

  /// Whether a driver has been assigned and their details are available.
  bool get hasDriver => driverName != null;

  OrderVendor? get vendor => vendorStoreName != null ? OrderVendor(id: vendorId, storeName: vendorStoreName!) : OrderVendor(id: vendorId, storeName: 'GoPickup Store');

  // Short, display-safe id fragments. Guards against RangeError when an id is
  // missing/short (Order.fromJson defaults absent ids to '').
  String get shortId => id.length >= 8 ? id.substring(0, 8) : id;
  String get shortClientId => clientId.length >= 8 ? clientId.substring(0, 8) : clientId;
  String get shortVendorId => vendorId.length >= 8 ? vendorId.substring(0, 8) : vendorId;

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
    this.whatsappNotifyVendorUrl,
    this.whatsappUrl,
    this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.vendorStoreName,
    this.vendorPhone,
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    this.driverPlate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = [];
    if (json['items'] != null) {
      itemsList = json['items'] as List<dynamic>;
    }

    // Extract nested client profile (from admin endpoint)
    final clientObj = json['client'] as Map<String, dynamic>?;
    final clientProfile = clientObj?['client_profile'] as Map<String, dynamic>?;

    // Extract nested vendor object (from admin endpoint)
    final vendorObj = json['vendor'] as Map<String, dynamic>?;

    // Extract nested assigned-driver profile (when preloaded).
    final driverObj = json['driver'] as Map<String, dynamic>?;
    final driverProfile = driverObj?['driver_profile'] as Map<String, dynamic>?;

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
      whatsappNotifyVendorUrl: json['whatsapp_notify_vendor_url'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
      // Nested client fields
      clientName: clientProfile?['full_name'] as String?,
      clientPhone: clientProfile?['phone_number'] as String?,
      clientEmail: clientObj?['email'] as String?,
      // Nested vendor fields
      vendorStoreName: vendorObj?['store_name'] as String?,
      vendorPhone: vendorObj?['phone_number'] as String?,
      // Nested assigned-driver fields
      driverName: driverProfile?['full_name'] as String?,
      driverPhone: driverProfile?['phone_number'] as String?,
      driverVehicle: driverProfile?['vehicle_type'] as String?,
      driverPlate: driverProfile?['plate_number'] as String?,
    );
  }
}

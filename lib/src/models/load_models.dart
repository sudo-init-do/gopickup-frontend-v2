/// Models for the "Loads" system — a client posts a delivery request (a load),
/// drivers bid on it, the client accepts a bid, and the driver fulfils it.
///
/// Backs both the "Post Load" scheduling form and the live "Book Driver" flow.
/// Mirrors the Go backend JSON (snake_case) in internal/models/load.go.
library;

class LoadBid {
  final String id;
  final String loadId;
  final String driverId;
  final double amount;
  final String? note;
  final String status; // pending, accepted, rejected

  // Nested driver info (from the `driver` -> `driver_profile` relation).
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String? driverPlate;

  LoadBid({
    required this.id,
    required this.loadId,
    required this.driverId,
    required this.amount,
    this.note,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    this.driverPlate,
  });

  factory LoadBid.fromJson(Map<String, dynamic> json) {
    final driverObj = json['driver'] as Map<String, dynamic>?;
    final driverProfile = driverObj?['driver_profile'] as Map<String, dynamic>?;
    return LoadBid(
      id: json['id'] as String? ?? '',
      loadId: json['load_id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      status: json['status'] as String? ?? 'pending',
      driverName: driverProfile?['full_name'] as String?,
      driverPhone: driverProfile?['phone_number'] as String?,
      driverVehicle: driverProfile?['vehicle_type'] as String?,
      driverPlate: driverProfile?['plate_number'] as String?,
    );
  }
}

class Load {
  final String id;
  final String clientId;
  final String? driverId;
  final String title;
  final String? description;
  final String goodsType;
  final String? equipmentType;
  final String? loadRequirement; // 'full' | 'partial'
  final double? weight;
  final double? lengthFt;
  final String pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupPin;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String? dropoffPin;
  final double? budgetAmount;
  final double? agreedAmount;
  final String status; // open, assigned, picked_up, delivered, cancelled
  final DateTime? scheduledAt;
  final DateTime createdAt;
  final List<LoadBid> bids;

  // Nested driver info (assigned driver), when the backend preloads it.
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String? driverPlate;

  // Assigned driver's last-known live position (from DriverProfile), used to
  // seed the tracking map instantly instead of waiting for the first websocket
  // `driver_moved` event. Present once a driver is assigned and has shared GPS.
  final double? driverLat;
  final double? driverLng;
  final DateTime? driverLocationAt;

  // Nested client info (the requester) — preloaded for the admin console.
  final String? clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? clientRole;

  Load({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.title,
    this.description,
    required this.goodsType,
    this.equipmentType,
    this.loadRequirement,
    this.weight,
    this.lengthFt,
    required this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.pickupPin,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.dropoffPin,
    this.budgetAmount,
    this.agreedAmount,
    required this.status,
    this.scheduledAt,
    required this.createdAt,
    this.bids = const [],
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    this.driverPlate,
    this.driverLat,
    this.driverLng,
    this.driverLocationAt,
    this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.clientRole,
  });

  /// Short, display-safe id fragment (guards against short/empty ids).
  String get shortId => id.length >= 8 ? id.substring(0, 8) : id;

  bool get isAssigned =>
      status == 'assigned' || status == 'picked_up' || status == 'delivered';

  /// The bid the client accepted, if any.
  LoadBid? get acceptedBid {
    for (final b in bids) {
      if (b.status == 'accepted') return b;
    }
    return null;
  }

  factory Load.fromJson(Map<String, dynamic> json) {
    final bidsRaw = json['bids'];
    final bids = bidsRaw is List
        ? bidsRaw
            .map((e) => LoadBid.fromJson(e as Map<String, dynamic>))
            .toList()
        : <LoadBid>[];

    final driverObj = json['driver'] as Map<String, dynamic>?;
    final driverProfile = driverObj?['driver_profile'] as Map<String, dynamic>?;
    final clientObj = json['client'] as Map<String, dynamic>?;
    final clientProfile = clientObj?['client_profile'] as Map<String, dynamic>?;

    return Load(
      id: json['id'] as String? ?? '',
      clientId: json['client_id'] as String? ?? '',
      driverId: json['driver_id'] as String?,
      title: json['title'] as String? ?? 'Delivery',
      description: json['description'] as String?,
      goodsType: json['goods_type'] as String? ?? '',
      equipmentType: json['equipment_type'] as String?,
      loadRequirement: json['load_requirement'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      lengthFt: (json['length_ft'] as num?)?.toDouble(),
      pickupAddress: json['pickup_address'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble(),
      pickupLng: (json['pickup_lng'] as num?)?.toDouble(),
      pickupPin: json['pickup_pin'] as String?,
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      dropoffPin: json['dropoff_pin'] as String?,
      budgetAmount: (json['budget_amount'] as num?)?.toDouble(),
      agreedAmount: (json['agreed_amount'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'open',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      bids: bids,
      driverName: driverProfile?['full_name'] as String?,
      driverPhone: driverProfile?['phone_number'] as String?,
      driverVehicle: driverProfile?['vehicle_type'] as String?,
      driverPlate: driverProfile?['plate_number'] as String?,
      driverLat: (driverProfile?['current_location_lat'] as num?)?.toDouble(),
      driverLng: (driverProfile?['current_location_lng'] as num?)?.toDouble(),
      driverLocationAt: driverProfile?['updated_at'] != null
          ? DateTime.tryParse(driverProfile!['updated_at'] as String)
          : null,
      clientName: clientProfile?['full_name'] as String?,
      clientPhone: clientProfile?['phone_number'] as String?,
      clientEmail: clientObj?['email'] as String?,
      clientRole: clientObj?['role'] as String?,
    );
  }
}

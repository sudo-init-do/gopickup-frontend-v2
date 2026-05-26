class User {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;
  final bool isProfileComplete;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isProfileComplete = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'is_profile_complete': isProfileComplete,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? role,
    DateTime? createdAt,
    bool? isComplete,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isComplete ?? isProfileComplete,
    );
  }
}

class ClientProfile {
  final String fullName;
  final String phoneNumber;
  final String address;
  final String? profilePictureUrl;

  ClientProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.profilePictureUrl,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      address: json['address'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
    };
  }
}

class DriverProfile {
  final String fullName;
  final String phoneNumber;
  final String licenseNumber;
  final String vehicleType;
  final String plateNumber;
  final double vehicleCapacity;
  final bool isApproved;
  final String? profilePictureUrl;

  DriverProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.vehicleType,
    required this.plateNumber,
    required this.vehicleCapacity,
    required this.isApproved,
    this.profilePictureUrl,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      licenseNumber: json['license_number'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? 'Tricycle',
      plateNumber: json['plate_number'] as String? ?? '',
      vehicleCapacity: (json['vehicle_capacity'] as num?)?.toDouble() ?? 0.0,
      isApproved: json['is_approved'] as bool? ?? false,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'vehicle_capacity': vehicleCapacity,
      'is_approved': isApproved,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
    };
  }
}

class VendorProfile {
  final String storeName;
  final String businessType;
  final String address;
  final String phoneNumber;
  final String? storeBannerUrl;
  final String? businessRegistrationNumber;
  final bool isApproved;

  VendorProfile({
    required this.storeName,
    required this.businessType,
    required this.address,
    required this.phoneNumber,
    this.businessRegistrationNumber,
    this.storeBannerUrl,
    required this.isApproved,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      storeName: json['store_name'] as String? ?? '',
      businessType: json['business_type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      storeBannerUrl: json['store_banner_url'] as String?,
      businessRegistrationNumber: json['business_registration_number'] as String?,
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'business_type': businessType,
      'address': address,
      'phone_number': phoneNumber,
      if (storeBannerUrl != null) 'store_banner_url': storeBannerUrl,
      if (businessRegistrationNumber != null)
        'business_registration_number': businessRegistrationNumber,
      'is_approved': isApproved,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'store_name': storeName,
      'phone_number': phoneNumber,
      'business_type': businessType,
      'address': address,
      if (businessRegistrationNumber != null)
        'business_registration_number': businessRegistrationNumber,
    };
  }
}

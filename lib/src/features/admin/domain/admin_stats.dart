class AdminStats {
  final int totalUsers;
  final int totalClients;
  final int totalDrivers;
  final int pendingDrivers;
  final int totalVendors;
  final int pendingVendors;
  final int totalOrders;
  final int pendingOrders;
  final int activeOrders;
  final int totalProducts;

  AdminStats({
    required this.totalUsers,
    required this.totalClients,
    required this.totalDrivers,
    required this.pendingDrivers,
    required this.totalVendors,
    required this.pendingVendors,
    required this.totalOrders,
    required this.pendingOrders,
    required this.activeOrders,
    required this.totalProducts,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalClients: json['total_clients'] as int? ?? 0,
      totalDrivers: json['total_drivers'] as int? ?? 0,
      pendingDrivers: json['pending_drivers'] as int? ?? 0,
      totalVendors: json['total_vendors'] as int? ?? 0,
      pendingVendors: json['pending_vendors'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      activeOrders: json['active_orders'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
    );
  }
}

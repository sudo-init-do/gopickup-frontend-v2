class Product {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String category;
  final String imageUrl;
  final bool isActive;
  final int stock;
  final int moq;
  final String vendorName;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.stock = 0,
    this.moq = 1,
    required this.category,
    required this.imageUrl,
    required this.isActive,
    this.vendorName = 'Unknown Vendor',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String vName = 'Unknown Vendor';
    if (json['vendor'] != null && json['vendor']['store_name'] != null) {
      vName = json['vendor']['store_name'];
    }

    return Product(
      id: json['id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      stock: json['stock_quantity'] as int? ?? (json['stock'] as int?) ?? 0,
      moq: json['moq'] as int? ?? (json['minimum_order_quantity'] as int?) ?? 1,
      category: json['category'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      vendorName: vName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}

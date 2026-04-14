class Product {
  final String id;
  final String name;
  final double price;
  final int moq;
  final int stock;
  final String vendorId;
  final String category;
  final String imageUrl;
  final String vendorName;
  final String vendorAddress;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.moq,
    this.stock = 0,
    required this.vendorId,
    required this.category,
    required this.imageUrl,
    this.vendorName = 'GoPickup Vendor',
    this.vendorAddress = 'Lagos, Nigeria',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String vName = 'GoPickup Vendor';
    String vAddress = 'Lagos, Nigeria';
    if (json['vendor'] != null) {
      if (json['vendor']['store_name'] != null) {
        vName = json['vendor']['store_name'];
      }
      if (json['vendor']['address'] != null) {
        vAddress = json['vendor']['address'];
      }
    }

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      moq: (json['moq'] ?? json['minimum_order_quantity'] ?? 1) as int,
      stock: (json['stock'] ?? json['stock_quantity'] ?? 0) as int,
      vendorId: json['vendor_id'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] ?? '',
      vendorName: vName,
      vendorAddress: vAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'moq': moq,
      'stock': stock,
      'vendor_id': vendorId,
      'category': category,
      'image_url': imageUrl,
    };
  }
}

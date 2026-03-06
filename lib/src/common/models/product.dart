class Product {
  final String id;
  final String name;
  final double price;
  final int moq;
  final String vendorId;
  final String category;
  final String imageUrl;
  final String vendorName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.moq,
    required this.vendorId,
    required this.category,
    required this.imageUrl,
    this.vendorName = 'Unknown Vendor',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String vName = 'Unknown Vendor';
    if (json['vendor'] != null && json['vendor']['store_name'] != null) {
      vName = json['vendor']['store_name'];
    }

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      moq: json['moq'] as int,
      vendorId: json['vendor_id'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] ?? '',
      vendorName: vName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'moq': moq,
      'vendor_id': vendorId,
      'category': category,
      'image_url': imageUrl,
    };
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final int moq;
  final String vendorId;
  final String category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.moq,
    required this.vendorId,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      moq: json['moq'] as int,
      vendorId: json['vendor_id'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
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

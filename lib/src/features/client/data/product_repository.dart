import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/models/product.dart';

class ProductRepository {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Portland Cement (50kg)',
      price: 8.50,
      moq: 10,
      vendorId: 'v1',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: '2',
      name: 'Steel Rebar (12mm)',
      price: 12.00,
      moq: 50,
      vendorId: 'v1',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: '3',
      name: 'Red Bricks (1000 pcs)',
      price: 250.00,
      moq: 1,
      vendorId: 'v2',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: '4',
      name: 'Construction Sand (1 Ton)',
      price: 45.00,
      moq: 5,
      vendorId: 'v2',
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: '5',
      name: 'Plywood Sheet (18mm)',
      price: 35.00,
      moq: 10,
      vendorId: 'v3',
      imageUrl: 'https://via.placeholder.com/150',
    ),
  ];

  List<Product> getProducts() {
    return _products;
  }

  Product getProduct(String id) {
    return _products.firstWhere((p) => p.id == id);
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});

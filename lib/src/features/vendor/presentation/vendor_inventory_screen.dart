import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../client/data/product_repository.dart';
import '../../../common/models/product.dart';
import '../../../common/styles/app_colors.dart';

class VendorInventoryScreen extends ConsumerWidget {
  const VendorInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showProductDialog(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _InventoryItem(product: products[index]);
        },
      ),
    );
  }

  void _showProductDialog(BuildContext context, [Product? product]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Product Name'),
              controller: TextEditingController(text: product?.name),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: product?.price.toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'MOQ'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: product?.moq.toString(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    product == null ? 'Product added' : 'Product updated',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final Product product;

  const _InventoryItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('\$${product.price} • MOQ: ${product.moq}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            // Find the parent widget to call the dialog method?
            // Better to pass a callback or use a provider for dialogs.
            // For simplicity, duplicate the dialog logic or make it static/mixin.
            // Or just instantiate the dialog here.
            _showEditDialog(context, product);
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Product product) {
    // Reusing the same dialog logic essentially
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Product Name'),
              controller: TextEditingController(text: product.name),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: product.price.toString(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'MOQ'),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: product.moq.toString(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Product updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

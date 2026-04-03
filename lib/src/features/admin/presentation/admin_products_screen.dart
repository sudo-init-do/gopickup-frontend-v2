import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/product_provider.dart';
import '../../../models/product_models.dart';
import 'admin_providers.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _deletedIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered = products.where((p) => !_deletedIds.contains(p.id)).toList();
    if (_searchController.text.isNotEmpty) {
      final q = _searchController.text.toLowerCase();
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q) || p.vendorName.toLowerCase().contains(q)).toList();
    }
    return filtered;
  }

  Future<void> _confirmDeleteProduct(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
          'Are you sure you want to permanently delete this product? This action cannot be undone.',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await ref.read(adminApiProvider).deleteProduct(id);
        setState(() => _deletedIds.add(id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product permanently deleted'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MARKETPLACE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.blueGrey.shade300)),
            const Text('Product Management', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (productState.isLoading && productState.products.isEmpty) {
            return const _AdminLoadingState();
          }
          if (productState.error != null && productState.products.isEmpty) {
            return _AdminErrorState(
              error: productState.error!,
              onRetry: () => ref.read(productProvider.notifier).fetchProducts(),
            );
          }

          final filtered = _getFilteredProducts(productState.products);

          return Column(
            children: [
              if (_isLoading) const LinearProgressIndicator(color: Colors.red, backgroundColor: Colors.white),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.blueGrey.shade300, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search products or vendors...',
                            hintStyle: TextStyle(fontSize: 15, color: Colors.blueGrey.shade200, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: const Color(0xFFF8FAFC),
                        child: Row(
                          children: [
                            Text('PRODUCT IDENTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade400, letterSpacing: 1.2)),
                            const Spacer(),
                            Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade400, letterSpacing: 1.2)),
                            const SizedBox(width: 80),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: filtered.isEmpty 
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade50),
                                itemBuilder: (context, index) {
                                  final product = filtered[index];
                                  return _buildProductRow(product);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              image: product.imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover)
                : null,
            ),
            child: product.imageUrl.isEmpty 
                ? Icon(Icons.shopping_bag_outlined, color: Colors.blueGrey.shade200, size: 24)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Vendor: ${product.vendorName}', style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade500, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₦${product.price}', 
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF3B7D23), letterSpacing: -0.2),
          ),
          const SizedBox(width: 24),
          _buildDeleteButton(product.id),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(String id) {
    return Material(
      color: Colors.red.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _confirmDeleteProduct(id),
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No products found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade200)),
        ],
      ),
    );
  }
}

class _AdminLoadingState extends StatelessWidget {
  const _AdminLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E293B), strokeWidth: 3),
          SizedBox(height: 20),
          Text('Fetching platform inventory...', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _AdminErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 24),
          const Text('Inventory Offline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14, height: 1.5)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry Connection', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/product.dart';
import '../../../common/styles/app_colors.dart';

class VendorStorefrontScreen extends ConsumerWidget {
  final String vendorId;

  const VendorStorefrontScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(vendorProfileProvider(vendorId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: profileAsync.when(
        data: (data) => _buildStorefront(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading store: $err')),
      ),
    );
  }

  Widget _buildStorefront(BuildContext context, Map<String, dynamic> data) {
    final storeName = data['store_name'] ?? 'GoPickup Store';
    final bannerUrl = data['store_banner_url'] ?? data['banner_url'];
    final productsJson = data['products'] as List? ?? [];
    final products = productsJson.map((p) => Product.fromJson(p)).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              storeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (bannerUrl != null)
                  Image.network(bannerUrl, fit: BoxFit.cover)
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                      ),
                    ),
                  ),
                Container(color: Colors.black.withOpacity( 0.2)),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Store Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                if (products.isEmpty)
                  const Center(child: Text('No products available in this store.'))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) => _buildProductCard(context, products[index]),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover)
                    : null,
                color: const Color(0xFFF3F4F6),
              ),
              child: product.imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.shopping_bag_outlined, color: Color(0xFFCBD5E1)))
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '₦${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/product.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';

class VendorStorefrontScreen extends ConsumerWidget {
  final String vendorId;

  const VendorStorefrontScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(vendorProfileProvider(vendorId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (data) => _buildStorefront(context, data),
        loading: () => const AppLoading(),
        error: (err, _) => AppErrorState(message: 'Error loading store: $err'),
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
              style: AppTextStyles.titleMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                shadows: const [Shadow(color: Colors.black45, blurRadius: 10)],
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
                        colors: [AppColors.vendorAccent, Color(0xFF9333EA)],
                      ),
                    ),
                  ),
                Container(color: Colors.black.withOpacity(0.2)),
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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Store Products',
                  style: AppTextStyles.headingMd,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (products.isEmpty)
                  const AppEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No products available',
                    message: 'This store has not added any products yet.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(context, products[index]),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.backgroundSubtle,
              ),
              child: product.imageUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.borderStrong,
                      ),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '₦${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.body.copyWith(
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

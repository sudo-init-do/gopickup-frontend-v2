import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../api/api_client.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import '../../../models/product_models.dart';
import '../data/cart_provider.dart';

/// Fetches the vendor profile + their products from /vendors/:id.
final clientVendorProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, vendorId) async {
  try {
    final res = await ApiClient.dio.get('vendors/$vendorId');
    return Map<String, dynamic>.from(res.data as Map);
  } on DioException catch (e) {
    final msg = (e.response?.data is Map)
        ? e.response?.data['error']
        : 'Failed to load vendor';
    throw Exception(msg ?? 'Failed to load vendor');
  }
});

class ClientVendorScreen extends ConsumerWidget {
  final String vendorId;
  const ClientVendorScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientVendorProvider(vendorId));
    final cartCount = ref.watch(cartProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorState(
          message: e.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(clientVendorProvider(vendorId)),
        ),
        data: (vendor) {
          final storeName = (vendor['store_name'] as String?) ?? 'Store';
          final businessType = vendor['business_type'] as String?;
          final address = vendor['address'] as String?;
          final phone = vendor['phone_number'] as String?;
          final banner = vendor['store_banner_url'] as String?;
          final products = ((vendor['products'] as List?) ?? const [])
              .map((p) => Product.fromJson(Map<String, dynamic>.from(p as Map)))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined,
                              color: Colors.white),
                          onPressed: () => context.push('/client/cart'),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.destructive,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: Text(
                                '$cartCount',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner != null && banner.isNotEmpty)
                        Image.network(
                          banner,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _bannerFallback(),
                        )
                      else
                        _bannerFallback(),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: AppTextStyles.headingLg.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (businessType != null && businessType.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            businessType,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (address != null && address.isNotEmpty)
                        _infoRow(Icons.location_on_outlined, address),
                      if (phone != null && phone.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _infoRow(Icons.phone_outlined, phone),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Products',
                        style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${products.length} item${products.length == 1 ? '' : 's'}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              if (products.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                    child: Center(
                      child: Text(
                        'No products from this vendor yet.',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _VendorProductRow(
                      product: products[i],
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Reviews',
                    style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.reviews_outlined,
                            color: AppColors.textTertiary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'No reviews yet. Vendor reviews are coming soon.',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            ],
          );
        },
      ),
    );
  }

  Widget _bannerFallback() {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Icon(Icons.storefront_rounded, size: 64, color: Colors.white24),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Row item: thumbnail + name/price/stock + MOQ + add-to-cart control.
class _VendorProductRow extends ConsumerWidget {
  final Product product;
  const _VendorProductRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final inCart = cart[product.id];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 72,
              height: 72,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _thumbFallback(),
                    )
                  : _thumbFallback(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '₦${product.price}/piece · ${product.stock} in stock',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'MOQ: ${product.moq}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (inCart == null)
            ElevatedButton(
              onPressed: () =>
                  ref.read(cartProvider.notifier).addItem(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            )
          else
            Row(
              children: [
                _qtyButton(
                  Icons.remove_rounded,
                  () => ref
                      .read(cartProvider.notifier)
                      .removeItem(product.id),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    '${inCart.quantity}',
                    style: AppTextStyles.label
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                _qtyButton(
                  Icons.add_rounded,
                  () => ref.read(cartProvider.notifier).addItem(product),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSubtle,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      color: AppColors.backgroundSubtle,
      child: Icon(Icons.image_outlined, color: Colors.grey[400]),
    );
  }
}

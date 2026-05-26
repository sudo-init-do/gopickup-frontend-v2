import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/cart_provider.dart';
import '../../../models/order_models.dart';
import '../../../state/order_provider.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/config/app_config.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import '../../../common/widgets/primary_button.dart';

class ClientCartScreen extends ConsumerWidget {
  const ClientCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalItems = ref.watch(cartProvider.notifier).uniqueItemsCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: cart.isEmpty
            ? _buildEmptyCart(context)
            : _buildCartList(context, ref, cart, totalItems),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context, 'Cart', showClear: false, onClear: () {}),
        const Expanded(
          child: AppEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            message: 'Browse Go-Market to add products',
            actionLabel: 'Explore Go-Market',
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    Map<String, CartItem> cart,
    int totalItems,
  ) {
    final subtotal = cart.values.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Column(
      children: [
        _buildHeader(
          context,
          'Cart ($totalItems)',
          showClear: true,
          onClear: () {
            ref.read(cartProvider.notifier).clear();
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final itemId = cart.keys.elementAt(index);
              final item = cart[itemId]!;
              return _buildCartItemCard(ref, item);
            },
          ),
        ),
        // Bottom Total Bar
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.xxxl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '₦${subtotal.toStringAsFixed(2)}',
                      style: AppTextStyles.headingLg.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Consumer(
                builder: (context, ref, _) {
                  return PrimaryButton(
                    label: 'Proceed to Checkout',
                    height: 64,
                    onPressed: () async {
                      // 1. Check Stock for all items
                      final outOfStockItems = cart.values
                          .where(
                            (item) => item.product.stock < item.quantity,
                          )
                          .toList();

                      if (outOfStockItems.isNotEmpty) {
                        final itemNames = outOfStockItems
                            .map((e) => e.product.name)
                            .take(2)
                            .join(', ');
                        final suffix = outOfStockItems.length > 2
                            ? ' and ${outOfStockItems.length - 2} more'
                            : '';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Sorry, $itemNames$suffix ${outOfStockItems.length > 1 ? 'are' : 'is'} currently out of stock.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                            margin: const EdgeInsets.all(AppSpacing.xl),
                          ),
                        );
                        return;
                      }

                      // 2. Call Checkout API
                      final notifier = ref.read(orderProvider.notifier);
                      final result = await notifier.checkout(
                        items: cart.values
                            .toList()
                            .map(
                              (e) => OrderItem(
                                productId: e.product.id,
                                quantity: e.quantity,
                                name: e.product.name,
                                price: e.product.price,
                              ),
                            )
                            .toList(),
                        paymentMethod: 'WhatsApp',
                        pickupAddress: 'Pending Office',
                        deliveryAddress: 'Default Address',
                      );

                      if (result != null && result['whatsapp_url'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Order created successfully, go to my orders to negotiate price.',
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.lg),
                            ),
                            margin: const EdgeInsets.all(AppSpacing.xl),
                            duration: const Duration(seconds: 4),
                          ),
                        );

                        final url = Uri.parse(result['whatsapp_url']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          final supportUrl = Uri.parse(
                            'https://wa.me/${AppConfig.supportPhone}',
                          );
                          await launchUrl(
                            supportUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                        // Clear cart after successful checkout initiate
                        ref.read(cartProvider.notifier).clear();

                        // Redirect to Orders
                        if (context.mounted) {
                          context.pushReplacement('/client/orders');
                        }
                      } else {
                        final error = ref.read(orderProvider).error;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHandler.getMessage(error)),
                            backgroundColor: AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title, {
    required bool showClear,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Text(title, style: AppTextStyles.headingMd),
          if (showClear)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear all',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(WidgetRef ref, CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              image: item.product.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.product.imageUrl.isEmpty
                ? const Icon(
                    Icons.image_outlined,
                    color: AppColors.borderStrong,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.product.vendorName,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(cartProvider.notifier)
                            .removeItem(item.product.id);
                      },
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.product.name,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .removeItem(item.product.id),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.card,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.label.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(cartProvider.notifier)
                                .addItem(item.product),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/cart_provider.dart';
import '../../../models/order_models.dart';
import '../../../state/order_provider.dart';
import '../../../common/config/app_config.dart';
import '../../../common/utils/error_handler.dart';

class ClientCartScreen extends ConsumerWidget {
  const ClientCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalItems = ref.watch(cartProvider.notifier).uniqueItemsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 40,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Browse Go-Market to add products',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B7D23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explore Go-Market',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '₦${subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton(
                      onPressed: () async {
                        // 1. Check Stock for all items
                        final outOfStockItems = cart.values
                            .where((item) => item.product.stock < item.quantity)
                            .toList();

                        if (outOfStockItems.isNotEmpty) {
                          // Show better out-of-stock message
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
                                  const Icon(Icons.error_outline,
                                      color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Sorry, $itemNames$suffix ${outOfStockItems.length > 1 ? 'are' : 'is'} currently out of stock.',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                          return;
                        }

                        // 2. Call Checkout API
                        final notifier = ref.read(orderProvider.notifier);
                        final result = await notifier.checkout(
                          items: cart.values.toList().map((e) => OrderItem(
                            productId: e.product.id,
                            quantity: e.quantity,
                            name: e.product.name,
                            price: e.product.price,
                          )).toList(),
                          paymentMethod: 'WhatsApp',
                          pickupAddress: 'Pending Office', // Default for now
                          deliveryAddress: 'Default Address', // Should be fetched from profile
                        );

                        if (result != null && result['whatsapp_url'] != null) {
                          final url = Uri.parse(result['whatsapp_url']);
                          if (await canLaunchUrl(url)) {
                             await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                             // Fallback to direct support
                             final supportUrl = Uri.parse('https://wa.me/2348087042206');
                             await launchUrl(supportUrl, mode: LaunchMode.externalApplication);
                          }
                          // Clear cart after successful checkout initiate
                          ref.read(cartProvider.notifier).clear();
                        } else {
                           // Error handled by state but show floating snackbar here too
                           final error = ref.read(orderProvider).error;
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text(ErrorHandler.getMessage(error)),
                               backgroundColor: Colors.red.shade800,
                               behavior: SnackBarBehavior.floating,
                             ),
                           );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B7D23),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          if (showClear)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClear,
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              image: item.product.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.product.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.product.imageUrl.isEmpty
                ? const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verified Vendor',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₦${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(18),
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1F2937),
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
                                color: Color(0xFF3B7D23),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/order.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(vendorOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Text(
                    'Orders',
                    style: AppTextStyles.displayLg.copyWith(letterSpacing: -0.5),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  _buildFilterTab('All', true),
                  _buildFilterTab('Pending', false),
                  _buildFilterTab('Processing', false),
                  _buildFilterTab('Shipped', false),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),

            // Orders List
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders found',
                      message: 'Orders from customers will appear here.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(vendorOrdersProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final itemsDescription = order.items
                            .map((i) => '${i.quantity}x ${i.product.name}')
                            .join('\n');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildOrderCard(
                            context,
                            ref,
                            order,
                            order.shortId,
                            'Client: ${order.clientId.substring(0, 8)}',
                            itemsDescription,
                            DateFormat(
                              'MMM d, yyyy • h:mm a',
                            ).format(order.placedAt),
                            '₦${order.total.toStringAsFixed(2)}',
                            order.status.displayName,
                            order.status.backgroundColor,
                            order.status.color,
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const AppLoading(),
                error: (err, _) => AppErrorState(message: 'Error: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.vendorAccent : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    Order order,
    String id,
    String customer,
    String items,
    String date,
    String price,
    String status,
    Color tagBg,
    Color tagColor,
  ) {
    return GestureDetector(
      onTap: () => context.push('/vendor/orders/${order.id}', extra: order),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  id,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.status == OrderStatus.delivered
                            ? Icons.check_circle_outline_rounded
                            : (order.status == OrderStatus.pending
                                ? Icons.access_time_rounded
                                : Icons.inventory_2_outlined),
                        size: 14,
                        color: tagColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        status,
                        style: AppTextStyles.caption.copyWith(
                          color: tagColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              customer,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              items,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.lg),
            if (order.status == OrderStatus.assigned) ...[
              SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, _) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        final (success, error) = await ref
                            .read(vendorRepositoryProvider)
                            .markOrderReady(order.id);
                        if (context.mounted) {
                          if (success) {
                            ref.invalidate(vendorOrdersProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order marked as ready!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ErrorHandler.getMessage(error)),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.inventory_2_rounded, size: 18),
                      label: const Text('Mark Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppSpacing.lg),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: AppTextStyles.caption,
                ),
                Row(
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

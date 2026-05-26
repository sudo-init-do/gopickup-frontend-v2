import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/order_models.dart';
import '../data/vendor_repository.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';

class VendorOrderDetailScreen extends ConsumerWidget {
  final Order order;

  const VendorOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.id.substring(0, 8),
              style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt),
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: order.status == 'pending'
                          ? AppColors.warning.withOpacity(0.12)
                          : AppColors.info.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.status == 'pending'
                          ? Icons.access_time_filled_rounded
                          : Icons.inventory_2_rounded,
                      color: order.status == 'pending'
                          ? AppColors.warning
                          : AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.status.toUpperCase(),
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          order.status == 'pending'
                              ? 'Waiting for your action'
                              : 'Order is being processed',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Customer Section
            _buildSectionHeader('Customer Information'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client ID: ${order.clientId.substring(0, 8)}',
                    style: AppTextStyles.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Address details could go here if available',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Order Items Section
            _buildSectionHeader('Order Items'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Column(
                children: order.items
                    .map(
                      (item) => Column(
                        children: [
                          _buildOrderItem(
                            item.name ?? 'Item',
                            '₦${(item.price ?? 0).toStringAsFixed(2)} x ${item.quantity}',
                            '₦${((item.price ?? 0) * item.quantity).toStringAsFixed(2)}',
                          ),
                          if (order.items.indexOf(item) !=
                              order.items.length - 1)
                            const Divider(
                              color: AppColors.border,
                              height: 1,
                              indent: AppSpacing.xl,
                              endIndent: AppSpacing.xl,
                            ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Financial Summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '₦${order.totalProductAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.headingMd.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: order.status == 'pending'
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Implement Reject/Cancel
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, _) {
                          return PrimaryButton(
                            label: 'Accept Order',
                            onPressed: () async {
                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );

                              final (success, error) = await ref
                                  .read(vendorRepositoryProvider)
                                  .updateOrderStatus(
                                      order.id, 'searching_driver');

                              if (context.mounted) {
                                Navigator.pop(context); // Close loading
                                if (success) {
                                  ref.invalidate(vendorOrdersProvider);
                                  context.pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Order accepted successfully!'),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          ErrorHandler.getMessage(error)),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildOrderItem(String name, String breakdown, String price) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  breakdown,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

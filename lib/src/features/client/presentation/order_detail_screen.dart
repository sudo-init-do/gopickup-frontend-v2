import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/launch_url.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/order_provider.dart';
import '../../../models/order_models.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/config/app_config.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = order.whatsappUrl ??
        AppConfig.supportWhatsappUrl(
          'Hello GoPickup Support, I have an inquiry about my order: ${order.id}',
        );
    final ok = await openExternalUrl(url);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
              order.id.length > 8 ? order.id.substring(0, 8) : order.id,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTrackingTop(context),
                    _buildSummarySection(),
                    _buildTimelineSection(),
                    const SizedBox(height: AppSpacing.xl),
                    if (order.status == 'pending' ||
                        order.status == 'awaiting_payment')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () => _launchWhatsApp(context),
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                ),
                                label: const Text('Negotiate on WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.whatsapp,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                  ),
                                ),
                              ),
                            ),
                            if (order.status == 'awaiting_payment') ...[
                              const SizedBox(height: AppSpacing.md),
                              Consumer(
                                builder: (context, ref, _) {
                                  final isLoading =
                                      ref.watch(orderProvider).isLoading;
                                  return PrimaryButton(
                                    label: isLoading
                                        ? 'Processing...'
                                        : 'I Have Made Payment',
                                    isLoading: isLoading,
                                    icon: Icons.check_circle_outline_rounded,
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            final success = await ref
                                                .read(orderProvider.notifier)
                                                .reportPaymentMade(order.id);
                                            if (context.mounted && success) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Payment reported successfully!',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      )
                    else if (order.status != 'delivered' &&
                        order.status != 'cancelled')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchWhatsApp(context),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                            ),
                            label: const Text('Chat with Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.whatsapp,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String orderId) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
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
          Column(
            children: [
              Text(
                'Order Tracking',
                style: AppTextStyles.headingLg.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                orderId,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_shipping_rounded,
            color: AppColors.primary,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (order.vendor != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.xxl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Color(0xFF166534),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendor Store',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.vendor!.storeName,
                          style: AppTextStyles.headingMd.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/vendor/store/${order.vendor!.id}'),
                    child: const Text('View Store'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildDriverCard(context),
        ],
      ),
    );
  }

  /// Maps the detailed backend order status onto the four customer-facing
  /// stages. Everything up to (and including) driver assignment reads as
  /// "Order confirmed"; the later steps map 1:1. Returns -1 for a cancelled
  /// order (handled separately).
  int _stageIndex(String status) {
    switch (status) {
      case 'picked_up':
        return 1; // Picked up
      case 'on_the_way':
        return 2; // Coming soon
      case 'delivered':
        return 3; // Delivered
      case 'cancelled':
        return -1;
      default:
        return 0; // pending … assigned/in_progress → Order confirmed
    }
  }

  Widget _buildTimelineSection() {
    final stages = [
      {
        'label': 'Order confirmed',
        'desc': 'Your order is confirmed and being prepared.',
      },
      {
        'label': 'Picked up',
        'desc': 'The driver has collected your order.',
      },
      {
        'label': 'Coming soon',
        'desc': 'Your order is on the way to you.',
      },
      {
        'label': 'Delivered',
        'desc': 'Order delivered. Enjoy!',
      },
    ];

    final bool cancelled = order.status == 'cancelled';
    final int currentIdx = _stageIndex(order.status);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xxxl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Updates',
            style: AppTextStyles.headingMd.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (cancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.destructive.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded,
                      color: AppColors.destructive, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('This order was cancelled.',
                        style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.destructive,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
          else
            ...List.generate(stages.length, (index) {
              final stage = stages[index];
              final bool isDone =
                  index < currentIdx || order.status == 'delivered';
              final bool isActive = index == currentIdx;
              final bool isLast = index == stages.length - 1;

              return _buildTimelineItem(
                stage['label']!,
                stage['desc']!,
                isActive ? 'Now' : '',
                isDone,
                isDone || isActive,
                isActive: isActive,
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }

  /// The assigned-driver card. Shows the real driver + vehicle once one is
  /// assigned (with a tap-to-call button), or a "finding a driver" placeholder
  /// while the order is still being matched.
  Widget _buildDriverCard(BuildContext context) {
    final assigned = order.hasDriver;
    final subtitle = [
      if (order.driverVehicle != null && order.driverVehicle!.isNotEmpty)
        order.driverVehicle!,
      if (order.driverPlate != null && order.driverPlate!.isNotEmpty)
        order.driverPlate!,
    ].join(' • ');
    final canCall =
        assigned && order.driverPhone != null && order.driverPhone!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: Icon(
              assigned
                  ? Icons.local_shipping_rounded
                  : Icons.local_shipping_outlined,
              color: AppColors.driverAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assigned ? order.driverName! : 'Finding a driver…',
                  style:
                      AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  assigned
                      ? (subtitle.isEmpty ? 'Your driver' : subtitle)
                      : 'We’ll assign a driver to your order shortly.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (canCall)
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => openExternalUrl('tel:${order.driverPhone}'),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Icon(Icons.call_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Order summary — items with quantities, the vendor, and the total (₦).
  Widget _buildSummarySection() {
    final currency = NumberFormat.currency(
        locale: 'en_NG', symbol: '₦', decimalDigits: 0);
    final itemsTotal = order.totalProductAmount;
    final deliveryFee = order.agreedDeliveryFee ?? 0;
    final grandTotal = (order.agreedPrice ?? itemsTotal) + deliveryFee;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary',
              style: AppTextStyles.headingMd
                  .copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: AppSpacing.xs),
          Text('From ${order.vendor?.storeName ?? 'GoPickup Store'}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.lg),
          if (order.items.isEmpty)
            Text('No item details available.',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textTertiary))
          else
            ...order.items.map((it) {
              final name = it.name ?? 'Item';
              final lineTotal = it.price != null ? it.price! * it.quantity : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text('${it.quantity}×',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(name,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                    if (lineTotal != null)
                      Text(currency.format(lineTotal),
                          style: AppTextStyles.bodySm
                              .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          if (deliveryFee > 0) ...[
            _summaryRow('Items', currency.format(itemsTotal)),
            const SizedBox(height: AppSpacing.xs),
            _summaryRow('Delivery', currency.format(deliveryFee)),
            const SizedBox(height: AppSpacing.sm),
          ],
          _summaryRow('Total', currency.format(grandTotal), emphasize: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    final labelStyle = emphasize
        ? AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800)
        : AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary);
    final valueStyle = emphasize
        ? AppTextStyles.titleMd
            .copyWith(fontWeight: FontWeight.w900, color: AppColors.primary)
        : AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: labelStyle), Text(value, style: valueStyle)],
    );
  }

  Widget _buildTimelineItem(
    String label,
    String desc,
    String time,
    bool isDone,
    bool showSolidLine, {
    bool isActive = false,
    bool isLast = false,
  }) {
    const color = AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isDone ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: !isDone ? Border.all(color: color, width: 2) : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    color: showSolidLine
                        ? color
                        : color.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.xxl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.titleMd.copyWith(
                            fontSize: 17,
                            fontWeight: isActive || isDone
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDone || isActive
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          desc,
                          style: AppTextStyles.body.copyWith(
                            color: isDone || isActive
                                ? AppColors.textSecondary
                                : AppColors.textSecondary.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.label.copyWith(
                      color: isActive ? color : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

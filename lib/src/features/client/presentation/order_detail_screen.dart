import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
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
                        'John Driver',
                        style: AppTextStyles.headingMd.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Toyota Hilux • ABC 1234',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final List<Map<String, dynamic>> stages = [
      {
        'status': 'pending',
        'label': 'Order Placed',
        'desc': 'Waiting for price estimation',
      },
      {
        'status': 'awaiting_payment',
        'label': 'Negotiation',
        'desc': 'Contact support to finalize price',
      },
      {
        'status': 'payment_made',
        'label': 'Payment Made',
        'desc': 'Awaiting admin verification',
      },
      {
        'status': 'processing',
        'label': 'Finding Driver',
        'desc': 'We are looking for a driver',
      },
      {
        'status': 'assigned',
        'label': 'Driver Assigned',
        'desc': 'We found a driver for you',
      },
      {
        'status': 'in_progress',
        'label': 'Accepted',
        'desc': 'Driver is heading to vendor',
      },
      {
        'status': 'picked_up',
        'label': 'Picked Up',
        'desc': 'Goods in possession of driver',
      },
      {
        'status': 'on_the_way',
        'label': 'In Transit',
        'desc': 'Driver is heading to you',
      },
      {
        'status': 'delivered',
        'label': 'Delivered',
        'desc': 'Order completed successfully',
      },
    ];

    // Status priority for determining progress
    final statusList = stages.map((s) => s['status'] as String).toList();
    final currentIdx = statusList.indexOf(order.status);

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
            'Delivery Timeline',
            style: AppTextStyles.headingMd.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final bool isDone =
                index < currentIdx || order.status == 'delivered';
            final bool isActive = index == currentIdx;
            final bool isLast = index == stages.length - 1;

            return _buildTimelineItem(
              stage['label'],
              stage['desc'],
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

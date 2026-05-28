import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Order Delivered',
        'message':
            'Your order ORD-002 has been successfully delivered by the driver.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'type': 'order',
        'isRead': false,
      },
      {
        'title': 'New Bid Received',
        'message':
            'A driver has submitted a bid of ₦120.00 for your delivery job.',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'bid',
        'isRead': true,
      },
      {
        'title': 'Payment Confirmed',
        'message': 'Your wallet top-up of ₦1,000.00 has been successful.',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'wallet',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
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
          Text(
            'Notifications',
            style: AppTextStyles.headingMd.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Clear all',
                style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] as bool;
    final String type = notification['type'] as String;

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'order':
        icon = Icons.inventory_2_outlined;
        iconColor = AppColors.info;
        bgColor = AppColors.info.withOpacity(0.1);
        break;
      case 'bid':
        icon = Icons.gavel_rounded;
        iconColor = AppColors.warning;
        bgColor = AppColors.warning.withOpacity(0.1);
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = const Color(0xFF8B5CF6);
        bgColor = const Color(0xFF8B5CF6).withOpacity(0.1);
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primaryLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isRead ? AppColors.backgroundSubtle : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isRead
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
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
                      notification['title'] as String,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  notification['message'] as String,
                  style: AppTextStyles.bodySm.copyWith(height: 1.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  DateFormat('h:mm a • MMM d').format(notification['time'] as DateTime),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
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

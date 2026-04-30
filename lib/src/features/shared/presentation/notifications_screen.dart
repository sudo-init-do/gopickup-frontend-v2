import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kBrandGreen = Color(0xFF3B7D23);

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
        'title': 'New Message',
        'message':
            'BuildMart Supplies: "Hello, we have confirmed your order and it is being processed."',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'type': 'chat',
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, kDarkTextColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(
                    notifications[index],
                    kDarkTextColor,
                    kMidTextColor,
                    kBrandGreen,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color darkText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    color: Colors.black.withOpacity( 0.04),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Clear all',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    Color darkText,
    Color midText,
    Color brandGreen,
  ) {
    final bool isRead = notification['isRead'] as bool;
    final String type = notification['type'] as String;

    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'order':
        icon = Icons.inventory_2_outlined;
        iconColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFEFF6FF);
        break;
      case 'chat':
        icon = Icons.chat_bubble_outline_rounded;
        iconColor = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        break;
      case 'bid':
        icon = Icons.gavel_rounded;
        iconColor = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFFFFBEB);
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = const Color(0xFF8B5CF6);
        bgColor = const Color(0xFFF5F3FF);
        break;
      default:
        icon = Icons.notifications_none_rounded;
        iconColor = brandGreen;
        bgColor = const Color(0xFFF0FDF4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isRead ? const Color(0xFFF1F5F9) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isRead
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
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
                      notification['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.w700 : FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: brandGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'h:mm a • MMM d',
                  ).format(notification['time'] as DateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: midText.withOpacity( 0.6),
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

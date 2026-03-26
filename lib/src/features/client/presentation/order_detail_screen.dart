import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/order_models.dart';
import '../../../common/styles/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  Future<void> _launchWhatsApp() async {
    const phone = "2348000000000"; // Real admin number should be used here
    final message = "Hello GoPickup Support, I have an inquiry about my order: ${order.id}";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kLightTextColor = Color(0xFF9CA3AF);
    final kBrandGreen = AppColors.primary;
 
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              context,
              order.id.length > 8 ? order.id.substring(0, 8) : order.id,
              kDarkTextColor,
              kLightTextColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTrackingTop(
                      kBrandGreen,
                      kDarkTextColor,
                      kMidTextColor,
                    ),
                    _buildTimelineSection(
                      kDarkTextColor,
                      kMidTextColor,
                      kLightTextColor,
                      kBrandGreen,
                    ),
                    const SizedBox(height: 24),
                    if (order.status != 'delivered' && order.status != 'cancelled')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: _launchWhatsApp,
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Chat with Support (WhatsApp)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String orderId,
    Color darkText,
    Color lightText,
  ) {
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
          Column(
            children: [
              const Text(
                'Order Tracking',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                orderId,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTop(Color brandGreen, Color darkText, Color midText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.local_shipping_rounded, color: brandGreen, size: 64),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFFF97316),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Driver',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: darkText,
                        ),
                      ),
                      Text(
                        'Toyota Hilux • ABC 1234',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: midText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandGreen,
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

  Widget _buildTimelineSection(
    Color darkText,
    Color midText,
    Color lightText,
    Color brandGreen,
  ) {
    final List<Map<String, dynamic>> stages = [
      {
        'status': 'pending',
        'label': 'Order Placed',
        'desc': 'Waiting for price estimation',
      },
      {
        'status': 'processing',
        'label': 'Negotiation',
        'desc': 'Contact support to finalize price',
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Timeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 32),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final bool isDone = index < currentIdx || order.status == 'delivered';
            final bool isActive = index == currentIdx;
            final bool isLast = index == stages.length - 1;

            return _buildTimelineItem(
              stage['label'],
              stage['desc'],
              isActive ? 'Now' : '',
              isDone,
              isDone || isActive,
              brandGreen,
              darkText,
              midText,
              lightText,
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
    bool showSolidLine,
    Color color,
    Color darkText,
    Color midText,
    Color lightText, {
    bool isActive = false,
    bool isLast = false,
  }) {
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
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: showSolidLine ? color : color.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: isActive || isDone
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDone || isActive
                                ? darkText
                                : darkText.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDone || isActive
                                ? midText
                                : midText.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive ? color : lightText,
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

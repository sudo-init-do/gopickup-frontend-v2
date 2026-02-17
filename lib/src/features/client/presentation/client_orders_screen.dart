import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../client/data/order_repository.dart';
import '../../../common/models/order.dart';

class ClientOrdersScreen extends ConsumerWidget {
  const ClientOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, orders[index]);
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
          const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    Color badgeColor;
    Color badgeTextColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.transit:
        badgeColor = const Color(0xFFFFF7ED);
        badgeTextColor = const Color(0xFFF97316);
        statusText = 'In Transit';
        break;
      case OrderStatus.delivered:
        badgeColor = const Color(0xFFECFDF5);
        badgeTextColor = const Color(0xFF10B981);
        statusText = 'Delivered';
        break;
      case OrderStatus.processing:
        badgeColor = const Color(0xFFF0FDF4);
        badgeTextColor = const Color(0xFF3B7D23);
        statusText = 'Processing';
        break;
    }

    // In a real app, these would come from the order model/vendor relation
    final vendorName = order.items.isNotEmpty ? 'BuildMart Supplies' : 'General Vendor';

    return GestureDetector(
      onTap: () => context.push('/client/orders/${order.id}', extra: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF3B7D23),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Color(0xFF1F2937),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy').format(order.placedAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorName,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${order.items.length} items',
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1F2937),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Color(0xFFD1D5DB),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order.status != OrderStatus.delivered) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Color(0xFFF3F4F6), height: 1),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: Color(0xFF3B7D23),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ETA:',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.status == OrderStatus.transit ? '2 hours' : 'Tomorrow',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/order.dart';
import 'package:intl/intl.dart';

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const kPurple = Color(0xFFA855F7);
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kLightBorderColor = Color(0xFFF1F5F9);

    final ordersAsync = ref.watch(vendorOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kDarkTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kLightBorderColor, width: 1.5),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterTab('All', true, kPurple),
                  _buildFilterTab('Pending', false, kPurple),
                  _buildFilterTab('Processing', false, kPurple),
                  _buildFilterTab('Shipped', false, kPurple),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: kLightBorderColor, height: 1),

            // Orders List
            Expanded(
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(child: Text('No orders found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(vendorOrdersProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final itemsDescription = order.items.map((i) => '${i.quantity}x ${i.product.name}').join('\n');
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildOrderCard(
                            context,
                            order,
                            order.shortId,
                            'Client: ${order.clientId.substring(0, 8)}',
                            itemsDescription,
                            DateFormat('MMM d, yyyy • h:mm a').format(order.placedAt),
                            '₦${order.total.toStringAsFixed(2)}',
                            order.status.displayName,
                            order.status.backgroundColor,
                            order.status.color,
                            kDarkTextColor,
                            kMidTextColor,
                            kLightBorderColor,
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFilterTab(String label, bool isActive, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Order order,
    String id,
    String customer,
    String items,
    String date,
    String price,
    String status,
    Color tagBg,
    Color tagColor,
    Color kDarkTextColor,
    Color kMidTextColor,
    Color kLightBorderColor,
  ) {
    return GestureDetector(
      onTap: () => context.push('/vendor/orders/${order.id}', extra: order),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: kLightBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kDarkTextColor.withOpacity(0.04),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kDarkTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        order.status == OrderStatus.delivered
                            ? Icons.check_circle_outline_rounded
                            : (order.status == OrderStatus.pending ? Icons.access_time_rounded : Icons.inventory_2_outlined),
                        size: 14,
                        color: tagColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: tagColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              customer,
              style: TextStyle(
                color: kMidTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              items,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: kLightBorderColor, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kDarkTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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

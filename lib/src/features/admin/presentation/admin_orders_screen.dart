import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_models.dart';
import 'admin_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final padding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Monitoring',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: isMobile ? 22 : null,
                  ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) return _buildEmptyState();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderTile(context, order, isMobile);
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()),
                ),
                error: (e, stack) => Center(
                  child: Padding(padding: const EdgeInsets.all(40.0), child: Text('Error: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, Order order, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Order ID + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),

          // Pickup address
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: isMobile ? 14 : 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'From: ${order.pickupAddress}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Delivery address
          Row(
            children: [
              Icon(Icons.home_outlined, size: isMobile ? 14 : 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'To: ${order.deliveryAddress}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom row: Products + Total
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Products: ${order.items.length}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Total: ₦${order.totalProductAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Products: ${order.items.length}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Total: ₦${order.totalProductAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active orders found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'delivered': color = Colors.green; break;
      case 'pending': color = Colors.amber; break;
      case 'searching_driver': color = Colors.blue; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/order.dart';
import '../../client/data/wallet_repository.dart';

class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(vendorOrdersProvider);
    final dashboardAsync = ref.watch(vendorDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vendorOrdersProvider);
          ref.invalidate(vendorDashboardProvider);
          ref.invalidate(vendorInventoryProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Purple Header with Curve
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 60,
                        left: 24,
                        right: 24,
                        bottom: 120,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Store Info Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'My Store',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFFD700),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Verified Vendor',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Stats Grid
                          dashboardAsync.when(
                            data: (data) => Row(
                              children: [
                                _buildStatCard(
                                  '${data['total_orders'] ?? 0}',
                                  'Total Orders',
                                  Icons.shopping_bag_outlined,
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  '${data['pending_orders'] ?? 0}',
                                  'Awaiting',
                                  Icons.pending_actions_rounded,
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  '₦${((data['total_revenue'] ?? 0) / 1000).toStringAsFixed(1)}k',
                                  'Revenue',
                                  Icons.payments_outlined,
                                ),
                                const SizedBox(width: 10),
                                ref.watch(vendorInventoryProvider).when(
                                  data: (products) => _buildStatCard(
                                    '${products.length}',
                                    'Products',
                                    Icons.inventory_2_outlined,
                                  ),
                                  loading: () => _buildStatCard('...', 'Products', Icons.inventory_2_outlined),
                                  error: (_, __) => _buildStatCard('0', 'Products', Icons.inventory_2_outlined),
                                ),
                              ],
                            ),
                            loading: () => Row(
                              children: [
                                _buildStatCard('...', 'Orders', Icons.shopping_bag_outlined),
                                const SizedBox(width: 10),
                                _buildStatCard('...', 'Pending', Icons.pending_actions_rounded),
                                const SizedBox(width: 10),
                                _buildStatCard('...', 'Revenue', Icons.payments_outlined),
                                const SizedBox(width: 10),
                                _buildStatCard('...', 'Products', Icons.inventory_2_outlined),
                              ],
                            ),
                            error: (err, _) => Row(
                              children: [
                                _buildStatCard('0', 'Orders', Icons.shopping_bag_outlined),
                                const SizedBox(width: 10),
                                _buildStatCard('0', 'Pending', Icons.pending_actions_rounded),
                                const SizedBox(width: 10),
                                _buildStatCard('₦0', 'Revenue', Icons.payments_outlined),
                                const SizedBox(width: 10),
                                _buildStatCard('0', 'Products', Icons.inventory_2_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Floating Action Bar (Overlapping)
                Positioned(
                  bottom: -40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.push('/vendor/inventory/add'),
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45A225),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/vendor/orders'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(
                                color: Color(0xFFF1F5F9),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                            child: const Text(
                              'View Orders',
                              style: TextStyle(color: Color(0xFF111827)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),
            // Recent Orders Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/vendor/orders'),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFFA855F7),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orders List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No orders yet'),
                      ),
                    );
                  }
                  return Column(
                    children: orders
                        .take(5)
                        .map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () => context.push(
                                '/vendor/orders/${order.id}',
                                extra: order,
                              ),
                              child: _buildOrderCard(order),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusText = order.status.displayName;
    final tagBg = order.status.backgroundColor;
    final tagText = order.status.color;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.shortId,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: tagText,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Client ID: ${order.clientId.substring(0, 8)}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} items',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₦${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

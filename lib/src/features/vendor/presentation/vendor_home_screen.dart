import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/models/order.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';

class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(vendorOrdersProvider);
    final dashboardAsync = ref.watch(vendorDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                        left: AppSpacing.xl,
                        right: AppSpacing.xl,
                        bottom: 120,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.vendorAccent, Color(0xFF9333EA)],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Store Info Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Store',
                                      style: AppTextStyles.headingLg.copyWith(
                                        color: Colors.white,
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
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          'GoPickup Vendor',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: Colors.white.withOpacity(0.9),
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
                          const SizedBox(height: AppSpacing.xxl),
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
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
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
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                ),
                                textStyle: AppTextStyles.button,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/vendor/orders'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.card,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                side: const BorderSide(
                                  color: AppColors.border,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                ),
                                textStyle: AppTextStyles.button,
                              ),
                              child: Text(
                                'View Orders',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textPrimary,
                                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: AppTextStyles.headingMd,
                    ),
                    TextButton(
                      onPressed: () => context.go('/vendor/orders'),
                      child: Text(
                        'View all',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.vendorAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Orders List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'No orders yet',
                        message: 'Your recent orders will appear here.',
                      );
                    }
                    return Column(
                      children: orders
                          .take(5)
                          .map(
                            (order) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                  loading: () => const AppLoading(),
                  error: (err, _) => AppErrorState(message: 'Error: $err'),
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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.titleMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
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
                style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w900),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.caption.copyWith(
                    color: tagText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'Client ID: ${order.clientId.substring(0, 8)}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.items.length} items',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
              ),
              Text(
                '₦${order.total.toStringAsFixed(2)}',
                style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w900),
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

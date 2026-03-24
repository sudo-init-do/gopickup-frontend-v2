import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: isMobile ? 22 : null,
              ),
            ),
            const SizedBox(height: 24),

            statsAsync.when(
              data: (stats) {
                final cards = [
                  _StatCard(
                    title: 'Total Users',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people,
                    color: Colors.blue.shade600,
                  ),
                  _StatCard(
                    title: 'Approved Drivers',
                    value: '${stats.totalDrivers - stats.pendingDrivers}/${stats.totalDrivers}',
                    icon: Icons.local_shipping,
                    color: Colors.green.shade600,
                  ),
                  _StatCard(
                    title: 'Approved Vendors',
                    value: '${stats.totalVendors - stats.pendingVendors}/${stats.totalVendors}',
                    icon: Icons.store,
                    color: Colors.orange.shade600,
                  ),
                  _StatCard(
                    title: 'Total Products',
                    value: stats.totalProducts.toString(),
                    icon: Icons.shopping_bag,
                    color: Colors.purple.shade600,
                  ),
                  _StatCard(
                    title: 'Total Orders',
                    value: stats.totalOrders.toString(),
                    icon: Icons.assignment,
                    color: Colors.teal.shade600,
                  ),
                  _StatCard(
                    title: 'Pending Orders',
                    value: stats.pendingOrders.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.amber.shade700,
                  ),
                  _StatCard(
                    title: 'Active Orders',
                    value: stats.activeOrders.toString(),
                    icon: Icons.radar,
                    color: Colors.lightBlue.shade600,
                    subtitle: 'In progress',
                  ),
                ];

                if (isMobile) {
                  // Mobile: 2-column grid
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) => cards[index],
                  );
                }

                // Desktop: rows of 4 + 3
                return Column(
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < 4; i++) ...[
                          if (i > 0) const SizedBox(width: 24),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        for (int i = 4; i < cards.length; i++) ...[
                          if (i > 4) const SizedBox(width: 24),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, stack) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isMobile ? 22 : 28),
          ),
          SizedBox(height: isMobile ? 12 : 24),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

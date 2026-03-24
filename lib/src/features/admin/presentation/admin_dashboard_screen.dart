import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            statsAsync.when(
              data: (stats) => Column(
                children: [
                   // Stats Cards - Row 1
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        title: 'Total Users', 
                        value: stats.totalUsers.toString(), 
                        icon: Icons.people, 
                        color: Colors.blue.shade600
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _StatCard(
                        title: 'Approved Drivers', 
                        value: '${stats.totalDrivers - stats.pendingDrivers}/${stats.totalDrivers}', 
                        icon: Icons.local_shipping, 
                        color: Colors.green.shade600
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _StatCard(
                        title: 'Approved Vendors', 
                        value: '${stats.totalVendors - stats.pendingVendors}/${stats.totalVendors}', 
                        icon: Icons.store, 
                        color: Colors.orange.shade600
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _StatCard(
                        title: 'Total Products', 
                        value: stats.totalProducts.toString(), 
                        icon: Icons.shopping_bag, 
                        color: Colors.purple.shade600
                      )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Order Snapshot Section
                  Row(
                    children: [
                       Expanded(child: _StatCard(
                        title: 'Total Orders', 
                        value: stats.totalOrders.toString(), 
                        icon: Icons.assignment, 
                        color: Colors.teal.shade600
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _StatCard(
                        title: 'Pending Orders', 
                        value: stats.pendingOrders.toString(), 
                        icon: Icons.warning_amber_rounded, 
                        color: Colors.amber.shade700
                      )),
                      const SizedBox(width: 24),
                      Expanded(child: _StatCard(
                        title: 'Active Orders', 
                        value: stats.activeOrders.toString(), 
                        icon: Icons.radar, 
                        color: Colors.lightBlue.shade600,
                        subtitle: 'Currently in progress',
                      )),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
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
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

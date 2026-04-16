import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MARKETPLACE OVERVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analytics Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Top Actions Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTopAction(Icons.check_circle_outline, 'Approve\n5 Drivers', Colors.blue),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      _buildTopAction(Icons.pending_actions, 'Review 3\nPending Orders', Colors.grey.shade600),
                      Container(width: 1, height: 30, color: Colors.grey.shade300),
                      _buildTopAction(Icons.add, 'New\nCampaign', Colors.grey.shade600),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'LAST 24 HOURS ▼',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Stats Column
                Column(
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      iconBgColor: Colors.blue.shade50,
                      iconColor: Colors.blue.shade600,
                      percentage: '+12%',
                      isPositive: true,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Approved Drivers',
                      value: stats.totalDrivers.toString(),
                      icon: Icons.local_shipping,
                      iconBgColor: Colors.orange.shade50,
                      iconColor: Colors.orange.shade600,
                      percentage: '+5.2%',
                      isPositive: true,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Approved Vendors',
                      value: stats.totalVendors.toString(),
                      icon: Icons.storefront,
                      iconBgColor: Colors.green.shade50,
                      iconColor: Colors.green.shade600,
                      percentage: 'Stable',
                      isPositive: true,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Total Orders',
                      value: stats.totalOrders.toString(),
                      icon: Icons.receipt_long,
                      iconBgColor: Colors.red.shade50,
                      iconColor: Colors.red.shade600,
                      percentage: '-2.4%',
                      isPositive: false,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Revenue Trend Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Monthly growth and volume', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                _buildTogglePill('Monthly', true),
                                _buildTogglePill('Weekly', false),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL'];
                                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(months[value.toInt()], style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 1),
                                  FlSpot(1, 1.2),
                                  FlSpot(2, 1.5),
                                  FlSpot(3, 2.8),
                                  FlSpot(4, 3.2),
                                  FlSpot(5, 4.0),
                                  FlSpot(6, 4.5),
                                ],
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent.withOpacity(0.3),
                                      Colors.blueAccent.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Order Categories Donut Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 50,
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(color: Colors.indigoAccent, value: 64, title: '', radius: 15),
                                  PieChartSectionData(color: Colors.orange.shade600, value: 24, title: '', radius: 15),
                                  PieChartSectionData(color: Colors.red.shade600, value: 12, title: '', radius: 15),
                                ],
                              ),
                            ),
                            const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('12.4k', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                  Text('TOTAL ORDERS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLegendItem(Colors.indigoAccent, 'Electronics', '64%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.orange.shade600, 'Home & Living', '24%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(Colors.red.shade600, 'Fashion', '12%'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('View All History', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActivityItem(
                        icon: Icons.person_add,
                        iconColor: Colors.blueAccent,
                        title: 'New Vendor Registered',
                        time: '2 mins ago',
                        desc: '"Urban Artisan Collective" joined the platform. Store pending review.',
                        isLast: false,
                      ),
                      _buildActivityItem(
                        icon: Icons.payments,
                        iconColor: Colors.orange.shade600,
                        title: 'High Value Order Placed',
                        time: '14 mins ago',
                        desc: 'Order #88219 reached ₦4,200 threshold. Fraud verification required.',
                        isLast: false,
                      ),
                      _buildActivityItem(
                        icon: Icons.verified,
                        iconColor: Colors.green.shade600,
                        title: 'Compliance Checklist Completed',
                        time: '1 hour ago',
                        desc: 'Driver "Sarah Jenkins" verified with 5-star safety rating.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48), // Padding for fab or bottom scroll
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTopAction(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTogglePill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(percentage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String desc,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String percentage;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: percentage == 'Stable' ? Colors.grey.shade100 : (isPositive ? Colors.green.shade50 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: percentage == 'Stable' ? Colors.grey.shade600 : (isPositive ? Colors.green.shade700 : Colors.red.shade700),
                      ),
                    ),
                    if (percentage != 'Stable') ...[
                      const SizedBox(width: 2),
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 10,
                        color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}

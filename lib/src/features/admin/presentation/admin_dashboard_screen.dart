import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_card.dart';
import '../../../common/widgets/app_states.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final padding = isMobile ? AppSpacing.lg : AppSpacing.xxl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MARKETPLACE OVERVIEW',
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Analytics Dashboard',
                  style: AppTextStyles.headingMd,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Top Actions Row
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTopAction(Icons.check_circle_outline, 'Approve\n5 Drivers', AppColors.adminAccent),
                      Container(width: 1, height: 30, color: AppColors.border),
                      _buildTopAction(Icons.pending_actions, 'Review 3\nPending Orders', AppColors.textSecondary),
                      Container(width: 1, height: 30, color: AppColors.border),
                      _buildTopAction(Icons.add, 'New\nCampaign', AppColors.textSecondary),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'LAST 24 HOURS ▼',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Main Stats Column
                Column(
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      iconBgColor: AppColors.info.withOpacity(0.1),
                      iconColor: AppColors.info,
                      percentage: '+12%',
                      isPositive: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatCard(
                      title: 'Approved Drivers',
                      value: stats.totalDrivers.toString(),
                      icon: Icons.local_shipping,
                      iconBgColor: AppColors.driverAccent.withOpacity(0.1),
                      iconColor: AppColors.driverAccent,
                      percentage: '+5.2%',
                      isPositive: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatCard(
                      title: 'Approved Vendors',
                      value: stats.totalVendors.toString(),
                      icon: Icons.storefront,
                      iconBgColor: AppColors.success.withOpacity(0.1),
                      iconColor: AppColors.success,
                      percentage: 'Stable',
                      isPositive: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _StatCard(
                      title: 'Total Orders',
                      value: stats.totalOrders.toString(),
                      icon: Icons.receipt_long,
                      iconBgColor: AppColors.destructive.withOpacity(0.1),
                      iconColor: AppColors.destructive,
                      percentage: '-2.4%',
                      isPositive: false,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Revenue Trend Chart
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Revenue Trend', style: AppTextStyles.titleMd),
                              SizedBox(height: AppSpacing.xs),
                              Text('Monthly growth and volume', style: AppTextStyles.caption),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSubtle,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                      const SizedBox(height: AppSpacing.xl),
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
                                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                                        child: Text(
                                          months[value.toInt()],
                                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                                        ),
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
                                color: AppColors.adminAccent,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.adminAccent.withOpacity(0.3),
                                      AppColors.adminAccent.withOpacity(0.0),
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

                const SizedBox(height: AppSpacing.xl),

                // Order Categories Donut Chart
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Categories', style: AppTextStyles.titleMd),
                      const SizedBox(height: AppSpacing.xl),
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
                                  PieChartSectionData(color: AppColors.adminAccent, value: 64, title: '', radius: 15),
                                  PieChartSectionData(color: AppColors.driverAccent, value: 24, title: '', radius: 15),
                                  PieChartSectionData(color: AppColors.destructive, value: 12, title: '', radius: 15),
                                ],
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('12.4k', style: AppTextStyles.headingMd),
                                  Text(
                                    'TOTAL ORDERS',
                                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildLegendItem(AppColors.adminAccent, 'Electronics', '64%'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildLegendItem(AppColors.driverAccent, 'Home & Living', '24%'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildLegendItem(AppColors.destructive, 'Fashion', '12%'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Recent Activity
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Activity', style: AppTextStyles.titleMd),
                          Text(
                            'View All History',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.adminAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildActivityItem(
                        icon: Icons.person_add,
                        iconColor: AppColors.adminAccent,
                        title: 'New Vendor Registered',
                        time: '2 mins ago',
                        desc: '"Urban Artisan Collective" joined the platform. Store pending review.',
                        isLast: false,
                      ),
                      _buildActivityItem(
                        icon: Icons.payments,
                        iconColor: AppColors.driverAccent,
                        title: 'High Value Order Placed',
                        time: '14 mins ago',
                        desc: 'Order #88219 reached ₦4,200 threshold. Fraud verification required.',
                        isLast: false,
                      ),
                      _buildActivityItem(
                        icon: Icons.verified,
                        iconColor: AppColors.success,
                        title: 'Compliance Checklist Completed',
                        time: '1 hour ago',
                        desc: 'Driver "Sarah Jenkins" verified with 5-star safety rating.',
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl + AppSpacing.sm), // Padding for fab or bottom scroll
              ],
            ),
          );
        },
        loading: () => const AppLoading(),
        error: (e, stack) => AppErrorState(message: 'Error: $e'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.adminAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTopAction(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTogglePill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.card : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm - 2),
        boxShadow: isActive
            ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
            : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
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
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.bodySm),
          ],
        ),
        Text(
          percentage,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
        ),
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
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.label,
                        ),
                      ),
                      Text(time, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    desc,
                    style: AppTextStyles.bodySm.copyWith(height: 1.4),
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
    final isStable = percentage == 'Stable';
    final badgeBg = isStable
        ? AppColors.backgroundSubtle
        : (isPositive ? AppColors.success.withOpacity(0.1) : AppColors.destructive.withOpacity(0.1));
    final badgeFg = isStable
        ? AppColors.textSecondary
        : (isPositive ? AppColors.success : AppColors.destructive);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      percentage,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: badgeFg,
                      ),
                    ),
                    if (!isStable) ...[
                      const SizedBox(width: 2),
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 10,
                        color: badgeFg,
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headingLg,
          ),
        ],
      ),
    );
  }
}

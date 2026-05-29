import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_card.dart';
import '../../../common/widgets/app_states.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // Live updates: refresh stats + recent signups so a new user who joins
    // while an admin is on this screen shows up automatically.
    _poll = Timer.periodic(const Duration(seconds: 12), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(adminStatsProvider);
    ref.invalidate(adminRecentUsersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          color: AppColors.adminAccent,
          child: statsAsync.when(
            data: (stats) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MARKETPLACE OVERVIEW',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text('Analytics Dashboard',
                            style: AppTextStyles.headingMd),
                      ],
                    ),
                    const _LiveBadge(),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Real stats grid (incl. Total Clients)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.55,
                  children: [
                    _StatCard(
                      title: 'Total Users',
                      value: stats.totalUsers,
                      icon: Icons.people_alt_rounded,
                      color: AppColors.info,
                    ),
                    _StatCard(
                      title: 'Total Clients',
                      value: stats.totalClients,
                      icon: Icons.person_rounded,
                      color: AppColors.clientAccent,
                    ),
                    _StatCard(
                      title: 'Drivers',
                      value: stats.totalDrivers,
                      icon: Icons.local_shipping_rounded,
                      color: AppColors.driverAccent,
                    ),
                    _StatCard(
                      title: 'Vendors',
                      value: stats.totalVendors,
                      icon: Icons.storefront_rounded,
                      color: AppColors.success,
                    ),
                    _StatCard(
                      title: 'Total Orders',
                      value: stats.totalOrders,
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.adminAccent,
                    ),
                    _StatCard(
                      title: 'Pending Orders',
                      value: stats.pendingOrders,
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      title: 'Active Orders',
                      value: stats.activeOrders,
                      icon: Icons.local_activity_rounded,
                      color: AppColors.secondary,
                    ),
                    _StatCard(
                      title: 'Products',
                      value: stats.totalProducts,
                      icon: Icons.inventory_2_rounded,
                      color: AppColors.destructive,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Real recent signups (replaces the old mock "Recent Activity")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Signups', style: AppTextStyles.titleMd),
                    Text(
                      'Live',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _RecentSignups(),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
            loading: () => const AppLoading(),
            error: (e, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: AppErrorState(
                    message: 'Could not load dashboard',
                    onRetry: _refresh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Live',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('$value', style: AppTextStyles.headingLg),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSignups extends ConsumerWidget {
  const _RecentSignups();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminRecentUsersProvider);
    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const AppCard(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: Text('No signups yet', style: AppTextStyles.bodySm)),
          );
        }
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              for (int i = 0; i < users.length; i++)
                _signupRow(users[i], isLast: i == users.length - 1),
            ],
          ),
        );
      },
      loading: () => const AppCard(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _signupRow(Map<String, dynamic> u, {required bool isLast}) {
    final email = (u['email'] ?? '').toString();
    final role = (u['role'] ?? 'client').toString();
    final name = (u['full_name'] as String?)?.trim();
    final display = (name == null || name.isEmpty)
        ? (email.isEmpty ? 'New user' : email.split('@').first)
        : name;
    final (color, icon) = _roleStyle(role);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
                Text(
                  role[0].toUpperCase() + role.substring(1),
                  style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            _relativeTime(u['created_at']?.toString()),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  (Color, IconData) _roleStyle(String role) {
    switch (role) {
      case 'driver':
        return (AppColors.driverAccent, Icons.local_shipping_rounded);
      case 'vendor':
        return (AppColors.success, Icons.storefront_rounded);
      case 'admin':
        return (AppColors.adminAccent, Icons.shield_rounded);
      default:
        return (AppColors.clientAccent, Icons.person_rounded);
    }
  }

  String _relativeTime(String? iso) {
    if (iso == null) return '';
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final d = DateTime.now().difference(t.toLocal());
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

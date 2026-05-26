import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/profile_provider.dart';
import '../../client/data/wallet_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Driver-accent Header Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 64, 28, 80),
                  decoration: const BoxDecoration(
                    color: AppColors.driverAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(48),
                      bottomRight: Radius.circular(48),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: AppTextStyles.displayLg.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ref.watch(driverProfileProvider).when(
                            data: (profile) => Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.fullName,
                                        style: AppTextStyles.headingLg.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        profile.phoneNumber,
                                        style: AppTextStyles.body.copyWith(color: Colors.white70),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm + 2,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(AppRadius.md),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.orange, size: 14),
                                                SizedBox(width: AppSpacing.xs),
                                                Text(
                                                  '4.8',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Text(
                                            '0 deliveries',
                                            style: AppTextStyles.label.copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator(color: Colors.white)),
                            error: (_, __) => const Row(
                              children: [
                                Text('Failed to load profile',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
                // Overlapping Stats Card
                Positioned(
                  bottom: -40,
                  left: 28,
                  right: 28,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildStatItem('0', 'Total Jobs', AppColors.textPrimary),
                        _buildDivider(),
                        _buildStatItem('0%', 'Completion', AppColors.textPrimary),
                        _buildDivider(),
                        ref.watch(balanceProvider).when(
                              data: (balance) => _buildStatItem(
                                  '₦${(balance / 1000).toStringAsFixed(1)}k',
                                  'Earned',
                                  AppColors.driverAccent),
                              loading: () => _buildStatItem(
                                  '...', 'Earned', AppColors.driverAccent),
                              error: (_, __) => _buildStatItem(
                                  '₦0.0k', 'Earned', AppColors.driverAccent),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 64), // Space for the overlapping card
            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.local_shipping_outlined,
                    'Vehicle Information',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.credit_card_rounded,
                    'License & Documents',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.location_on_outlined,
                    'Address',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_none_rounded,
                    'Notifications',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '/notifications',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.shield_outlined,
                    'Privacy & Security',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '/settings/privacy',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '/settings',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    AppColors.driverAccent.withOpacity(0.12),
                    AppColors.driverAccent,
                    '/help',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.logout_rounded,
                    'Log Out',
                    AppColors.destructive.withOpacity(0.1),
                    AppColors.destructive,
                    '',
                    isLogout: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.headingMd.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1.5, height: 40, color: AppColors.backgroundSubtle);
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor,
    String route, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            context.go('/');
          } else if (route.isNotEmpty) {
            context.push(route);
          }
        },
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    color: isLogout ? AppColors.destructive : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLogout
                    ? AppColors.destructive.withOpacity(0.5)
                    : AppColors.border,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

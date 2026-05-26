import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 64, 28, 80),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(48),
                      bottomRight: Radius.circular(48),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Store Profile',
                            style: AppTextStyles.displayLg.copyWith(
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => context.push('/settings'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 4,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_outlined,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BuildMart Supplies',
                                  style: AppTextStyles.headingLg.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Hardware • Lagos',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.warning,
                                      size: 18,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '4.9 (1.2k reviews)',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: Colors.white,
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
                      border: Border.all(color: AppColors.border, width: 1.5),
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
                        _buildStatItem('45', 'Active Sales', AppColors.textPrimary),
                        _buildDivider(),
                        _buildStatItem('2.4k', 'Products', AppColors.textPrimary),
                        _buildDivider(),
                        _buildStatItem('₦24.5k', 'Revenue', AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 64),

            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.inventory_2_outlined,
                    'Manage Inventory',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/vendor/inventory',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.assignment_outlined,
                    'Sales History',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/vendor/orders',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Store Wallet',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/vendor/wallet',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.business_outlined,
                    'Business Details',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/vendor/details',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications_none_rounded,
                    'Notifications',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/notifications',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.insights_outlined,
                    'Analytics & Reports',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
                    '/vendor/analytics',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    AppColors.info.withOpacity(0.12),
                    AppColors.info,
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
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.5,
      height: 40,
      color: AppColors.border,
    );
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
            border: Border.all(color: AppColors.border, width: 1.5),
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
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    color: isLogout
                        ? AppColors.destructive
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLogout
                    ? AppColors.destructive.withOpacity(0.5)
                    : AppColors.borderStrong,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

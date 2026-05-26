import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/auth_provider.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green Header Section
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
                      colors: [AppColors.primary, Color(0xFF4CA634)],
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
                            'My Profile',
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
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {},
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
                                Icons.person_outline_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Client Name',
                                  style: AppTextStyles.headingLg.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  user?.email ?? 'client@example.com',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Lagos, Nigeria',
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.white,
                                  ),
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
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.backgroundSubtle,
                        width: 1.5,
                      ),
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
                        _buildStatItem('12', 'Active Orders', AppColors.textPrimary),
                        _buildDivider(),
                        _buildStatItem(
                          '156',
                          'Total Orders',
                          AppColors.textPrimary,
                        ),
                        _buildDivider(),
                        _buildStatItem('₦4.8k', 'Spent', AppColors.primary),
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
                    ref,
                    Icons.inventory_2_outlined,
                    'My Orders',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/client/orders',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.account_balance_wallet_outlined,
                    'My Wallet',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/client/wallet',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.location_on_outlined,
                    'Delivery Addresses',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/client/addresses',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.notifications_none_rounded,
                    'Notifications',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/notifications',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.shield_outlined,
                    'Privacy & Security',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/settings/privacy',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.settings_outlined,
                    'Settings',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/settings',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    AppColors.primaryLight,
                    AppColors.success,
                    '/help',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.logout_rounded,
                    'Log Out',
                    const Color(0xFFFFEBEE),
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
    return Container(
      width: 1.5,
      height: 40,
      color: AppColors.backgroundSubtle,
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
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
        onTap: () async {
          if (isLogout) {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              context.go('/auth/login');
            }
          } else if (route.isNotEmpty) {
            context.push(route);
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.xxl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.xxl),
            border: Border.all(
              color: AppColors.backgroundSubtle,
              width: 1.5,
            ),
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
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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

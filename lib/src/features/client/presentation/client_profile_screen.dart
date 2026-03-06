import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/auth_provider.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const kBrandGreen = Color(0xFF3B7D23);
    const kStatTextColor = Color(0xFF1E293B);
    const kLightGrey = Color(0xFFF1F5F9);
    const kIconBgColor = Color(0xFFF1FDF4);
    const kIconColor = Color(0xFF22C55E);

    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      colors: [Color(0xFF3B7D23), Color(0xFF4CA634)],
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
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
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
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
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
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Client Name',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'client@example.com',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Lagos, Nigeria',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: kLightGrey, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildStatItem('12', 'Active Orders', kStatTextColor),
                        _buildDivider(),
                        _buildStatItem('156', 'Total Orders', kStatTextColor),
                        _buildDivider(),
                        _buildStatItem('₦4.8k', 'Spent', kBrandGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 64),

            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.inventory_2_outlined,
                    'My Orders',
                    kIconBgColor,
                    kIconColor,
                    '/client/orders',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.account_balance_wallet_outlined,
                    'My Wallet',
                    kIconBgColor,
                    kIconColor,
                    '/client/wallet',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.location_on_outlined,
                    'Delivery Addresses',
                    kIconBgColor,
                    kIconColor,
                    '/client/addresses',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.notifications_none_rounded,
                    'Notifications',
                    kIconBgColor,
                    kIconColor,
                    '/notifications',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.shield_outlined,
                    'Privacy & Security',
                    kIconBgColor,
                    kIconColor,
                    '/settings/privacy',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.settings_outlined,
                    'Settings',
                    kIconBgColor,
                    kIconColor,
                    '/settings',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.help_outline_rounded,
                    'Help & Support',
                    kIconBgColor,
                    kIconColor,
                    '/help',
                  ),
                  _buildMenuItem(
                    context,
                    ref,
                    Icons.logout_rounded,
                    'Log Out',
                    const Color(0xFFFFEBEE),
                    const Color(0xFFEF5350),
                    '',
                    isLogout: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1.5, height: 40, color: const Color(0xFFF1F5F9));
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
      margin: const EdgeInsets.only(bottom: 16),
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
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isLogout
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLogout
                    ? const Color(0xFFEF5350).withValues(alpha: 0.5)
                    : const Color(0xFFCBD5E1),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

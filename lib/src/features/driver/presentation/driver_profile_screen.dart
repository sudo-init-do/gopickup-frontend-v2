import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kBrandGreen = Color(0xFF45A225);
    const kStatTextColor = Color(0xFF1E293B);
    const kMenuTextColor = Color(0xFF1E293B);
    const kLightGrey = Color(0xFFF1F5F9);
    const kIconBgColor = Color(0xFFE8F5E9);
    const kIconColor = Color(0xFF4CAF50);

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
                    color: kBrandGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(48),
                      bottomRight: Radius.circular(48),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 50),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ghfcytx',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '+1234567890',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.orange, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            '4.8',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '156 deliveries',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: kLightGrey, width: 1.5),
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
                        _buildStatItem('156', 'Total Jobs', kStatTextColor),
                        _buildDivider(),
                        _buildStatItem('98%', 'Completion', kStatTextColor),
                        _buildDivider(),
                        _buildStatItem('\$12.4k', 'Earned', kBrandGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 64), // Space for the overlapping card
            
            // Menu Items List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.local_shipping_outlined, 'Vehicle Information', kIconBgColor, kIconColor, ''),
                  _buildMenuItem(context, Icons.credit_card_rounded, 'License & Documents', kIconBgColor, kIconColor, ''),
                  _buildMenuItem(context, Icons.location_on_outlined, 'Address', kIconBgColor, kIconColor, ''),
                  _buildMenuItem(context, Icons.notifications_none_rounded, 'Notifications', kIconBgColor, kIconColor, '/notifications'),
                  _buildMenuItem(context, Icons.shield_outlined, 'Privacy & Security', kIconBgColor, kIconColor, '/settings/privacy'),
                  _buildMenuItem(context, Icons.settings_outlined, 'Settings', kIconBgColor, kIconColor, '/settings'),
                  _buildMenuItem(context, Icons.help_outline_rounded, 'Help & Support', kIconBgColor, kIconColor, '/help'),
                  _buildMenuItem(context, Icons.logout_rounded, 'Log Out', const Color(0xFFFFEBEE), const Color(0xFFEF5350), '', isLogout: true),
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
    return Container(
      width: 1.5,
      height: 40,
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Color bgColor, Color iconColor, String route, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            context.go('/');
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
                    color: isLogout ? const Color(0xFFEF5350) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isLogout ? const Color(0xFFEF5350).withOpacity(0.5) : const Color(0xFFCBD5E1),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

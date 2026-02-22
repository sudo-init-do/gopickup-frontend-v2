import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Purple Header with Curve
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 120),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Store Info Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BuildMart Supplies',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.8 (124 reviews)',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Notification Icon
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Stats Grid
                        Row(
                          children: [
                            _buildStatCard('24', 'Products', Icons.inventory_2_outlined),
                            const SizedBox(width: 10),
                            _buildStatCard('156', 'Orders', Icons.shopping_cart_outlined),
                            const SizedBox(width: 10),
                            _buildStatCard('\$12.4k', 'Revenue', Icons.attach_money_rounded),
                            const SizedBox(width: 10),
                            _buildStatCard('2.3k', 'Views', Icons.visibility_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating Action Bar (Overlapping)
                Positioned(
                  bottom: -40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/vendor/inventory'),
                            icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF45A225),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.go('/vendor/orders'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.2),
                            ),
                            child: const Text('View Orders', style: TextStyle(color: Color(0xFF111827))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),
            // Recent Orders Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View all',
                      style: TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),


            // Orders List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/vendor/orders/ORD-156'),
                    child: _buildOrderCard('ORD-156', 'John Smith', 'Pending', '5 items • 5 mins ago', '\$458.00', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/vendor/orders/ORD-155'),
                    child: _buildOrderCard('ORD-155', 'Sarah Johnson', 'Processing', '2 items • 1 hour ago', '\$124.00', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/vendor/orders/ORD-154'),
                    child: _buildOrderCard('ORD-154', 'Mike Wilson', 'Shipped', '8 items • 3 hours ago', '\$890.00', const Color(0xFFE0F2FE), const Color(0xFF075985)),
                  ),
                  const SizedBox(height: 120), // Bottom padding for navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(String id, String user, String status, String details, String price, Color tagBg, Color tagText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF111827)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  status,
                  style: TextStyle(color: tagText, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                user,
                style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(details, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500)),
              Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF111827))),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 20, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kPurple = Color(0xFFA855F7);
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kLightBorderColor = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kDarkTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kLightBorderColor, width: 1.5),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Tabs
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterTab('All', true, kPurple),
                  _buildFilterTab('Pending', false, kPurple),
                  _buildFilterTab('Processing', false, kPurple),
                  _buildFilterTab('Shipped', false, kPurple),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: kLightBorderColor, height: 1),

            // Orders List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildOrderCard(
                    context,
                    'ORD-156',
                    'John Smith',
                    '20x Portland Cement 50kg\n50x Rebar Steel 12mm',
                    'Feb 7, 2026 • 10:30 AM',
                    '₦458.00',
                    'Pending',
                    const Color(0xFFFFF7ED),
                    const Color(0xFFF59E0B),
                    kDarkTextColor,
                    kMidTextColor,
                    kLightBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildOrderCard(
                    context,
                    'ORD-155',
                    'Sarah Johnson',
                    '5x Interior Paint White 5gal',
                    'Feb 7, 2026 • 9:15 AM',
                    '₦449.95',
                    'Processing',
                    const Color(0xFFF0FDF4),
                    const Color(0xFF22C55E),
                    kDarkTextColor,
                    kMidTextColor,
                    kLightBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildOrderCard(
                    context,
                    'ORD-154',
                    'Mike Wilson',
                    '10x Plywood 3/4" 4x8\n30x Portland Cement 50kg',
                    'Feb 6, 2026 • 3:45 PM',
                    '₦825.00',
                    'Shipped',
                    const Color(0xFFFFF7ED),
                    const Color(0xFFEA580C),
                    kDarkTextColor,
                    kMidTextColor,
                    kLightBorderColor,
                  ),
                  const SizedBox(height: 20),
                  _buildOrderCard(
                    context,
                    'ORD-153',
                    'Emily Davis',
                    '100x Rebar Steel 12mm',
                    'Feb 5, 2026 • 11:20 AM',
                    '₦875.00',
                    'Delivered',
                    const Color(0xFFF0FDF4),
                    const Color(0xFF15803D),
                    kDarkTextColor,
                    kMidTextColor,
                    kLightBorderColor,
                    isDelivered: true,
                  ),
                  const SizedBox(height: 100), // Space for navbar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String id,
    String customer,
    String items,
    String date,
    String price,
    String status,
    Color tagBg,
    Color tagColor,
    Color kDarkTextColor,
    Color kMidTextColor,
    Color kLightBorderColor, {
    bool isDelivered = false,
  }) {
    return GestureDetector(
      onTap: () => context.push('/vendor/orders/$id'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: kLightBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kDarkTextColor.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kDarkTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDelivered
                            ? Icons.check_circle_outline_rounded
                            : (status == 'Pending' ? Icons.access_time_rounded : Icons.inventory_2_outlined),
                        size: 14,
                        color: tagColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: tagColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              customer,
              style: TextStyle(
                color: kMidTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              items,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: kLightBorderColor, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kDarkTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

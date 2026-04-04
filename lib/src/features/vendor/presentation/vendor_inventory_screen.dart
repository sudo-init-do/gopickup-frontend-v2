import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/vendor_repository.dart';
import '../../../common/config/app_config.dart';

class VendorInventoryScreen extends ConsumerWidget {
  const VendorInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const kPurple = Color(0xFFA855F7);
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kLightBorderColor = Color(0xFFF1F5F9);
    const kBrandGreen = Color(0xFF45A225);

    final inventoryAsync = ref.watch(vendorInventoryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kDarkTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/vendor/inventory/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search and Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: kLightBorderColor,
                          width: 1.5,
                        ),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kLightBorderColor, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ),
                ],
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
                  _buildFilterTab('Active', false, kPurple),
                  _buildFilterTab('Inactive', false, kPurple),
                  _buildFilterTab('Low Stock', false, kPurple),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: kLightBorderColor, height: 1),

            // Products List
            Expanded(
              child: inventoryAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No products in inventory'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(vendorInventoryProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildProductCard(
                            product.name,
                            product.category,
                            '₦${product.price.toStringAsFixed(2)}',
                            '${product.stock}',
                            '${product.moq}',
                            '0 sold', // Mock sold for now
                            product.imageUrl,
                            kDarkTextColor,
                            kMidTextColor,
                            kLightBorderColor,
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
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

  Widget _buildProductCard(
    String title,
    String category,
    String price,
    String stock,
    String moq,
    String sold,
    String imageUrl,
    Color kDarkTextColor,
    Color kMidTextColor,
    Color kLightBorderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: kLightBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kDarkTextColor.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF94A3B8),
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kDarkTextColor,
                          ),
                        ),
                        const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    Text(
                      category,
                      style: TextStyle(
                        color: kMidTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: kDarkTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock: $stock',
                          style: TextStyle(
                            color: kMidTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'MOQ: $moq',
                          style: TextStyle(
                            color: kMidTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: kLightBorderColor, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sold,
                style: TextStyle(
                  color: kMidTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  _buildCardAction(Icons.edit_outlined),
                  const SizedBox(width: 12),
                  _buildCardAction(Icons.visibility_outlined),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF45A225), size: 20),
    );
  }
}

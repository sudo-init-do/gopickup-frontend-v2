import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String _selectedCategory = 'Cement';
  final List<String> _categories = [
    'Cement',
    'Steel',
    'Wood',
    'Paint',
    'Electrical',
    'Quarry Materials',
    'Plumbing',
    'Hardware'
  ];

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF64748B);
    const kLightBorderColor = Color(0xFFF1F5F9);
    const kBrandGreen = Color(0xFFA5C498); // Muted green as seen in the mockup button

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: kDarkTextColor, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(
            color: kDarkTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: kLightBorderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Product Images', kDarkTextColor),
            const SizedBox(height: 12),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1.5,
                  style: BorderStyle.solid, // Note: Flutter doesn't natively do dashed easily without a package, using solid for now
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF94A3B8), size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: kMidTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Product Name', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField('Enter product name'),
            const SizedBox(height: 32),

            _buildSectionLabel('Description', kDarkTextColor),
            const SizedBox(height: 12),
            _buildTextField('Describe your product...', maxLines: 4),
            const SizedBox(height: 32),

            _buildSectionLabel('Category', kDarkTextColor),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFA855F7) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : kMidTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Price (₦)', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField('0.00'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Stock', kDarkTextColor),
                      const SizedBox(height: 12),
                      _buildTextField('0'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('Minimum Order Quantity (MOQ)', kDarkTextColor),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kDarkTextColor),
                  ),
                  const Icon(Icons.unfold_more_rounded, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customers must order at least this quantity',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLightBorderColor)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }
}

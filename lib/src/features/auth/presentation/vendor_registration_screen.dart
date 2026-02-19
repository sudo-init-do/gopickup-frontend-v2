import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Building Materials';

  final List<String> _categories = [
    'Building Materials',
    'Electrical Supplies',
    'Plumbing',
    'Hardware',
    'Paint & Finishes',
    'Lumber',
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kPurple = Color(0xFFA855F7);
    const kLightPurple = Color(0xFFFAF5FF);
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kInputBg = Color(0xFFFAFAFA);
    const kInputBorder = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vendor Registration',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kDarkTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your store and start selling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: kMidTextColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Horizontal Stepper/Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStepChip('Store Info', Icons.storefront_rounded, true, kPurple, kLightPurple),
                    const SizedBox(width: 12),
                    _buildStepChip('Location', Icons.location_on_outlined, false, kPurple, kLightPurple),
                    const SizedBox(width: 12),
                    _buildStepChip('Verification', Icons.assignment_outlined, false, kPurple, kLightPurple),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Store Logo Upload Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: kInputBg,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: kInputBorder, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.store_outlined, size: 48, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Form Fields
              _buildInputLabel('Store Name', kDarkTextColor),
              _buildTextField(_storeNameController, 'Enter store name', kInputBg, kInputBorder),
              const SizedBox(height: 24),

              _buildInputLabel('Owner Name', kDarkTextColor),
              _buildTextField(_ownerNameController, 'Enter your full name', kInputBg, kInputBorder),
              const SizedBox(height: 24),

              _buildInputLabel('Category', kDarkTextColor),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPurple : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kMidTextColor,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              _buildInputLabel('Store Description', kDarkTextColor),
              _buildTextField(_descriptionController, 'Describe your store...', kInputBg, kInputBorder, maxLines: 4),
              
              const SizedBox(height: 48),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next step or home
                    context.go('/vendor');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChip(String label, IconData icon, bool isActive, Color activeColor, Color activeBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color bg, Color border, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }
}

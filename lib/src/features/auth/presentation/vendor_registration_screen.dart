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
  bool _isFormValid = false;

  final List<String> _categories = [
    'Building Materials',
    'Electrical Supplies',
    'Plumbing',
    'Hardware',
    'Paint & Finishes',
    'Lumber',
  ];

  @override
  void initState() {
    super.initState();
    _storeNameController.addListener(_validateForm);
    _ownerNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _storeNameController.text.isNotEmpty &&
          _ownerNameController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty;
    });
  }

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
    const kLightPurpleBg = Color(0xFFF5F3FF);
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kGreenButton = Color(0xFFA5C498);
    const kActiveGreen = Color(0xFF45A225);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vendor Registration',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kDarkTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your store and start selling',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: kMidTextColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Progress Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStepChip('Store Info', Icons.store_mall_directory_rounded, true, kPurple),
                    const SizedBox(width: 12),
                    _buildStepChip('Location', Icons.location_on_outlined, false, kPurple),
                    const SizedBox(width: 12),
                    _buildStepChip('Verification', Icons.assignment_outlined, false, kPurple),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Icon(Icons.store_outlined, size: 40, color: Color(0xFF475569)),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildInputLabel('Store Name', kDarkTextColor),
              _buildTextField(_storeNameController, 'Enter store name'),
              const SizedBox(height: 24),

              _buildInputLabel('Owner Name', kDarkTextColor),
              _buildTextField(_ownerNameController, 'Enter your full name'),
              const SizedBox(height: 24),

              _buildInputLabel('Category', kDarkTextColor),
              const SizedBox(height: 12),
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
                        color: isSelected ? kLightPurpleBg : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected ? Border.all(color: kPurple.withOpacity(0.3)) : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? kPurple : kMidTextColor,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              _buildInputLabel('Store Description', kDarkTextColor),
              _buildTextField(_descriptionController, 'Describe your store...', maxLines: 4),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isFormValid ? () => context.go('/vendor') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? kActiveGreen : kGreenButton,
                    disabledBackgroundColor: kGreenButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
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

  Widget _buildStepChip(String label, IconData icon, bool isActive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF6B7280), size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
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

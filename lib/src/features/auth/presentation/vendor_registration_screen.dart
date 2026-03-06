import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/profile_provider.dart';
import '../../../models/user_models.dart';

class VendorRegistrationScreen extends ConsumerStatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  ConsumerState<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState
    extends ConsumerState<VendorRegistrationScreen> {
  int _currentStep = 0; // 0: Store Info, 1: Location, 2: Verification

  // Store Info Controllers
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Building Materials';

  // Location Controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  // Assume state is captured somehow or omitted

  // Custom mock since UI missing
  final String _mockPhone = '000-000-0000';

  // Verification Controllers
  final _registrationController = TextEditingController();

  final List<String> _categories = [
    'Building Materials',
    'Electrical Supplies',
    'Plumbing',
    'Hardware',
    'Paint & Finishes',
    'Lumber',
    'Quarry Materials',
  ];

  @override
  void initState() {
    super.initState();
    _storeNameController.addListener(_validateForm);
    _ownerNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _registrationController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _isStep1Valid =>
      _storeNameController.text.isNotEmpty &&
      _ownerNameController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty;

  bool get _isStep2Valid => _addressController.text.isNotEmpty;

  bool get _isStep3Valid => _registrationController.text.isNotEmpty;

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _registrationController.dispose();
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

    bool isCurrentStepValid = _currentStep == 0
        ? _isStep1Valid
        : (_currentStep == 1 ? _isStep2Valid : _isStep3Valid);

    final isLoading = ref.watch(profileProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendor Registration',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: kDarkTextColor,
                        letterSpacing: -0.8,
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
                          _buildStepChip(
                            'Store Info',
                            Icons.store_mall_directory_rounded,
                            _currentStep == 0,
                            kPurple,
                          ),
                          const SizedBox(width: 12),
                          _buildStepChip(
                            'Location',
                            Icons.location_on_outlined,
                            _currentStep == 1,
                            kPurple,
                          ),
                          const SizedBox(width: 12),
                          _buildStepChip(
                            'Verification',
                            Icons.assignment_outlined,
                            _currentStep == 2,
                            kPurple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (_currentStep == 0)
                      _buildStoreInfoStep(
                        kPurple,
                        kLightPurpleBg,
                        kDarkTextColor,
                        kMidTextColor,
                      ),
                    if (_currentStep == 1)
                      _buildLocationStep(kDarkTextColor, kMidTextColor),
                    if (_currentStep == 2)
                      _buildVerificationStep(
                        kDarkTextColor,
                        kMidTextColor,
                        kPurple,
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: (isCurrentStepValid && !isLoading)
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentStepValid
                        ? kActiveGreen
                        : kGreenButton,
                    disabledBackgroundColor: kGreenButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 2 ? 'Complete Setup' : 'Continue',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      final profile = VendorProfile(
        storeName: _storeNameController.text.trim(),
        businessType: _selectedCategory,
        address: _addressController.text.trim(),
        phoneNumber: _mockPhone,
        isApproved: false,
      );

      final success = await ref
          .read(profileProvider.notifier)
          .createVendorProfile(profile);

      if (mounted) {
        if (success) {
          context.go('/vendor');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(profileProvider).error ??
                    'Failed to complete setup. Please try again.',
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildStoreInfoStep(
    Color kPurple,
    Color kLightPurpleBg,
    Color kDarkTextColor,
    Color kMidTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: Color(0xFF475569),
                  ),
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
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? kLightPurpleBg : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? kPurple : Colors.transparent,
                    width: 1.5,
                  ),
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
        _buildTextField(
          _descriptionController,
          'Describe your store...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationStep(Color kDarkTextColor, Color kMidTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Store Address', kDarkTextColor),
        _buildTextField(_addressController, 'Enter full address'),
        const SizedBox(height: 24),

        // Pin on map action
        Row(
          children: const [
            Icon(Icons.location_on_rounded, color: Color(0xFFA855F7), size: 20),
            SizedBox(width: 8),
            Text(
              'Pin location on map',
              style: TextStyle(
                color: Color(0xFFA855F7),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Map Preview
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.location_on_outlined,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 8),
              Text(
                'Map preview',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep(
    Color kDarkTextColor,
    Color kMidTextColor,
    Color kPurple,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Verification Header Card
        Container(
          padding: const EdgeInsets.all(24),
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
                  color: kPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.business_rounded, color: kPurple, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verify your business to start selling',
                      style: TextStyle(
                        fontSize: 14,
                        color: kMidTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _buildInputLabel('Business Registration Number', kDarkTextColor),
        _buildTextField(_registrationController, 'Enter registration number'),
        const SizedBox(height: 32),

        // Note section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Text(
            'Note: Verification may take 1-2 business days. You can still set up your store while waiting.',
            style: TextStyle(
              color: Color(0xFF9A3412),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepChip(
    String label,
    IconData icon,
    bool isActive,
    Color activeColor,
  ) {
    bool isCompleted = false;
    // Determine if step is completed based on current step index
    if (label == 'Store Info' && _currentStep > 0) isCompleted = true;
    if (label == 'Location' && _currentStep > 1) isCompleted = true;

    Color bgColor = const Color(0xFFF3F4F6);
    Color contentColor = const Color(0xFF6B7280);
    Widget? prefix;

    if (isActive) {
      bgColor = activeColor;
      contentColor = Colors.white;
      prefix = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      );
    } else if (isCompleted) {
      bgColor = const Color(0xFFEAF5E9);
      contentColor = const Color(0xFF45A225);
      prefix = const Icon(Icons.check, color: Color(0xFF45A225), size: 16);
    } else {
      prefix = Icon(icon, color: contentColor, size: 16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          prefix,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: contentColor,
              fontWeight: FontWeight.w700,
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

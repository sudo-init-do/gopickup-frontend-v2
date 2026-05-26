import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/profile_provider.dart';
import '../../../state/auth_provider.dart';
import '../../../models/user_models.dart';

import '../../../common/utils/error_handler.dart';

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
  final _phoneController = TextEditingController();
  String _selectedCategory = 'Building Materials';

  // Location Controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  // Assume state is captured somehow or omitted

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
    _phoneController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _registrationController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _isStep1Valid =>
      _storeNameController.text.isNotEmpty &&
      _ownerNameController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty;

  bool get _isStep2Valid => _addressController.text.isNotEmpty;

  bool get _isStep3Valid => _registrationController.text.isNotEmpty;

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentStepValid = _currentStep == 0
        ? _isStep1Valid
        : (_currentStep == 1 ? _isStep2Valid : _isStep3Valid);

    final isLoading = ref.watch(profileProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Registration',
                      style: AppTextStyles.displayLg.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Set up your store and start selling',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Progress Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStepChip(
                            'Store Info',
                            Icons.store_mall_directory_rounded,
                            _currentStep == 0,
                            AppColors.vendorAccent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _buildStepChip(
                            'Location',
                            Icons.location_on_outlined,
                            _currentStep == 1,
                            AppColors.vendorAccent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _buildStepChip(
                            'Verification',
                            Icons.assignment_outlined,
                            _currentStep == 2,
                            AppColors.vendorAccent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    if (_currentStep == 0)
                      _buildStoreInfoStep(),
                    if (_currentStep == 1)
                      _buildLocationStep(),
                    if (_currentStep == 2)
                      _buildVerificationStep(),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: _currentStep == 2 ? 'Complete Setup' : 'Continue',
                onPressed: (isCurrentStepValid && !isLoading)
                    ? _handleContinue
                    : null,
                isLoading: isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() async {
    debugPrint('Current Step: $_currentStep. Validating...');

    if (_currentStep < 2) {
      debugPrint('Moving from $_currentStep to ${_currentStep + 1}');
      setState(() => _currentStep++);
    } else {
      debugPrint('Attempting profile creation...');
      final registrationNumber = _registrationController.text.trim();
      debugPrint('Registration Number: $registrationNumber');

      try {
        final profile = VendorProfile(
          storeName: _storeNameController.text.trim(),
          businessType: _selectedCategory,
          address: _addressController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          businessRegistrationNumber: registrationNumber,
          isApproved: false,
        );

        debugPrint('Vendor Profile Payload: ${profile.toCreateJson()}');

        final success = await ref
            .read(profileProvider.notifier)
            .createVendorProfile(profile);

        debugPrint('Profile creation success: $success');

        if (!mounted) return;

        if (success) {
          debugPrint('Marking profile as complete for local state...');
          ref.read(authProvider.notifier).markProfileComplete();
          debugPrint('Navigating to /vendor');
          context.go('/vendor');
        } else {
          final error = ref.read(profileProvider).error;
          debugPrint('Profile creation failed: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getMessage(error)),
              backgroundColor: AppColors.destructive,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e, stack) {
        debugPrint('CRITICAL ERROR during registration: $e');
        debugPrint('Stack: $stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Widget _buildStoreInfoStep() {
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
                  color: AppColors.backgroundSubtle.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.vendorAccent,
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
        const SizedBox(height: AppSpacing.xxl),
        _buildInputLabel('Store Name'),
        _buildTextField(_storeNameController, 'Enter store name'),
        const SizedBox(height: AppSpacing.xl),
        _buildInputLabel('Owner Name'),
        _buildTextField(_ownerNameController, 'Enter your full name'),
        const SizedBox(height: AppSpacing.xl),
        _buildInputLabel('Phone Number'),
        _buildTextField(_phoneController, 'Enter phone number'),
        const SizedBox(height: AppSpacing.xl),
        _buildInputLabel('Category'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.vendorAccent.withOpacity(0.08)
                      : AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isSelected ? AppColors.vendorAccent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isSelected ? AppColors.vendorAccent : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildInputLabel('Store Description'),
        _buildTextField(
          _descriptionController,
          'Describe your store...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel('Store Address'),
        _buildTextField(_addressController, 'Enter full address'),
        const SizedBox(height: AppSpacing.xl),

        // Pin on map action
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.vendorAccent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Pin location on map',
              style: AppTextStyles.body.copyWith(
                color: AppColors.vendorAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Map Preview
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.backgroundSubtle.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Map preview',
                style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Verification Header Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.vendorAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.business_rounded, color: AppColors.vendorAccent, size: 28),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Verification',
                      style: AppTextStyles.titleMd,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Verify your business to start selling',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        _buildInputLabel('Business Registration Number'),
        _buildTextField(_registrationController, 'Enter registration number'),
        const SizedBox(height: AppSpacing.xxl),

        // Note section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Text(
            'Note: Verification may take 1-2 business days. You can still set up your store while waiting.',
            style: AppTextStyles.body.copyWith(
              color: const Color(0xFF9A3412),
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

    Color bgColor = AppColors.backgroundSubtle;
    Color contentColor = AppColors.textSecondary;
    Widget? prefix;

    if (isActive) {
      bgColor = activeColor;
      contentColor = Colors.white;
      prefix = Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      );
    } else if (isCompleted) {
      bgColor = AppColors.primaryLight;
      contentColor = AppColors.primary;
      prefix = const Icon(Icons.check, color: AppColors.primary, size: 16);
    } else {
      prefix = Icon(icon, color: contentColor, size: 16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          prefix,
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg + AppSpacing.xs,
          ),
        ),
      ),
    );
  }
}

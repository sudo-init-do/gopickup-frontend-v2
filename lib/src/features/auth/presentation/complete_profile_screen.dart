import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/profile_provider.dart';
import '../../../models/user_models.dart';
import '../../../state/auth_provider.dart';
import '../../../common/utils/error_handler.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Profile Step Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController(); // For Vendors
  final TextEditingController _licenseController = TextEditingController(); // For Drivers

  // Address Step Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _businessTypeController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  bool get _isProfileValid {
    final role = ref.read(authProvider).user?.role ?? 'client';
    final nameValid = _nameController.text.trim().length >= 3;
    final phoneValid = _phoneController.text.trim().length >= 10;

    if (role == 'vendor') {
      return nameValid && phoneValid && _businessTypeController.text.trim().isNotEmpty;
    } else if (role == 'driver') {
      return nameValid && phoneValid && _licenseController.text.trim().isNotEmpty;
    }
    return nameValid && phoneValid;
  }

  bool get _isAddressValid =>
      _addressController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty;

  Future<void> _nextStep() async {
    if (_currentStep == 0 && _isProfileValid) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _isAddressValid) {
      setState(() => _isLoading = true);

      final role = ref.read(authProvider).user?.role ?? 'client';
      final address = '${_addressController.text.trim()}, ${_cityController.text.trim()}';
      final notifier = ref.read(profileProvider.notifier);
      bool success = false;

      if (role == 'vendor') {
        final profile = VendorProfile(
          storeName: _nameController.text.trim(),
          businessType: _businessTypeController.text.trim(),
          address: address,
          phoneNumber: _phoneController.text.trim(),
          isApproved: false,
        );
        success = await notifier.createVendorProfile(profile);
      } else if (role == 'driver') {
        final profile = DriverProfile(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
          vehicleType: 'Truck', // Default
          plateNumber: 'PENDING',
          vehicleCapacity: 0.0,
          isApproved: false,
        );
        success = await notifier.createDriverProfile(profile);
      } else {
        // Client
        final profile = ClientProfile(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: address,
        );
        success = await notifier.createClientProfile(profile);
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ref.read(authProvider.notifier).markProfileComplete();
        if (role == 'vendor') {
          context.go('/vendor');
        } else if (role == 'driver') {
          context.go('/driver/home');
        } else {
          context.go('/client');
        }
      } else {
        final error = ref.read(profileProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getMessage(error)),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildProfileStep(), _buildAddressStep()],
              ),
            ),
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: _currentStep == 0 ? 'Continue' : 'Complete Setup',
                onPressed: (_currentStep == 0
                        ? _isProfileValid
                        : _isAddressValid && !_isLoading)
                    ? _nextStep
                    : null,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep() {
    final role = ref.read(authProvider).user?.role ?? 'client';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          _buildHeader(),
          const SizedBox(height: AppSpacing.xxxl),
          _buildStepper(),
          const SizedBox(height: 56),
          _buildProfilePhotoPicker(),
          const SizedBox(height: 56),
          // Name Field
          Text(
            role == 'vendor' ? 'Store Name' : 'Full Name',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomTextField(
            controller: _nameController,
            hintText: role == 'vendor' ? 'Enter your store name' : 'Enter your full name',
            isValid: _nameController.text.trim().length >= 3,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Phone Number Field
          Text(
            'Phone Number',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomTextField(
            controller: _phoneController,
            hintText: 'e.g. 08087042206',
            isValid: _phoneController.text.trim().length >= 10,
          ),
          if (role == 'vendor') ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Business Type',
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildCustomTextField(
              controller: _businessTypeController,
              hintText: 'e.g. Construction Materials',
              isValid: _businessTypeController.text.trim().isNotEmpty,
            ),
          ],
          if (role == 'driver') ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Driver License Number',
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildCustomTextField(
              controller: _licenseController,
              hintText: 'e.g. ABC-123456',
              isValid: _licenseController.text.trim().isNotEmpty,
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          _buildHeader(),
          const SizedBox(height: AppSpacing.xxxl),
          _buildStepper(),
          const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
          // Street Address Input
          Text(
            'Street Address',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomTextField(
            controller: _addressController,
            hintText: 'Enter your address',
            isValid: _addressController.text.isNotEmpty,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // City Input
          Text(
            'City',
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomTextField(
            controller: _cityController,
            hintText: 'Enter your city',
            isValid: _cityController.text.isNotEmpty,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Use Current Location
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Use current location',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete your profile',
          style: AppTextStyles.displayLg.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Just a few more details to get started',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _StepBubble(
          icon: _currentStep > 0 ? Icons.check_rounded : Icons.person_rounded,
          label: 'Profile',
          isActive: _currentStep == 0,
          isCompleted: _currentStep > 0,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: _currentStep > 0 ? AppColors.primary : AppColors.backgroundSubtle,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _StepBubble(
          icon: Icons.location_on_rounded,
          label: 'Address',
          isActive: _currentStep == 1,
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildProfilePhotoPicker() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.backgroundSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 56,
              color: AppColors.textDisabled,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isValid,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isValid ? AppColors.primary : AppColors.backgroundSubtle,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
        ),
      ),
    );
  }
}

class _StepBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepBubble({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color contentColor;

    if (isCompleted) {
      bgColor = AppColors.primaryLight.withOpacity(0.5);
      contentColor = AppColors.primary;
    } else if (isActive) {
      bgColor = AppColors.primary;
      contentColor = Colors.white;
    } else {
      bgColor = AppColors.background;
      contentColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: isCompleted
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../state/profile_provider.dart';
import '../../../models/user_models.dart';
import '../../../state/auth_provider.dart';

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

      setState(() => _isLoading = false);

      if (success && mounted) {
        if (role == 'vendor') context.go('/vendor');
        else if (role == 'driver') context.go('/driver/home');
        else context.go('/client');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(profileProvider).error ?? 'Failed to create profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_currentStep == 0
                          ? _isProfileValid
                          : _isAddressValid && !_isLoading)
                      ? _nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primarySage.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
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
                              _currentStep == 0 ? 'Continue' : 'Complete Setup',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
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

  Widget _buildProfileStep() {
    final role = ref.read(authProvider).user?.role ?? 'client';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          _buildHeader(),
          const SizedBox(height: 40),
          _buildStepper(),
          const SizedBox(height: 56),
          _buildProfilePhotoPicker(),
          const SizedBox(height: 56),
          // Name Field
          Text(
            role == 'vendor' ? 'Store Name' : 'Full Name',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _nameController,
            hintText: role == 'vendor' ? 'Enter your store name' : 'Enter your full name',
            isValid: _nameController.text.trim().length >= 3,
          ),
          const SizedBox(height: 32),
          // Phone Number Field
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _phoneController,
            hintText: 'e.g. 08087042206',
            isValid: _phoneController.text.trim().length >= 10,
          ),
          if (role == 'vendor') ...[
            const SizedBox(height: 32),
            const Text(
              'Business Type',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _businessTypeController,
              hintText: 'e.g. Construction Materials',
              isValid: _businessTypeController.text.trim().isNotEmpty,
            ),
          ],
          if (role == 'driver') ...[
             const SizedBox(height: 32),
            const Text(
              'Driver License Number',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _licenseController,
              hintText: 'e.g. ABC-123456',
              isValid: _licenseController.text.trim().isNotEmpty,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 56),
          _buildHeader(),
          const SizedBox(height: 40),
          _buildStepper(),
          const SizedBox(height: 48),
          // Street Address Input
          const Text(
            'Street Address',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _addressController,
            hintText: 'Enter your address',
            isValid: _addressController.text.isNotEmpty,
          ),
          const SizedBox(height: 32),
          // City Input
          const Text(
            'City',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _cityController,
            hintText: 'Enter your city',
            isValid: _cityController.text.isNotEmpty,
          ),
          const SizedBox(height: 24),
          // Use Current Location
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
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
      children: const [
        Text(
          'Complete your profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Just a few more details to get started',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            letterSpacing: 0.1,
          ),
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
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _currentStep > 0
                  ? AppColors.primary
                  : const Color(0xFFF3F4F6),
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
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 56,
              color: Color(0xFF9CA3AF),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isValid ? AppColors.primary : const Color(0xFFF3F4F6),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
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
      bgColor = AppColors.primaryLight.withValues(alpha: 0.5);
      contentColor = AppColors.primary;
    } else if (isActive) {
      bgColor = AppColors.primary;
      contentColor = Colors.white;
    } else {
      bgColor = const Color(0xFFF9FAFB);
      contentColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: contentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}

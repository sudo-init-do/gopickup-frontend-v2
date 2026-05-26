import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../state/profile_provider.dart';
import '../../../state/auth_provider.dart';
import '../../../models/user_models.dart';

import '../../../common/utils/error_handler.dart';

class DriverRegistrationScreen extends ConsumerStatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  ConsumerState<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState
    extends ConsumerState<DriverRegistrationScreen> {
  late final PageController _pageController;
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _licenseController;
  late final TextEditingController _plateController;
  String? _selectedVehicleType;

  // Missing from UI mockup, needed by backend
  final String _mockPhone = "000-000-0000";
  final double _mockCapacity =
      1000.0; // Assume 1k capacity for everything by default

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _licenseController = TextEditingController();
    _plateController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _licenseController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_currentStep == 0) {
      final name = _nameController.text.trim();
      final address = _addressController.text.trim();
      return name.isNotEmpty && address.isNotEmpty;
    } else if (_currentStep == 1) {
      return _licenseController.text.trim().isNotEmpty;
    } else if (_currentStep == 2) {
      return _selectedVehicleType != null &&
          _plateController.text.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> _nextStep() async {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      setState(() => _isLoading = true);

      final profile = DriverProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _mockPhone,
        licenseNumber: _licenseController.text.trim(),
        vehicleType: _selectedVehicleType ?? "Truck",
        plateNumber: _plateController.text.trim(),
        vehicleCapacity: _mockCapacity,
        isApproved: false, // Set to false initially, admin approves
      );

      final success = await ref
          .read(profileProvider.notifier)
          .createDriverProfile(profile);

      if (!mounted) return;
      
      setState(() => _isLoading = false);

      if (success) {
        ref.read(authProvider.notifier).markProfileComplete();
        context.go('/driver');
      } else {
        final error = ref.read(profileProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getMessage(error)),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kOrangeColor = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Driver Registration',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: kDarkTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Complete your driver profile to start earning',
                      style: TextStyle(
                        fontSize: 16,
                        color: kMidTextColor.withOpacity( 0.8),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _buildTab(
                          icon: Icons.person_rounded,
                          label: 'Profile',
                          isActive: _currentStep == 0,
                          isCompleted: _currentStep > 0,
                          activeColor: kOrangeColor,
                        ),
                        _buildDivider(),
                        _buildTab(
                          icon: Icons.badge_outlined,
                          label: 'License',
                          isActive: _currentStep == 1,
                          isCompleted: _currentStep > 1,
                          activeColor: kOrangeColor,
                        ),
                        _buildDivider(),
                        _buildTab(
                          icon: Icons.local_shipping_outlined,
                          label: 'Vehicle',
                          isActive: _currentStep == 2,
                          isCompleted: false,
                          activeColor: kOrangeColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 700,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildProfileForm(
                            kDarkTextColor,
                            kMidTextColor,
                            kOrangeColor,
                          ),
                          _buildLicenseForm(kDarkTextColor, kMidTextColor),
                          _buildVehicleForm(
                            kDarkTextColor,
                            kMidTextColor,
                            kOrangeColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isLoading) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
                              _currentStep == 2
                                  ? 'Complete Registration'
                                  : 'Continue',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
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

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required Color activeColor,
  }) {
    final bgColor = isCompleted
        ? const Color(0xFFE8F3E5)
        : (isActive ? activeColor : const Color(0xFFF3F4F6));
    final contentColor = isCompleted
        ? const Color(0xFF3B7D23)
        : (isActive ? Colors.white : const Color(0xFF94A3B8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_rounded : icon,
            size: 18,
            color: contentColor,
          ),
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

  Widget _buildDivider() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildProfileForm(Color darkText, Color midText, Color orange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 50,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: 32),
        Text(
          'Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _addressController,
          hintText: 'Enter your address',
        ),
      ],
    );
  }

  Widget _buildLicenseForm(Color darkText, Color midText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Driver's License Number",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _licenseController,
          hintText: 'Enter license number',
        ),
        const SizedBox(height: 32),
        Text(
          'Upload License Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_upload_outlined,
                  color: Color(0xFF6B7280),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload license',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PNG, JPG up to 5MB',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
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

  Widget _buildVehicleForm(Color darkText, Color midText, Color orange) {
    final vehicleTypes = [
      {
        'title': 'Tricycle',
        'subtitle': 'Up to 1 ton',
        'icon': Icons.electric_rickshaw,
      },
      {
        'title': 'Van',
        'subtitle': 'Up to 2 tons',
        'icon': Icons.airport_shuttle,
      },
      {
        'title': 'Canter',
        'subtitle': 'Up to 4 tons',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'Truck',
        'subtitle': 'Up to 10 tons',
        'icon': Icons.local_shipping,
      },
      {
        'title': 'Flatbed',
        'subtitle': 'Up to 20 tons',
        'icon': Icons.rv_hookup,
      },
      {
        'title': 'Tipper',
        'subtitle': 'Up to 30 tons',
        'icon': Icons.local_shipping_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Vehicle Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: vehicleTypes.length,
          itemBuilder: (context, index) {
            final type = vehicleTypes[index];
            final isSelected = _selectedVehicleType == type['title'];
            return _buildVehicleCard(
              title: type['title'] as String,
              subtitle: type['subtitle'] as String,
              icon: type['icon'] as IconData,
              isSelected: isSelected,
              activeColor: orange,
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Plate Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _plateController,
          hintText: 'Enter plate number',
        ),
      ],
    );
  }

  Widget _buildVehicleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleType = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFF1F5F9),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity( 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : const Color(0xFF94A3B8),
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

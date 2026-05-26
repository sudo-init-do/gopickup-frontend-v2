import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
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
  final double _mockCapacity = 1000.0; // Assume 1k capacity for everything by default

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
                    Text(
                      'Driver Registration',
                      style: AppTextStyles.displayLg.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Complete your driver profile to start earning',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary.withOpacity(0.8),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        _buildTab(
                          icon: Icons.person_rounded,
                          label: 'Profile',
                          isActive: _currentStep == 0,
                          isCompleted: _currentStep > 0,
                          activeColor: AppColors.driverAccent,
                        ),
                        _buildDivider(),
                        _buildTab(
                          icon: Icons.badge_outlined,
                          label: 'License',
                          isActive: _currentStep == 1,
                          isCompleted: _currentStep > 1,
                          activeColor: AppColors.driverAccent,
                        ),
                        _buildDivider(),
                        _buildTab(
                          icon: Icons.local_shipping_outlined,
                          label: 'Vehicle',
                          isActive: _currentStep == 2,
                          isCompleted: false,
                          activeColor: AppColors.driverAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    SizedBox(
                      height: 700,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildProfileForm(),
                          _buildLicenseForm(),
                          _buildVehicleForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: _currentStep == 2 ? 'Complete Registration' : 'Continue',
                onPressed: (_isFormValid && !_isLoading) ? _nextStep : null,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
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
        ? AppColors.primaryLight
        : (isActive ? activeColor : AppColors.backgroundSubtle);
    final contentColor = isCompleted
        ? AppColors.primary
        : (isActive ? Colors.white : AppColors.textTertiary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_rounded : icon,
            size: 18,
            color: contentColor,
          ),
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

  Widget _buildDivider() {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        color: AppColors.border,
      ),
    );
  }

  Widget _buildProfileForm() {
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
                  color: AppColors.backgroundSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 50,
                  color: AppColors.border,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.driverAccent,
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
        const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
        Text(
          'Full Name',
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _nameController,
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Address',
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _addressController,
          hintText: 'Enter your address',
        ),
      ],
    );
  }

  Widget _buildLicenseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Driver's License Number",
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _licenseController,
          hintText: 'Enter license number',
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Upload License Photo',
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.borderStrong, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_upload_outlined,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Upload license',
                style: AppTextStyles.titleMd.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'PNG, JPG up to 5MB',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
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

  Widget _buildVehicleForm() {
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
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
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
              activeColor: AppColors.driverAccent,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Plate Number',
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.backgroundSubtle,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.1),
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
              color: isSelected ? activeColor : AppColors.textTertiary,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

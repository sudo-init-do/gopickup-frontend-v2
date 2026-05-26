import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/auth_provider.dart';
import '../../../state/signup_provider.dart';
import '../../../common/utils/error_handler.dart';

class RolePickerScreen extends ConsumerStatefulWidget {
  const RolePickerScreen({super.key});

  @override
  ConsumerState<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends ConsumerState<RolePickerScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _onContinue() async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
    });

    final roleValue = _selectedRole?.toLowerCase() ?? 'client';
    ref.read(signupProvider.notifier).updateRole(roleValue);

    final signupData = ref.read(signupProvider);
    final success = await ref
        .read(authProvider.notifier)
        .register(signupData.email, signupData.password, roleValue);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      context.push('/verify?email=${signupData.email}');
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getMessage(error)),
          backgroundColor: AppColors.destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),
                    // Logo and Name
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 50,
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
                    // Title
                    Text(
                      'Choose your role',
                      style: AppTextStyles.displayLg.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Subtitle
                    Text(
                      'Select how you want to use Go Pickup',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    // Role Cards
                    _RoleOptionCard(
                      title: 'Client',
                      subtitle: 'Buy materials & book deliveries',
                      icon: Icons.person_outline,
                      iconColor: AppColors.info,
                      iconBgColor: const Color(0xFFEFF6FF),
                      tags: const [
                        'Browse Go-Market',
                        'Post loads',
                        'Track deliveries',
                        'Manage payments',
                      ],
                      isSelected: _selectedRole == 'Client',
                      onTap: () => setState(() => _selectedRole = 'Client'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RoleOptionCard(
                      title: 'Driver',
                      subtitle: 'Deliver loads & earn money',
                      icon: Icons.local_shipping_outlined,
                      iconColor: AppColors.driverAccent,
                      iconBgColor: const Color(0xFFFFF7ED),
                      tags: const [
                        'Accept jobs',
                        'Bid on loads',
                        'Navigate routes',
                        'Track earnings',
                      ],
                      isSelected: _selectedRole == 'Driver',
                      onTap: () => setState(() => _selectedRole = 'Driver'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RoleOptionCard(
                      title: 'Vendor',
                      subtitle: 'Sell your products online',
                      icon: Icons.store_outlined,
                      iconColor: AppColors.vendorAccent,
                      iconBgColor: const Color(0xFFFAF5FF),
                      tags: const [
                        'List products',
                        'Manage inventory',
                        'Process orders',
                        'Receive payments',
                      ],
                      isSelected: _selectedRole == 'Vendor',
                      onTap: () => setState(() => _selectedRole = 'Vendor'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            // Continue Button at the bottom
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: 'Continue',
                onPressed: (_selectedRole != null && !_isLoading) ? _onContinue : null,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<String> tags;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.tags,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.5)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.backgroundSubtle,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMd,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.success : AppColors.borderStrong,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: tags.map((tag) => _FeatureTag(tag: tag)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String tag;
  const _FeatureTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        tag,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

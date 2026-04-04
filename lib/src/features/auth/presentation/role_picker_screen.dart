import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
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
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
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
                        const SizedBox(width: 12),
                        Text(
                          'Go Pickup',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Title
                    const Text(
                      'Choose your role',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const Text(
                      'Select how you want to use Go Pickup',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Role Cards
                    _RoleOptionCard(
                      title: 'Client',
                      subtitle: 'Buy materials & book deliveries',
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF3B82F6),
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
                    const SizedBox(height: 16),
                    _RoleOptionCard(
                      title: 'Driver',
                      subtitle: 'Deliver loads & earn money',
                      icon: Icons.local_shipping_outlined,
                      iconColor: const Color(0xFFF97316),
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
                    const SizedBox(height: 16),
                    _RoleOptionCard(
                      title: 'Vendor',
                      subtitle: 'Sell your products online',
                      icon: Icons.store_outlined,
                      iconColor: const Color(0xFFA855F7),
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Continue Button at the bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_selectedRole != null && !_isLoading)
                      ? _onContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B7D23),
                    disabledBackgroundColor: const Color(
                      0xFF3B7D23,
                    ).withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.7,
                    ),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFF3F4F6),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}

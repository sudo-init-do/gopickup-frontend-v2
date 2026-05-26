import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/auth_provider.dart';
import '../../../common/utils/error_handler.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // If already logged in as admin, go to dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null && user.role == 'admin') {
        context.go('/admin');
      }
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _adminLogin() async {
    final success = await ref
        .read(authProvider.notifier)
        .adminLogin(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    if (success) {
      context.go('/admin');
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
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SizedBox(
                  width: 240,
                  height: 100,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Subtitle
                Text(
                  'Central Command Center',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),

                // Email Field
                TextField(
                  controller: _emailController,
                  onChanged: (_) => _validateForm(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    labelStyle: AppTextStyles.label,
                    prefixIcon: const Icon(Icons.mail_outline, color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.adminAccent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password Field
                TextField(
                  controller: _passwordController,
                  onChanged: (_) => _validateForm(),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTextStyles.label,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.adminAccent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Login Button
                PrimaryButton(
                  label: 'Login to Dashboard',
                  onPressed: _isFormValid ? _adminLogin : null,
                  isLoading: isLoading,
                  color: AppColors.adminAccent,
                ),
                const SizedBox(height: AppSpacing.xl),

                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'Back to User Login',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.adminAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

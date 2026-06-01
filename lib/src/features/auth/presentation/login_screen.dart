import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../state/auth_provider.dart';
import '../../../common/utils/launch_url.dart';
import '../../../common/config/app_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isLoading = false;

  Future<void> _launchSupport() async {
    await openExternalUrl(AppConfig.supportWhatsappUrl());
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.textTertiary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.backgroundSubtle,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  String _cleanErrorMessage(String rawError) {
    String msg = rawError.replaceAll('Exception: ', '').trim();

    // Map common technical errors to user-friendly messages
    if (msg.toLowerCase().contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.toLowerCase().contains('connection refused') ||
        msg.toLowerCase().contains('xmlhttprequest') ||
        msg.toLowerCase().contains('socketexception')) {
      return 'Network issue, please check your connection.';
    }
    if (msg.toLowerCase().contains('not verified')) {
      return 'Account not verified. Please check your email for OTP.';
    }

    return msg.isEmpty ? 'Login failed' : msg;
  }

  Future<void> _signIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      final user = ref.read(authProvider).user;
      if (user?.role == 'vendor') {
        context.go('/vendor');
      } else if (user?.role == 'driver') {
        context.go('/driver');
      } else {
        context.go('/client');
      }
    } else {
      final error = ref.read(authProvider).error ?? '';
      final friendlyMsg = _cleanErrorMessage(error);

      // Trigger visual feedback
      _shake();

      // If unauthorized, clear password
      if (error.toLowerCase().contains('invalid email or password')) {
        _passwordController.clear();
        _validateForm();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMsg),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Padding(
                padding: EdgeInsets.only(
                  left: _shakeAnimation.value,
                  right: 10 - _shakeAnimation.value,
                ),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Logo
                SizedBox(
                  width: 200,
                  height: 84,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.fitHeight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Welcome heading
                Text(
                  'Welcome back',
                  style: AppTextStyles.displayLg.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sign in to continue',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Email Field
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  onChanged: (_) => _validateForm(),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(
                    hint: 'Email address',
                    icon: Icons.mail_outline,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password Field
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  onChanged: (_) => _validateForm(),
                  obscureText: _obscurePassword,
                  decoration: _fieldDecoration(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
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
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: AppTextStyles.label.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Sign In Button
                PrimaryButton(
                  label: 'Sign In',
                  onPressed: (_isFormValid && !_isLoading) ? _signIn : null,
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // OR Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.push('/signup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    child: Text(
                      'Create an account',
                      style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),

                // Footer
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.caption,
                    children: [
                      const TextSpan(text: 'By signing in, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/terms-of-service'),
                      ),
                      const TextSpan(text: ' and\n'),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/privacy-policy'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: _isLoading ? null : _launchSupport,
                  child: Text(
                    'Need help? Contact Support',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.borderStrong,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

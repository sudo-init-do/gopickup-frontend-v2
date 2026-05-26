import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/config/app_config.dart';
import '../../../state/signup_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;
  bool _obscurePassword = true;
  bool _agreeToPolicy = false;

  Future<void> _launchSupport() async {
    final Uri url = Uri.parse('whatsapp://send?phone=${AppConfig.supportPhone}');
    if (!await launchUrl(url)) {
      final Uri webUrl = Uri.parse('https://wa.me/${AppConfig.supportPhone}');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      _isFormValid = emailRegex.hasMatch(_emailController.text) &&
          _passwordController.text.length >= 6 &&
          _agreeToPolicy;
    });
  }

  void _onNext() {
    ref.read(signupProvider.notifier).updateEmail(_emailController.text);
    ref.read(signupProvider.notifier).updatePassword(_passwordController.text);
    context.push('/roles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
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
              // Welcome Text
              Text(
                'Welcome!',
                style: AppTextStyles.displayLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Subtext
              Text(
                'Enter your details to get started',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Email Input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: _emailController.text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.backgroundSubtle,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  onChanged: (_) => _validateForm(),
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Icon(
                        Icons.mail_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Password Input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: _passwordController.text.isNotEmpty
                        ? AppColors.primary
                        : AppColors.backgroundSubtle,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _passwordController,
                  onChanged: (_) => _validateForm(),
                  obscureText: _obscurePassword,
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
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
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Policy Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToPolicy,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm / 2),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _agreeToPolicy = value ?? false;
                        _validateForm();
                      });
                    },
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push('/privacy-policy'),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'terms of use',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push('/terms-of-service'),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Next Button
              PrimaryButton(
                label: 'Next',
                onPressed: _isFormValid ? _onNext : null,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: GestureDetector(
                  onTap: _launchSupport,
                  child: Text(
                    'Need help? Contact Support',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.border,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

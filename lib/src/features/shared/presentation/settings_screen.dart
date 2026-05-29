import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/auth_repository.dart';
import '../../../state/auth_provider.dart';
import '../../../common/config/app_config.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/utils/launch_url.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _locationServices = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushNotifications = prefs.getBool('pref_push_notifications') ?? true;
      _locationServices = prefs.getBool('pref_location_services') ?? true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _editProfile() {
    final role = ref.read(authProvider).user?.role;
    if (role == 'driver' || role == 'vendor' || role == 'client') {
      context.go('/$role/profile');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
                children: [
                  _buildSectionHeader('ACCOUNT'),
                  _buildSettingItem(
                    Icons.person_outline_rounded,
                    'Edit Profile',
                    'Change your name and contact info',
                    onTap: _editProfile,
                  ),
                  _buildSettingItem(
                    Icons.lock_outline_rounded,
                    'Change Password',
                    'Reset via a code sent to your email',
                    onTap: () => context.push('/forgot-password'),
                  ),
                  _buildSettingItem(
                    Icons.language_rounded,
                    'Language',
                    'English (United States)',
                    suffix: 'English',
                    onTap: () => _toast('More languages are coming soon.'),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('PREFERENCES'),
                  _buildToggleItem(
                    Icons.notifications_none_rounded,
                    'Push Notifications',
                    _pushNotifications,
                    (val) {
                      setState(() => _pushNotifications = val);
                      _setPref('pref_push_notifications', val);
                      _toast(val
                          ? 'Push notifications enabled'
                          : 'Push notifications disabled');
                    },
                  ),
                  _buildToggleItem(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    false,
                    (_) => _toast('Dark mode is coming soon.'),
                  ),
                  _buildToggleItem(
                    Icons.location_on_outlined,
                    'Location Services',
                    _locationServices,
                    (val) {
                      setState(() => _locationServices = val);
                      _setPref('pref_location_services', val);
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('SUPPORT'),
                  _buildSettingItem(
                    Icons.help_outline_rounded,
                    'Help Center',
                    'FAQs and customer support',
                    onTap: () => openExternalUrl(AppConfig.supportWhatsappUrl()),
                  ),
                  _buildSettingItem(
                    Icons.shield_outlined,
                    'Privacy Policy',
                    'How we handle your data',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  _buildSettingItem(
                    Icons.description_outlined,
                    'Terms of Service',
                    'Platform usage rules',
                    onTap: () => context.push('/terms-of-service'),
                  ),
                  _buildSettingItem(
                    Icons.info_outline_rounded,
                    'About App',
                    'Version 1.0.0',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'GoPickup',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 GoPickup',
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildDangerItem(
                    Icons.delete_outline_rounded,
                    'Delete Account',
                    onTap: () => _showDeleteAccountConfirmation(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Text(
            'Settings',
            style: AppTextStyles.headingMd.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    String? suffix,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
        title: Text(title, style: AppTextStyles.titleMd),
        subtitle: Text(subtitle, style: AppTextStyles.bodySm),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (suffix != null)
              Text(
                suffix,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right_rounded, color: AppColors.border),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
        title: Text(title, style: AppTextStyles.titleMd),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? All your data, products, and history will be permanently removed. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final success = await ref.read(authRepositoryProvider).deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading indicator
        if (success) {
          context.go('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account. Please try again later.')),
          );
        }
      }
    }
  }

  Widget _buildDangerItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.destructive.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.destructive, size: 22),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMd.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.destructive,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.destructive),
        onTap: onTap,
      ),
    );
  }
}

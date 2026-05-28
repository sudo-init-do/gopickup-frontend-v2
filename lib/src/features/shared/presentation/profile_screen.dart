import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/api_client.dart';
import '../../../state/auth_provider.dart';
import '../../../state/profile_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _setupControllers(Map<String, dynamic> data) {
    if (_nameController.text.isEmpty) {
      _nameController.text = data['full_name'] ?? data['store_name'] ?? '';
    }
    if (_phoneController.text.isEmpty) {
      _phoneController.text = data['phone_number'] ?? '';
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = data['address'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final profileAsync = ref.watch(fullProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) {
          _setupControllers(profile);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(
                  context,
                  _nameController.text.trim(),
                  user?.email ?? '',
                  profile['profile_picture_url'] ?? profile['store_banner_url'],
                  user?.role ?? 'client',
                ),

                const SizedBox(height: AppSpacing.xxl),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account Details'),
                      const SizedBox(height: AppSpacing.lg),

                      _buildModernField(
                        label: user?.role == 'vendor' ? 'Store Name' : 'Full Name',
                        controller: _nameController,
                        isEditing: _isEditing,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildModernField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        icon: Icons.phone_android_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildModernField(
                        label: 'Address',
                        controller: _addressController,
                        isEditing: _isEditing,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // Primary action: edit / save
                      PrimaryButton(
                        label: _isEditing ? 'Save Changes' : 'Edit Profile',
                        icon: _isEditing ? Icons.check_circle_outline : Icons.edit_note_rounded,
                        onPressed: () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                        isLoading: ref.watch(profileProvider).isLoading,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Secondary action: log out (neutral, not alarming)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text(
                            'Log Out',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Destructive action de-emphasized at the bottom
                      Center(
                        child: TextButton.icon(
                          onPressed: _showDeleteAccountConfirmation,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text('Delete Account'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.destructive,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const _ProfileLoadingState(),
        error: (e, s) => _ProfileErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(fullProfileProvider),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String name,
    String email,
    String? photoUrl,
    String role,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF4CA634)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.xxl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              // Title row with settings entry point
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: AppTextStyles.headingMd.copyWith(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Profile photo with camera button
              Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Container(
                              color: Colors.white.withOpacity(0.2),
                              child: const Icon(Icons.person, size: 56, color: Colors.white),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Name leads the hierarchy; email is secondary
              Text(
                name.isEmpty ? 'Set up your profile' : name,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                email,
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingLg.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isEditing ? AppColors.card : AppColors.backgroundSubtle,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isEditing ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            boxShadow: isEditing
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          // readOnly (not disabled) keeps saved values crisp & full-colour
          // in view mode instead of greyed out.
          child: TextField(
            controller: controller,
            readOnly: !isEditing,
            maxLines: maxLines,
            cursorColor: AppColors.primary,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isEditing ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              hintText: 'Enter ${label.toLowerCase()}',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (mounted) {
        _showToast('Uploading profile image...', Icons.cloud_upload_outlined);
      }

      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: image.name),
      });

      final response = await ApiClient.dio.post('upload', data: formData);
      final imageUrl = response.data['url'];

      if (imageUrl != null) {
        final success = await ref.read(profileProvider.notifier).updateProfile({
          'profile_picture_url': imageUrl,
        });
        if (success && mounted) {
          _showToast('Profile photo updated!', Icons.check_circle_outline, AppColors.success);
        }
      }
    } catch (e) {
      if (mounted) {
        _showToast('Upload failed: ${e.toString().split(':').last}', Icons.error_outline, AppColors.destructive);
      }
    }
  }

  Future<void> _saveProfile() async {
    final role = ref.read(authProvider).user?.role;
    final updates = {
      if (role == 'vendor') 'store_name': _nameController.text.trim()
      else 'full_name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    final success = await ref.read(profileProvider.notifier).updateProfile(updates);
    if (success && mounted) {
      setState(() => _isEditing = false);
      _showToast('Profile updated!', Icons.check_circle_outline, AppColors.success);
    } else if (mounted) {
      _showToast('Update failed!', Icons.error_outline, AppColors.destructive);
    }
  }

  void _showToast(String message, IconData icon, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: color ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/');
    }
  }

  Future<void> _showDeleteAccountConfirmation() async {
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

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.destructive)),
      );

      final success = await ref.read(authRepositoryProvider).deleteAccount();

      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading indicator
        if (success) {
          context.go('/');
        } else {
          _showToast('Failed to delete account. Please try again later.', Icons.error_outline, AppColors.destructive);
        }
      }
    }
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Syncing your profile...',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.destructive.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.destructive),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Connection Issue',
              style: AppTextStyles.headingLg.copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              error.contains('404')
                  ? 'We couldn\'t find your profile record. It might not be created yet.'
                  : 'Something went wrong while fetching your profile.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Try Again',
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

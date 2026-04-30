import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/api_client.dart';
import '../../../state/auth_provider.dart';
import '../../../state/profile_provider.dart';

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

    const kBrandGreen = Color(0xFF3B7D23);
    const kDeepGreen = Color(0xFF1B4332);
    const kSurfaceColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: profileAsync.when(
        data: (profile) {
          _setupControllers(profile);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Premium Header
                _buildPremiumHeader(
                  user?.email ?? '',
                  profile['profile_picture_url'] ?? profile['store_banner_url'],
                  user?.role ?? 'client',
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account Details'),
                      const SizedBox(height: 16),
                      
                      _buildModernField(
                        label: user?.role == 'vendor' ? 'Store Name' : 'Full Name',
                        controller: _nameController,
                        isEditing: _isEditing,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildModernField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        icon: Icons.phone_android_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildModernField(
                        label: 'Address',
                        controller: _addressController,
                        isEditing: _isEditing,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Action Buttons
                      _buildPrimaryAction(
                        label: _isEditing ? 'Save Changes' : 'Edit Profile',
                        icon: _isEditing ? Icons.check_circle_outline : Icons.edit_note_rounded,
                        onTap: () {
                          if (_isEditing) {
                            _saveProfile();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                        isLoading: ref.watch(profileProvider).isLoading,
                        color: kBrandGreen,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildPrimaryAction(
                        label: 'Log Out',
                        icon: Icons.logout_rounded,
                        onTap: _handleLogout,
                        color: Colors.redAccent,
                        isOutlined: true,
                      ),
                      const SizedBox(height: 60),
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

  Widget _buildPremiumHeader(String email, String? photoUrl, String role) {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF3B7D23),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative Abstract Shape
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity( 0.05),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Profile Photo
              Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity( 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Container(
                              color: Colors.white.withOpacity( 0.2),
                              child: const Icon(Icons.person, size: 80, color: Colors.white),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: Color(0xFF3B7D23),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity( 0.3)),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B),
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isEditing ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEditing ? const Color(0xFF3B7D23).withOpacity( 0.3) : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: isEditing
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B7D23).withOpacity( 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            enabled: isEditing,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isEditing ? const Color(0xFF3B7D23) : Colors.grey.shade400,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isLoading = false,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onTap,
              icon: Icon(icon, size: 22),
              label: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onTap,
              icon: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(icon, size: 22),
              label: isLoading
                  ? const SizedBox()
                  : Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
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
           _showToast('Profile photo updated!', Icons.check_circle_outline, Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        _showToast('Upload failed: ${e.toString().split(':').last}', Icons.error_outline, Colors.redAccent);
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
      _showToast('Profile updated!', Icons.check_circle_outline, Colors.green);
    } else if (mounted) {
      _showToast('Update failed!', Icons.error_outline, Colors.redAccent);
    }
  }

  void _showToast(String message, IconData icon, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: color ?? Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3B7D23)),
          SizedBox(height: 20),
          Text(
            'Syncing your profile...',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Issue',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            Text(
              error.contains('404') 
                  ? 'We couldn\'t find your profile record. It might not be created yet.' 
                  : 'Something went wrong while fetching your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    const kLightGrey = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: profileAsync.when(
        data: (profile) {
          _setupControllers(profile);
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(
                  user?.email ?? '', 
                  profile['profile_picture_url'] ?? profile['store_banner_url']
                ),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Account Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (_isEditing) {
                                _saveProfile();
                              } else {
                                setState(() => _isEditing = true);
                              }
                            },
                            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, size: 18),
                            label: Text(_isEditing ? 'Save' : 'Edit'),
                            style: TextButton.styleFrom(foregroundColor: kBrandGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: user?.role == 'vendor' ? 'Store Name' : 'Full Name',
                        controller: _nameController,
                        isEditing: _isEditing,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        isEditing: _isEditing,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoField(
                        label: 'Address',
                        controller: _addressController,
                        isEditing: _isEditing,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Logout Button
                      _buildActionTile(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        color: Colors.red,
                        onTap: () => _handleLogout(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader(String email, String? photoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B7D23), Color(0xFF4CA634)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF3B7D23)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            email,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ref.read(authProvider).user?.role.toUpperCase() ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  ListTile _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
      }

      // Convert image to multipart
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
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
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

    setState(() => _isEditing = false);
    
    final success = await ref.read(profileProvider.notifier).updateProfile(updates);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/');
  }
}

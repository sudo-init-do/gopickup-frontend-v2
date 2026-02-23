import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kBrandGreen = Color(0xFF3B7D23);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, kDarkTextColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  _buildSectionHeader('ACCOUNT'),
                  _buildSettingItem(Icons.person_outline_rounded, 'Edit Profile', 'Change your name and contact info'),
                  _buildSettingItem(Icons.lock_outline_rounded, 'Change Password', 'Update your login credentials'),
                  _buildSettingItem(Icons.language_rounded, 'Language', 'English (United States)', suffix: 'English'),
                  
                  const SizedBox(height: 24),
                  _buildSectionHeader('PREFERENCES'),
                  _buildToggleItem(Icons.notifications_none_rounded, 'Push Notifications', true, kBrandGreen),
                  _buildToggleItem(Icons.dark_mode_outlined, 'Dark Mode', false, kBrandGreen),
                  _buildToggleItem(Icons.location_on_outlined, 'Location Services', true, kBrandGreen),

                  const SizedBox(height: 24),
                  _buildSectionHeader('SUPPORT'),
                  _buildSettingItem(Icons.help_outline_rounded, 'Help Center', 'FAQs and customer support'),
                  _buildSettingItem(Icons.shield_outlined, 'Privacy Policy', 'How we handle your data'),
                  _buildSettingItem(Icons.info_outline_rounded, 'About App', 'Version 1.0.0'),

                  const SizedBox(height: 32),
                  _buildDangerItem(Icons.delete_outline_rounded, 'Delete Account'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color darkText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {String? suffix}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (suffix != null)
              Text(
                suffix,
                style: const TextStyle(
                  color: Color(0xFF3B7D23),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value, Color brandGreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: (val) {},
          activeColor: brandGreen,
          activeTrackColor: brandGreen.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildDangerItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.redAccent, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.redAccent,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
        onTap: () {},
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../state/auth_provider.dart';

class AdminScaffold extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    // Safety check - redirect to login if not admin (handled in router too)
    if (user != null && user.role != 'admin') {
       // redirect handled in router redirection logic usually
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _AdminSidebar(currentLocation: currentLocation),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _AdminHeader(userName: user?.email ?? 'Admin'),
                // Content Area
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends ConsumerWidget {
  final String currentLocation;

  const _AdminSidebar({required this.currentLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      color: Colors.black87,
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Go Pickup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // Navigation
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: '/admin',
            isSelected: currentLocation == '/admin',
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            label: 'User Management',
            route: '/admin/users',
            isSelected: currentLocation == '/admin/users',
          ),
          _SidebarItem(
            icon: Icons.local_shipping_outlined,
            label: 'Order Monitoring',
            route: '/admin/orders',
            isSelected: currentLocation == '/admin/orders',
          ),
          const Spacer(),
          const Divider(color: Colors.white24),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            route: '/',
            isSelected: false,
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap ?? () => context.go(route),
      ),
    );
  }
}

class _AdminHeader extends ConsumerWidget {
  final String userName;

  const _AdminHeader({required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.notifications_none, color: Colors.grey),
          const SizedBox(width: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person_outline, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

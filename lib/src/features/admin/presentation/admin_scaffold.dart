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

  int _getSelectedIndex(String location) {
    if (location.startsWith('/admin/orders')) return 2;
    if (location.startsWith('/admin/products')) return 3;
    if (location.startsWith('/admin/users')) return 1;
    return 0; // '/admin'
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/users');
        break;
      case 2:
        context.go('/admin/orders');
        break;
      case 3:
        context.go('/admin/products');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isLoading && (user == null || user.role != 'admin')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/admin/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.blueAccent),
              centerTitle: true,
              title: const Text(
                'Admin Console',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  child: const Text('Logout', style: TextStyle(color: Colors.blueAccent)),
                ),
                const SizedBox(width: 8),
              ],
            ),
            drawer: _AdminDrawer(currentLocation: currentLocation),
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _getSelectedIndex(currentLocation),
              onTap: (index) => _onItemTapped(index, context),
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white, type: BottomNavigationBarType.fixed,
              elevation: 8,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'DASHBOARD'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'USERS'),
                BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'ORDERS'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'MARKET'),
              ],
            ),
          );
        }

        // Desktop layout
        return Scaffold(
          body: Row(
            children: [
              _AdminSidebar(currentLocation: currentLocation),
              Expanded(
                child: Column(
                  children: [
                    _AdminHeader(userName: user?.email ?? 'Admin'),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Mobile drawer
class _AdminDrawer extends ConsumerWidget {
  final String currentLocation;

  const _AdminDrawer({required this.currentLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
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
            const SizedBox(height: 36),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              route: '/admin',
              isSelected: currentLocation == '/admin',
            ),
            _DrawerItem(
              icon: Icons.people_outline,
              label: 'User Management',
              route: '/admin/users',
              isSelected: currentLocation == '/admin/users',
            ),
            _DrawerItem(
              icon: Icons.local_shipping_outlined,
              label: 'Order Monitoring',
              route: '/admin/orders',
              isSelected: currentLocation == '/admin/orders',
            ),
            _DrawerItem(
              icon: Icons.storefront_outlined,
              label: 'Product Management',
              route: '/admin/products',
              isSelected: currentLocation == '/admin/products',
            ),
            const Spacer(),
            const Divider(color: Colors.white24),
            _DrawerItem(
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
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap ?? () {
          Navigator.pop(context); // Close drawer
          context.go(route);
        },
      ),
    );
  }
}

// Desktop sidebar
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
          _SidebarItem(
            icon: Icons.storefront_outlined,
            label: 'Product Management',
            route: '/admin/products',
            isSelected: currentLocation == '/admin/products',
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final List<NavigationItem> items;
  final String currentLocation;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.items,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate selected index based on current location
    int selectedIndex = 0;
    for (int i = 0; i < items.length; i++) {
      if (currentLocation.startsWith(items[i].route)) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            context.go(items[index].route);
          },
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 80,
          destinations: items.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

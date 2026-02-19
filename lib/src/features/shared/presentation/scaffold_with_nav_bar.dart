import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationItem {
  final IconData unselectedIcon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.unselectedIcon,
    required this.selectedIcon,
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
        if (currentLocation == items[i].route || 
            currentLocation.startsWith('${items[i].route}/')) {
          selectedIndex = i;
        }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = selectedIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(item.route),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.unselectedIcon,
                          color: isSelected ? const Color(0xFF45A225) : const Color(0xFF94A3B8),
                          size: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF45A225) : const Color(0xFF94A3B8),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 20 : 12, 
                            vertical: 8
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF3B7D23).withOpacity(0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            (isSelected ? item.selectedIcon : item.unselectedIcon) ?? Icons.error_outline,
                            color: isSelected ? const Color(0xFF3B7D23) : const Color(0xFF94A3B8),
                            size: isSelected ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF3B7D23) : const Color(0xFF94A3B8),
                            letterSpacing: isSelected ? 0 : -0.2,
                          ),
                          child: Text(item.label),
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

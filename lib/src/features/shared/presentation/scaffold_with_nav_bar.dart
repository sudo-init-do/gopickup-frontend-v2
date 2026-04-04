import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/auth_provider.dart';

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

class ScaffoldWithNavBar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isComplete = authState.user?.isProfileComplete ?? false;

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
      bottomNavigationBar: isComplete ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SafeArea(
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
                              isSelected
                                  ? item.selectedIcon
                                  : item.unselectedIcon,
                              color: isSelected
                                  ? const Color(0xFF45A225)
                                  : const Color(0xFF94A3B8),
                              size: 26,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF45A225)
                                    : const Color(0xFF94A3B8),
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF45A225),
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(height: 11),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Bottom Indicator pill
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 140,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ) : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/auth/presentation/role_picker_screen.dart';
import '../features/auth/presentation/complete_profile_screen.dart';
import '../features/client/presentation/client_home_screen.dart';
import '../features/client/presentation/client_products_screen.dart';
import '../features/client/presentation/client_orders_screen.dart';
import '../features/client/presentation/client_profile_screen.dart';
import '../features/client/presentation/client_cart_screen.dart';
import '../features/client/presentation/order_detail_screen.dart';
import '../features/driver/presentation/driver_home_screen.dart';
import '../features/driver/presentation/driver_earnings_screen.dart';
import '../features/driver/presentation/driver_profile_screen.dart';
import '../features/vendor/presentation/vendor_home_screen.dart';
import '../features/vendor/presentation/vendor_inventory_screen.dart';
import '../features/vendor/presentation/vendor_profile_screen.dart';
import '../features/shared/chat/chat_list_screen.dart';
import '../features/shared/chat/chat_screen.dart';
import '../features/shared/presentation/scaffold_with_nav_bar.dart';
import '../common/models/order.dart';
import '../common/models/chat.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RolePickerScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final chat = state.extra as Chat;
          return ChatScreen(chat: chat);
        },
      ),

      GoRoute(
        path: '/client/cart',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ClientCartScreen(),
      ),

      // Client Shell
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentLocation: state.uri.toString(),
            items: [
              NavigationItem(
                unselectedIcon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                route: '/client',
              ),
              NavigationItem(
                unselectedIcon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag,
                label: 'Shop',
                route: '/client/products',
              ),
              NavigationItem(
                unselectedIcon: Icons.receipt_outlined,
                selectedIcon: Icons.receipt,
                label: 'Orders',
                route: '/client/orders',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_outlined,
                selectedIcon: Icons.chat,
                label: 'Chat',
                route: '/client/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.person_outlined,
                selectedIcon: Icons.person,
                label: 'Profile',
                route: '/client/profile',
              ),
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/client',
            builder: (context, state) => const ClientHomeScreen(),
          ),
          GoRoute(
            path: '/client/products',
            builder: (context, state) => const ClientProductsScreen(),
          ),
          GoRoute(
            path: '/client/orders',
            builder: (context, state) => const ClientOrdersScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final order = state.extra as Order;
                  return OrderDetailScreen(order: order);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/client/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/client/profile',
            builder: (context, state) => const ClientProfileScreen(),
          ),
        ],
      ),

      // Driver Shell
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentLocation: state.uri.toString(),
            items: [
              NavigationItem(
                unselectedIcon: Icons.local_shipping_outlined,
                selectedIcon: Icons.local_shipping,
                label: 'Jobs',
                route: '/driver',
              ),
              NavigationItem(
                unselectedIcon: Icons.payments_outlined,
                selectedIcon: Icons.payments,
                label: 'Earnings',
                route: '/driver/earnings',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_outlined,
                selectedIcon: Icons.chat,
                label: 'Chat',
                route: '/driver/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.person_outlined,
                selectedIcon: Icons.person,
                label: 'Profile',
                route: '/driver/profile',
              ),
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/driver',
            builder: (context, state) => const DriverHomeScreen(),
          ),
          GoRoute(
            path: '/driver/earnings',
            builder: (context, state) => const DriverEarningsScreen(),
          ),
          GoRoute(
            path: '/driver/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/driver/profile',
            builder: (context, state) => const DriverProfileScreen(),
          ),
        ],
      ),

      // Vendor Shell
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentLocation: state.uri.toString(),
            items: [
              NavigationItem(
                unselectedIcon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: 'Sales',
                route: '/vendor',
              ),
              NavigationItem(
                unselectedIcon: Icons.inventory_outlined,
                selectedIcon: Icons.inventory,
                label: 'Inventory',
                route: '/vendor/inventory',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_outlined,
                selectedIcon: Icons.chat,
                label: 'Chat',
                route: '/vendor/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.store_outlined,
                selectedIcon: Icons.store,
                label: 'Profile',
                route: '/vendor/profile',
              ),
            ],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/vendor',
            builder: (context, state) => const VendorHomeScreen(),
          ),
          GoRoute(
            path: '/vendor/inventory',
            builder: (context, state) => const VendorInventoryScreen(),
          ),
          GoRoute(
            path: '/vendor/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/vendor/profile',
            builder: (context, state) => const VendorProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

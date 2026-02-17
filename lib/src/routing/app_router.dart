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
                icon: Icons.home_rounded,
                label: 'Home',
                route: '/client',
              ),
              NavigationItem(
                icon: Icons.shopping_bag_rounded,
                label: 'Shop',
                route: '/client/products',
              ),
              NavigationItem(
                icon: Icons.receipt_long_rounded,
                label: 'Orders',
                route: '/client/orders',
              ),
              NavigationItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                route: '/client/chat',
              ),
              NavigationItem(
                icon: Icons.person_outline_rounded,
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
                icon: Icons.work_outline,
                label: 'Jobs',
                route: '/driver',
              ),
              NavigationItem(
                icon: Icons.attach_money,
                label: 'Earnings',
                route: '/driver/earnings',
              ),
              NavigationItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                route: '/driver/chat',
              ),
              NavigationItem(
                icon: Icons.person_outline,
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
                icon: Icons.dashboard_outlined,
                label: 'Sales',
                route: '/vendor',
              ),
              NavigationItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                route: '/vendor/inventory',
              ),
              NavigationItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                route: '/vendor/chat',
              ),
              NavigationItem(
                icon: Icons.store_outlined,
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

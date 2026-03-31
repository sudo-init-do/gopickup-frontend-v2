import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/privacy_policy_screen.dart';
import '../features/auth/presentation/terms_of_service_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/auth/presentation/role_picker_screen.dart';
import '../features/auth/presentation/complete_profile_screen.dart';
import '../features/auth/presentation/driver_registration_screen.dart';
import '../features/auth/presentation/vendor_registration_screen.dart';
import '../features/client/presentation/client_home_screen.dart';
import '../features/client/presentation/client_products_screen.dart';
import '../features/client/presentation/client_orders_screen.dart';
import '../features/client/presentation/client_profile_screen.dart';
import '../features/client/presentation/client_cart_screen.dart';
import '../features/client/presentation/client_wallet_screen.dart';
import '../features/client/presentation/client_addresses_screen.dart';
import '../features/client/presentation/order_detail_screen.dart';
import '../features/client/presentation/create_job_screen.dart';
import '../features/client/presentation/book_truck_screen.dart';
import '../features/driver/presentation/driver_home_screen.dart';
import '../features/driver/presentation/driver_bids_screen.dart';
import '../features/driver/presentation/driver_earnings_screen.dart';
import '../features/driver/presentation/driver_profile_screen.dart';
import '../features/driver/presentation/submit_bid_screen.dart';
import '../features/vendor/presentation/vendor_home_screen.dart';
import '../features/vendor/presentation/vendor_inventory_screen.dart';
import '../features/vendor/presentation/vendor_orders_screen.dart';
import '../features/vendor/presentation/vendor_wallet_screen.dart';
import '../features/vendor/presentation/vendor_profile_screen.dart';
import '../features/vendor/presentation/vendor_order_detail_screen.dart';
import '../features/vendor/presentation/add_product_screen.dart';
import '../features/shared/chat/chat_list_screen.dart';
import '../features/shared/chat/chat_screen.dart';
import '../features/shared/presentation/scaffold_with_nav_bar.dart';
import '../features/shared/presentation/notifications_screen.dart';
import '../features/shared/presentation/settings_screen.dart';
import '../models/order_models.dart';
import '../models/chat_models.dart';

import '../features/auth/presentation/admin_login_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_users_screen.dart';
import '../features/admin/presentation/admin_orders_screen.dart';
import '../features/admin/presentation/admin_scaffold.dart';
import '../state/auth_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final subpath = state.uri.path;
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.user != null;

      // Avoid redirecting while checking session
      if (isLoading) {
        return null;
      }

      // Public routes that don't require authentication
      final publicRoutes = [
        '/',
        '/admin/login',
        '/signup',
        '/forgot-password',
        '/reset-password',
        '/privacy-policy',
        '/terms-of-service',
        '/verify',
      ];

      final isPublicRoute = publicRoutes.contains(subpath);

      if (!isLoggedIn && !isPublicRoute) {
        // Not logged in and trying to access a restricted route
        return '/';
      }

      if (isLoggedIn && subpath == '/') {
        // Logged in and trying to access login page, redirect to their dashboard
        final role = authState.user?.role;
        if (role == 'vendor') return '/vendor';
        if (role == 'driver') return '/driver';
        return '/client';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
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
        path: '/vendor/registration',
        builder: (context, state) => const VendorRegistrationScreen(),
      ),
      GoRoute(
        path: '/driver/registration',
        builder: (context, state) => const DriverRegistrationScreen(),
      ),
      GoRoute(
        path: '/driver/submit-bid',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final job = state.extra as Order;
          return SubmitBidScreen(job: job);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final chat = state.extra as Conversation;
          return ChatScreen(chat: chat);
        },
      ),

      GoRoute(
        path: '/client/cart',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ClientCartScreen(),
      ),
      GoRoute(
        path: '/client/create-job',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/client/book-truck',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BookTruckScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Client Shell
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(
            currentLocation: state.uri.toString(),
            items: [
              NavigationItem(
                unselectedIcon: Icons.home_outlined,
                selectedIcon: Icons.home_outlined,
                label: 'Home',
                route: '/client',
              ),
              NavigationItem(
                unselectedIcon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag_outlined,
                label: 'Go-Market',
                route: '/client/products',
              ),
              NavigationItem(
                unselectedIcon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_outlined,
                label: 'Orders',
                route: '/client/orders',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                route: '/client/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                route: '/client/wallet',
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
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return ClientProductsScreen(initialSearchQuery: query);
            },
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
            path: '/client/wallet',
            builder: (context, state) => const ClientWalletScreen(),
          ),
          GoRoute(
            path: '/client/profile',
            builder: (context, state) => const ClientProfileScreen(),
          ),
          GoRoute(
            path: '/client/addresses',
            builder: (context, state) => const ClientAddressesScreen(),
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
                unselectedIcon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment_rounded,
                label: 'Jobs',
                route: '/driver',
              ),
              NavigationItem(
                unselectedIcon: Icons.trending_up_rounded,
                selectedIcon: Icons.trending_up_rounded,
                label: 'Bids',
                route: '/driver/bids',
              ),
              NavigationItem(
                unselectedIcon: Icons.attach_money_rounded,
                selectedIcon: Icons.attach_money_rounded,
                label: 'Earnings',
                route: '/driver/earnings',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                route: '/driver/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
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
            path: '/driver/bids',
            builder: (context, state) => const DriverBidsScreen(),
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
                unselectedIcon: Icons.storefront_outlined,
                selectedIcon: Icons.storefront_rounded,
                label: 'Store',
                route: '/vendor',
              ),
              NavigationItem(
                unselectedIcon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2_rounded,
                label: 'Products',
                route: '/vendor/inventory',
              ),
              NavigationItem(
                unselectedIcon: Icons.assignment_outlined,
                selectedIcon: Icons.assignment_rounded,
                label: 'Orders',
                route: '/vendor/orders',
              ),
              NavigationItem(
                unselectedIcon: Icons.chat_bubble_outline_rounded,
                selectedIcon: Icons.chat_bubble_rounded,
                label: 'Chat',
                route: '/vendor/chat',
              ),
              NavigationItem(
                unselectedIcon: Icons.account_balance_wallet_outlined,
                selectedIcon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                route: '/vendor/wallet',
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
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AddProductScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/vendor/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/vendor/orders',
            builder: (context, state) => const VendorOrdersScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final order = state.extra as Order;
                  return VendorOrderDetailScreen(order: order);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/vendor/wallet',
            builder: (context, state) => const VendorWalletScreen(),
          ),
          GoRoute(
            path: '/vendor/profile',
            builder: (context, state) => const VendorProfileScreen(),
          ),
        ],
      ),

      // Admin Shell
      ShellRoute(
        builder: (context, state, child) {
          return AdminScaffold(
            currentLocation: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
        ],
      ),
    ],
  );
});

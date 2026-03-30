import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/styles/app_theme.dart';
import 'routing/app_router.dart';
import 'api/api_client.dart';
import 'state/auth_provider.dart';

class GoPickupApp extends ConsumerWidget {
  const GoPickupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Attach global 401 listener to force logout on session expiration
    ApiClient.onUnauthorized = () {
      ref.read(authProvider.notifier).logout();
    };

    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'GoPickup Unity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}

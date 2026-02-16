import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/styles/app_theme.dart';
import 'routing/app_router.dart';

class GoPickupApp extends ConsumerWidget {
  const GoPickupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'GoPickup Unity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}

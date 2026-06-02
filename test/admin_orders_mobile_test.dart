import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopickup_unity/src/features/admin/presentation/admin_orders_screen.dart';
import 'package:gopickup_unity/src/features/admin/presentation/admin_scaffold.dart';
import 'package:gopickup_unity/src/features/admin/presentation/admin_providers.dart';
import 'package:gopickup_unity/src/models/order_models.dart';
import 'package:gopickup_unity/src/models/user_models.dart';
import 'package:gopickup_unity/src/state/auth_provider.dart';

class _AdminAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(
        isLoading: false,
        user: User.fromJson(const {
          'id': 'admin-1',
          'email': 'admin2@gopickup.com.ng',
          'role': 'admin',
          'is_profile_complete': true,
        }),
      );
}

void main() {
  testWidgets('AdminScaffold + AdminOrdersScreen render at phone width',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final raw = File('test/fixtures/admin_orders.json').readAsStringSync();
    final orders = (jsonDecode(raw) as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_AdminAuthNotifier.new),
          adminOrdersProvider.overrideWith((ref) async => orders),
        ],
        child: const MaterialApp(
          home: AdminScaffold(
            currentLocation: '/admin/orders',
            child: AdminOrdersScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The screen must actually render its content at phone width (regression
    // guard: a build-time throw here would replace the body with a blank
    // ErrorWidget in release). Non-fatal RenderFlex overflow is tolerated.
    expect(find.text('LIVE FEED'), findsOneWidget);
    expect(find.byType(AdminOrdersScreen), findsOneWidget);
  });
}

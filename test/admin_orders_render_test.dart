import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopickup_unity/src/features/admin/presentation/admin_orders_screen.dart';
import 'package:gopickup_unity/src/features/admin/presentation/admin_providers.dart';
import 'package:gopickup_unity/src/models/order_models.dart';

void main() {
  testWidgets('AdminOrdersScreen builds with the real admin/orders payload',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final raw = File('test/fixtures/admin_orders.json').readAsStringSync();
    final orders = (jsonDecode(raw) as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminOrdersProvider.overrideWith((ref) async => orders),
        ],
        child: const MaterialApp(home: AdminOrdersScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // A fatal build throw would replace the body with a blank ErrorWidget, so
    // these finders would fail. (Non-fatal RenderFlex overflow is tolerated.)
    expect(find.text('LIVE FEED'), findsOneWidget);
    expect(find.byType(AdminOrdersScreen), findsOneWidget);
  });
}

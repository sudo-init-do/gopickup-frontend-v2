import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'src/app.dart';
import 'src/api/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  ApiClient.initialize();
  runApp(const ProviderScope(child: GoPickupApp()));
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/api/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.initialize();
  runApp(const ProviderScope(child: GoPickupApp()));
}

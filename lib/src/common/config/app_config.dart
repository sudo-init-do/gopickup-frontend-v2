import 'package:flutter/foundation.dart';

class AppConfig {
  // Production backend — CORS is configured to allow https://main.gopickup.com.ng
  static const String prodBaseUrl = 'https://backend.gopickup.com.ng/api/v1/';
  static const String devBaseUrl = 'https://backend.gopickup.com.ng/api/v1/';

  // Used for prefixing relative image paths returned by the backend
  static const String apiBaseUrl = 'https://backend.gopickup.com.ng';

  // WebSocket endpoint
  static const String wsUrl = 'wss://backend.gopickup.com.ng/api/v1/ws';

  // Always use the full backend URL — Flutter Web bakes URLs at compile time
  static String get baseUrl => kDebugMode ? devBaseUrl : prodBaseUrl;
}

import 'package:flutter/foundation.dart';

class AppConfig {
  static const String devBaseUrl = 'http://localhost:8080/api/v1';
  static const String prodBaseUrl = 'https://backend.gopickup.com.ng/api/v1';

  static String get baseUrl {
    return kDebugMode ? devBaseUrl : prodBaseUrl;
  }
}

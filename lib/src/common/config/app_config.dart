import 'package:flutter/foundation.dart';

class AppConfig {
  static const String devBaseUrl = 'http://localhost:8080/api/v1';
  static const String prodBaseUrl = 'https://backend.gopickup.com.ng/api/v1';

  static String get baseUrl {
    if (kIsWeb) {
      // In Docker/Production, if serving from the same host, we can use relative path
      // or the specific production domain.
      return kDebugMode ? devBaseUrl : '/api/v1'; 
    }
    return kDebugMode ? devBaseUrl : prodBaseUrl;
  }
}


import 'package:flutter/foundation.dart';

class AppConfig {
  static const String devBaseUrl = 'https://backend.gopickup.com.ng/api/v1/';
  static const String prodBaseUrl = 'https://backend.gopickup.com.ng/api/v1/';
  
  // The host URL used for prefixing relative image paths returned by the backend.
  static const String apiBaseUrl = 'https://backend.gopickup.com.ng';

  static String get baseUrl {
    if (kIsWeb) {
      return '/api/v1/'; 
    }
    return kDebugMode ? devBaseUrl : prodBaseUrl;
  }
}

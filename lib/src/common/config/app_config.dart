class AppConfig {
  static const String baseUrl = 'https://api.gopickup.com/api/v1'; // Production
  static const String devBaseUrl = 'http://localhost:8080/api/v1'; // Local Dev
  
  static bool get isDev => true; // Toggle this for testing
  
  static String get activeBaseUrl => isDev ? devBaseUrl : baseUrl;
}

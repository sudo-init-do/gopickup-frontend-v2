import 'package:flutter/foundation.dart';

class AppConfig {
  // ─── NEW PRODUCTION BACKEND ────────────────────────────────────────────────
  static const String prodBaseUrl = 'https://api.gopickup.com.ng/api/v1/';
  static const String devBaseUrl  = 'https://api.gopickup.com.ng/api/v1/';

  // Base used for image/upload URLs returned by the backend
  static const String apiBaseUrl  = 'https://api.gopickup.com.ng';

  // Uploads directory
  static const String uploadsBaseUrl = 'https://api.gopickup.com.ng/uploads/';

  // WebSocket endpoint
  static const String wsUrl = 'wss://api.gopickup.com.ng/api/v1/ws';

  // ─── Support ────────────────────────────────────────────────────────────────
  // GoPickup support WhatsApp/phone number (no '+' prefix). Single source of
  // truth — do not hardcode this elsewhere.
  static const String supportPhone = '2348087042206';

  /// Builds a WhatsApp deep link to support with an optional prefilled message.
  static String supportWhatsappUrl([String? message]) {
    const base = 'https://wa.me/$supportPhone';
    return (message == null || message.isEmpty)
        ? base
        : '$base?text=${Uri.encodeComponent(message)}';
  }

  // Always use the full backend URL — Flutter Web bakes URLs at compile time
  static String get baseUrl => kDebugMode ? devBaseUrl : prodBaseUrl;
}

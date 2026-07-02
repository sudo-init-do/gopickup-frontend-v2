import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows local (heads-up) notifications for delivery events — "Driver on the
/// way", "Your driver is arriving", "Delivered", etc.
///
/// These fire whenever the app process is alive (foreground or backgrounded),
/// driven by the websocket `notification` / `load_status_updated` events the
/// client already receives on their private room. For push that reaches a
/// *fully closed* app you additionally need FCM (the backend already has the
/// sender + token plumbing) — this service is the always-available layer.
///
/// No-op on web, where local notifications aren't supported (web push would go
/// through a service worker + FCM web instead).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _channelId = 'delivery_tracking';
  static const String _channelName = 'Delivery updates';
  static const String _channelDesc =
      'Live updates about your delivery and driver.';

  /// Initialise the plugin and create the Android channel. Safe to call more
  /// than once. Returns immediately on web.
  Future<void> init() async {
    if (kIsWeb || _ready) return;
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ));
    _ready = true;
  }

  /// Ask the OS for notification permission (Android 13+, iOS). Best-effort.
  Future<void> requestPermission() async {
    if (kIsWeb) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Show a notification. [id] lets related updates replace each other (e.g.
  /// all updates for one load share an id so they don't stack).
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (!_ready) await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Stable notification id derived from a load id so updates for the same load
  /// replace one another instead of piling up.
  static int idForLoad(String loadId) => loadId.hashCode & 0x7fffffff;
}

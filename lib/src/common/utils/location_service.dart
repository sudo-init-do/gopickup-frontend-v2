import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Thin wrapper around geolocator that fails gracefully — on web the browser
/// shows a permission prompt; if it's denied (or unsupported) we return null so
/// callers can fall back to a typed address instead of hard-blocking the flow.
class LocationService {
  /// Returns the current device position, or null if unavailable/denied.
  static Future<Position?> currentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  /// Whether we already hold (or can silently obtain) location permission.
  static Future<bool> ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// A live stream of positions for streaming a driver's movement. Emits a new
  /// position whenever the device moves at least [distanceFilter] metres.
  static Stream<Position> positionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Ensures we hold **background** ("Always") location permission so the driver
  /// keeps sharing their position after leaving the app / locking the phone.
  ///
  /// On Android 10+ this requires a second, separate grant on top of the
  /// while-in-use permission, so we request twice. On web there is no such thing
  /// as background location — we just confirm foreground access. Returns whether
  /// we ended up with at least while-in-use permission (the minimum needed to
  /// stream at all); callers can still start a foreground-only stream if the
  /// user declined the "Always" upgrade.
  static Future<bool> ensureBackgroundPermission() async {
    try {
      if (kIsWeb) return ensurePermission();
      if (!await Geolocator.isLocationServiceEnabled()) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
      // We have at least while-in-use. Try to upgrade to "Always"; a second
      // request surfaces the background-location prompt on Android 10+.
      if (permission == LocationPermission.whileInUse) {
        final upgraded = await Geolocator.requestPermission();
        if (upgraded != LocationPermission.denied &&
            upgraded != LocationPermission.deniedForever) {
          permission = upgraded;
        }
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// A background-capable position stream for an active delivery. On Android it
  /// runs a foreground service (with a persistent notification) so location
  /// keeps flowing when the app is backgrounded; on iOS it enables background
  /// location updates. On web/other it degrades to a plain foreground stream.
  ///
  /// [distanceFilter] gates emissions at the OS level — a stationary driver
  /// emits nothing, which (together with the backend's 5s throttle) keeps the
  /// stream cheap.
  static Stream<Position> backgroundPositionStream({int distanceFilter = 15}) {
    final LocationSettings settings;
    if (kIsWeb) {
      settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        forceLocationManager: false,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'GoPickup delivery in progress',
          notificationText: 'Sharing your live location with the customer',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        activityType: ActivityType.automotiveNavigation,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      );
    }
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}

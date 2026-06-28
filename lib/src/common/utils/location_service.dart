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
}

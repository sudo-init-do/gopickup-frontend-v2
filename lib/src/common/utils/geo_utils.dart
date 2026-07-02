import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Small geospatial helpers shared by the client and driver tracking maps.
///
/// Kept dependency-free (just `dart:math` + `latlong2`) so both the live map
/// widgets and the ETA fallback can reuse the same maths.
class GeoUtils {
  const GeoUtils._();

  static const double _earthRadiusM = 6371000.0;

  /// Great-circle distance between two points, in metres.
  static double haversineMeters(LatLng a, LatLng b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * _earthRadiusM * math.asin(math.min(1.0, math.sqrt(h)));
  }

  /// Initial bearing (compass heading, degrees clockwise from north) travelling
  /// from [a] to [b]. Used to rotate the vehicle marker so it faces its
  /// direction of travel. Returns a value in [0, 360).
  static double bearing(LatLng a, LatLng b) {
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    final deg = _deg(math.atan2(y, x));
    return (deg + 360) % 360;
  }

  /// Linearly interpolate between two coordinates (fraction [t] in [0,1]). Over
  /// short city distances a straight lat/lng lerp is visually indistinguishable
  /// from a great-circle path and is what powers the smooth marker glide.
  static LatLng lerp(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  /// A rough ETA in seconds from a straight-line distance, assuming an average
  /// urban driving speed. Only used as a fallback when the OSRM route (which
  /// returns a real duration) is unavailable.
  static int fallbackEtaSeconds(LatLng from, LatLng to,
      {double avgSpeedKmh = 22}) {
    final meters = haversineMeters(from, to);
    final mps = avgSpeedKmh * 1000 / 3600;
    if (mps <= 0) return 0;
    return (meters / mps).round();
  }

  /// Decode an encoded polyline (Google/OSRM "polyline" format, precision 5)
  /// into a list of coordinates.
  static List<LatLng> decodePolyline(String encoded, {int precision = 5}) {
    final points = <LatLng>[];
    final factor = math.pow(10, precision).toDouble();
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int result = 0, shift = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / factor, lng / factor));
    }
    return points;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
}

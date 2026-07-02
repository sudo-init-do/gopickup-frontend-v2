import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import 'geo_utils.dart';

/// The result of an OSRM route lookup: the road geometry plus the driving
/// distance and duration used to render the route line and the live ETA.
class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// A human-friendly ETA label, e.g. "5 min" or "just arriving".
  String get etaLabel {
    final mins = (durationSeconds / 60).round();
    if (mins <= 0) return 'Arriving now';
    if (mins == 1) return '1 min away';
    return '$mins mins away';
  }

  /// A human-friendly distance label, e.g. "2.3 km" or "600 m".
  String get distanceLabel {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }
}

/// Thin client for the OSRM routing API. Fails soft: any error (offline, rate
/// limited, malformed response) returns null so callers fall back to a straight
/// line + Haversine ETA. Uses its own short-timeout Dio so a slow route request
/// never blocks the live map.
class OsrmService {
  OsrmService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 6),
            ));

  final Dio _dio;

  /// Fetch the driving route from [from] to [to]. Returns null on any failure.
  Future<RouteResult?> route(LatLng from, LatLng to) async {
    try {
      final coords =
          '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';
      final url = '${AppConfig.osrmBaseUrl}/route/v1/driving/$coords';
      final resp = await _dio.get(url, queryParameters: {
        'overview': 'full',
        'geometries': 'polyline',
      });

      final data = resp.data;
      if (data is! Map || data['code'] != 'Ok') return null;
      final routes = data['routes'];
      if (routes is! List || routes.isEmpty) return null;

      final first = routes.first as Map;
      final geometry = first['geometry'] as String?;
      if (geometry == null || geometry.isEmpty) return null;

      final points = GeoUtils.decodePolyline(geometry);
      if (points.isEmpty) return null;

      return RouteResult(
        points: points,
        distanceMeters: (first['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (first['duration'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

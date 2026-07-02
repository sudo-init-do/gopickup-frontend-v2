import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../styles/app_colors.dart';
import '../utils/geo_utils.dart';
import '../utils/osrm_service.dart';

/// A Bolt/Uber-style live map shared by the client and driver tracking screens.
///
/// Given the pickup, dropoff and the *raw* latest driver position, it:
///  - glides the vehicle marker smoothly between GPS fixes (no teleporting),
///  - rotates the vehicle to its direction of travel,
///  - draws the real road route to the next stop (OSRM, straight-line fallback),
///  - gently keeps the camera on the vehicle,
///  - reports the live route/ETA to the parent via [onRoute].
///
/// The parent just feeds a new [driver] value whenever a `driver_moved` event
/// (or the device's own GPS) produces a fix; all animation/routing lives here.
class LiveTrackingMap extends StatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.driver,
    required this.status,
    this.pickup,
    this.dropoff,
    this.driverIcon = Icons.local_shipping_rounded,
    this.driverColor = AppColors.driverAccent,
    this.followDriver = true,
    this.showRoute = true,
    this.onRoute,
  });

  /// Latest raw driver position. Null until the first fix is known.
  final LatLng? driver;

  /// Load status; selects the current target stop (pickup vs dropoff).
  final String status;

  final LatLng? pickup;
  final LatLng? dropoff;
  final IconData driverIcon;
  final Color driverColor;
  final bool followDriver;

  /// Whether to fetch the OSRM road route (and ETA). The driver's own view can
  /// turn this off to save a request if it only needs its position.
  final bool showRoute;

  /// Reports the current route + ETA (or null when only a straight-line fallback
  /// is available) so the parent can render an ETA card.
  final ValueChanged<RouteResult?>? onRoute;

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap>
    with SingleTickerProviderStateMixin {
  static const LatLng _fallbackCenter = LatLng(6.5244, 3.3792); // Lagos

  final MapController _mapController = MapController();
  final OsrmService _osrm = OsrmService();

  late final AnimationController _glide;
  LatLng? _from; // glide start
  LatLng? _to; // glide end (latest fix)
  LatLng? _displayed; // interpolated position actually drawn
  double _heading = 0;

  List<LatLng> _route = const [];
  LatLng? _lastRoutedFrom;
  String? _lastRoutedTarget;
  bool _routing = false;
  bool _fitted = false;

  @override
  void initState() {
    super.initState();
    _glide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(_onGlideTick);

    if (widget.driver != null) {
      _displayed = widget.driver;
      _to = widget.driver;
      _maybeRoute();
    }
  }

  @override
  void didUpdateWidget(covariant LiveTrackingMap old) {
    super.didUpdateWidget(old);
    final next = widget.driver;
    if (next != null && next != _to) {
      _from = _displayed ?? next;
      _to = next;
      if (_from != null && _from != next) {
        _heading = GeoUtils.bearing(_from!, next);
      }
      _glide
        ..reset()
        ..forward();
      _maybeRoute();
    }
    // Target stop changed (e.g. picked_up) → recompute the route.
    if (old.status != widget.status) _maybeRoute(force: true);
  }

  void _onGlideTick() {
    final from = _from, to = _to;
    if (from == null || to == null) return;
    setState(() => _displayed = GeoUtils.lerp(from, to, _glide.value));
    if (widget.followDriver && _displayed != null) {
      _mapController.move(_displayed!, _mapController.camera.zoom);
    }
  }

  LatLng? get _nextStop =>
      widget.status == 'picked_up' ? widget.dropoff : widget.pickup;

  /// Fetch a road route to the next stop, but only when it's worth it: the
  /// driver has moved a meaningful distance from the last routed origin, or the
  /// target stop changed. Falls back to a straight line + Haversine ETA.
  Future<void> _maybeRoute({bool force = false}) async {
    if (!widget.showRoute) {
      _reportFallbackEta();
      return;
    }
    final driver = _to;
    final stop = _nextStop;
    if (driver == null || stop == null) return;

    final movedEnough = _lastRoutedFrom == null ||
        GeoUtils.haversineMeters(_lastRoutedFrom!, driver) > 40;
    final targetChanged = _lastRoutedTarget != widget.status;
    if (!force && !movedEnough && !targetChanged) return;
    if (_routing) return;

    _routing = true;
    _lastRoutedFrom = driver;
    _lastRoutedTarget = widget.status;
    try {
      final result = await _osrm.route(driver, stop);
      if (!mounted) return;
      if (result != null) {
        setState(() => _route = result.points);
        widget.onRoute?.call(result);
      } else {
        setState(() => _route = [driver, stop]);
        _reportFallbackEta();
      }
    } catch (_) {
      _reportFallbackEta();
    } finally {
      _routing = false;
    }
  }

  void _reportFallbackEta() {
    final driver = _to, stop = _nextStop;
    if (driver == null || stop == null) {
      widget.onRoute?.call(null);
      return;
    }
    final meters = GeoUtils.haversineMeters(driver, stop);
    widget.onRoute?.call(RouteResult(
      points: _route.isNotEmpty ? _route : [driver, stop],
      distanceMeters: meters,
      durationSeconds: GeoUtils.fallbackEtaSeconds(driver, stop).toDouble(),
    ));
  }

  LatLng get _initialCenter =>
      _displayed ?? widget.driver ?? widget.pickup ?? widget.dropoff ?? _fallbackCenter;

  void _fitOnce() {
    if (_fitted) return;
    final pts = <LatLng>[
      if (_displayed != null) _displayed!,
      if (_nextStop != null) _nextStop!,
    ];
    if (pts.length < 2) return;
    _fitted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: pts,
          padding: const EdgeInsets.all(72),
          maxZoom: 16,
        ),
      );
    });
  }

  @override
  void dispose() {
    _glide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fitOnce();
    final markers = <Marker>[
      if (widget.pickup != null)
        _pinMarker(widget.pickup!, Icons.trip_origin_rounded, AppColors.primary),
      if (widget.dropoff != null)
        _pinMarker(
            widget.dropoff!, Icons.location_on_rounded, AppColors.destructive),
      if (_displayed != null) _vehicleMarker(_displayed!),
    ];

    final polylines = <Polyline>[
      if (_route.length >= 2)
        Polyline(
          points: _route,
          strokeWidth: 5,
          color: widget.driverColor.withOpacity(0.85),
          borderStrokeWidth: 1,
          borderColor: Colors.white.withOpacity(0.6),
        ),
    ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gopickup.app',
          maxZoom: 19,
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Marker _pinMarker(LatLng point, IconData icon, Color color) {
    return Marker(
      point: point,
      width: 38,
      height: 38,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Marker _vehicleMarker(LatLng point) {
    return Marker(
      point: point,
      width: 50,
      height: 50,
      child: Transform.rotate(
        angle: _heading * math.pi / 180.0,
        child: Container(
          decoration: BoxDecoration(
            color: widget.driverColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
            ],
          ),
          child: Icon(widget.driverIcon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

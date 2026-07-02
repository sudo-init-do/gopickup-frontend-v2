import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../api/loads_api.dart';
import '../common/utils/location_service.dart';
import '../state/load_provider.dart' show loadsApiProvider;
import '../state/order_provider.dart' show websocketServiceProvider;
import 'websocket_service.dart';

/// Streams the driver's GPS to the backend for the duration of an active
/// delivery — independent of any screen. Once started it keeps a single
/// background-capable geolocator subscription running (foreground service on
/// Android, background updates on iOS), so the customer keeps seeing the truck
/// move even when the driver backgrounds the app or locks the phone.
///
/// This is the "always on while there's a job" piece of Uber/Bolt-style
/// tracking. The tracking *screen* only visualises; this service does the work.
class DriverLocationBroadcaster {
  DriverLocationBroadcaster(this._ref) {
    // React to lifecycle changes on the active load pushed over the websocket:
    // once it's delivered/cancelled there's nothing left to track.
    _statusSub = _ws.onLoadStatus.listen((payload) {
      if (payload['load_id']?.toString() != _activeLoadId) return;
      final status = payload['status']?.toString();
      if (status == 'delivered' || status == 'cancelled') {
        stop();
      }
    });
  }

  final Ref _ref;
  WebSocketService get _ws => _ref.read(websocketServiceProvider);
  LoadsApi get _loadsApi => _ref.read(loadsApiProvider);

  StreamSubscription<Position>? _posSub;
  StreamSubscription? _statusSub;
  final _positions = StreamController<LatLng>.broadcast();

  String? _activeLoadId;
  LatLng? _current;
  bool _sharing = false;
  bool _starting = false;

  /// The load currently being broadcast, if any.
  String? get activeLoadId => _activeLoadId;

  /// Whether we're actively streaming location right now.
  bool get isSharing => _sharing;

  /// The most recent known position (also seeds a freshly-opened map).
  LatLng? get current => _current;

  /// Live position updates for this device's own driver — used by the driver's
  /// map to show itself without opening a second GPS subscription.
  Stream<LatLng> get positions => _positions.stream;

  /// Start broadcasting for [loadId]. Idempotent: calling it again for the same
  /// load is a no-op; calling it for a different load switches over cleanly.
  Future<void> start(String loadId) async {
    if (_activeLoadId == loadId && _sharing) return;
    if (_starting) return;
    _starting = true;
    try {
      // Switching loads: tear down the previous stream first.
      if (_activeLoadId != null && _activeLoadId != loadId) {
        await _posSub?.cancel();
        _posSub = null;
        _sharing = false;
      }
      _activeLoadId = loadId;

      final ok = await LocationService.ensureBackgroundPermission();
      if (!ok) {
        _sharing = false;
        return;
      }

      // Push an immediate first fix so the customer sees the truck right away,
      // then let the OS distance filter gate subsequent emissions.
      final first = await LocationService.currentPosition();
      if (first != null) _emit(first);

      await _posSub?.cancel();
      _posSub = LocationService.backgroundPositionStream(distanceFilter: 15)
          .listen(_emit, onError: (_) {});
      _sharing = true;
    } finally {
      _starting = false;
    }
  }

  /// Stop broadcasting (delivery finished/cancelled, or no active job).
  Future<void> stop() async {
    await _posSub?.cancel();
    _posSub = null;
    _activeLoadId = null;
    _sharing = false;
  }

  /// Reconcile the broadcaster with the driver's current server-side state:
  /// start streaming their in-progress load, or stop if they have none. Called
  /// after the assigned-loads list loads and on app resume so tracking
  /// self-heals after the app was killed or the network dropped.
  Future<void> syncFromActiveLoads() async {
    try {
      final loads = await _loadsApi.getAssignedLoads();
      final active = loads.where(
          (l) => l.status == 'assigned' || l.status == 'picked_up');
      if (active.isEmpty) {
        if (_sharing) await stop();
        return;
      }
      await start(active.first.id);
    } catch (_) {
      // Network hiccup — leave any existing stream running; we'll retry on the
      // next sync (list refresh / app resume).
    }
  }

  void _emit(Position pos) {
    final here = LatLng(pos.latitude, pos.longitude);
    _current = here;
    if (!_positions.isClosed) _positions.add(here);
    final loadId = _activeLoadId;
    if (loadId != null) {
      // Backend validates assignment + status and rate-limits to 1/5s.
      _ws.sendDriverLocationUpdateForLoad(loadId, pos.latitude, pos.longitude);
    }
  }

  void dispose() {
    _posSub?.cancel();
    _statusSub?.cancel();
    if (!_positions.isClosed) _positions.close();
  }
}

/// App-wide singleton broadcaster. Kept alive for the session so streaming
/// survives navigation; disposed on logout when the container tears down.
final driverLocationBroadcasterProvider =
    Provider<DriverLocationBroadcaster>((ref) {
  final broadcaster = DriverLocationBroadcaster(ref);
  ref.onDispose(broadcaster.dispose);
  return broadcaster;
});

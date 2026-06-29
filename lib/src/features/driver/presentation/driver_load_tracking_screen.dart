import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/utils/launch_url.dart';
import '../../../common/utils/location_service.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../models/load_models.dart';
import '../../../state/load_provider.dart';
import '../../../state/order_provider.dart' show websocketServiceProvider;

/// Driver-side live screen for an assigned delivery. Streams the driver's GPS
/// to the backend (which relays it to the client's tracking map) and lets the
/// driver advance the delivery status.
class DriverLoadTrackingScreen extends ConsumerStatefulWidget {
  final String loadId;
  const DriverLoadTrackingScreen({super.key, required this.loadId});

  @override
  ConsumerState<DriverLoadTrackingScreen> createState() =>
      _DriverLoadTrackingScreenState();
}

class _DriverLoadTrackingScreenState
    extends ConsumerState<DriverLoadTrackingScreen> {
  static const LatLng _fallbackCenter = LatLng(6.5244, 3.3792);

  final MapController _mapController = MapController();
  StreamSubscription<Position>? _posSub;
  StreamSubscription? _statusSub;

  Load? _load;
  LatLng? _me;
  String _status = 'assigned';
  bool _sharing = false;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    final ws = ref.read(websocketServiceProvider);
    ws.joinLoadRoom(widget.loadId);
    _statusSub = ws.onLoadStatus.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      final s = payload['status']?.toString();
      if (s != null && mounted) setState(() => _status = s);
    });
    _fetchLoad();
    _startSharing();
  }

  Future<void> _fetchLoad() async {
    try {
      // Drivers reach this from the assigned list; reuse the same load object
      // shape. getLoad is a client endpoint, so fall back gracefully.
      final loads = await ref.read(loadsApiProvider).getAssignedLoads();
      final match = loads.where((l) => l.id == widget.loadId).toList();
      if (match.isNotEmpty && mounted) {
        setState(() {
          _load = match.first;
          _status = match.first.status;
        });
      }
    } catch (_) {/* keep going; sharing still works */}
  }

  Future<void> _startSharing() async {
    final ok = await LocationService.ensurePermission();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is needed so the customer can track you.'),
          ),
        );
      }
      return;
    }
    setState(() => _sharing = true);
    final ws = ref.read(websocketServiceProvider);

    // Send an immediate first fix, then stream on movement.
    final first = await LocationService.currentPosition();
    if (first != null && mounted) {
      _onPosition(first, ws);
    }

    _posSub = LocationService.positionStream(distanceFilter: 10).listen(
      (pos) => _onPosition(pos, ws),
      onError: (_) {},
    );
  }

  void _onPosition(Position pos, ws) {
    if (!mounted) return;
    final here = LatLng(pos.latitude, pos.longitude);
    setState(() => _me = here);
    _mapController.move(here, 15);
    // Backend rate-limits to 1/5s and validates assignment + status.
    ws.sendDriverLocationUpdateForLoad(
        widget.loadId, pos.latitude, pos.longitude);
  }

  LatLng? get _pickup => (_load?.pickupLat != null && _load?.pickupLng != null)
      ? LatLng(_load!.pickupLat!, _load!.pickupLng!)
      : null;
  LatLng? get _dropoff =>
      (_load?.deliveryLat != null && _load?.deliveryLng != null)
          ? LatLng(_load!.deliveryLat!, _load!.deliveryLng!)
          : null;

  /// A tappable navigation link for the current stop: the customer-supplied
  /// Google pin/Plus code if present, otherwise a Maps search of the address.
  String? get _navTarget {
    final load = _load;
    if (load == null) return null;
    final isDropoff = _status == 'picked_up';
    final pin = isDropoff ? load.dropoffPin : load.pickupPin;
    if (pin != null && pin.trim().isNotEmpty) {
      final p = pin.trim();
      if (p.startsWith('http')) return p;
      // Treat anything else (e.g. a Plus code) as a Maps query.
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(p)}';
    }
    final address = isDropoff ? load.deliveryAddress : load.pickupAddress;
    if (address.isNotEmpty) {
      return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    }
    return null;
  }

  Future<void> _advance(String to) async {
    setState(() => _updatingStatus = true);
    try {
      await ref.read(loadsApiProvider).updateLoadStatus(widget.loadId, to);
      if (mounted) setState(() => _status = to);
      if (to == 'delivered') {
        await _posSub?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Delivery completed!'),
                backgroundColor: AppColors.success),
          );
          ref.invalidate(assignedLoadsProvider);
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _statusSub?.cancel();
    ref.read(websocketServiceProvider).leaveLoadRoom(widget.loadId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Active Delivery', style: AppTextStyles.headingMd),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMap()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final markers = <Marker>[
      if (_pickup != null) _marker(_pickup!, Icons.trip_origin_rounded, AppColors.primary),
      if (_dropoff != null)
        _marker(_dropoff!, Icons.location_on_rounded, AppColors.destructive),
      if (_me != null)
        _marker(_me!, Icons.navigation_rounded, AppColors.driverAccent, big: true),
    ];
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _me ?? _pickup ?? _fallbackCenter,
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
        MarkerLayer(markers: markers),
      ],
    );
  }

  Marker _marker(LatLng point, IconData icon, Color color, {bool big = false}) {
    final size = big ? 46.0 : 38.0;
    return Marker(
      point: point,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: Icon(icon, color: Colors.white, size: big ? 24 : 20),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _sharing ? AppColors.success : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _sharing
                      ? 'Sharing your live location'
                      : 'Location not shared',
                  style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                Text(_status.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.driverAccent,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            if (_navTarget != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => openExternalUrl(_navTarget!),
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: Text(_status == 'picked_up'
                      ? 'Navigate to drop-off'
                      : 'Navigate to pickup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: const BorderSide(color: AppColors.info),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_status == 'assigned')
              PrimaryButton(
                label: 'Mark as picked up',
                icon: Icons.inventory_rounded,
                color: AppColors.driverAccent,
                isLoading: _updatingStatus,
                onPressed: () => _advance('picked_up'),
              )
            else if (_status == 'picked_up')
              PrimaryButton(
                label: 'Mark as delivered',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                isLoading: _updatingStatus,
                onPressed: () => _advance('delivered'),
              )
            else
              Text('Delivery ${_status.replaceAll('_', ' ')}',
                  style: AppTextStyles.titleMd),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_spacing.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/utils/launch_url.dart';
import '../../../../models/load_models.dart';
import '../../../../state/load_provider.dart';
import '../../../../state/order_provider.dart' show websocketServiceProvider;

/// Step 3 of "Book Driver": the live map. The assigned driver streams GPS over
/// the websocket; we plot it on an OpenStreetMap map and update the status as
/// the trip progresses (assigned → picked_up → delivered).
class BookDriverTrackingScreen extends ConsumerStatefulWidget {
  final String loadId;
  const BookDriverTrackingScreen({super.key, required this.loadId});

  @override
  ConsumerState<BookDriverTrackingScreen> createState() =>
      _BookDriverTrackingScreenState();
}

class _BookDriverTrackingScreenState
    extends ConsumerState<BookDriverTrackingScreen> {
  // Default map center until we have real coordinates (Lagos).
  static const LatLng _fallbackCenter = LatLng(6.5244, 3.3792);

  final MapController _mapController = MapController();
  StreamSubscription? _moveSub;
  StreamSubscription? _statusSub;

  Load? _load;
  LatLng? _driver;
  String _status = 'assigned';
  bool _hasCenteredOnDriver = false;

  @override
  void initState() {
    super.initState();
    final ws = ref.read(websocketServiceProvider);
    ws.joinLoadRoom(widget.loadId);

    _moveSub = ws.onDriverMoved.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      final lat = (payload['lat'] as num?)?.toDouble();
      final lng = (payload['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return;
      setState(() => _driver = LatLng(lat, lng));
      _mapController.move(LatLng(lat, lng), _hasCenteredOnDriver ? _mapController.camera.zoom : 15);
      _hasCenteredOnDriver = true;
    });

    _statusSub = ws.onLoadStatus.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      final s = payload['status']?.toString();
      if (s != null) setState(() => _status = s);
    });

    _fetchLoad();
  }

  Future<void> _fetchLoad() async {
    try {
      final load = await ref.read(loadsApiProvider).getLoad(widget.loadId);
      if (!mounted) return;
      setState(() {
        _load = load;
        _status = load.status;
      });
    } catch (_) {/* keep showing the map; live events still flow */}
  }

  LatLng? get _pickup => (_load?.pickupLat != null && _load?.pickupLng != null)
      ? LatLng(_load!.pickupLat!, _load!.pickupLng!)
      : null;

  LatLng? get _dropoff =>
      (_load?.deliveryLat != null && _load?.deliveryLng != null)
          ? LatLng(_load!.deliveryLat!, _load!.deliveryLng!)
          : null;

  LatLng get _initialCenter => _driver ?? _pickup ?? _dropoff ?? _fallbackCenter;

  @override
  void dispose() {
    _moveSub?.cancel();
    _statusSub?.cancel();
    ref.read(websocketServiceProvider).leaveLoadRoom(widget.loadId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMap(),
          // Floating back/close button.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topLeft,
                child: _circleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.go('/client'),
                ),
              ),
            ),
          ),
          // Bottom status / driver card.
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final markers = <Marker>[
      if (_pickup != null)
        _marker(_pickup!, Icons.trip_origin_rounded, AppColors.primary),
      if (_dropoff != null)
        _marker(_dropoff!, Icons.location_on_rounded, AppColors.destructive),
      if (_driver != null)
        _marker(_driver!, Icons.local_shipping_rounded, AppColors.vendorAccent,
            big: true),
    ];

    // Line from the driver to their next stop.
    final nextStop = _status == 'picked_up' ? _dropoff : _pickup;
    final polylines = <Polyline>[
      if (_driver != null && nextStop != null)
        Polyline(
          points: [_driver!, nextStop],
          strokeWidth: 4,
          color: AppColors.vendorAccent.withOpacity(0.7),
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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: big ? 24 : 20),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  ({String title, String subtitle, Color color}) get _statusInfo {
    switch (_status) {
      case 'assigned':
        return (
          title: 'Driver on the way to pickup',
          subtitle: 'Your driver is heading to the pickup point.',
          color: AppColors.info,
        );
      case 'picked_up':
        return (
          title: 'On the way to you',
          subtitle: 'Your goods have been picked up and are en route.',
          color: AppColors.vendorAccent,
        );
      case 'delivered':
        return (
          title: 'Delivered',
          subtitle: 'This delivery is complete. Thank you!',
          color: AppColors.success,
        );
      case 'cancelled':
        return (
          title: 'Cancelled',
          subtitle: 'This delivery was cancelled.',
          color: AppColors.destructive,
        );
      default:
        return (
          title: 'Matched with a driver',
          subtitle: 'Waiting for the driver to start the trip.',
          color: AppColors.textSecondary,
        );
    }
  }

  Widget _buildBottomCard() {
    final info = _statusInfo;
    final acceptedBid = _load?.acceptedBid;
    final driverName =
        _load?.driverName ?? acceptedBid?.driverName ?? 'Your driver';
    final driverPhone = _load?.driverPhone ?? acceptedBid?.driverPhone;
    final vehicle = _load?.driverVehicle ?? acceptedBid?.driverVehicle;
    final plate = _load?.driverPlate ?? acceptedBid?.driverPlate;
    final price = _load?.agreedAmount ?? acceptedBid?.amount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pill.
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: info.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(info.title,
                      style: AppTextStyles.caption.copyWith(
                          color: info.color, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(info.subtitle,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.vendorAccent.withOpacity(0.12),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.vendorAccent, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driverName,
                          style: AppTextStyles.titleMd
                              .copyWith(fontWeight: FontWeight.w800)),
                      if (vehicle != null)
                        Text(
                          '$vehicle${plate != null ? ' • $plate' : ''}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      if (price != null)
                        Text('Agreed: ₦${price.toStringAsFixed(0)}',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                if (driverPhone != null && driverPhone.isNotEmpty)
                  _circleButton(
                    icon: Icons.call_rounded,
                    onTap: () => openExternalUrl('tel:$driverPhone'),
                  ),
              ],
            ),
            if (_driver == null && _status != 'delivered') ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Waiting for live location…',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

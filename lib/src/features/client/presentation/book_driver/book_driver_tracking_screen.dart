import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_spacing.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../common/utils/launch_url.dart';
import '../../../../common/utils/osrm_service.dart';
import '../../../../common/widgets/live_tracking_map.dart';
import '../../../../models/load_models.dart';
import '../../../../realtime/notification_service.dart';
import '../../../../state/load_provider.dart';
import '../../../../state/order_provider.dart'
    show websocketServiceProvider, notificationServiceProvider;

/// Step 3 of "Book Driver": the live map. The assigned driver streams GPS over
/// the websocket; we glide it along the road on an OpenStreetMap map, show a
/// live ETA, and update the status as the trip progresses
/// (assigned → picked_up → delivered).
class BookDriverTrackingScreen extends ConsumerStatefulWidget {
  final String loadId;
  const BookDriverTrackingScreen({super.key, required this.loadId});

  @override
  ConsumerState<BookDriverTrackingScreen> createState() =>
      _BookDriverTrackingScreenState();
}

class _BookDriverTrackingScreenState
    extends ConsumerState<BookDriverTrackingScreen> {
  StreamSubscription? _moveSub;
  StreamSubscription? _statusSub;

  Load? _load;
  LatLng? _driver;
  RouteResult? _eta;
  String _status = 'assigned';
  bool _arrivingNotified = false;

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
    });

    _statusSub = ws.onLoadStatus.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      final s = payload['status']?.toString();
      if (s != null && s != _status) {
        setState(() {
          _status = s;
          // Allow a fresh "arriving" alert for the next leg (e.g. to drop-off).
          _arrivingNotified = false;
        });
      }
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
        // Seed the map immediately from the driver's last-known position so the
        // truck shows up right away instead of waiting for the first live ping.
        if (_driver == null &&
            load.driverLat != null &&
            load.driverLng != null) {
          _driver = LatLng(load.driverLat!, load.driverLng!);
        }
      });
    } catch (_) {/* keep showing the map; live events still flow */}
  }

  /// Fire a one-time "driver is arriving" notification once the live ETA to the
  /// current stop drops under ~2 minutes.
  void _maybeNotifyArriving(RouteResult? r) {
    if (_arrivingNotified || r == null) return;
    if (_status != 'assigned' && _status != 'picked_up') return;
    if (r.durationSeconds <= 0 || r.durationSeconds > 120) return;
    _arrivingNotified = true;
    final heading =
        _status == 'picked_up' ? 'Your load is almost there' : 'Driver arriving';
    ref.read(notificationServiceProvider).show(
          id: NotificationService.idForLoad(widget.loadId),
          title: '$heading 🚚',
          body: 'Your driver is about ${r.etaLabel.replaceAll(' away', '')} '
              'away (${r.distanceLabel}). Please get ready.',
          payload: widget.loadId,
        );
  }

  LatLng? get _pickup => (_load?.pickupLat != null && _load?.pickupLng != null)
      ? LatLng(_load!.pickupLat!, _load!.pickupLng!)
      : null;

  LatLng? get _dropoff =>
      (_load?.deliveryLat != null && _load?.deliveryLng != null)
          ? LatLng(_load!.deliveryLat!, _load!.deliveryLng!)
          : null;

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
          LiveTrackingMap(
            driver: _driver,
            status: _status,
            pickup: _pickup,
            dropoff: _dropoff,
            driverIcon: Icons.local_shipping_rounded,
            driverColor: AppColors.vendorAccent,
            showRoute: _status != 'delivered' && _status != 'cancelled',
            onRoute: (r) {
              if (mounted) setState(() => _eta = r);
              _maybeNotifyArriving(r);
            },
          ),
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
    final showEta = _driver != null &&
        _eta != null &&
        _status != 'delivered' &&
        _status != 'cancelled';

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
            // Status pill + live ETA.
            Row(
              children: [
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
                        decoration: BoxDecoration(
                            color: info.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(info.title,
                          style: AppTextStyles.caption.copyWith(
                              color: info.color, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const Spacer(),
                if (showEta)
                  Text(
                    '${_eta!.etaLabel} • ${_eta!.distanceLabel}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800),
                  ),
              ],
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

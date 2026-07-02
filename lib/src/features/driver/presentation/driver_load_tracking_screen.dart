import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/utils/launch_url.dart';
import '../../../common/widgets/live_tracking_map.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../models/load_models.dart';
import '../../../realtime/driver_location_broadcaster.dart';
import '../../../state/load_provider.dart';
import '../../../state/order_provider.dart' show websocketServiceProvider;

/// Driver-side live screen for an assigned delivery. The actual GPS streaming is
/// owned by [DriverLocationBroadcaster] (which keeps running in the background
/// even when this screen is closed); here we just visualise the driver's own
/// position, draw the route to the next stop, and let the driver advance the
/// delivery status.
class DriverLoadTrackingScreen extends ConsumerStatefulWidget {
  final String loadId;
  const DriverLoadTrackingScreen({super.key, required this.loadId});

  @override
  ConsumerState<DriverLoadTrackingScreen> createState() =>
      _DriverLoadTrackingScreenState();
}

class _DriverLoadTrackingScreenState
    extends ConsumerState<DriverLoadTrackingScreen> {
  StreamSubscription? _posSub;
  StreamSubscription? _statusSub;

  Load? _load;
  LatLng? _me;
  String _status = 'assigned';
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

    // Start background broadcasting for this delivery and mirror its positions
    // onto our own map. The broadcaster survives this screen being closed.
    final broadcaster = ref.read(driverLocationBroadcasterProvider);
    _me = broadcaster.current;
    _posSub = broadcaster.positions.listen((p) {
      if (mounted) setState(() => _me = p);
    });
    broadcaster.start(widget.loadId);

    _fetchLoad();
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
        // The broadcaster also stops itself on the delivered status event, but
        // stop explicitly so location sharing ends the moment we're done.
        await ref.read(driverLocationBroadcasterProvider).stop();
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
    // Only detach this screen's listeners — the broadcaster keeps streaming in
    // the background until the delivery is completed.
    _posSub?.cancel();
    _statusSub?.cancel();
    ref.read(websocketServiceProvider).leaveLoadRoom(widget.loadId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharing =
        ref.watch(driverLocationBroadcasterProvider).isSharing || _me != null;
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
          Expanded(
            child: LiveTrackingMap(
              driver: _me,
              status: _status,
              pickup: _pickup,
              dropoff: _dropoff,
              driverIcon: Icons.navigation_rounded,
              driverColor: AppColors.driverAccent,
              showRoute: _status != 'delivered' && _status != 'cancelled',
            ),
          ),
          _buildControls(sharing),
        ],
      ),
    );
  }

  Widget _buildControls(bool sharing) {
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
                    color: sharing ? AppColors.success : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  sharing
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

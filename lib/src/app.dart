import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/styles/app_theme.dart';
import 'routing/app_router.dart';
import 'api/api_client.dart';
import 'realtime/notification_service.dart';
import 'state/auth_provider.dart';
import 'state/order_provider.dart';

class GoPickupApp extends ConsumerWidget {
  const GoPickupApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Attach global 401 listener to force logout on session expiration
    ApiClient.onUnauthorized = () {
      ref.read(authProvider.notifier).logout();
    };

    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'GoPickup',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      // Clamp OS text scaling so very large accessibility font settings can't
      // overflow layouts on small devices (a common cause of broken UI).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return _NotificationHost(
          child: MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.15,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

/// Sits at the app root and turns backend/websocket delivery events into local
/// heads-up notifications, so the customer is told when their driver is on the
/// way, arriving, or done — even when they're not on the tracking screen (as
/// long as the app is running). The websocket delivers `load_status_updated`
/// and `notification` to the user's private room app-wide.
class _NotificationHost extends ConsumerStatefulWidget {
  const _NotificationHost({required this.child});
  final Widget child;

  @override
  ConsumerState<_NotificationHost> createState() => _NotificationHostState();
}

class _NotificationHostState extends ConsumerState<_NotificationHost> {
  StreamSubscription? _notifSub;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(notificationServiceProvider);
    notifier.init().then((_) => notifier.requestPermission());

    final ws = ref.read(websocketServiceProvider);

    // Backend-pushed notifications already carry a title/body (new bids, etc.).
    _notifSub = ws.onNotification.listen((payload) {
      final title = payload['title']?.toString();
      final body = payload['body']?.toString();
      if (title == null || body == null) return;
      final data = payload['data'];
      final loadId = data is Map ? data['load_id']?.toString() : null;
      notifier.show(
        id: loadId != null
            ? NotificationService.idForLoad(loadId)
            : DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        payload: loadId,
      );
    });

    // Load status transitions → friendly delivery updates, for clients only
    // (the driver is the one moving and doesn't need "driver on the way").
    _statusSub = ws.onLoadStatus.listen((payload) {
      final role = ref.read(authProvider).user?.role.toLowerCase();
      if (role != 'client') return;
      final loadId = payload['load_id']?.toString();
      final status = payload['status']?.toString();
      if (loadId == null || status == null) return;
      final copy = _statusCopy(status);
      if (copy == null) return;
      notifier.show(
        id: NotificationService.idForLoad(loadId),
        title: copy.title,
        body: copy.body,
        payload: loadId,
      );
    });
  }

  ({String title, String body})? _statusCopy(String status) {
    switch (status) {
      case 'assigned':
        return (
          title: 'Driver on the way 🚚',
          body: 'A driver accepted your delivery and is heading to pickup.',
        );
      case 'picked_up':
        return (
          title: 'Your load is on the move',
          body: 'Your goods have been picked up and are en route to you.',
        );
      case 'delivered':
        return (
          title: 'Delivered ✅',
          body: 'Your delivery is complete. Thank you for using GoPickup!',
        );
      case 'cancelled':
        return (
          title: 'Delivery cancelled',
          body: 'Your delivery was cancelled.',
        );
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

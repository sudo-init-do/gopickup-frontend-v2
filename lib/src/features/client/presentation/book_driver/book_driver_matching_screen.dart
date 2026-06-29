import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/styles/app_colors.dart';
import '../../../../common/styles/app_spacing.dart';
import '../../../../common/styles/app_text_styles.dart';
import '../../../../models/load_models.dart';
import '../../../../state/load_provider.dart';
import '../../../../state/order_provider.dart' show websocketServiceProvider;

/// Step 2 of "Book Driver": we've created the load; now drivers send offers.
/// Bids arrive live over the websocket (`load_bid`), with a 5s `getLoad` poll
/// as a fallback in case a socket event is missed across a reconnect.
class BookDriverMatchingScreen extends ConsumerStatefulWidget {
  final String loadId;
  const BookDriverMatchingScreen({super.key, required this.loadId});

  @override
  ConsumerState<BookDriverMatchingScreen> createState() =>
      _BookDriverMatchingScreenState();
}

class _BookDriverMatchingScreenState
    extends ConsumerState<BookDriverMatchingScreen> {
  final List<LoadBid> _bids = [];
  StreamSubscription? _bidSub;
  StreamSubscription? _statusSub;
  Timer? _pollTimer;
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    final ws = ref.read(websocketServiceProvider);
    ws.joinLoadRoom(widget.loadId);

    _bidSub = ws.onLoadBid.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      _refreshFromServer();
    });

    // If the load gets assigned (e.g. accepted in another session), move on.
    _statusSub = ws.onLoadStatus.listen((payload) {
      if (payload['load_id']?.toString() != widget.loadId) return;
      final status = payload['status']?.toString();
      if (status == 'assigned' || status == 'picked_up') {
        _goToTracking();
      }
    });

    // Initial load + polling fallback.
    _refreshFromServer();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshFromServer(),
    );
  }

  Future<void> _refreshFromServer() async {
    try {
      final load = await ref.read(loadsApiProvider).getLoad(widget.loadId);
      if (!mounted) return;
      if (load.isAssigned) {
        _goToTracking();
        return;
      }
      final pending = load.bids.where((b) => b.status == 'pending').toList();
      setState(() {
        _bids
          ..clear()
          ..addAll(pending);
      });
    } catch (_) {
      // transient; the next poll will retry
    }
  }

  void _goToTracking() {
    if (!mounted) return;
    _pollTimer?.cancel();
    context.pushReplacement('/client/book-driver/tracking', extra: widget.loadId);
  }

  Future<void> _accept(LoadBid bid) async {
    setState(() => _accepting = true);
    try {
      await ref.read(loadsApiProvider).acceptLoadBid(widget.loadId, bid.id);
      _goToTracking();
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<bool> _cancel() async {
    try {
      await ref.read(loadsApiProvider).cancelLoad(widget.loadId);
    } catch (_) {
      // ignore — leaving the screen anyway
    }
    return true;
  }

  @override
  void dispose() {
    _bidSub?.cancel();
    _statusSub?.cancel();
    _pollTimer?.cancel();
    ref.read(websocketServiceProvider).leaveLoadRoom(widget.loadId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _cancel();
        if (mounted) context.go('/client');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Finding a driver', style: AppTextStyles.headingMd),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              await _cancel();
              if (mounted) context.go('/client');
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchingHeader(),
              Expanded(
                child: _bids.isEmpty
                    ? _buildWaiting()
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: _bids.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) => _buildBidCard(_bids[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.vendorAccent.withOpacity(0.06),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.vendorAccent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _bids.isEmpty
                  ? 'Reaching out to nearby drivers…'
                  : '${_bids.length} driver${_bids.length == 1 ? '' : 's'} '
                      'responded — pick one',
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 54,
              height: 54,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.vendorAccent),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Searching for drivers',
                style: AppTextStyles.titleMd, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hang tight — we\'re reaching out to nearby drivers. We\'ll notify '
              'you as offers arrive, so keep an eye on your notifications 🔔 for '
              'driver bids. You can safely wait here or leave this screen.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.vendorAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_active_outlined,
                      size: 16, color: AppColors.vendorAccent),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Watch your notifications for bids',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.vendorAccent,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidCard(LoadBid bid) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.vendorAccent.withOpacity(0.12),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.vendorAccent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.driverName ?? 'Driver',
                      style: AppTextStyles.titleMd
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (bid.driverVehicle != null)
                      Text(
                        '${bid.driverVehicle}'
                        '${bid.driverPlate != null ? ' • ${bid.driverPlate}' : ''}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
              Text(
                '₦${bid.amount.toStringAsFixed(0)}',
                style: AppTextStyles.headingMd.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.vendorAccent,
                ),
              ),
            ],
          ),
          if (bid.note != null && bid.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(bid.note!, style: AppTextStyles.bodySm),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _accepting ? null : () => _accept(bid),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vendorAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text('Accept & track'),
            ),
          ),
        ],
      ),
    );
  }
}

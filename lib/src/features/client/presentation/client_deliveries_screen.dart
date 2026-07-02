import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import '../../../models/load_models.dart';
import '../../../state/load_provider.dart';

/// Client-facing list of the deliveries they've booked, so they can jump back
/// into the live map for any in-progress load at any moment — the "where is my
/// load right now?" entry point. Active loads (assigned/picked_up) are shown
/// first with a live badge; delivered/cancelled loads follow.
class ClientDeliveriesScreen extends ConsumerWidget {
  const ClientDeliveriesScreen({super.key});

  static const _activeStatuses = {'assigned', 'picked_up'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myLoadsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('My Deliveries', style: AppTextStyles.headingMd),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myLoadsProvider),
        child: async.when(
          loading: () => const AppLoading(),
          error: (e, _) => AppErrorState(message: 'Error: $e'),
          data: (loads) {
            if (loads.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: 'No deliveries yet',
                    message:
                        'Book a driver and your deliveries will show up here to track.',
                  ),
                ],
              );
            }
            // Active first (live), then the rest by most recent.
            final sorted = [...loads]..sort((a, b) {
                final aActive = _activeStatuses.contains(a.status) ? 0 : 1;
                final bActive = _activeStatuses.contains(b.status) ? 0 : 1;
                if (aActive != bActive) return aActive - bActive;
                return b.createdAt.compareTo(a.createdAt);
              });
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => _DeliveryCard(load: sorted[i]),
            );
          },
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Load load;
  const _DeliveryCard({required this.load});

  bool get _isActive =>
      load.status == 'assigned' || load.status == 'picked_up';
  bool get _isTrackable => _isActive || load.status == 'delivered';

  ({String label, Color color}) get _statusChip {
    switch (load.status) {
      case 'assigned':
        return (label: 'DRIVER ON THE WAY', color: AppColors.info);
      case 'picked_up':
        return (label: 'IN TRANSIT', color: AppColors.vendorAccent);
      case 'delivered':
        return (label: 'DELIVERED', color: AppColors.success);
      case 'cancelled':
        return (label: 'CANCELLED', color: AppColors.destructive);
      case 'open':
        return (label: 'FINDING DRIVER', color: AppColors.textSecondary);
      default:
        return (label: load.status.toUpperCase(), color: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _statusChip;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: _isTrackable
            ? () => context.push('/client/book-driver/tracking', extra: load.id)
            : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: _isActive ? chip.color.withOpacity(0.4) : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: chip.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isActive) ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: chip.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Text(chip.label,
                            style: AppTextStyles.caption.copyWith(
                                color: chip.color,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (load.agreedAmount != null || load.budgetAmount != null)
                    Text(
                      '₦${(load.agreedAmount ?? load.budgetAmount)!.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(load.title,
                  style: AppTextStyles.titleMd
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.md),
              _row(Icons.trip_origin_rounded, load.pickupAddress,
                  AppColors.primary),
              const SizedBox(height: AppSpacing.xs),
              _row(Icons.location_on_rounded, load.deliveryAddress,
                  AppColors.destructive),
              if (_isTrackable) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _isActive ? 'Track live' : 'View trip',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary, size: 18),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

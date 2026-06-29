import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/utils/launch_url.dart';
import '../../../common/widgets/app_states.dart';
import '../../../models/load_models.dart';
import 'admin_providers.dart';

/// Admin console for incoming Book Driver requests + Post Load schedules so the
/// team can see new jobs and call drivers in to bid.
class AdminLoadsScreen extends ConsumerStatefulWidget {
  const AdminLoadsScreen({super.key});

  @override
  ConsumerState<AdminLoadsScreen> createState() => _AdminLoadsScreenState();
}

class _AdminLoadsScreenState extends ConsumerState<AdminLoadsScreen> {
  // 0 All, 1 Needs driver (open), 2 Book Driver, 3 Post Load
  int _filter = 0;

  bool _matchesFilter(Load l) {
    switch (_filter) {
      case 1:
        return l.status == 'open';
      case 2:
        return l.scheduledAt == null; // instant request
      case 3:
        return l.scheduledAt != null; // scheduled
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminLoadsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADMIN CONSOLE',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  const Text('Driver Bookings & Loads',
                      style: AppTextStyles.headingMd),
                ],
              ),
            ),
            _buildFilters(),
            Expanded(
              child: async.when(
                loading: () => const AppLoading(),
                error: (e, _) => AppErrorState(
                  message: e.toString().replaceFirst('Exception: ', ''),
                  onRetry: () => ref.invalidate(adminLoadsProvider),
                ),
                data: (loads) {
                  final filtered = loads.where(_matchesFilter).toList();
                  if (filtered.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'No requests yet',
                      message: 'New driver bookings and posted loads show here.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(adminLoadsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) => _LoadAdminCard(filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const labels = ['All', 'Needs driver', 'Book Driver', 'Post Load'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final sel = _filter == i;
          return GestureDetector(
            onTap: () => setState(() => _filter = i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: sel ? AppColors.adminAccent : AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                    color: sel ? Colors.transparent : AppColors.border),
              ),
              child: Text(labels[i],
                  style: AppTextStyles.label.copyWith(
                      color: sel ? Colors.white : AppColors.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}

class _LoadAdminCard extends StatelessWidget {
  final Load load;
  const _LoadAdminCard(this.load);

  bool get _isScheduled => load.scheduledAt != null;

  Color get _statusColor {
    switch (load.status) {
      case 'open':
        return AppColors.warning;
      case 'assigned':
      case 'picked_up':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.destructive;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingBids = load.bids.where((b) => b.status == 'pending').length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill(
                _isScheduled ? 'POST LOAD' : 'BOOK DRIVER',
                _isScheduled ? AppColors.warning : AppColors.vendorAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              _pill(load.status.replaceAll('_', ' ').toUpperCase(), _statusColor),
              const Spacer(),
              if (load.budgetAmount != null)
                Text('₦${load.budgetAmount!.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMd
                        .copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${load.title} • ${load.goodsType}',
              style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (load.equipmentType != null)
                _tag(Icons.local_shipping_outlined, load.equipmentType!),
              if (load.loadRequirement != null)
                _tag(
                    Icons.layers_outlined,
                    load.loadRequirement == 'partial'
                        ? 'Partial Load'
                        : 'Full Load'),
              if (load.weight != null)
                _tag(Icons.scale_outlined, '${load.weight!.toStringAsFixed(0)} kg'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _locRow(Icons.trip_origin_rounded, 'Pickup', load.pickupAddress,
              load.pickupPin, AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          _locRow(Icons.location_on_rounded, 'Drop-off', load.deliveryAddress,
              load.dropoffPin, AppColors.destructive),
          if (_isScheduled) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 15, color: AppColors.textTertiary),
                const SizedBox(width: AppSpacing.sm),
                Text('Scheduled: ${_fmt(load.scheduledAt!)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: AppColors.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  load.clientName ?? 'Customer',
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: pendingBids > 0
                      ? AppColors.success.withOpacity(0.12)
                      : AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('$pendingBids bid${pendingBids == 1 ? '' : 's'}',
                    style: AppTextStyles.caption.copyWith(
                        color: pendingBids > 0
                            ? AppColors.success
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (load.clientPhone != null && load.clientPhone!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => openExternalUrl('tel:${load.clientPhone}'),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: Text('Call customer (${load.clientPhone})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.adminAccent,
                  side: const BorderSide(color: AppColors.adminAccent),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(text,
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w800)),
      );

  Widget _tag(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textTertiary),
          const SizedBox(width: 3),
          Text(text,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      );

  Widget _locRow(IconData icon, String label, String value, String? pin,
      Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label: $value',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              if (pin != null && pin.isNotEmpty)
                GestureDetector(
                  onTap: () => openExternalUrl(_mapsUrl(pin)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop_outlined,
                            size: 13, color: AppColors.info),
                        const SizedBox(width: 3),
                        Text('Open map pin',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _mapsUrl(String pin) {
    final p = pin.trim();
    if (p.startsWith('http')) return p;
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(p)}';
  }

  String _fmt(DateTime d) {
    final local = d.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    final m = local.minute.toString().padLeft(2, '0');
    return '${local.day}/${local.month}/${local.year} • $h:$m $ampm';
  }
}

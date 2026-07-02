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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      load.clientRole == 'admin'
                          ? 'Booked by admin'
                          : (load.clientName ??
                              load.clientEmail ??
                              'Customer'),
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((load.clientRole == 'admin' ||
                            load.clientName != null) &&
                        load.clientEmail != null)
                      Text(
                        load.clientEmail!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
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
          _LoadAdminActions(load),
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

/// Admin actions on a load: assign/re-assign a driver and push status updates.
/// The client and driver are notified live by the backend.
class _LoadAdminActions extends ConsumerStatefulWidget {
  final Load load;
  const _LoadAdminActions(this.load);

  @override
  ConsumerState<_LoadAdminActions> createState() => _LoadAdminActionsState();
}

class _LoadAdminActionsState extends ConsumerState<_LoadAdminActions> {
  bool _busy = false;

  Load get load => widget.load;
  bool get _isCompleted =>
      load.status == 'delivered' || load.status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    final assignedName = load.driverName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assignedName != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_rounded,
                    size: 18, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Driver: $assignedName'
                    '${load.driverVehicle != null ? ' • ${load.driverVehicle}' : ''}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (_busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          )
        else
          Row(
            children: [
              if (!_isCompleted)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openDriverPicker,
                    icon: Icon(
                        assignedName == null
                            ? Icons.person_add_alt_1_rounded
                            : Icons.swap_horiz_rounded,
                        size: 18),
                    label: Text(
                        assignedName == null ? 'Assign driver' : 'Reassign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md)),
                    ),
                  ),
                ),
              if (!_isCompleted) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openStatusPicker,
                  icon: const Icon(Icons.campaign_rounded, size: 18),
                  label: const Text('Update'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.adminAccent,
                    side: const BorderSide(color: AppColors.adminAccent),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _openDriverPicker() async {
    final result = await showModalBottomSheet<({String driverId, double? amount})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _DriverPickerSheet(load: load),
    );
    if (result == null) return;
    await _run(() => ref.read(adminApiProvider).assignDriverToLoad(
          loadId: load.id,
          driverId: result.driverId,
          agreedAmount: result.amount,
        ));
  }

  Future<void> _openStatusPicker() async {
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _StatusPickerSheet(current: load.status),
    );
    if (status == null || status == load.status) return;
    await _run(
        () => ref.read(adminApiProvider).updateLoadStatus(load.id, status));
  }

  /// Runs an admin action with a spinner, refreshes the list, and reports the
  /// outcome via a snackbar.
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(adminLoadsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Load updated — customer notified.'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Bottom sheet listing drivers to assign, with an optional agreed amount.
/// Pops `(driverId, amount)` on selection.
class _DriverPickerSheet extends ConsumerStatefulWidget {
  final Load load;
  const _DriverPickerSheet({required this.load});

  @override
  ConsumerState<_DriverPickerSheet> createState() => _DriverPickerSheetState();
}

class _DriverPickerSheetState extends ConsumerState<_DriverPickerSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.load.agreedAmount?.toStringAsFixed(0) ??
        widget.load.budgetAmount?.toStringAsFixed(0) ??
        '',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(adminUsersProvider('driver'));
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Assign a driver',
              style: AppTextStyles.titleMd
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Agreed amount (₦) — optional',
              prefixText: '₦ ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Flexible(
            child: driversAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Failed to load drivers: $e',
                    style: AppTextStyles.bodySm),
              ),
              data: (drivers) {
                if (drivers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Text('No drivers found.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, i) => _driverTile(drivers[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverTile(Map<String, dynamic> driver) {
    final profile = driver['driver_profile'] as Map<String, dynamic>?;
    final name = profile?['full_name'] as String? ??
        driver['email'] as String? ??
        'Driver';
    final vehicle = profile?['vehicle_type'] as String?;
    final plate = profile?['plate_number'] as String?;
    final approved = profile?['is_approved'] == true;
    final id = driver['id'] as String?;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.adminAccent.withOpacity(0.12),
        child: const Icon(Icons.person_rounded, color: AppColors.adminAccent),
      ),
      title: Text(name,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(
        [
          if (vehicle != null) vehicle,
          if (plate != null) plate,
          if (!approved) 'Not approved',
        ].join(' • '),
        style: AppTextStyles.caption.copyWith(
            color: approved ? AppColors.textTertiary : AppColors.destructive),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: id == null
          ? null
          : () {
              final amt = double.tryParse(_amount.text.trim());
              Navigator.of(context).pop((driverId: id, amount: amt));
            },
    );
  }
}

/// Bottom sheet to pick a new load status. Pops the chosen status string.
class _StatusPickerSheet extends StatelessWidget {
  final String current;
  const _StatusPickerSheet({required this.current});

  static const _options = [
    ('assigned', 'Driver assigned', Icons.assignment_ind_rounded),
    ('picked_up', 'Picked up', Icons.inventory_rounded),
    ('delivered', 'Delivered', Icons.check_circle_rounded),
    ('cancelled', 'Cancelled', Icons.cancel_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Send status update',
                style:
                    AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: AppSpacing.sm),
            Text('The customer is notified instantly.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.md),
            for (final o in _options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(o.$3,
                    color: o.$1 == current
                        ? AppColors.textTertiary
                        : AppColors.adminAccent),
                title: Text(o.$2,
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w700)),
                trailing: o.$1 == current
                    ? Text('Current',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary))
                    : const Icon(Icons.chevron_right_rounded),
                onTap: o.$1 == current
                    ? null
                    : () => Navigator.of(context).pop(o.$1),
              ),
          ],
        ),
      ),
    );
  }
}

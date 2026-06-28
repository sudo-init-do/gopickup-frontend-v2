import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_states.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../models/load_models.dart';
import '../../../state/load_provider.dart';

/// Driver-facing "Book Driver" jobs: open delivery requests to bid on, plus the
/// driver's currently-assigned deliveries which open the live tracking screen.
class DriverLoadsScreen extends ConsumerStatefulWidget {
  const DriverLoadsScreen({super.key});

  @override
  ConsumerState<DriverLoadsScreen> createState() => _DriverLoadsScreenState();
}

class _DriverLoadsScreenState extends ConsumerState<DriverLoadsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
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
        title: const Text('Delivery Requests', style: AppTextStyles.headingMd),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.driverAccent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.driverAccent,
          tabs: const [Tab(text: 'Available'), Tab(text: 'My deliveries')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [_AvailableTab(), _ActiveTab()],
      ),
    );
  }
}

class _AvailableTab extends ConsumerWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(availableLoadsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(availableLoadsProvider),
      child: async.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorState(message: 'Error: $e'),
        data: (loads) {
          if (loads.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No open requests',
                  message: 'New delivery requests will appear here.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: loads.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => _LoadCard(
              load: loads[i],
              onBid: () => _showBidSheet(context, ref, loads[i]),
            ),
          );
        },
      ),
    );
  }

  void _showBidSheet(BuildContext context, WidgetRef ref, Load load) {
    final amountController = TextEditingController(
      text: load.budgetAmount != null
          ? load.budgetAmount!.toStringAsFixed(0)
          : '',
    );
    final noteController = TextEditingController();
    var submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            ),
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Bid on ${load.title}', style: AppTextStyles.headingMd),
                const SizedBox(height: AppSpacing.xs),
                Text('${load.pickupAddress} → ${load.deliveryAddress}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: AppSpacing.xl),
                Text('Your price (₦)',
                    style:
                        AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: _dec('e.g. 5000'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Note (optional)',
                    style:
                        AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: _dec('e.g. I can be there in 15 mins'),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Send offer',
                  color: AppColors.driverAccent,
                  isLoading: submitting,
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount')),
                      );
                      return;
                    }
                    setSheet(() => submitting = true);
                    try {
                      await ref.read(loadsApiProvider).placeBid(
                            load.id,
                            amount,
                            note: noteController.text.trim(),
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.invalidate(availableLoadsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offer sent!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      setSheet(() => submitting = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(e
                                  .toString()
                                  .replaceFirst('Exception: ', ''))),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );
}

class _ActiveTab extends ConsumerWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(assignedLoadsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(assignedLoadsProvider),
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
                  title: 'No active deliveries',
                  message: 'Accepted deliveries you can track will appear here.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: loads.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => _LoadCard(
              load: loads[i],
              actionLabel: 'Open & share location',
              onBid: () => context.push('/driver/load/${loads[i].id}/track'),
            ),
          );
        },
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  final Load load;
  final VoidCallback onBid;
  final String actionLabel;
  const _LoadCard({
    required this.load,
    required this.onBid,
    this.actionLabel = 'Send offer',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.driverAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.driverAccent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(load.title,
                        style: AppTextStyles.titleMd
                            .copyWith(fontWeight: FontWeight.w800)),
                    if (load.weight != null)
                      Text('${load.weight!.toStringAsFixed(0)} kg',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (load.budgetAmount != null)
                Text('₦${load.budgetAmount!.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.driverAccent)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _row(Icons.trip_origin_rounded, load.pickupAddress, AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          _row(Icons.location_on_rounded, load.deliveryAddress,
              AppColors.destructive),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBid,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.driverAccent,
                side: const BorderSide(color: AppColors.driverAccent),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

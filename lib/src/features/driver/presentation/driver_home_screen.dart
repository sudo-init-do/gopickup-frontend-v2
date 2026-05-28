import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/utils/launch_url.dart';
import '../../driver/data/job_repository.dart';
import '../../../common/models/order.dart' as common_order;
import '../../../models/order_models.dart';
import '../../../state/order_provider.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/config/app_config.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/primary_button.dart';
import '../../../common/widgets/app_card.dart';
import '../../../common/widgets/app_states.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = true;
  int _selectedTabIndex = 0;

  Future<void> _launchWhatsApp(String orderId, [String? customUrl]) async {
    final url = customUrl ??
        AppConfig.supportWhatsappUrl(
          'Hello, I am agreeing to the delivery for Order #$orderId',
        );
    final ok = await openExternalUrl(url);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  void _showAcceptJobDialog(common_order.Order job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
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
            const Text('Accept Assignment', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Assignment ID: ${job.shortId}',
              style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildDialogSection('VENDOR', job.items.isNotEmpty ? job.items.first.product.vendorName : 'Go-Market', Icons.storefront_rounded),
            const SizedBox(height: AppSpacing.xl),
            _buildDialogSection('AGREED PRICE', '₦${job.total.toStringAsFixed(2)}', Icons.payments_outlined),
            const SizedBox(height: AppSpacing.xl),
            _buildDialogSection('PAYMENT METHOD', 'Wallet (Prepaid)', Icons.wallet_rounded),
            const Spacer(),
            PrimaryButton(
              label: 'Negotiate Price on WhatsApp',
              onPressed: () => _launchWhatsApp(job.id),
              color: AppColors.whatsapp,
              icon: Icons.chat_bubble_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: 'Accept Assignment in App',
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                final (success, error) = await ref.read(jobRepositoryProvider).acceptJob(job.id);

                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  Navigator.pop(context); // Close sheet

                  if (success) {
                    ref.invalidate(assignedJobsProvider);
                    ref.invalidate(driverOrdersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job accepted successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ErrorHandler.getMessage(error)),
                        backgroundColor: AppColors.destructive,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Portal',
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                      ),
                      const Text(
                        'GoPickup Delivery',
                        style: AppTextStyles.headingLg,
                      ),
                    ],
                  ),
                  _buildStatusToggle(),
                ],
              ),
            ),
            _buildSearchAndFilter(),
            _buildTabs(_selectedTabIndex, (index) {
              setState(() => _selectedTabIndex = index);
            }),
            Expanded(
              child: _buildJobList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: _isOnline ? AppColors.success.withOpacity(0.12) : AppColors.destructive.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: _isOnline ? AppColors.success.withOpacity(0.2) : AppColors.destructive.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.success : AppColors.destructive,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: _isOnline ? const Color(0xFF166534) : const Color(0xFF991B1B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogSection(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
              Text(value, style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(int selectedIndex, Function(int) onSelect) {
    final tabs = ['New Jobs', 'Active', 'History'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : AppSpacing.sm,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.driverAccent : AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: AppTextStyles.label.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildJobList() {
    if (_selectedTabIndex == 0) {
      return _buildNewAssignmentsList();
    }
    if (_selectedTabIndex == 1) {
      return _buildActiveTasksList();
    }
    return _buildHistoryJobList();
  }

  Widget _buildNewAssignmentsList() {
    final assignedJobsAsync = ref.watch(assignedJobsProvider);

    return assignedJobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return const AppEmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'No new assignments',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return GestureDetector(
              onTap: () => _showAcceptJobDialog(job),
              child: _buildJobCard(job),
            );
          },
        );
      },
      loading: () => const AppLoading(),
      error: (err, stack) => AppErrorState(message: 'Error: $err'),
    );
  }

  Widget _buildActiveTasksList() {
    final driverOrdersAsync = ref.watch(driverOrdersProvider);

    return driverOrdersAsync.when(
      data: (orders) {
        final activeJobs = orders
            .where((o) =>
                o.status == 'in_progress' ||
                o.status == 'picked_up' ||
                o.status == 'on_the_way')
            .toList();

        if (activeJobs.isEmpty) {
          return const AppEmptyState(
            icon: Icons.assignment_outlined,
            title: 'No active tasks',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
          itemCount: activeJobs.length,
          itemBuilder: (context, index) {
            final job = activeJobs[index];
            return _buildAssignedOrderCard(job);
          },
        );
      },
      loading: () => const AppLoading(),
      error: (err, stack) => const AppErrorState(message: 'Error loading tasks'),
    );
  }

  Widget _buildHistoryJobList() {
    final driverOrdersAsync = ref.watch(driverOrdersProvider);

    return driverOrdersAsync.when(
      data: (orders) {
        final historyJobs =
            orders
                .where(
                  (o) => o.status == 'delivered' || o.status == 'cancelled',
                )
                .toList();

        if (historyJobs.isEmpty) {
          return const AppEmptyState(
            icon: Icons.history_rounded,
            title: 'No history yet',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
          itemCount: historyJobs.length,
          itemBuilder: (context, index) {
            final job = historyJobs[index];
            return _buildHistoryOrderCard(job);
          },
        );
      },
      loading: () => const AppLoading(),
      error: (err, stack) => const AppErrorState(message: 'Failed to load history'),
    );
  }

  Widget _buildAssignedOrderCard(Order job) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.items.isNotEmpty ? job.items.first.name ?? 'Load' : 'Task',
                      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.status.toUpperCase(),
                      style: AppTextStyles.label.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Text(
                '₦${job.totalProductAmount.toStringAsFixed(0)}',
                style: AppTextStyles.headingMd.copyWith(color: AppColors.success, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.backgroundSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Pickup: ', style: AppTextStyles.body),
                  Text(
                    job.createdAt.toString().split(' ').first,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              PrimaryButton(
                label: 'Dashboard',
                onPressed: () {},
                expanded: false,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryOrderCard(Order job) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.textTertiary, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.items.isNotEmpty ? job.items.first.name ?? 'Delivery' : 'Completed',
                      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.createdAt.toString().split(' ').first,
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  job.status,
                  style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.backgroundSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₦${job.totalProductAmount.toStringAsFixed(0)}',
                style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View Details',
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(common_order.Order job) {
    // For title, use the first product name or a generic title
    final title =
        job.items.isNotEmpty ? job.items.first.product.name : 'Bulk Delivery';
    final from =
        job.items.isNotEmpty
            ? job.items.first.product.vendorName
            : 'Vendor Depot';
    final to =
        job.id.length > 8
            ? job.id.substring(0, 8)
            : job.id; // Just a placeholder for destination address for now

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.driverAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.driverAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.shortId,
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLocationRow(
            Icons.location_on_outlined,
            'From:',
            from,
            AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLocationRow(Icons.location_on, 'To:', 'Near $to', AppColors.destructive),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.backgroundSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job.items.length} items',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text(
                    '₦${job.total.toStringAsFixed(2)}',
                    style: AppTextStyles.headingMd.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: job.status == common_order.OrderStatus.assigned ? AppColors.info.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  job.status == common_order.OrderStatus.assigned ? 'Assigned to You' : 'Available',
                  style: AppTextStyles.caption.copyWith(
                    color: job.status == common_order.OrderStatus.assigned ? AppColors.info : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchWhatsApp(job.id, job.whatsappUrl),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Negotiate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.whatsapp,
                    side: const BorderSide(color: AppColors.whatsapp),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'I Accept',
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    final (success, error) = await ref.read(jobRepositoryProvider).acceptJob(job.id);

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading

                      if (success) {
                        ref.invalidate(assignedJobsProvider);
                        ref.invalidate(driverOrdersProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job accepted successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHandler.getMessage(error)),
                            backgroundColor: AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

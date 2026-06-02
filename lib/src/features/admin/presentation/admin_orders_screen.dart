import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/utils/launch_url.dart';
import '../../../models/order_models.dart';
import 'admin_providers.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';
import '../../../common/widgets/app_card.dart';
import '../../../common/widgets/app_states.dart';
import '../../../common/widgets/primary_button.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedTab = 'All Orders';
  final _searchController = TextEditingController();

  List<Order> _getFilteredOrders(List<Order> orders) {
    var filtered = orders;

    // Tab filter
    if (_selectedTab == 'Pending') {
      filtered = filtered.where((o) => o.status == 'pending' || o.status == 'awaiting_payment' || o.status == 'payment_made').toList();
    } else if (_selectedTab == 'Active') {
      filtered = filtered.where((o) => !['pending', 'awaiting_payment', 'payment_made', 'delivered', 'cancelled'].contains(o.status)).toList();
    } else if (_selectedTab == 'Completed') {
      filtered = filtered.where((o) => o.status == 'delivered').toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((o) => o.id.toLowerCase().contains(query) || o.clientId.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN CONSOLE',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Orders Monitoring', style: AppTextStyles.titleMd),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: AppColors.textPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: AppColors.textPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _buildTab('All Orders'),
                const SizedBox(width: AppSpacing.sm),
                _buildTab('Pending'),
                const SizedBox(width: AppSpacing.sm),
                _buildTab('Active'),
                const SizedBox(width: AppSpacing.sm),
                _buildTab('Completed'),
                const SizedBox(width: AppSpacing.sm),
                _buildTab('Signups'),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search ID, Customer...',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.borderStrong),
                  ),
                  child: const Icon(Icons.calendar_today, size: 18, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Live Feed Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LIVE FEED',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                ordersAsync.whenData((orders) => Text(
                  '${orders.length} Active Transmissions',
                  style: AppTextStyles.caption,
                )).value ?? const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Order List
          Expanded(
            child: _selectedTab == 'Signups'
                ? _buildRecentSignups(context)
                : ordersAsync.when(
                    data: (orders) {
                      final filtered = _getFilteredOrders(orders);
                      if (filtered.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No orders found',
                          message: 'Try adjusting your tab or search query.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) => _OrderCard(
                          order: filtered[index],
                          onTap: () => _showFocusedView(context, filtered[index]),
                        ),
                      );
                    },
                    loading: () => const AppLoading(),
                    error: (e, stack) => AppErrorState(message: 'Error: $e'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isActive = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.adminAccent : AppColors.backgroundSubtle,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySm.copyWith(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _signupDisplayName(Map<String, dynamic> user) {
    final name = (user['full_name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = (user['email'] as String?) ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'New user';
  }

  Widget _buildRecentSignups(BuildContext context) {
    final recentUsersAsync = ref.watch(adminRecentUsersProvider);

    return recentUsersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const AppEmptyState(
            icon: Icons.person_add_outlined,
            title: 'No recent signups',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final user = users[index];
            final joinedDate = user['created_at'] != null
                ? DateFormat('MMM d, h:mm a').format(DateTime.parse(user['created_at']))
                : 'Unknown';

            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _signupDisplayName(user),
                        style: AppTextStyles.titleMd,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          (user['role'] ?? 'Client').toString().toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _signupInfo(Icons.email_outlined, user['email'] ?? 'No email'),
                  _signupInfo(
                    Icons.phone_outlined,
                    (user['vendor_profile']?['phone_number'] ??
                            user['client_profile']?['phone_number'] ??
                            user['driver_profile']?['phone_number'] ??
                            user['phone_number'] ??
                            'No phone')
                        .toString(),
                  ),
                  _signupInfo(
                    Icons.location_on_outlined,
                    (user['vendor_profile']?['address'] ??
                            user['client_profile']?['address'] ??
                            user['driver_profile']?['address'] ??
                            'No address')
                        .toString(),
                  ),
                  const Divider(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Joined $joinedDate', style: AppTextStyles.caption),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textTertiary),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const AppLoading(),
      error: (e, stack) => AppErrorState(message: 'Error: $e'),
    );
  }

  Widget _signupInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }

  void _showFocusedView(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FocusedView(order: order, ref: ref),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete order?'),
        content: Text(
          'Permanently delete order ORD-${order.shortId.toUpperCase()}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(adminApiProvider).deleteOrder(order.id);
      ref.invalidate(adminOrdersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Order deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate type based on items count for UI matching
    final isLogistics = order.items.isEmpty || order.vendorId.isEmpty;

    // Convert status to visual group
    String statusLabel = 'Pending';
    Color statusColor = AppColors.info;
    Color statusBgColor = AppColors.info.withOpacity(0.1);

    if (order.status == 'delivered') {
      statusLabel = 'Completed';
      statusColor = AppColors.textPrimary;
      statusBgColor = AppColors.backgroundSubtle;
    } else if (order.status == 'pending' || order.status == 'awaiting_payment' || order.status == 'payment_made') {
      statusLabel = order.status == 'payment_made' ? 'Verification' : 'Pending';
      statusColor = order.status == 'payment_made' ? AppColors.warning : AppColors.adminAccent;
      statusBgColor = order.status == 'payment_made'
          ? AppColors.warning.withOpacity(0.1)
          : AppColors.adminAccent.withOpacity(0.1);
    } else {
      statusLabel = 'Active';
      statusColor = AppColors.success;
      statusBgColor = AppColors.success.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogistics
                        ? AppColors.adminAccent.withOpacity(0.1)
                        : AppColors.driverAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isLogistics ? Icons.local_shipping : Icons.storefront,
                    color: isLogistics ? AppColors.adminAccent : AppColors.driverAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORD-${order.shortId.toUpperCase()}',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLogistics ? 'Logistics' : 'Marketplace',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text('Placed recent', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm - 2),
                    Text(
                      '₦${(order.totalProductAmount + (order.agreedDeliveryFee ?? 0)).toStringAsFixed(2)}',
                      style: AppTextStyles.label,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppColors.textTertiary, size: 20),
                      padding: EdgeInsets.zero,
                      onSelected: (v) {
                        if (v == 'delete') _confirmAndDelete(context, ref);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: AppColors.destructive, size: 20),
                              SizedBox(width: AppSpacing.sm),
                              Text('Delete order'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      order.clientName ?? order.clientEmail ?? order.shortClientId,
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: 100,
                      child: Text(
                        order.deliveryAddress,
                        style: AppTextStyles.bodySm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusedView extends StatelessWidget {
  final Order order;
  final WidgetRef ref;

  const _FocusedView({required this.order, required this.ref});

  void _showManageOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ManageOrderDialog(order: order, ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final isPickedUp = ['picked_up', 'on_the_way', 'delivered'].contains(status);
    final isOut = ['on_the_way', 'delivered'].contains(status);
    final isDelivered = status == 'delivered';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FOCUSED VIEW',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.adminAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Order #${order.shortId.toUpperCase()}',
                              style: AppTextStyles.headingMd,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Map Graphic Header
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.teal.shade700,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(Icons.public, size: 160, color: Colors.white.withOpacity(0.2)),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.adminAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                          ),
                        ),
                        Positioned(
                          bottom: AppSpacing.lg,
                          right: AppSpacing.lg,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm - 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                                const SizedBox(width: AppSpacing.sm - 2),
                                Text(
                                  'Live Tracking',
                                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY TIMELINE',
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        const _TimelineItem(
                          isCompleted: true,
                          isLast: false,
                          title: 'Placed',
                          desc: 'Order received',
                        ),
                        _TimelineItem(
                          isCompleted: isPickedUp,
                          isLast: false,
                          isActive: !isPickedUp,
                          title: 'Picked Up',
                          desc: 'Driver acquired package',
                        ),
                        _TimelineItem(
                          isCompleted: isOut,
                          isLast: false,
                          isActive: isPickedUp && !isOut,
                          title: 'Out for Delivery',
                          desc: 'Expected soon',
                        ),
                        _TimelineItem(
                          isCompleted: isDelivered,
                          isLast: true,
                          title: 'Delivered',
                          desc: isDelivered ? 'Completed' : 'Pending arrival',
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'CUSTOMER DETAILS',
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // --- Client Card ---
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: AppColors.info, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.clientName ?? order.clientEmail ?? 'Client #${order.shortClientId}',
                                      style: AppTextStyles.label,
                                    ),
                                    if (order.clientPhone != null)
                                      Text(order.clientPhone!, style: AppTextStyles.bodySm)
                                    else if (order.clientEmail != null)
                                      Text(order.clientEmail!, style: AppTextStyles.bodySm),
                                  ],
                                ),
                              ),
                              if (order.clientPhone != null)
                                GestureDetector(
                                  onTap: () => openExternalUrl('tel:${order.clientPhone}'),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: const Icon(Icons.call, size: 16, color: AppColors.success),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: const Icon(Icons.message, size: 16, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // --- Vendor Card ---
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.storefront, color: AppColors.success, size: 20),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.vendorStoreName ?? 'Vendor #${order.shortVendorId}',
                                      style: AppTextStyles.label,
                                    ),
                                    if (order.vendorPhone != null)
                                      Text(order.vendorPhone!, style: AppTextStyles.bodySm)
                                    else
                                      const Text('No contact available', style: AppTextStyles.bodySm),
                                  ],
                                ),
                              ),
                              if (order.vendorPhone != null)
                                GestureDetector(
                                  onTap: () => openExternalUrl('tel:${order.vendorPhone}'),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: const Icon(Icons.call, size: 16, color: AppColors.success),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: 'Manage Order / Update Status',
                          onPressed: () => _showManageOrderDialog(context),
                          icon: Icons.settings,
                          color: AppColors.adminAccent,
                        ),
                        const SizedBox(height: AppSpacing.xxxl + AppSpacing.sm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final String title;
  final String desc;

  const _TimelineItem({
    required this.isCompleted,
    this.isActive = false,
    required this.isLast,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.adminAccent
                      : (isActive ? AppColors.card : AppColors.backgroundSubtle),
                  border: isActive ? Border.all(color: AppColors.adminAccent, width: 2) : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isActive
                        ? const Center(child: CircleAvatar(radius: 4, backgroundColor: AppColors.adminAccent))
                        : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.adminAccent : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: isCompleted || isActive ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    desc,
                    style: AppTextStyles.bodySm.copyWith(
                      color: isCompleted || isActive ? AppColors.adminAccent : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Preserve existing Manager Dialog
class _ManageOrderDialog extends StatefulWidget {
  final Order order;
  final WidgetRef ref;
  const _ManageOrderDialog({required this.order, required this.ref});

  @override
  State<_ManageOrderDialog> createState() => _ManageOrderDialogState();
}

class _ManageOrderDialogState extends State<_ManageOrderDialog> {
  String? _selectedDriverId;
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController.text = (widget.order.agreedPrice ?? 0).toString();
    _feeController.text = (widget.order.agreedDeliveryFee ?? 0).toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = widget.ref.watch(adminUsersProvider('driver'));
    final order = widget.order;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl + 4)),
      backgroundColor: AppColors.card,
      elevation: 24,
      child: Container(
        width: 450,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANAGE ORDER',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.adminAccent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Order #${order.shortId.toUpperCase()}',
                          style: AppTextStyles.headingMd,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.status == 'payment_made') ...[
                      _sectionHeader('PAYMENT VERIFICATION'),
                      const SizedBox(height: AppSpacing.lg),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Verify Agreed Price (₦)',
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _primaryButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_priceController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter agreed price')));
                                  return;
                                }
                                setState(() => _isLoading = true);
                                try {
                                  await widget.ref.read(adminApiProvider).verifyPayment(
                                    orderId: order.id,
                                    agreedPrice: double.parse(_priceController.text),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    widget.ref.invalidate(adminOrdersProvider);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                        label: 'Verify & Approve Payment',
                        color: AppColors.adminAccent,
                        icon: Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    if (order.status == 'awaiting_payment') ...[
                      _sectionHeader('MANUAL PAYMENT STATUS'),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Waiting for client to report payment via WhatsApp.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF92400E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    if (order.status == 'pending' ||
                        order.status == 'processing' ||
                        order.status == 'awaiting_payment' ||
                        order.status == 'payment_made') ...[
                      _sectionHeader('LOGISTICS ASSIGNMENT'),
                      const SizedBox(height: AppSpacing.lg),
                      driversAsync.when(
                        data: (drivers) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Logistics Driver',
                                labelStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                              items: drivers
                                  .map((d) => DropdownMenuItem(
                                        value: d['id'] as String,
                                        child: Text(
                                          d['full_name'] ?? d['email'] ?? 'Driver',
                                          style: AppTextStyles.body,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedDriverId = val),
                              value: _selectedDriverId,
                            ),
                          ),
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.adminAccent,
                            ),
                          ),
                        ),
                        error: (e, s) => Text(
                          'Error loading drivers',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.destructive),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Item Price (₦)',
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTextField(
                              controller: _feeController,
                              label: 'Delivery Fee (₦)',
                              icon: Icons.local_shipping_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _primaryButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_selectedDriverId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please select a driver')));
                                  return;
                                }
                                setState(() => _isLoading = true);
                                try {
                                  await widget.ref.read(adminApiProvider).assignDriver(
                                        orderId: order.id,
                                        driverId: _selectedDriverId!,
                                        agreedPrice: double.parse(_priceController.text),
                                        deliveryFee: double.parse(_feeController.text),
                                      );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    widget.ref.invalidate(adminOrdersProvider);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              },
                        label: 'Update & Assign Driver',
                        color: AppColors.success,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ] else if (order.status != 'delivered' && order.status != 'cancelled') ...[
                      _sectionHeader('STATUS SHIPMENT CONTROL'),
                      const SizedBox(height: AppSpacing.lg),
                      _statusButton('picked_up', 'Confirm Picked Up', Icons.inventory),
                      const SizedBox(height: AppSpacing.md),
                      _statusButton('on_the_way', 'Set as In Transit', Icons.local_shipping),
                      const SizedBox(height: AppSpacing.md),
                      _statusButton('delivered', 'Mark as Delivered', Icons.done_all,
                          color: AppColors.adminAccent),
                    ] else ...[
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(height: AppSpacing.xl),
                            Icon(Icons.check_circle, size: 64, color: AppColors.success),
                            SizedBox(height: AppSpacing.lg),
                            Text('Order Finalized', style: AppTextStyles.headingMd),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'This order is completed and archived.',
                              style: AppTextStyles.bodySm,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        cursorColor: AppColors.adminAccent,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppColors.adminAccent.withOpacity(0.7)),
          labelText: label,
          labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _primaryButton({
    required VoidCallback? onPressed,
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        overlayColor: Colors.white.withOpacity(0.1),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.sm)],
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ],
            ),
    );
  }

  Widget _statusButton(String status, String label, IconData icon, {Color? color}) {
    return OutlinedButton(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await widget.ref.read(adminApiProvider).updateOrderStatus(widget.order.id, status);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  widget.ref.invalidate(adminOrdersProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.textPrimary,
        side: BorderSide(
          color: color?.withOpacity(0.3) ?? AppColors.borderStrong,
          width: 1.5,
        ),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: AppTextStyles.label.copyWith(color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

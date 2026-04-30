import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../driver/data/job_repository.dart';
import '../../../common/models/order.dart' as common_order;
import '../../../models/order_models.dart';
import '../../../state/order_provider.dart';
import '../../../common/utils/error_handler.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = true;
  int _selectedTabIndex = 0;

  Future<void> _launchWhatsApp(String orderId, [String? customUrl]) async {
    if (customUrl != null && await canLaunchUrl(Uri.parse(customUrl))) {
      await launchUrl(Uri.parse(customUrl), mode: LaunchMode.externalApplication);
      return;
    }
    const phone = "2348087042206"; // Admin Support
    final message = "Hello, I am agreeing to the delivery for Order #$orderId";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Accept Assignment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              'Assignment ID: ${job.shortId}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildDialogSection('VENDOR', job.items.isNotEmpty ? job.items.first.product.vendorName : 'Go-Market', Icons.storefront_rounded),
            const SizedBox(height: 24),
            _buildDialogSection('AGREED PRICE', '₦${job.total.toStringAsFixed(2)}', Icons.payments_outlined),
            const SizedBox(height: 24),
            _buildDialogSection('PAYMENT METHOD', 'Wallet (Prepaid)', Icons.wallet_rounded),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _launchWhatsApp(job.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.chat_bubble_outline_rounded),
                   SizedBox(width: 12),
                   Text('Negotiate Price on WhatsApp', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Show loading
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
                        backgroundColor: Color(0xFF388E3C),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ErrorHandler.getMessage(error)),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Accept Assignment in App', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF97316);
    const darkText = Color(0xFF111827);
    const midText = Color(0xFF64748B);
    const green = Color(0xFF388E3C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driver Portal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: midText),
                      ),
                      const Text(
                        'GoPickup Delivery',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: darkText),
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
            }, orange),
            Expanded(
              child: _buildJobList(darkText, midText, orange, green),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isOnline ? const Color(0xFF22C55E).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 13,
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
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(int selectedIndex, Function(int) onSelect, Color orange) {
    final tabs = ['New Jobs', 'Active', 'History'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index == tabs.length - 1 ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? orange : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  Widget _buildJobList(
    Color darkText,
    Color midText,
    Color orange,
    Color green,
  ) {
    if (_selectedTabIndex == 0)
      return _buildNewAssignmentsList(darkText, midText, orange, green);
    if (_selectedTabIndex == 1)
      return _buildActiveTasksList(darkText, midText, orange, green);
    return _buildHistoryJobList(darkText, midText, orange, green);
  }

  Widget _buildNewAssignmentsList(
    Color darkText,
    Color midText,
    Color orange,
    Color green,
  ) {
    // These are jobs with status 'assigned' but not yet 'in_progress'
    final assignedJobsAsync = ref.watch(assignedJobsProvider);

    return assignedJobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: midText.withOpacity( 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No new assignments',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return GestureDetector(
              onTap: () => _showAcceptJobDialog(job),
              child: _buildJobCard(job, darkText, midText, orange, green),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildActiveTasksList(
    Color darkText,
    Color midText,
    Color orange,
    Color green,
  ) {
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: midText.withOpacity( 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No active tasks',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: activeJobs.length,
          itemBuilder: (context, index) {
            final job = activeJobs[index];
            return _buildAssignedOrderCard(job, darkText, midText, green);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading tasks')),
    );
  }

  Widget _buildHistoryJobList(
    Color darkText,
    Color midText,
    Color orange,
    Color green,
  ) {
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: midText.withOpacity( 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No history yet',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: historyJobs.length,
          itemBuilder: (context, index) {
            final job = historyJobs[index];
            return _buildHistoryOrderCard(job, darkText, midText, green);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Failed to load history')),
    );
  }

  Widget _buildHistoryJobCard(
    Map<String, dynamic> job,
    Color darkText,
    Color midText,
    Color green,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: midText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: green.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job['price'],
                style: TextStyle(
                  fontSize: 20,
                  color: darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View Receipt',
                  style: TextStyle(
                    color: midText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedOrderCard(
    Order job,
    Color darkText,
    Color midText,
    Color green,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: green.withOpacity( 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_shipping_outlined, color: green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.items.isNotEmpty ? job.items.first.name ?? 'Load' : 'Task',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₦\${job.totalProductAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  color: green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pickup: ',
                    style: TextStyle(
                      color: midText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    job.createdAt.toString().split(' ').first,
                    style: TextStyle(
                      color: darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryOrderCard(
    Order job,
    Color darkText,
    Color midText,
    Color green,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.items.isNotEmpty ? job.items.first.name ?? 'Delivery' : 'Completed',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.createdAt.toString().split(' ').first,
                      style: TextStyle(
                        fontSize: 14,
                        color: midText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: green.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₦\${job.totalProductAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  color: darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: midText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    common_order.Order job,
    Color darkText,
    Color midText,
    Color orange,
    Color green,
  ) {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orange.withOpacity( 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.shortId,
                      style: TextStyle(
                        fontSize: 14,
                        color: midText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLocationRow(
            Icons.location_on_outlined,
            'From:',
            from,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on, 'To:', 'Near $to', Colors.red),
          const SizedBox(height: 20),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job.items.length} items',
                style: TextStyle(
                  color: midText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '₦${job.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: darkText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: midText, size: 24),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status == 'assigned' ? Colors.blue.withOpacity( 0.1) : Colors.green.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status == 'assigned' ? 'Assigned to You' : 'Available',
                  style: TextStyle(
                    color: job.status == 'assigned' ? Colors.blue : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchWhatsApp(job.id, job.whatsappUrl),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Negotiate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Show loading
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
                            backgroundColor: Color(0xFF388E3C),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ErrorHandler.getMessage(error)),
                            backgroundColor: Colors.red.shade800,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('I Accept', style: TextStyle(fontWeight: FontWeight.w800)),
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
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

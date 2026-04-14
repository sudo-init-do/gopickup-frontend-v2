import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/order_models.dart';
import 'admin_providers.dart';

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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADMIN CONSOLE', style: TextStyle(fontSize: 10, fontWeight: 
FontWeight.bold, letterSpacing: 1.2, color: Colors.grey.shade600)),
            const Text('Orders Monitoring', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTab('All Orders'),
                const SizedBox(width: 8),
                _buildTab('Pending'),
                const SizedBox(width: 8),
                _buildTab('Active'),
                const SizedBox(width: 8),
                _buildTab('Completed'),
                const SizedBox(width: 8),
                _buildTab('Signups'),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search ID, Customer...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.calendar_today, size: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Live Feed Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('LIVE FEED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                ordersAsync.whenData((orders) => Text('${orders.length} Active Transmissions', style: TextStyle(fontSize: 10, color: Colors.grey.shade500))).value ?? const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Order List
          Expanded(
            child: _selectedTab == 'Signups'
                ? _buildRecentSignups(context)
                : ordersAsync.when(
                    data: (orders) {
                      final filtered = _getFilteredOrders(orders);
                      if (filtered.isEmpty) return const Center(child: Text('No orders found'));

                      return ListView.separated(
                        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _OrderCard(
                          order: filtered[index],
                          onTap: () => _showFocusedView(context, filtered[index]),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, stack) => Center(child: Text('Error: $e')),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSignups(BuildContext context) {
    final recentUsersAsync = ref.watch(adminRecentUsersProvider);

    return recentUsersAsync.when(
      data: (users) {
        if (users.isEmpty) return const Center(child: Text('No recent signups'));

        return ListView.separated(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            final joinedDate = user['created_at'] != null 
                ? DateFormat('MMM d, h:mm a').format(DateTime.parse(user['created_at']))
                : 'Unknown';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user['full_name'] ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (user['role'] ?? 'Client').toString().toUpperCase(),
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _signupInfo(Icons.email_outlined, user['email'] ?? 'No email'),
                  _signupInfo(Icons.phone_outlined, user['phone_number'] ?? 'No phone'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Joined $joinedDate', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(child: Text('Error: $e')),
    );
  }

  Widget _signupInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generate type based on items count for UI matching
    final isLogistics = order.items.isEmpty || order.vendorId.isEmpty;
    
    // Convert status to visual group
    String statusLabel = 'Pending';
    Color statusColor = Colors.blue;
    Color statusBgColor = Colors.blue.shade50;
    
    if (order.status == 'delivered') {
      statusLabel = 'Completed';
      statusColor = Colors.black87;
      statusBgColor = Colors.grey.shade100;
    } else if (order.status == 'pending' || order.status == 'awaiting_payment' || order.status == 'payment_made') {
      statusLabel = order.status == 'payment_made' ? 'Verification' : 'Pending';
      statusColor = order.status == 'payment_made' ? Colors.orange.shade800 : Colors.blueAccent;
      statusBgColor = order.status == 'payment_made' ? Colors.orange.shade50 : Colors.blue.shade50;
    } else {
      statusLabel = 'Active';
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLogistics ? Colors.indigo.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLogistics ? Icons.local_shipping : Icons.storefront,
                    color: isLogistics ? Colors.indigo : Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORD-${order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLogistics ? 'Logistics' : 'Marketplace',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Placed recent', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${(order.totalProductAmount + (order.agreedDeliveryFee ?? 0)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(order.clientId.substring(0, 8), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 100,
                      child: Text(
                        order.deliveryAddress,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FOCUSED VIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${order.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 3, backgroundColor: Colors.green.shade600),
                                const SizedBox(width: 6),
                                const Text('Live Tracking', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DELIVERY TIMELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 24),
                        
                        _TimelineItem(
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

                        const SizedBox(height: 32),
                        const Text('CUSTOMER DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                child: Icon(Icons.person, color: Colors.blue.shade600, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Client: ${order.clientId.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Text('Contact provided', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.message, size: 16, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showManageOrderDialog(context),
                            icon: const Icon(Icons.settings),
                            label: const Text('Manage Order / Update Status'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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
                  color: isCompleted ? Colors.blueAccent : (isActive ? Colors.white : Colors.grey.shade200),
                  border: isActive ? Border.all(color: Colors.blueAccent, width: 2) : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isActive ? Center(child: CircleAvatar(radius: 4, backgroundColor: Colors.blueAccent)) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: isCompleted ? Colors.blueAccent : Colors.grey.shade200),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCompleted || isActive ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted || isActive ? Colors.blueAccent : Colors.grey.shade400,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      elevation: 24,
      child: Container(
        width: 450,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANAGE ORDER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.status == 'payment_made') ...[
                      _sectionHeader('PAYMENT VERIFICATION'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Verify Agreed Price (₦)',
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 20),
                      _primaryButton(
                        onPressed: _isLoading ? null : () async {
                          if (_priceController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter agreed price')));
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
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        label: 'Verify & Approve Payment',
                        color: Colors.blueAccent,
                        icon: Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (order.status == 'awaiting_payment') ...[
                      _sectionHeader('MANUAL PAYMENT STATUS'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Waiting for client to report payment via WhatsApp.',
                                style: TextStyle(fontSize: 13, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (order.status == 'pending' || order.status == 'processing' || order.status == 'awaiting_payment' || order.status == 'payment_made') ...[
                      _sectionHeader('LOGISTICS ASSIGNMENT'),
                      const SizedBox(height: 16),
                      driversAsync.when(
                        data: (drivers) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Select Logistics Driver',
                                labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              items: drivers.map((d) => DropdownMenuItem(
                                value: d['id'] as String,
                                child: Text(d['full_name'] ?? d['email'] ?? 'Driver', style: const TextStyle(fontSize: 15)),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedDriverId = val),
                              value: _selectedDriverId,
                            ),
                          ),
                        ),
                        loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2))),
                        error: (e, s) => Text('Error loading drivers', style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Item Price (₦)',
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _feeController,
                              label: 'Delivery Fee (₦)',
                              icon: Icons.local_shipping_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _primaryButton(
                        onPressed: _isLoading ? null : () async {
                          if (_selectedDriverId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a driver')));
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
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        label: 'Update & Assign Driver',
                        color: const Color(0xFF388E3C),
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(height: 32),
                    ] else if (order.status != 'delivered' && order.status != 'cancelled') ...[
                      _sectionHeader('STATUS SHIPMENT CONTROL'),
                      const SizedBox(height: 16),
                      _statusButton('picked_up', 'Confirm Picked Up', Icons.inventory),
                      const SizedBox(height: 12),
                      _statusButton('on_the_way', 'Set as In Transit', Icons.local_shipping),
                      const SizedBox(height: 12),
                      _statusButton('delivered', 'Mark as Delivered', Icons.done_all, color: Colors.blue.shade700),
                    ] else ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
                            const SizedBox(height: 16),
                            const Text('Order Finalized', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('This order is completed and archived.', style: TextStyle(color: Colors.grey)),
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
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.blueAccent,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent.shade200),
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _primaryButton({required VoidCallback? onPressed, required String label, required Color color, IconData? icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        overlayColor: Colors.white.withOpacity(0.1),
      ),
      child: _isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
    );
  }

  Widget _statusButton(String status, String label, IconData icon, {Color? color}) {
    return OutlinedButton(
      onPressed: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        try {
          await widget.ref.read(adminApiProvider).updateOrderStatus(widget.order.id, status);
          if (context.mounted) {
             Navigator.pop(context);
             Navigator.pop(context);
             widget.ref.invalidate(adminOrdersProvider);
          }
        } catch (e) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
          setState(() => _isLoading = false);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? Colors.black87,
        side: BorderSide(color: color?.withOpacity(0.3) ?? Colors.grey.shade300, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

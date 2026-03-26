import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/order_models.dart';
import 'admin_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final padding = isMobile ? 16.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Monitoring',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: isMobile ? 22 : null,
                  ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ordersAsync.when(
                data: (orders) {
                  if (orders.isEmpty) return _buildEmptyState();
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) => _buildOrderTile(context, ref, orders[index], isMobile),
                  );
                },
                loading: () => const Center(
                  child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()),
                ),
                error: (e, stack) => Center(
                  child: Padding(padding: const EdgeInsets.all(40.0), child: Text('Error: $e')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, WidgetRef ref, Order order, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Order ID + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
                ),
              ),
              _StatusBadge(status: order.status),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showManageOrderDialog(context, ref, order),
                icon: const Icon(Icons.settings_outlined, size: 20),
                tooltip: 'Manage Flow',
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pickup address
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: isMobile ? 14 : 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'From: ${order.pickupAddress}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Delivery address
          Row(
            children: [
              Icon(Icons.home_outlined, size: isMobile ? 14 : 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'To: ${order.deliveryAddress}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: isMobile ? 12 : 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom row: Products + Total
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Products: ${order.items.length}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Total: ₦${order.totalProductAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Products: ${order.items.length}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('Total: ₦${order.totalProductAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
        ],
      ),
    );
  }

  void _showManageOrderDialog(BuildContext context, WidgetRef ref, Order order) {
    showDialog(
      context: context,
      builder: (context) => _ManageOrderDialog(order: order),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active orders found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _ManageOrderDialog extends ConsumerStatefulWidget {
  final Order order;
  const _ManageOrderDialog({required this.order});

  @override
  ConsumerState<_ManageOrderDialog> createState() => _ManageOrderDialogState();
}

class _ManageOrderDialogState extends ConsumerState<_ManageOrderDialog> {
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
    final driversAsync = ref.watch(adminUsersProvider('driver'));
    final order = widget.order;

    return AlertDialog(
      title: Text('Manage Order #${order.id.substring(0, 8)}'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.status == 'pending' || order.status == 'processing') ...[
                const Text('Assign Driver & Set Prices', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                driversAsync.when(
                  data: (drivers) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Driver', border: OutlineInputBorder()),
                    items: drivers.map((d) => DropdownMenuItem(
                      value: d['id'] as String,
                      child: Text(d['full_name'] ?? d['email']),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedDriverId = val),
                    value: _selectedDriverId,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading drivers: $e'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Agreed Price (₦)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feeController,
                  decoration: const InputDecoration(labelText: 'Delivery Fee (₦)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_selectedDriverId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a driver')));
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await ref.read(adminApiProvider).assignDriver(
                        orderId: order.id,
                        driverId: _selectedDriverId!,
                        agreedPrice: double.parse(_priceController.text),
                        deliveryFee: double.parse(_feeController.text),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.invalidate(adminOrdersProvider);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('Confirm Assignment'),
                ),
              ] else if (order.status != 'delivered' && order.status != 'cancelled') ...[
                const Text('Update Delivery Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatusButton('picked_up', 'Mark as Picked Up'),
                const SizedBox(height: 8),
                _buildStatusButton('on_the_way', 'Mark as On the Way'),
                const SizedBox(height: 8),
                _buildStatusButton('delivered', 'Mark as Delivered', color: Colors.green),
              ] else ...[
                const Center(child: Text('This order is completed and cannot be modified.')),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  Widget _buildStatusButton(String status, String label, {Color? color}) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        try {
          await ref.read(adminApiProvider).updateOrderStatus(widget.order.id, status);
          if (context.mounted) {
             Navigator.pop(context);
             ref.invalidate(adminOrdersProvider);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        } finally {
          setState(() => _isLoading = false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color != null ? Colors.white : null,
        minimumSize: const Size(double.infinity, 44),
      ),
      child: Text(label),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'delivered': color = Colors.green; break;
      case 'pending': color = Colors.amber; break;
      case 'processing': color = Colors.blue; break;
      case 'assigned': color = Colors.purple; break;
      case 'in_progress': color = Colors.indigo; break;
      case 'picked_up': color = Colors.deepOrange; break;
      case 'on_the_way': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

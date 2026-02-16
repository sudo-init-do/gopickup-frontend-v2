import 'package:flutter/material.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _VerticalTimeline(status: order.status),
            const SizedBox(height: 32),
            Text(
              'Items',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${item.quantity} x \$${item.product.price}'),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.quantity * item.product.price).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalTimeline extends StatelessWidget {
  final OrderStatus status;

  const _VerticalTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'label': 'Order Placed',
        'desc': 'Your order has been received.',
        'status': null,
      },
      {
        'label': 'Processing',
        'desc': 'Vendor is preparing your items.',
        'status': OrderStatus.processing,
      },
      {
        'label': 'In Transit',
        'desc': 'Driver is on the way.',
        'status': OrderStatus.transit,
      },
      {
        'label': 'Delivered',
        'desc': 'Package has been delivered.',
        'status': OrderStatus.delivered,
      },
    ];

    int currentIndex = 0; // Placed is 0
    if (status == OrderStatus.processing) currentIndex = 1;
    if (status == OrderStatus.transit) currentIndex = 2;
    if (status == OrderStatus.delivered) currentIndex = 3;

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 12, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index < currentIndex
                            ? AppColors.success
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.black : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[index]['desc'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

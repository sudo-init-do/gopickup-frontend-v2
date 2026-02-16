import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../common/styles/app_colors.dart';
import '../../client/data/order_repository.dart';
import '../../../common/models/order.dart';

class ClientOrdersScreen extends ConsumerWidget {
  const ClientOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/client/orders/${order.id}', extra: order);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.placedAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.items.length} items • \$${order.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _OrderTimeline(status: order.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderStatus status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Placed', 'status': null}, // Always done
      {'label': 'Processing', 'status': OrderStatus.processing},
      {'label': 'In Transit', 'status': OrderStatus.transit},
      {'label': 'Delivered', 'status': OrderStatus.delivered},
    ];

    int currentIndex = 0;
    if (status == OrderStatus.processing) currentIndex = 1;
    if (status == OrderStatus.transit) currentIndex = 2;
    if (status == OrderStatus.delivered) currentIndex = 3;

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.success : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isCompleted ? AppColors.primaryDark : Colors.grey,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex
                        ? AppColors.success
                        : Colors.grey[300],
                    margin: const EdgeInsets.only(
                      bottom: 14,
                    ), // Align with circle center (approx)
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

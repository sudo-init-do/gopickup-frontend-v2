import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/styles/app_colors.dart';
import '../../../state/order_provider.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅';
    if (hour < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Transparent to show gradient
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      extendBodyBehindAppBar: true, // Allow body to extend behind status bar
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Combined Header & Search Bar Sliver
          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Green Gradient Background
                    Container(
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3B7D23), Color(0xFF4CA634)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                    ),
                    // Decorative Circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Header Content
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _getGreeting().toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getGreetingEmoji(),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Welcome back',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity( 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () =>
                                        context.push('/notifications'),
                                    padding: const EdgeInsets.all(10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Delivery Address Card
                            InkWell(
                              onTap: () => context.push('/client/addresses'),
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity( 0.15),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withOpacity( 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'DELIVER TO',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Add delivery address',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating Search Bar with translation to overlap
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: _FloatingSearchBar(),
                  ),
                ),
              ],
            ),
          ),

          // Reset spacing for the content below
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Quick Actions Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                      title: 'Go-Market',
                      subtitle: 'Vendors',
                      onTap: () => context.go('/client/products'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.inventory_2_outlined,
                      color: const Color(0xFFF59E0B),
                      title: 'Post Load',
                      subtitle: 'Drivers',
                      onTap: () => context.push('/client/create-job'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.local_shipping_outlined,
                      color: const Color(0xFF8B5CF6),
                      title: 'Book Truck',
                      subtitle: 'Schedule',
                      onTap: () => context.push('/client/book-truck'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Active Delivery Section
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final orderState = ref.watch(orderProvider);
                if (orderState.isLoading && orderState.orders.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Find first active order (Pending or In Transit)
                final activeOrders = orderState.orders
                    .where(
                      (o) => o.status == 'pending' || o.status == 'in_transit',
                    )
                    .toList();

                if (activeOrders.isEmpty) return const SizedBox.shrink();

                final order = activeOrders.first;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: InkWell(
                    onTap: () => context.push(
                      '/client/orders/${order.id}',
                      extra: order,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity( 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity( 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Delivery',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${order.items.length} items • ${order.status.toUpperCase()}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Recent Orders Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Builder(
                builder: (context) {
                  final orderState = ref.watch(orderProvider);
                  if (orderState.isLoading && orderState.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (orderState.error != null) {
                    return Center(child: Text('Error: ${orderState.error}'));
                  }

                  final orders = orderState.orders;
                  if (orders.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: orders
                        .take(3)
                        .map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => context.push(
                                '/client/orders/${order.id}',
                                extra: order,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              child: _RecentOrderCard(
                                title: 'Order ${order.id.substring(0, 8)}',
                                status: order.status.toUpperCase(),
                                items: order.items.length,
                                time: 'Recently',
                                price: order.totalProductAmount,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  final String title;
  final String status;
  final int items;
  final String time;
  final double price;

  const _RecentOrderCard({
    required this.title,
    required this.status,
    required this.items,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFECFDF5);
        break;
      case 'processing':
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFFFBEB);
        break;
      case 'in transit':
      default:
        statusColor = AppColors.primaryDark;
        statusBgColor = AppColors.primaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$items items • $time',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₦${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingSearchBar extends StatelessWidget {
  const _FloatingSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity( 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.go('/client/products?q=$value');
          } else {
            context.go('/client/products');
          }
        },
        decoration: InputDecoration(
          hintText: 'Search materials, vendors...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.withOpacity( 0.2),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Slightly smaller radius
        border: Border.all(color: Colors.grey.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), // Tighter padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Smaller icon container
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20), // Smaller icon
                ),
                const SizedBox(height: 12), // Tighter vertical spacing
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Smaller font size
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2, // Tighter letters
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1, // Prevent wrapping
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11, // Smaller subtitle
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

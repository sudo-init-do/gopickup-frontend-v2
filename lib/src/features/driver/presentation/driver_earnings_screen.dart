import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../client/data/wallet_repository.dart';

class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kBrandGreen = Color(0xFF3B7D23);
    const kGreenColor = Color(0xFF22C55E);
    const kRedColor = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(kDarkTextColor, kMidTextColor),
              _buildBalanceCard(kBrandGreen, ref),
              _buildStatsRow(ref, kDarkTextColor, kGreenColor, kRedColor),
              _buildTransactionsSection(
                kDarkTextColor,
                kMidTextColor,
                kGreenColor,
                ref,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color darkText, Color midText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your income',
            style: TextStyle(
              fontSize: 16,
              color: midText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Color orange, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: orange,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          balanceAsync.when(
            data: (balance) => Text(
              '₦${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (err, stack) => const Text(
              '₦0.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Available for payout',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.south_west_rounded, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Request Payout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    WidgetRef ref,
    Color darkText,
    Color green,
    Color red,
  ) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: transactionsAsync.when(
        data: (transactions) {
          final now = DateTime.now();
          final todayAmount = transactions
              .where(
                (t) =>
                    t.createdAt.day == now.day &&
                    t.createdAt.month == now.month &&
                    t.createdAt.year == now.year &&
                    t.type == 'credit',
              )
              .fold(0.0, (sum, t) => sum + t.amount);

          return Row(
            children: [
              _buildStatCard(
                'Today',
                '₦\${todayAmount.toStringAsFixed(0)}',
                'Real-time',
                green,
                true,
              ),
              const SizedBox(width: 16),
              _buildStatCard('This Week', '₦--', '---', green, true),
              const SizedBox(width: 16),
              _buildStatCard('This Month', '₦--', '---', red, false),
            ],
          );
        },
        loading: () => Row(
          children: [
            _buildStatCard('Today', '...', 'Loading', green, true),
            const SizedBox(width: 16),
            _buildStatCard('This Week', '...', 'Loading', green, true),
            const SizedBox(width: 16),
            _buildStatCard('This Month', '...', 'Loading', red, false),
          ],
        ),
        error: (_, __) => Row(
          children: [
            _buildStatCard('Today', '₦--', 'Unavailable', red, false),
            const SizedBox(width: 16),
            _buildStatCard('This Week', '₦--', 'Unavailable', red, false),
            const SizedBox(width: 16),
            _buildStatCard('This Month', '₦--', 'Unavailable', red, false),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String amount,
    String change,
    Color changeColor,
    bool isPositive,
  ) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 14,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(
    Color darkText,
    Color midText,
    Color green,
    WidgetRef ref,
  ) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF3B7D23),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: midText),
                  ),
                ),
              );
            }
            return Column(
              children: transactions.take(5).map((tx) {
                final isIncoming = tx.type != 'withdrawal';
                final sign = isIncoming ? '+' : '-';
                return _buildTransactionItem(
                  tx.reference.isNotEmpty
                      ? 'Transaction: ${tx.reference}'
                      : 'Wallet ${tx.type}',
                  tx.createdAt.toLocal().toString().split('.')[0],
                  '$sign₦${tx.amount.toStringAsFixed(2)}',
                  isIncoming ? green : darkText,
                  isIncoming,
                  isBonus: tx.type == 'bonus',
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Failed to load transactions',
                style: TextStyle(color: midText),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String time,
    String amount,
    Color amountColor,
    bool isIncoming, {
    bool isBonus = false,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBonus
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.attach_money_rounded,
              color: isBonus
                  ? const Color(0xFFD97706)
                  : const Color(0xFF22C55E),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

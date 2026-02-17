import 'package:flutter/material.dart';

class ClientWalletScreen extends StatelessWidget {
  const ClientWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Text(
          'My Wallet',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B7D23), Color(0xFF2D611A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B7D23).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wallet_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '\$12,458.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '**** **** **** 4582',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.add_rounded, 'Top Up'),
        _buildActionItem(Icons.arrow_outward_rounded, 'Withdraw'),
        _buildActionItem(Icons.swap_horiz_rounded, 'Transfer'),
        _buildActionItem(Icons.more_horiz_rounded, 'More'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF3B7D23), size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {'title': 'Steel Order #ORD-002', 'date': 'Feb 4, 2026', 'amount': '- \$1,240.00', 'type': 'debit'},
      {'title': 'Wallet Top-up', 'date': 'Feb 3, 2026', 'amount': '+ \$5,000.00', 'type': 'credit'},
      {'title': 'Cement #ORD-001', 'date': 'Feb 2, 2026', 'amount': '- \$458.00', 'type': 'debit'},
    ];

    return Column(
      children: transactions.map((tx) {
        final isCredit = tx['type'] == 'credit';
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      tx['date']!,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                tx['amount']!,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isCredit ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

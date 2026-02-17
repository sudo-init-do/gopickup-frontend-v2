import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientWalletScreen extends StatelessWidget {
  const ClientWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kLightTextColor = Color(0xFF9CA3AF);
    const kBrandGreen = Color(0xFF3B7D23);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, kDarkTextColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(kBrandGreen),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Payment Methods', kMidTextColor),
                    const SizedBox(height: 16),
                    _buildPaymentMethods(kDarkTextColor, kLightTextColor, kBrandGreen),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Recent Transactions', kMidTextColor),
                    const SizedBox(height: 16),
                    _buildTransactionList(kDarkTextColor, kMidTextColor, kLightTextColor, kBrandGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color darkText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 24),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          Text(
            'Wallet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: darkText,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color midText) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: midText.withOpacity(0.8),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildBalanceCard(Color brandGreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: brandGreen,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: brandGreen.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$2,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.add_rounded,
                  label: 'Top Up',
                  bgColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.call_made_rounded,
                  label: 'Transfer',
                  bgColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required Color bgColor}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(Color darkText, Color lightText, Color brandGreen) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black.withOpacity(0.02)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.credit_card_rounded, color: Color(0xFF3B7D23), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•••• 4532',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Visa • Expires 12/27',
                      style: TextStyle(
                        fontSize: 13,
                        color: lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: brandGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black.withOpacity(0.03), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: lightText, size: 24),
              const SizedBox(width: 12),
              Text(
                'Add payment method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: lightText.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(Color darkText, Color midText, Color lightText, Color brandGreen) {
    final transactions = [
      {
        'title': 'Order Payment - ORD-001',
        'date': 'Feb 6, 2026',
        'amount': '\$458.00',
        'isCredit': false,
      },
      {
        'title': 'Wallet Top-up',
        'date': 'Feb 5, 2026',
        'amount': '+\$1000.00',
        'isCredit': true,
      },
      {
        'title': 'Order Payment - ORD-002',
        'date': 'Feb 4, 2026',
        'amount': '\$1240.00',
        'isCredit': false,
      },
      {
        'title': 'Refund - ORD-099',
        'date': 'Feb 3, 2026',
        'amount': '+\$125.00',
        'isCredit': true,
      },
    ];

    return Column(
      children: transactions.map((tx) {
        final isCredit = tx['isCredit'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
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
                  color: isCredit ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.call_received_rounded : Icons.call_made_rounded,
                  color: isCredit ? brandGreen : Colors.redAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx['date'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                tx['amount'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isCredit ? brandGreen : darkText,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

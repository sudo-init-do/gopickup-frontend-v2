import 'package:flutter/material.dart';
import '../../shared/presentation/coming_soon_screen.dart';

// Original vendor wallet implementation preserved in git history.

class VendorWalletScreen extends StatelessWidget {
  const VendorWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      featureName: 'Wallet',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: Color(0xFF45A225), // Vendor uses a slightly different green
    );
  }
}

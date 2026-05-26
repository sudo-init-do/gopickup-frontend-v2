import 'package:flutter/material.dart';
import '../../shared/presentation/coming_soon_screen.dart';
import '../../../common/styles/app_colors.dart';

// Original client wallet implementation preserved in git history.

class ClientWalletScreen extends StatelessWidget {
  const ClientWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      featureName: 'Wallet',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.primary,
    );
  }
}

import 'package:flutter/material.dart';

class VendorWalletScreen extends StatelessWidget {
  const VendorWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: const Center(child: Text('Vendor Wallet details')),
    );
  }
}

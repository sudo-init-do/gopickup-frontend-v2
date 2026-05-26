import 'package:flutter/material.dart';
import '../../shared/presentation/coming_soon_screen.dart';
import '../../../common/styles/app_colors.dart';

class BookTruckScreen extends StatelessWidget {
  const BookTruckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      featureName: 'Book Truck',
      icon: Icons.local_shipping_rounded,
      accentColor: AppColors.vendorAccent,
    );
  }
}

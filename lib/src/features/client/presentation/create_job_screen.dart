import 'package:flutter/material.dart';
import '../../shared/presentation/coming_soon_screen.dart';

class CreateJobScreen extends StatelessWidget {
  const CreateJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      featureName: 'Post Load',
      icon: Icons.inventory_2_rounded,
      accentColor: Color(0xFFF59E0B),
    );
  }
}

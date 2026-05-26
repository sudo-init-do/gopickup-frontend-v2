import 'package:flutter/material.dart';
import '../presentation/coming_soon_screen.dart';
import '../../../common/styles/app_colors.dart';

// Original chat list implementation preserved below for re-enabling.
// See git history for full ChatListScreen with conversations, search, etc.

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      featureName: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      accentColor: AppColors.primary,
    );
  }
}

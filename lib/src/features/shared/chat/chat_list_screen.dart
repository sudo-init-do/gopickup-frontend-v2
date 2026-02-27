import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'chat_repository.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatsProvider);

    // Color constants for high-fidelity design
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kLightTextColor = Color(0xFF9CA3AF);
    const kBrandGreen = Color(0xFF3B7D23);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Sectionaa
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kDarkTextColor,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Search Bar
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: TextStyle(
                          color: kMidTextColor.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: kMidTextColor.withOpacity(0.5),
                          size: 26,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Conversations List
            Expanded(
              child: chats.when(
                data: (chatList) => ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: chatList.length,
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    color: const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final chat = chatList[index];
                    final otherUser = chat.participants.firstWhere((p) => p.id != 'me');
                    
                    // Mock unread count for BuildMart Supplies to match mockup
                    final hasUnread = otherUser.name == 'BuildMart Supplies';
                    final unreadCount = hasUnread ? 2 : 0;

                    return _ChatListItem(
                      name: otherUser.name,
                      lastMessage: chat.lastMessage,
                      time: _formatDateTime(chat.lastUpdated),
                      unreadCount: unreadCount,
                      kDarkTextColor: kDarkTextColor,
                      kMidTextColor: kMidTextColor,
                      kLightTextColor: kLightTextColor,
                      kBrandGreen: kBrandGreen,
                      onTap: () => context.push('/chat/${chat.id}', extra: chat),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} mins ago';
    if (difference.inHours < 24) return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    if (difference.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dateTime);
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final Color kDarkTextColor;
  final Color kMidTextColor;
  final Color kLightTextColor;
  final Color kBrandGreen;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.kDarkTextColor,
    required this.kMidTextColor,
    required this.kLightTextColor,
    required this.kBrandGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF22C55E),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w700,
                          color: kDarkTextColor,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: unreadCount > 0 ? kDarkTextColor.withOpacity(0.6) : kLightTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                            color: unreadCount > 0 ? kMidTextColor : kLightTextColor,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kBrandGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../common/styles/app_colors.dart';
import 'chat_repository.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index];
          final otherUser = chat.participants.firstWhere((p) => p.id != 'me');

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                otherUser.name[0],
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            title: Text(
              otherUser.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('h:mm a').format(chat.lastUpdated),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              context.push('/chat/${chat.id}', extra: chat);
            },
          );
        },
      ),
    );
  }
}

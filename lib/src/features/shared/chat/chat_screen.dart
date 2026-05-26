import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/chat_models.dart';
import '../../../state/auth_provider.dart';
import '../../../state/chat_provider.dart';
import '../../../common/styles/app_colors.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_text_styles.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation chat;

  const ChatScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).fetchMessages(widget.chat.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final currentUser = ref.watch(authProvider).user;
    final otherUserName = widget.chat.otherUserName ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, otherUserName),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading && chatState.currentMessages.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    itemCount: chatState.currentMessages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.currentMessages[index];
                      return _MessageBubble(
                        message: message,
                        isMe: message.senderId == currentUser?.id,
                      );
                    },
                  ),
          ),
          _ChatInput(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSubtle,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      titleSpacing: AppSpacing.md,
      title: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTextStyles.titleMd.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Online',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildCircularAction(Icons.phone_outlined),
        const SizedBox(width: AppSpacing.sm),
        _buildCircularAction(Icons.more_vert),
        const SizedBox(width: AppSpacing.lg),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.backgroundSubtle, height: 1),
      ),
    );
  }

  Widget _buildCircularAction(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSubtle,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 20),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.backgroundSubtle,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.xl),
                topRight: const Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(isMe ? AppRadius.xl : 0),
                bottomRight: Radius.circular(isMe ? 0 : AppRadius.xl),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTextStyles.body.copyWith(
                    color: isMe
                        ? Colors.white
                        : AppColors.textPrimary.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormat('h:mm a').format(message.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: isMe
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.backgroundSubtle)),
      ),
      child: Row(
        children: [
          _buildInputIcon(Icons.attachment_rounded),
          const SizedBox(width: AppSpacing.sm),
          _buildInputIcon(Icons.image_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.backgroundSubtle, width: 1.5),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSubtle,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 20),
    );
  }
}

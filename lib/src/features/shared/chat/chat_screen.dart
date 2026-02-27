import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../common/models/chat.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.chat.messages);
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().toString(),
          senderId: 'me',
          content: _controller.text,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.chat.participants.firstWhere(
      (p) => p.id != 'me',
      orElse: () => widget.chat.participants.first,
    );

    // Refined color palette to match mockup
    const kDarkTextColor = Color(0xFF111827);
    const kMidTextColor = Color(0xFF6B7280);
    const kBrandGreen = Color(0xFF45A225); // Vibrant green from mockup
    const kIncomingBg = Color(0xFFF1F5F9);
    const kChatBg = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: kChatBg,
      appBar: _buildAppBar(context, otherUser.name, kDarkTextColor, kBrandGreen),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  kBrandGreen: kBrandGreen,
                  kDarkTextColor: kDarkTextColor,
                  kMidTextColor: kMidTextColor,
                  kIncomingBg: kIncomingBg,
                );
              },
            ),
          ),
          _ChatInput(
            controller: _controller,
            onSend: _sendMessage,
            kBrandGreen: kBrandGreen,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String name, Color darkText, Color brandGreen) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: darkText, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      titleSpacing: 12,
      title: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person_outline_rounded, color: Color(0xFF4CAF50), size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Online',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _buildCircularAction(Icons.phone_outlined),
        const SizedBox(width: 8),
        _buildCircularAction(Icons.more_vert),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFF1F5F9),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildCircularAction(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final Color kBrandGreen;
  final Color kDarkTextColor;
  final Color kMidTextColor;
  final Color kIncomingBg;

  const _MessageBubble({
    required this.message,
    required this.kBrandGreen,
    required this.kDarkTextColor,
    required this.kMidTextColor,
    required this.kIncomingBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: message.isMe ? kBrandGreen : kIncomingBg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(message.isMe ? 24 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 24),
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
                  style: TextStyle(
                    color: message.isMe ? Colors.white : kDarkTextColor.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: message.isMe ? Colors.white.withOpacity(0.8) : kMidTextColor.withOpacity(0.6),
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
  final Color kBrandGreen;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.kBrandGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          _buildInputIcon(Icons.attachment_rounded),
          const SizedBox(width: 8),
          _buildInputIcon(Icons.image_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kBrandGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kBrandGreen.withOpacity(0.3),
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
        color: Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
    );
  }
}

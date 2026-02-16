import 'package:flutter/material.dart';
import '../../../common/styles/app_colors.dart';
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
    final otherUser = widget.chat.participants.firstWhere((p) => p.id != 'me');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                otherUser.name[0],
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(otherUser.name),
          ],
        ),
      ),
      body: Column(
        children: [
          // Order Reference Header (Mock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order #ORD-12345',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View Details')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          _ChatInput(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 0),
            bottomRight: Radius.circular(message.isMe ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.content,
          style: TextStyle(color: message.isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

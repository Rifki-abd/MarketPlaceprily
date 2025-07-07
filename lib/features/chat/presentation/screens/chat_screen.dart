// lib/features/chat/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/chat/domain/message_model.dart';
import 'package:preloft_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.chatRoomId, super.key});
  final String chatRoomId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
    if (currentUser == null) return;

    ref.read(chatActionNotifierProvider.notifier).sendMessage(
      chatRoomId: widget.chatRoomId,
      senderId: currentUser.id,
      content: content,
    );
    
    _messageController.clear();
    FocusScope.of(context).unfocus(); // Tutup keyboard setelah mengirim
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(chatActionNotifierProvider);
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatRoomId));
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat dengan Penjual'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Mulai percakapan Anda!'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (err, stack) => Center(child: Text('Gagal memuat pesan: $err')),
            ),
          ),
          _buildMessageInput(sendState.isLoading),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isSending) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: InputBorder.none,
                ),
                onSubmitted: isSending ? null : (_) => _sendMessage(),
              ),
            ),
            isSending
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
          ],
        ),
      ),
    );
  }
}

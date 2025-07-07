// lib/features/chat/presentation/screens/chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:preloft_app/shared/widgets/empty_state_widget.dart';
import 'package:preloft_app/shared/widgets/loading_widget.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatRoomListStreamProvider);
    final currentUserId = ref.watch(userProfileProvider).value?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kotak Masuk'),
      ),
      body: chatListAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyStateWidget(
              title: 'Tidak Ada Pesan',
              message: 'Mulai percakapan dengan penjual untuk melihatnya di sini.',
              icon: Icons.message_outlined,
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isMeBuyer = chat.buyerId == currentUserId;
              final otherPersonName = isMeBuyer ? chat.sellerName : chat.buyerName;
              
              // Tentukan jumlah pesan belum dibaca untuk chat ini
              final unreadCount = isMeBuyer ? chat.buyerUnreadCount : chat.sellerUnreadCount;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chat.productImageUrl != null 
                    ? NetworkImage(chat.productImageUrl!) 
                    : null,
                  child: chat.productImageUrl == null 
                    ? const Icon(Icons.shopping_bag) 
                    : null,
                ),
                title: Text(otherPersonName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  chat.lastMessage ?? 'Terkait: ${chat.productName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // --- TAMPILKAN LENCANA NOTIFIKASI ---
                trailing: unreadCount > 0
                  ? CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
                onTap: () => context.push('/chat/${chat.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (err, stack) => Center(child: Text('Gagal memuat daftar chat: $err')),
      ),
    );
  }
}

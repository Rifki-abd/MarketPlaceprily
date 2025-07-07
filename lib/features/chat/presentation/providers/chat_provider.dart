// lib/features/chat/presentation/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:preloft_app/features/chat/data/chat_repository.dart';
import 'package:preloft_app/features/chat/domain/chat_room_detail_model.dart';
import 'package:preloft_app/features/chat/domain/message_model.dart';

// ... (provider lain tetap sama)
final chatRepositoryProvider = Provider.autoDispose<ChatRepository>((ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
});

final chatRoomListStreamProvider = StreamProvider.autoDispose<List<ChatRoomDetail>>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getChatRoomListStream();
});

final totalUnreadMessagesProvider = Provider.autoDispose<int>((ref) {
  final chatListAsync = ref.watch(chatRoomListStreamProvider);
  final currentUserId = ref.watch(userProfileProvider).value?.id;
  
  return chatListAsync.when(
    data: (chats) {
      if (currentUserId == null) return 0;
      int total = 0;
      for (final chat in chats) {
        if (chat.buyerId == currentUserId) {
          total += chat.buyerUnreadCount;
        } else if (chat.sellerId == currentUserId) {
          total += chat.sellerUnreadCount;
        }
      }
      return total;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final messagesStreamProvider = 
    StreamProvider.autoDispose.family<List<Message>, String>((ref, chatRoomId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getMessagesStream(chatRoomId);
});

final chatActionNotifierProvider = 
    StateNotifierProvider.autoDispose<ChatActionNotifier, AsyncValue<void>>((ref) {
  return ChatActionNotifier(ref.watch(chatRepositoryProvider), ref);
});

class ChatActionNotifier extends StateNotifier<AsyncValue<void>> {
  ChatActionNotifier(this._repository, this._ref) : super(const AsyncData(null));
  final ChatRepository _repository;
  final Ref _ref;

  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.sendMessage(
        chatRoomId: chatRoomId, 
        senderId: senderId, 
        content: content
      );
      _ref.invalidate(messagesStreamProvider(chatRoomId));
      _ref.invalidate(chatRoomListStreamProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // --- FUNGSI BARU UNTUK MENANDAI SEBAGAI SUDAH DIBACA ---
  Future<void> markAsRead(String chatRoomId) async {
    final userId = _ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (userId == null) return;
    
    // Panggil repository tanpa mengubah state loading
    await _repository.resetUnreadCount(chatRoomId: chatRoomId, userId: userId);
    _ref.invalidate(chatRoomListStreamProvider);
  }
}

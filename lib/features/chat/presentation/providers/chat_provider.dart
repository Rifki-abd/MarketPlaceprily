// lib/features/chat/presentation/providers/chat_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:preloft_app/core/providers/supabase_provider.dart';
import 'package:preloft_app/features/chat/data/chat_repository.dart';
import 'package:preloft_app/features/chat/domain/chat_room_detail_model.dart';
import 'package:preloft_app/features/chat/domain/message_model.dart';

// Provider untuk ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
});

// Provider Stream untuk daftar chat room
final chatRoomListStreamProvider = StreamProvider.autoDispose<List<ChatRoomDetail>>((ref) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getChatRoomListStream();
});

// Provider Stream untuk mendapatkan pesan-pesan
final messagesStreamProvider = 
    StreamProvider.autoDispose.family<List<Message>, String>((ref, chatRoomId) {
  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.getMessagesStream(chatRoomId);
});

// Notifier untuk Aksi Chat (mengirim pesan)
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
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// lib/features/chat/data/chat_repository.dart

import 'package:preloft_app/features/chat/domain/chat_room_detail_model.dart';
import 'package:preloft_app/features/chat/domain/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient _client;
  ChatRepository(this._client);

  Future<String> startOrGetChatRoom({
    required String buyerId,
    required String sellerId,
    required String productId,
  }) async {
    // ... (tidak berubah)
    try {
      final data = await _client.rpc('start_or_get_chat_room', params: {
        'p_buyer_id': buyerId,
        'p_seller_id': sellerId,
        'p_product_id': productId,
      });
      return data as String;
    } catch (e) {
      throw Exception('Gagal memulai atau mendapatkan chat room: $e');
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String content,
  }) async {
    // ... (tidak berubah)
    try {
      await _client.from('messages').insert({
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'content': content,
      });
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }
  
  // --- FUNGSI BARU UNTUK MERESET HITUNGAN ---
  Future<void> resetUnreadCount({
    required String chatRoomId,
    required String userId,
  }) async {
    try {
      await _client.rpc('reset_unread_count', params: {
        'p_chat_room_id': chatRoomId,
        'p_user_id': userId,
      });
    } catch (e) {
      // Kita tidak perlu melempar error di sini karena ini adalah operasi latar belakang
      print('Gagal mereset unread count: $e');
    }
  }

  Stream<List<Message>> getMessagesStream(String chatRoomId) {
    // ... (tidak berubah)
    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true)
          .map((maps) => maps.map(Message.fromMap).toList());
    } catch (e) {
      throw Exception('Gagal mendapatkan stream pesan: $e');
    }
  }
  
  Stream<List<ChatRoomDetail>> getChatRoomListStream() {
    // ... (tidak berubah)
    try {
      return _client
          .from('chat_room_details')
          .stream(primaryKey: ['id'])
          .order('last_message_at', ascending: false)
          .map((maps) => maps.map(ChatRoomDetail.fromMap).toList());
    } catch (e) {
      throw Exception('Gagal mendapatkan daftar chat: $e');
    }
  }
}

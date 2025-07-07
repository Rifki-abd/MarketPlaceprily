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

  Stream<List<Message>> getMessagesStream(String chatRoomId) {
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
  
  /// Mendapatkan stream daftar chat room dari VIEW 'chat_room_details'.
  Stream<List<ChatRoomDetail>> getChatRoomListStream() {
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

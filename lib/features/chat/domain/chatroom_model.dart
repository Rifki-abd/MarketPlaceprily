// lib/features/chat/domain/chatroom_model.dart

class ChatRoom {

  ChatRoom({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
  });
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
}

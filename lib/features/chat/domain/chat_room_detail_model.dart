// lib/features/chat/domain/chat_room_detail_model.dart

class ChatRoomDetail {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String productName;
  final String? productImageUrl;
  final String buyerName;
  final String sellerName;

  ChatRoomDetail({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    required this.productName,
    this.productImageUrl,
    required this.buyerName,
    required this.sellerName,
  });

  factory ChatRoomDetail.fromMap(Map<String, dynamic> map) {
    return ChatRoomDetail(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      buyerId: map['buyer_id'] as String,
      sellerId: map['seller_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'] as String)
          : null,
      productName: map['product_name'] as String,
      productImageUrl: map['product_image_url'] as String?,
      buyerName: map['buyer_name'] as String,
      sellerName: map['seller_name'] as String,
    );
  }
}

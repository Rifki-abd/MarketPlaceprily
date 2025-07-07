// lib/features/chat/domain/chat_room_detail_model.dart

class ChatRoomDetail {

  ChatRoomDetail({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.productName, required this.buyerName, required this.sellerName, required this.buyerUnreadCount, required this.sellerUnreadCount, this.lastMessage,
    this.lastMessageAt,
    this.productImageUrl,
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
      
      // --- PERBAIKAN DI SINI: Menangani nilai NULL dengan aman ---
      // Jika 'buyer_unread_count' adalah null, anggap sebagai 0.
      buyerUnreadCount: (map['buyer_unread_count'] as num?)?.toInt() ?? 0,
      sellerUnreadCount: (map['seller_unread_count'] as num?)?.toInt() ?? 0,
    );
  }
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
  final int buyerUnreadCount;
  final int sellerUnreadCount;
}

// lib/features/chat/domain/message_model.dart

class Message {
  final String id;
  final String chatroomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatroomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  // --- PERBAIKAN DI SINI: Menambahkan konstruktor fromMap ---
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      chatroomId: map['chat_room_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

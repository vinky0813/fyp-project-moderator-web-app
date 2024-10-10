class ChatMessage {
  final String message_id;
  final String sender_id;
  final String property_id;
  final String receiver_id;
  final String content;
  final DateTime created_at;

  ChatMessage({
    required this.message_id,
    required this.sender_id,
    required this.property_id,
    required this.receiver_id,
    required this.content,
    required this.created_at,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> map) {
    return ChatMessage(
      message_id: map['message_id'],
      sender_id: map['sender_id'],
      property_id: map['property_id'],
      receiver_id: map['receiver_id'],
      content: map['content'],
      created_at: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message_id': message_id,
      'sender_id': sender_id,
      'property_id': property_id,
      'receiver_id': receiver_id,
      'content': content,
      'created_at': created_at.toIso8601String(),
    };
  }
}

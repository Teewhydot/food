class MessageEntity {
  final String id;
  final String content, senderId, receiverId;
  final DateTime timestamp;

  MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'MessageEntity(id: $id, content: $content, timestamp: $timestamp)';
  }
}

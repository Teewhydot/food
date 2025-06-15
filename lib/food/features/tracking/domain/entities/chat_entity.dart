class ChatEntity {
  final String id, senderID, receiverID;
  final String name, lastMessage;
  final String imageUrl;
  final DateTime lastMessageTime;

  ChatEntity({
    required this.id,
    required this.senderID,
    required this.receiverID,
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.lastMessageTime,
  });
}

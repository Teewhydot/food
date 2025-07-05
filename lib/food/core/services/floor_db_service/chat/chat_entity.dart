import 'package:floor/floor.dart';

@Entity(tableName: 'chats')
class ChatFloorEntity {
  @PrimaryKey()
  final String id;
  final String senderID;
  final String receiverID;
  final String name;
  final String lastMessage;
  final String imageUrl;
  final int lastMessageTime;
  final String orderId;

  ChatFloorEntity({
    required this.id,
    required this.senderID,
    required this.receiverID,
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    required this.lastMessageTime,
    required this.orderId,
  });
}
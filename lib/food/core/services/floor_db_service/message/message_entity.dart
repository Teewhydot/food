import 'package:floor/floor.dart';

@Entity(tableName: 'messages')
class MessageFloorEntity {
  @PrimaryKey()
  final String id;
  final String chatId;
  final String content;
  final String senderId;
  final String receiverId;
  final int timestamp;
  final bool isRead;

  MessageFloorEntity({
    required this.id,
    required this.chatId,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    required this.isRead,
  });
}
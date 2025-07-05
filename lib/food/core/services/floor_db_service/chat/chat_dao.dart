import 'package:floor/floor.dart';
import 'chat_entity.dart';

@dao
abstract class ChatDao {
  @Query('SELECT * FROM chats WHERE senderID = :userId OR receiverID = :userId ORDER BY lastMessageTime DESC')
  Future<List<ChatFloorEntity>> getUserChats(String userId);

  @Query('SELECT * FROM chats WHERE id = :chatId')
  Future<ChatFloorEntity?> getChatById(String chatId);

  @Query('SELECT * FROM chats WHERE orderId = :orderId')
  Future<ChatFloorEntity?> getChatByOrderId(String orderId);

  @insert
  Future<void> insertChat(ChatFloorEntity chat);

  @insert
  Future<void> insertChats(List<ChatFloorEntity> chats);

  @update
  Future<void> updateChat(ChatFloorEntity chat);

  @Query('UPDATE chats SET lastMessage = :lastMessage, lastMessageTime = :timestamp WHERE id = :chatId')
  Future<void> updateLastMessage(String chatId, String lastMessage, int timestamp);

  @delete
  Future<void> deleteChat(ChatFloorEntity chat);

  @Query('DELETE FROM chats')
  Future<void> deleteAllChats();
}
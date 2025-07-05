import 'package:floor/floor.dart';
import 'message_entity.dart';

@dao
abstract class MessageDao {
  @Query('SELECT * FROM messages WHERE chatId = :chatId ORDER BY timestamp ASC')
  Future<List<MessageFloorEntity>> getChatMessages(String chatId);

  @Query('SELECT * FROM messages WHERE id = :messageId')
  Future<MessageFloorEntity?> getMessageById(String messageId);

  @Query('SELECT * FROM messages WHERE chatId = :chatId ORDER BY timestamp DESC LIMIT 1')
  Future<MessageFloorEntity?> getLastMessage(String chatId);

  @Query('SELECT * FROM messages WHERE receiverId = :userId AND isRead = 0')
  Future<List<MessageFloorEntity>> getUnreadMessages(String userId);

  @insert
  Future<void> insertMessage(MessageFloorEntity message);

  @insert
  Future<void> insertMessages(List<MessageFloorEntity> messages);

  @update
  Future<void> updateMessage(MessageFloorEntity message);

  @Query('UPDATE messages SET isRead = 1 WHERE id = :messageId')
  Future<void> markMessageAsRead(String messageId);

  @Query('UPDATE messages SET isRead = 1 WHERE chatId = :chatId AND receiverId = :userId')
  Future<void> markChatMessagesAsRead(String chatId, String userId);

  @delete
  Future<void> deleteMessage(MessageFloorEntity message);

  @Query('DELETE FROM messages WHERE chatId = :chatId')
  Future<void> deleteChatMessages(String chatId);

  @Query('DELETE FROM messages')
  Future<void> deleteAllMessages();
}
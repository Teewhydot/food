import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  // Chat management
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId);
  Future<Either<Failure, ChatEntity>> getChatById(String chatId);
  Future<Either<Failure, ChatEntity>> createOrGetChat({
    required String userId,
    required String otherUserId,
    required String orderId,
  });
  Future<Either<Failure, void>> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime timestamp,
  });
  
  // Message management
  Future<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId);
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  });
  Future<Either<Failure, void>> markMessageAsRead(String messageId);
  Future<Either<Failure, void>> deleteMessage(String messageId);
  
  // Real-time streams
  Stream<List<ChatEntity>> watchUserChats(String userId);
  Stream<List<MessageEntity>> watchChatMessages(String chatId);
  Stream<MessageEntity> watchNewMessages(String chatId);
}
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class ChatUseCase {
  final ChatRepository repository;

  ChatUseCase(this.repository);

  // Chat management
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId) async {
    return await repository.getUserChats(userId);
  }

  Future<Either<Failure, ChatEntity>> getChatById(String chatId) async {
    return await repository.getChatById(chatId);
  }

  Future<Either<Failure, ChatEntity>> createOrGetChat({
    required String userId,
    required String otherUserId,
    required String orderId,
  }) async {
    return await repository.createOrGetChat(
      userId: userId,
      otherUserId: otherUserId,
      orderId: orderId,
    );
  }

  // Message management
  Future<Either<Failure, List<MessageEntity>>> getChatMessages(
    String chatId,
  ) async {
    return await repository.getChatMessages(chatId);
  }

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    return await repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
  }

  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    return await repository.markMessageAsRead(messageId);
  }

  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    return await repository.deleteMessage(messageId);
  }

  // Real-time streams
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    return repository.watchUserChats(userId);
  }

  Stream<List<MessageEntity>> watchChatMessages(String chatId) {
    return repository.watchChatMessages(chatId);
  }

  Stream<MessageEntity> watchNewMessages(String chatId) {
    return repository.watchNewMessages(chatId);
  }
}
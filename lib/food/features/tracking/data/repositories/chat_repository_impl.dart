import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../remote/data_sources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChatEntity>>> getUserChats(String userId) {
    return handleExceptions(() async {
      return await remoteDataSource.getUserChats(userId);
    });
  }

  @override
  Future<Either<Failure, ChatEntity>> getChatById(String chatId) {
    return handleExceptions(() async {
      return await remoteDataSource.getChatById(chatId);
    });
  }

  @override
  Future<Either<Failure, ChatEntity>> createOrGetChat({
    required String userId,
    required String otherUserId,
    required String orderId,
  }) {
    return handleExceptions(() async {
      return await remoteDataSource.createOrGetChat(
        userId: userId,
        otherUserId: otherUserId,
        orderId: orderId,
      );
    });
  }

  @override
  Future<Either<Failure, void>> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime timestamp,
  }) {
    return handleExceptions(() async {
      await remoteDataSource.updateLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
        timestamp: timestamp,
      );
    });
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId) {
    return handleExceptions(() async {
      return await remoteDataSource.getChatMessages(chatId);
    });
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return handleExceptions(() async {
      return await remoteDataSource.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
    });
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) {
    return handleExceptions(() async {
      await remoteDataSource.markMessageAsRead(messageId);
    });
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) {
    return handleExceptions(() async {
      await remoteDataSource.deleteMessage(messageId);
    });
  }

  @override
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    return remoteDataSource.watchUserChats(userId);
  }

  @override
  Stream<List<MessageEntity>> watchChatMessages(String chatId) {
    return remoteDataSource.watchChatMessages(chatId);
  }

  @override
  Stream<MessageEntity> watchNewMessages(String chatId) {
    return remoteDataSource.watchNewMessages(chatId);
  }
}
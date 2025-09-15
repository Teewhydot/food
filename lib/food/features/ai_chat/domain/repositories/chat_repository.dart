import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/chat_message.dart';
import '../entities/chat_room.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatMessage>>> getMessages(String roomId);
  Future<Either<Failure, void>> sendMessage(String roomId, ChatMessage message);
  Future<Either<Failure, ChatRoom>> createChatRoom(ChatRoom chatRoom);
  Future<Either<Failure, ChatRoom>> getChatRoom(String roomId);
  Future<Either<Failure, List<ChatRoom>>> getUserChatRooms(String userId);
  Future<Either<Failure, void>> updateMessage(String roomId, ChatMessage message);
  Future<Either<Failure, void>> markMessagesAsRead(String roomId, String userId);
  Future<Either<Failure, void>> updateChatRoom(ChatRoom chatRoom);
}
import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<ChatMessage>>> getMessages(String roomId) async* {
    try {
      if (!await networkInfo.isConnected) {
        yield const Left(ServerFailure('No internet connection', 503));
        return;
      }

      yield* remoteDataSource.getMessages(roomId).map((messages) {
        return Right<Failure, List<ChatMessage>>(
          messages.map((model) => model as ChatMessage).toList(),
        );
      }).handleError((error) {
        if (error is ServerException) {
          return Left<Failure, List<ChatMessage>>(
            ServerFailure(error.message, error.statusCode),
          );
        }
        return Left<Failure, List<ChatMessage>>(
          ServerFailure('Unknown error occurred', 500),
        );
      });
    } catch (e) {
      yield Left(ServerFailure('Unexpected error: $e', 500));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(
      String roomId, ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      await remoteDataSource.sendMessage(roomId, messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e', 500));
    }
  }

  @override
  Future<Either<Failure, ChatRoom>> createChatRoom(ChatRoom chatRoom) async {
    try {
      final chatRoomModel = ChatRoomModel.fromEntity(chatRoom);
      await remoteDataSource.createChatRoom(chatRoomModel);
      return Right(chatRoom);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to create chat room: $e', 500));
    }
  }

  @override
  Future<Either<Failure, ChatRoom>> getChatRoom(String roomId) async {
    try {
      if (await networkInfo.isConnected) {
        final chatRoom = await remoteDataSource.getChatRoom(roomId);
        return Right(chatRoom);
      } else {
        return const Left(ServerFailure('No internet connection', 503));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to get chat room: $e', 500));
    }
  }

  @override
  Future<Either<Failure, List<ChatRoom>>> getUserChatRooms(
      String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection', 503));
      }
      
      final chatRooms = await remoteDataSource.getUserChatRooms(userId);
      return Right(chatRooms.map((model) => model as ChatRoom).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to get user chat rooms: $e', 500));
    }
  }

  @override
  Future<Either<Failure, void>> updateMessage(
      String roomId, ChatMessage message) async {
    try {
      final messageModel = ChatMessageModel.fromEntity(message);
      await remoteDataSource.updateMessage(roomId, messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to update message: $e', 500));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
      String roomId, String userId) async {
    try {
      await remoteDataSource.markMessagesAsRead(roomId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to mark messages as read: $e', 500));
    }
  }

  @override
  Future<Either<Failure, void>> updateChatRoom(ChatRoom chatRoom) async {
    try {
      final chatRoomModel = ChatRoomModel.fromEntity(chatRoom);
      await remoteDataSource.updateChatRoom(chatRoomModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to update chat room: $e', 500));
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/chat_room.dart';
import '../repositories/chat_repository.dart';

class CreateChatRoomUseCase implements UseCase<ChatRoom, CreateChatRoomParams> {
  final ChatRepository repository;

  CreateChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, ChatRoom>> call(CreateChatRoomParams params) async {
    return await repository.createChatRoom(params.chatRoom);
  }
}

class GetChatRoomUseCase implements UseCase<ChatRoom, GetChatRoomParams> {
  final ChatRepository repository;

  GetChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, ChatRoom>> call(GetChatRoomParams params) async {
    return await repository.getChatRoom(params.roomId);
  }
}

class GetUserChatRoomsUseCase implements UseCase<List<ChatRoom>, GetUserChatRoomsParams> {
  final ChatRepository repository;

  GetUserChatRoomsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatRoom>>> call(GetUserChatRoomsParams params) async {
    return await repository.getUserChatRooms(params.userId);
  }
}

class UpdateChatRoomUseCase implements UseCase<void, UpdateChatRoomParams> {
  final ChatRepository repository;

  UpdateChatRoomUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateChatRoomParams params) async {
    return await repository.updateChatRoom(params.chatRoom);
  }
}

class MarkMessagesAsReadUseCase implements UseCase<void, MarkMessagesAsReadParams> {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkMessagesAsReadParams params) async {
    return await repository.markMessagesAsRead(params.roomId, params.userId);
  }
}

// Parameter classes
class CreateChatRoomParams extends Equatable {
  final ChatRoom chatRoom;

  const CreateChatRoomParams({required this.chatRoom});

  @override
  List<Object> get props => [chatRoom];
}

class GetChatRoomParams extends Equatable {
  final String roomId;

  const GetChatRoomParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

class GetUserChatRoomsParams extends Equatable {
  final String userId;

  const GetUserChatRoomsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateChatRoomParams extends Equatable {
  final ChatRoom chatRoom;

  const UpdateChatRoomParams({required this.chatRoom});

  @override
  List<Object> get props => [chatRoom];
}

class MarkMessagesAsReadParams extends Equatable {
  final String roomId;
  final String userId;

  const MarkMessagesAsReadParams({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object> get props => [roomId, userId];
}
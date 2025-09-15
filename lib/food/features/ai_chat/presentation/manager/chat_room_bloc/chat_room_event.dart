import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_room.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserChatRooms extends ChatRoomEvent {
  final String userId;

  const LoadUserChatRooms(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateChatRoom extends ChatRoomEvent {
  final ChatRoom chatRoom;

  const CreateChatRoom(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class GetChatRoom extends ChatRoomEvent {
  final String roomId;

  const GetChatRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class UpdateChatRoom extends ChatRoomEvent {
  final ChatRoom chatRoom;

  const UpdateChatRoom(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class CreateAIChatRoom extends ChatRoomEvent {
  final String userId;
  final String userName;

  const CreateAIChatRoom({
    required this.userId,
    required this.userName,
  });

  @override
  List<Object> get props => [userId, userName];
}

class RefreshChatRooms extends ChatRoomEvent {
  final String userId;

  const RefreshChatRooms(this.userId);

  @override
  List<Object> get props => [userId];
}
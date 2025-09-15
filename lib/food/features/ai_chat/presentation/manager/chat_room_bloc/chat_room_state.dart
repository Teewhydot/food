import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_room.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<ChatRoom> chatRooms;
  final bool isRefreshing;

  const ChatRoomLoaded({
    required this.chatRooms,
    this.isRefreshing = false,
  });

  ChatRoomLoaded copyWith({
    List<ChatRoom>? chatRooms,
    bool? isRefreshing,
  }) {
    return ChatRoomLoaded(
      chatRooms: chatRooms ?? this.chatRooms,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [chatRooms, isRefreshing];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  final String? errorCode;

  const ChatRoomError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class ChatRoomCreated extends ChatRoomState {
  final ChatRoom chatRoom;

  const ChatRoomCreated(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class ChatRoomUpdated extends ChatRoomState {
  final ChatRoom chatRoom;

  const ChatRoomUpdated(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}

class SingleChatRoomLoaded extends ChatRoomState {
  final ChatRoom chatRoom;

  const SingleChatRoomLoaded(this.chatRoom);

  @override
  List<Object> get props => [chatRoom];
}
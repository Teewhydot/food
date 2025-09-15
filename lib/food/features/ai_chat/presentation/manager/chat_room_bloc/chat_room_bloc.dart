import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_room.dart';
import '../../../domain/usecases/chat_room_usecases.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final CreateChatRoomUseCase createChatRoom;
  final GetChatRoomUseCase getChatRoom;
  final GetUserChatRoomsUseCase getUserChatRooms;
  final UpdateChatRoomUseCase updateChatRoom;

  ChatRoomBloc({
    required this.createChatRoom,
    required this.getChatRoom,
    required this.getUserChatRooms,
    required this.updateChatRoom,
  }) : super(ChatRoomInitial()) {
    on<LoadUserChatRooms>(_onLoadUserChatRooms);
    on<CreateChatRoom>(_onCreateChatRoom);
    on<GetChatRoom>(_onGetChatRoom);
    on<UpdateChatRoom>(_onUpdateChatRoom);
    on<CreateAIChatRoom>(_onCreateAIChatRoom);
    on<RefreshChatRooms>(_onRefreshChatRooms);
  }

  Future<void> _onLoadUserChatRooms(
    LoadUserChatRooms event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());

    final result = await getUserChatRooms(
      GetUserChatRoomsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (chatRooms) => emit(ChatRoomLoaded(chatRooms: chatRooms)),
    );
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoom event,
    Emitter<ChatRoomState> emit,
  ) async {
    final result = await createChatRoom(
      CreateChatRoomParams(chatRoom: event.chatRoom),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (chatRoom) => emit(ChatRoomCreated(chatRoom)),
    );
  }

  Future<void> _onGetChatRoom(
    GetChatRoom event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());

    final result = await getChatRoom(
      GetChatRoomParams(roomId: event.roomId),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (chatRoom) => emit(SingleChatRoomLoaded(chatRoom)),
    );
  }

  Future<void> _onUpdateChatRoom(
    UpdateChatRoom event,
    Emitter<ChatRoomState> emit,
  ) async {
    final result = await updateChatRoom(
      UpdateChatRoomParams(chatRoom: event.chatRoom),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (_) => emit(ChatRoomUpdated(event.chatRoom)),
    );
  }

  Future<void> _onCreateAIChatRoom(
    CreateAIChatRoom event,
    Emitter<ChatRoomState> emit,
  ) async {
    // Create an AI support chat room
    final chatRoom = ChatRoom(
      id: '', // Will be set by repository
      title: 'AI Support',
      participantIds: [event.userId, 'ai_assistant'],
      participantNames: {
        event.userId: event.userName,
        'ai_assistant': 'AI Assistant',
      },
      participantTypes: {
        event.userId: 'user',
        'ai_assistant': 'ai',
      },
      lastMessage: 'Chat started',
      lastMessageTime: DateTime.now(),
      createdAt: DateTime.now(),
      unreadCount: {
        event.userId: 0,
        'ai_assistant': 0,
      },
      isActive: true,
      roomType: ChatRoomType.aiSupport,
      context: {
        'created_by': event.userId,
        'room_purpose': 'ai_support',
      },
    );

    final result = await createChatRoom(
      CreateChatRoomParams(chatRoom: chatRoom),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (createdRoom) => emit(ChatRoomCreated(createdRoom)),
    );
  }

  Future<void> _onRefreshChatRooms(
    RefreshChatRooms event,
    Emitter<ChatRoomState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatRoomLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await getUserChatRooms(
      GetUserChatRoomsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ChatRoomError(message: failure.message)),
      (chatRooms) => emit(ChatRoomLoaded(
        chatRooms: chatRooms,
        isRefreshing: false,
      )),
    );
  }
}
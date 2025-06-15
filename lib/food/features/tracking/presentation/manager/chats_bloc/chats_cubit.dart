import 'package:bloc/bloc.dart';
import 'package:food/food/features/tracking/domain/entities/chat_entity.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_state.dart';
import 'package:uuid/uuid.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatsInitial());

  void loadChats() async {
    emit(ChatsLoading());
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2), () {
      final chats = [
        ChatEntity(
          id: Uuid().v4(),
          senderID: Uuid().v4(),
          receiverID: Uuid().v4(),
          name: Uuid().v4(),
          imageUrl: Uuid().v4(),
          lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
          lastMessage: Uuid().v4(),
        ),
      ];
      emit(ChatsLoaded(chats: chats));
    });
  }
}

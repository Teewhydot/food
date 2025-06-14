import 'package:bloc/bloc.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatsInitial());

  void loadChats() async {
    emit(ChatsLoading());
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2), () {
      final notifications = [
        // NotificationEntity(
        //   id: '1',
        //   title: 'New Message',
        //   body: 'You have a new message',
        //   createdAt: DateTime.now(),
        // ),
        // NotificationEntity(
        //   id: '2',
        //   title: 'Order Update',
        //   body: 'Your order has been shipped',
        //   createdAt: DateTime.now().subtract(Duration(days: 1)),
        // ),
      ];
      emit(ChatsLoaded(chats: []));
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void loadNotifications() async {
    emit(NotificationLoading());
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
      emit(NotificationLoaded(notifications: []));
    });
  }
}

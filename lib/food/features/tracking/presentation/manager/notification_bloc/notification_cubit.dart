import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';
// import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_state.dart'; // Commented out - using BaseState now

/// Migrated NotificationCubit to use BaseState<List<NotificationEntity>>
class NotificationCubit extends BaseCubit<BaseState<List<NotificationEntity>>> {
  NotificationCubit() : super(const InitialState<List<NotificationEntity>>());

  void loadNotifications() async {
    emit(const LoadingState<List<NotificationEntity>>(message: 'Loading notifications...'));
    
    try {
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      
      // Sample notifications - in real app this would come from a service
      final notifications = [
        NotificationEntity(
          id: '1',
          title: 'New Message',
          body: 'You have a new message',
          createdAt: DateTime.now(),
        ),
        NotificationEntity(
          id: '2',
          title: 'Order Update',
          body: 'Your order has been shipped',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      if (notifications.isEmpty) {
        emit(const EmptyState<List<NotificationEntity>>(message: 'No notifications'));
      } else {
        emit(
          LoadedState<List<NotificationEntity>>(
            data: notifications,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      emit(
        ErrorState<List<NotificationEntity>>(
          errorMessage: 'Failed to load notifications: ${e.toString()}',
          errorCode: 'notifications_load_failed',
          isRetryable: true,
        ),
      );
    }
  }
  
  /// Mark notification as read
  void markAsRead(String notificationId) async {
    if (state.hasData) {
      final currentNotifications = state.data!;
      final updatedNotifications = currentNotifications.map((notification) {
        if (notification.id == notificationId) {
          return NotificationEntity(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            createdAt: notification.createdAt,
            isRead: true,
          );
        }
        return notification;
      }).toList();
      
      emit(
        LoadedState<List<NotificationEntity>>(
          data: updatedNotifications,
          lastUpdated: DateTime.now(),
        ),
      );
      
      emit(
        const SuccessState<List<NotificationEntity>>(
          successMessage: 'Notification marked as read',
        ),
      );
    }
  }
  
  /// Clear all notifications
  void clearAllNotifications() async {
    emit(const LoadingState<List<NotificationEntity>>(message: 'Clearing notifications...'));
    
    try {
      // Simulate network call to clear notifications
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(
        const SuccessState<List<NotificationEntity>>(
          successMessage: 'All notifications cleared',
        ),
      );
      
      emit(const EmptyState<List<NotificationEntity>>(message: 'No notifications'));
    } catch (e) {
      emit(
        ErrorState<List<NotificationEntity>>(
          errorMessage: 'Failed to clear notifications: ${e.toString()}',
          errorCode: 'clear_notifications_failed',
          isRetryable: true,
        ),
      );
    }
  }
}

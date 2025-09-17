import 'package:dartz/dartz.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';

import '../../../domain/use_cases/notification_usecase.dart';

class NotificationCubit extends BaseCubit<BaseState<List<NotificationEntity>>> {
  NotificationCubit() : super(const InitialState<List<NotificationEntity>>());
  final notificationsUseCase = NotificationUseCase();

  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications(
    String userId,
  ) async* {
    yield* notificationsUseCase.watchUserNotifications(userId);
  }

  // /// Mark notification as read
  //
  // /// Clear all notifications
  // void clearAllNotifications(String userId) async {
  //   emit(
  //     const LoadingState<List<NotificationEntity>>(
  //       message: 'Clearing notifications...',
  //     ),
  //   );
  //   final result = await notificationsUseCase.clearAllNotifications(userId);
  //   result.fold(
  //     (failure) {
  //       emit(
  //         ErrorState<List<NotificationEntity>>(
  //           errorMessage: failure.failureMessage,
  //           errorCode: 'clear_notifications_failed',
  //           isRetryable: false,
  //         ),
  //       );
  //     },
  //     (_) {
  //       emit(
  //         const SuccessState<List<NotificationEntity>>(
  //           successMessage: 'All notifications cleared successfully',
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // /// Delete a specific notification
  // void deleteNotification(String notificationId) async {
  //   emit(
  //     const LoadingState<NotificationEntity>(
  //       message: 'Deleting notification...',
  //     ),
  //   );
  //   final result = await notificationsUseCase.deleteNotification(
  //     notificationId,
  //   );
  //   result.fold(
  //     (failure) {
  //       emit(
  //         ErrorState<NotificationEntity>(
  //           errorMessage: failure.failureMessage,
  //           errorCode: 'delete_notification_failed',
  //           isRetryable: false,
  //         ),
  //       );
  //     },
  //     (_) {
  //       emit(
  //         const SuccessState<NotificationEntity>(
  //           successMessage: 'Notification deleted successfully',
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // /// Mark all notifications as read
  // void markAllAsRead(String userId) async {
  //   emit(
  //     const LoadingState<List<NotificationEntity>>(
  //       message: 'Marking all notifications as read...',
  //     ),
  //   );
  //   final result = await notificationsUseCase.markAllNotificationsAsRead(
  //     userId,
  //   );
  //   result.fold(
  //     (failure) {
  //       emit(
  //         ErrorState<List<NotificationEntity>>(
  //           errorMessage: failure.failureMessage,
  //           errorCode: 'mark_all_read_failed',
  //           isRetryable: false,
  //         ),
  //       );
  //     },
  //     (_) {
  //       emit(
  //         const SuccessState<List<NotificationEntity>>(
  //           successMessage: 'All notifications marked as read',
  //         ),
  //       );
  //     },
  //   );
  // }
}

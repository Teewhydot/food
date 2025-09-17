import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../remote/data_sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final remoteDataSource = GetIt.instance<NotificationRemoteDataSource>();

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getUserNotifications(userId);
    });
  }

  @override
  Future<Either<Failure, NotificationEntity>> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return handleExceptions(() async {
      return await remoteDataSource.sendNotification(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    });
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) {
    return handleExceptions(() async {
      await remoteDataSource.markNotificationAsRead(notificationId);
    });
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) {
    return handleExceptions(() async {
      await remoteDataSource.deleteNotification(notificationId);
    });
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() {
    return handleExceptions(() async {
      return await remoteDataSource.getFCMToken();
    });
  }

  @override
  Future<Either<Failure, void>> updateFCMToken(String userId, String token) {
    return handleExceptions(() async {
      await remoteDataSource.updateFCMToken(userId, token);
    });
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> watchUserNotifications(
    String userId,
  ) {
    return ErrorHandler.handleStream(
      () => remoteDataSource.watchUserNotifications(userId),
      operationName: 'watchUserNotifications',
    );
  }

  @override
  Future<Either<Failure, void>> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return handleExceptions(() async {
      await remoteDataSource.sendPushNotification(
        targetUserId: targetUserId,
        title: title,
        body: body,
        data: data,
      );
    });
  }
}

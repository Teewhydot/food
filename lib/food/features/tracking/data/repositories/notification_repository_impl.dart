import 'package:dartz/dartz.dart';
import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../remote/data_sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId) {
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
  Stream<Either<Failure, List<NotificationEntity>>> watchUserNotifications(String userId) {
    try {
      return remoteDataSource.watchUserNotifications(userId).map<Either<Failure, List<NotificationEntity>>>((notifications) {
        return Right(notifications);
      }).handleError((error) {
        return Stream.value(Left<Failure, List<NotificationEntity>>(ServerFailure(failureMessage: error.toString())));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(failureMessage: e.toString())));
    }
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
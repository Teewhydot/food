import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId);
  Future<Either<Failure, NotificationEntity>> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, String?>> getFCMToken();
  Future<Either<Failure, void>> updateFCMToken(String userId, String token);
  Stream<Either<Failure, List<NotificationEntity>>> watchUserNotifications(String userId);
  Future<Either<Failure, void>> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}
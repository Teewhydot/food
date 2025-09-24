import 'package:dartz/dartz.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, String?>> getFCMToken();
  Future<Either<Failure, void>> updateFCMToken(String userId, String token);
  Stream<Either<Failure, List<NotificationEntity>>> watchUserNotifications(
    String userId,
  );
}

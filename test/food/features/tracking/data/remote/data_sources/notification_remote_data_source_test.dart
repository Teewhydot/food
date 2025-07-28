import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:food/food/features/tracking/data/remote/data_sources/notification_remote_data_source.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';

import 'notification_remote_data_source_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
  FirebaseMessaging,
])
void main() {
  late FirebaseNotificationRemoteDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
  late MockFirebaseMessaging mockMessaging;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockMessaging = MockFirebaseMessaging();

    dataSource = FirebaseNotificationRemoteDataSource();
  });

  group('NotificationRemoteDataSource', () {
    const userId = 'test_user_id';
    const notificationId = 'test_notification_id';
    const fcmToken = 'test_fcm_token';

    final testNotificationData = {
      'id': notificationId,
      'title': 'Test Notification',
      'body': 'Test notification body',
      'isRead': false,
      'createdAt': Timestamp.now(),
    };

    group('getUserNotifications', () {
      test('should return list of notifications when successful', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: userId))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testNotificationData);

        // Act
        final result = await dataSource.getUserNotifications(userId);

        // Assert
        expect(result, isA<List<NotificationEntity>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(notificationId));
        verify(mockFirestore.collection('notifications')).called(1);
      });

      test('should throw exception when firestore throws error', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: userId))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => dataSource.getUserNotifications(userId),
          throwsException,
        );
      });
    });

    group('sendNotification', () {
      test('should send notification successfully', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.add(any))
            .thenAnswer((_) async => mockDocumentReference);
        when(mockDocumentReference.id).thenReturn(notificationId);

        // Act
        final result = await dataSource.sendNotification(
          userId: userId,
          title: 'Test Title',
          body: 'Test Body',
          data: {'orderId': 'order123'},
        );

        // Assert
        expect(result, isA<NotificationEntity>());
        expect(result.title, equals('Test Title'));
        verify(mockCollectionReference.add(any)).called(1);
      });
    });

    group('markNotificationAsRead', () {
      test('should mark notification as read successfully', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(notificationId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update({'isRead': true}))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.markNotificationAsRead(notificationId);

        // Assert
        verify(mockDocumentReference.update({'isRead': true})).called(1);
      });
    });

    group('deleteNotification', () {
      test('should delete notification successfully', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(notificationId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete())
            .thenAnswer((_) async => {});

        // Act
        await dataSource.deleteNotification(notificationId);

        // Assert
        verify(mockDocumentReference.delete()).called(1);
      });
    });

    group('getFCMToken', () {
      test('should return FCM token when available', () async {
        // Arrange
        when(mockMessaging.getToken())
            .thenAnswer((_) async => fcmToken);

        // Act
        final result = await dataSource.getFCMToken();

        // Assert
        expect(result, equals(fcmToken));
        verify(mockMessaging.getToken()).called(1);
      });

      test('should return null when token is not available', () async {
        // Arrange
        when(mockMessaging.getToken())
            .thenAnswer((_) async => null);

        // Act
        final result = await dataSource.getFCMToken();

        // Assert
        expect(result, isNull);
      });
    });

    group('updateFCMToken', () {
      test('should update FCM token successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update({'fcmToken': fcmToken}))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.updateFCMToken(userId, fcmToken);

        // Assert
        verify(mockDocumentReference.update({'fcmToken': fcmToken})).called(1);
      });
    });

    group('watchUserNotifications', () {
      test('should return stream of notifications', () async {
        // Arrange
        when(mockFirestore.collection('notifications'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('userId', isEqualTo: userId))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testNotificationData);

        // Act
        final stream = dataSource.watchUserNotifications(userId);

        // Assert
        expect(stream, isA<Stream<List<NotificationEntity>>>());
        
        final notifications = await stream.first;
        expect(notifications.length, equals(1));
        expect(notifications.first.id, equals(notificationId));
      });
    });
  });
}
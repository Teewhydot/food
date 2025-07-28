import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getUserNotifications(String userId);
  Future<NotificationEntity> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<String?> getFCMToken();
  Future<void> updateFCMToken(String userId, String token);
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);
  Future<void> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}

class FirebaseNotificationRemoteDataSource implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => _notificationFromFirestore(doc)).toList();
  }

  @override
  Future<NotificationEntity> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final notificationData = {
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'data': data ?? {},
    };

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notificationData);

    return NotificationEntity(
      id: docRef.id,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  @override
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _notificationFromFirestore(doc))
            .toList());
  }

  @override
  Future<void> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Get the target user's FCM token
    final userDoc = await _firestore.collection('users').doc(targetUserId).get();
    final userData = userDoc.data();
    final fcmToken = userData?['fcmToken'] as String?;

    if (fcmToken == null) {
      // User doesn't have FCM token, save as in-app notification only
      await sendNotification(
        userId: targetUserId,
        title: title,
        body: body,
        data: data,
      );
      return;
    }

    // In production, you would use Firebase Cloud Functions or your backend
    // to send push notifications via FCM HTTP API
    // For now, we'll just save as in-app notification
    await sendNotification(
      userId: targetUserId,
      title: title,
      body: body,
      data: data,
    );

    // TODO: Implement actual push notification sending via Cloud Functions
    // This would typically involve calling your backend API or Firebase Cloud Functions
  }

  NotificationEntity _notificationFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return NotificationEntity(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
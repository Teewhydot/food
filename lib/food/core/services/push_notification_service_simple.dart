import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../routes/routes.dart';
import '../utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.logBasic('Background message: ${message.messageId}', tag: 'Push');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  String? _fcmToken;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        Logger.logWarning('Notifications not authorized', tag: 'Push');
        return;
      }

      // Initialize local notifications
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload?.isNotEmpty ?? false) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _handleNotificationTap(data);
            } catch (_) {}
          }
        },
      );

      // Create Android channels
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        await androidPlugin?.createNotificationChannel(
          const AndroidNotificationChannel(
            'food_channel',
            'Food App',
            importance: Importance.high,
          ),
        );
      }

      // Set FCM handlers
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _onMessageSubscription = FirebaseMessaging.onMessage.listen(_showLocalNotification);
      _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleNotificationTap(message.data),
      );

      // Handle initial message
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage.data);
      }

      // Save token
      await _saveToken();

      _isInitialized = true;
      Logger.logSuccess('Push notifications initialized', tag: 'Push');
    } catch (e) {
      Logger.logError('Failed to initialize: $e', tag: 'Push');
    }
  }

  Future<void> _saveToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      final userId = _auth.currentUser?.uid;

      if (_fcmToken != null && userId != null) {
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': _fcmToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      Logger.logError('Failed to save token: $e', tag: 'Push');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? 'Food App',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'food_channel',
          'Food App',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );

    // Save to Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': notification.title,
        'body': notification.body,
        'data': message.data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'order_update':
        final orderId = data['orderId'] as String?;
        if (orderId != null) {
          Get.toNamed(Routes.tracking, arguments: {'orderId': orderId});
        }
        break;
      case 'chat':
        final chatId = data['chatId'] as String?;
        if (chatId != null) {
          Get.toNamed(Routes.chatScreen, arguments: {'chatId': chatId});
        }
        break;
      default:
        Get.toNamed(Routes.notifications);
    }
  }

  Future<String?> getToken() async => _fcmToken ?? await _messaging.getToken();

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Stream<int> getUnreadCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _isInitialized = false;
  }
}
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import '../../features/tracking/domain/use_cases/notification_usecase.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  Future<void> initialize() async {
    // Request permission for iOS
    if (Platform.isIOS) {
      await _requestPermission();
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get and update FCM token
    await _updateFCMToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Handle messages
    _setupMessageHandlers();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _updateFCMToken() async {
    final token = await _messaging.getToken();
    final userId = _auth.currentUser?.uid;
    
    if (token != null && userId != null) {
      try {
        final notificationUseCase = GetIt.instance<NotificationUseCase>();
        await notificationUseCase.updateFCMToken(userId, token);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to update FCM token: $e');
        }
      }
    }
  }

  void _onTokenRefresh(String token) async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final notificationUseCase = GetIt.instance<NotificationUseCase>();
        await notificationUseCase.updateFCMToken(userId, token);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to update FCM token on refresh: $e');
        }
      }
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from background
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle messages when app is opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received message in foreground: ${message.messageId}');
    }

    // Show local notification when app is in foreground
    _showLocalNotification(message);

    // Save notification to database
    _saveNotificationToDatabase(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message clicked: ${message.messageId}');
    }

    // Handle navigation based on message data
    _handleNotificationTap(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'food_app_channel',
      'Food App Notifications',
      channelDescription: 'Notifications for food orders and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Food App',
      message.notification?.body ?? 'You have a new notification',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _saveNotificationToDatabase(RemoteMessage message) {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final notificationUseCase = GetIt.instance<NotificationUseCase>();
        notificationUseCase.sendNotification(
          userId: userId,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
          data: message.data,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save notification to database: $e');
        }
      }
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        // Parse payload and handle navigation
        final data = <String, dynamic>{}; // Parse the payload string
        _handleNotificationTap(data);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to handle notification response: $e');
        }
      }
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'order_update':
        final orderId = data['orderId'] as String?;
        if (orderId != null) {
          // Navigate to order details screen
          _navigateToOrderDetails(orderId);
        }
        break;
      case 'new_message':
        final chatId = data['chatId'] as String?;
        if (chatId != null) {
          // Navigate to chat screen
          _navigateToChatScreen(chatId);
        }
        break;
      default:
        // Navigate to notifications screen
        _navigateToNotifications();
    }
  }

  void _navigateToOrderDetails(String orderId) {
    // TODO: Implement navigation to order details
    if (kDebugMode) {
      print('Navigate to order details: $orderId');
    }
  }

  void _navigateToChatScreen(String chatId) {
    // TODO: Implement navigation to chat screen
    if (kDebugMode) {
      print('Navigate to chat screen: $chatId');
    }
  }

  void _navigateToNotifications() {
    // TODO: Implement navigation to notifications screen
    if (kDebugMode) {
      print('Navigate to notifications screen');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}
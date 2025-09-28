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
import 'notification_preferences_service.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.logBasic(
    'Handling background message: ${message.messageId}',
    tag: 'NotificationService',
  );
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();

  bool _isInitialized = false;
  String? _fcmToken;

  // Stream subscriptions for proper cleanup
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;
  StreamSubscription<User?>? _authStateSubscription;

  // Notification channels
  static const String _orderChannelId = 'order_channel';
  static const String _orderChannelName = 'Order Notifications';
  static const String _orderChannelDescription =
      'Notifications for order updates and delivery';

  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.logWarning(
        'PushNotificationService already initialized',
        tag: 'NotificationService',
      );
      return;
    }

    try {
      // Request notification permissions
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.logSuccess(
          'User granted notification permissions',
          tag: 'NotificationService',
        );

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Configure FCM
        await _configureFCM();

        // Get FCM token (but don't save yet if no user is logged in)
        _fcmToken = await _messaging.getToken();
        Logger.logSuccess('FCM token generated', tag: 'NotificationService');

        // Save token if user is already authenticated
        if (_auth.currentUser != null) {
          await _saveFCMTokenForCurrentUser();
        }

        // Listen for auth state changes to save token when user logs in
        _authStateSubscription = _auth.authStateChanges().listen((user) async {
          if (user != null && _fcmToken != null) {
            await _saveFCMTokenForCurrentUser();
          }
        });

        // Initialize preferences service
        await _preferencesService.initialize();

        // Setup token refresh listener
        _setupTokenRefreshListener();

        _isInitialized = true;
        Logger.logSuccess(
          'PushNotificationService initialized successfully',
          tag: 'NotificationService',
        );
      } else {
        Logger.logWarning(
          'User declined notification permissions',
          tag: 'NotificationService',
        );
      }
    } catch (e) {
      Logger.logError(
        'Failed to initialize notifications: $e',
        tag: 'NotificationService',
      );
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    Logger.logBasic(
      'Permission status: ${settings.authorizationStatus}',
      tag: 'NotificationService',
    );
    return settings;
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      // Order channel
      const orderChannel = AndroidNotificationChannel(
        _orderChannelId,
        _orderChannelName,
        description: _orderChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await androidPlugin.createNotificationChannel(orderChannel);

      Logger.logSuccess(
        'Notification channels created',
        tag: 'NotificationService',
      );
    }
  }

  Future<void> _configureFCM() async {
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Handle notification taps when app is in background/terminated
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
        .listen(_handleNotificationOpen);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  // Public method to save FCM token for the current authenticated user
  Future<void> saveFCMTokenForCurrentUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      Logger.logWarning('Cannot save FCM token: No authenticated user', tag: 'NotificationService');
      return;
    }

    _fcmToken ??= await _messaging.getToken();

    await _saveFCMTokenForCurrentUser();
  }

  Future<void> _saveFCMTokenForCurrentUser() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || _fcmToken == null) {
        Logger.logWarning('Cannot save token: userId=$userId, token=${_fcmToken != null ? 'exists' : 'null'}', tag: 'NotificationService');
        return;
      }

      // Save FCM token to Firestore
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': _fcmToken,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      }, SetOptions(merge: true));

      Logger.logSuccess(
        'FCM token saved successfully for user $userId',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.logError(
        'Failed to save FCM token: $e',
        tag: 'NotificationService',
      );
    }
  }

  void _setupTokenRefreshListener() {
    // Listen for token refresh
    _onTokenRefreshSubscription = _messaging.onTokenRefresh.listen((
      newToken,
    ) async {
      _fcmToken = newToken;
      Logger.logBasic('FCM token refreshed', tag: 'NotificationService');

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _saveFCMTokenForCurrentUser();
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Logger.logBasic(
      'Received foreground message: ${message.messageId}',
      tag: 'NotificationService',
    );

    // Check if notification type is allowed
    final notificationType = message.data['type'] ?? 'general';
    final isAllowed = await _preferencesService.isNotificationTypeAllowed(
      notificationType,
    );

    if (isAllowed) {
      // Save notification to Firestore
      await _saveNotificationToFirestore(message);

      // Show local notification
      await _showLocalNotification(message);
    } else {
      Logger.logWarning(
        'Notification blocked due to user preferences: $notificationType',
        tag: 'NotificationService',
      );
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    // Determine channel based on notification type
    String channelId = _orderChannelId;
    String channelName = _orderChannelName;
    String channelDescription = _orderChannelDescription;

    final type = data['type'] as String?;
    switch (type) {
      case 'order_update':
      case 'delivery_update':
      default:
        // Use order channel as default
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      ticker: notification?.title,
      styleInformation: BigTextStyleInformation(
        notification?.body ?? '',
        contentTitle: notification?.title,
        summaryText: data['summary'] as String?,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification?.title ?? 'Food App',
      notification?.body ?? 'You have a new notification',
      details,
      payload: jsonEncode(data),
    );
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': message.notification?.title,
          'body': message.notification?.body,
          'data': message.data,
          'isRead': false,
          'type': message.data['type'] ?? 'general',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Logger.logError(
        'Failed to save notification to Firestore: $e',
        tag: 'NotificationService',
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationTap(data);
      } catch (e) {
        Logger.logError(
          'Failed to parse notification payload: $e',
          tag: 'NotificationService',
        );
      }
    }
  }

  void _handleNotificationOpen(RemoteMessage message) {
    Logger.logBasic(
      'Notification opened: ${message.data}',
      tag: 'NotificationService',
    );
    _handleNotificationTap(message.data);
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    Logger.logBasic(
      'Handling notification tap: type=$type',
      tag: 'NotificationService',
    );

    switch (type) {
      case 'order_update':
      case 'delivery_update':
        final orderId = data['orderId'] as String?;
        if (orderId != null) {
          _navigateToOrderDetails(orderId);
        } else {
          _navigateToOrders();
        }
        break;
      case 'new_message':
      case 'chat':
        final chatId = data['chatId'] as String?;
        if (chatId != null) {
          _navigateToChatScreen(chatId);
        } else {
          _navigateToNotifications();
        }
        break;
      case 'promotion':
      case 'offer':
        final restaurantId = data['restaurantId'] as String?;
        if (restaurantId != null) {
          _navigateToRestaurant(restaurantId);
        } else {
          _navigateToHome();
        }
        break;
      default:
        _navigateToNotifications();
    }
  }

  void _navigateToOrderDetails(String orderId) {
    Logger.logBasic(
      'Navigate to order details: $orderId',
      tag: 'NotificationService',
    );
    Get.toNamed(Routes.tracking, arguments: {'orderId': orderId});
  }

  void _navigateToOrders() {
    Logger.logBasic('Navigate to orders', tag: 'NotificationService');
    Get.toNamed(Routes.orderHistory);
  }

  void _navigateToChatScreen(String chatId) {
    Logger.logBasic(
      'Navigate to chat screen: $chatId',
      tag: 'NotificationService',
    );
    Get.toNamed(Routes.chatScreen, arguments: {'chatId': chatId});
  }

  void _navigateToRestaurant(String restaurantId) {
    Logger.logBasic(
      'Navigate to restaurant: $restaurantId',
      tag: 'NotificationService',
    );
    Get.toNamed(
      Routes.restaurantDetails,
      arguments: {'restaurantId': restaurantId},
    );
  }

  void _navigateToHome() {
    Logger.logBasic('Navigate to home', tag: 'NotificationService');
    Get.toNamed(Routes.home);
  }

  void _navigateToNotifications() {
    Logger.logBasic('Navigate to notifications', tag: 'NotificationService');
    Get.toNamed(Routes.notifications);
  }

  // Public methods
  Future<String?> getToken() async {
    return _fcmToken ?? await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.logSuccess(
        'Subscribed to topic: $topic',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.logError(
        'Failed to subscribe to topic: $e',
        tag: 'NotificationService',
      );
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.logSuccess(
        'Unsubscribed from topic: $topic',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.logError(
        'Failed to unsubscribe from topic: $e',
        tag: 'NotificationService',
      );
    }
  }

  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    Logger.logSuccess('All notifications cleared', tag: 'NotificationService');
  }

  Future<void> clearNotification(int id) async {
    await _localNotifications.cancel(id);
    Logger.logSuccess('Notification $id cleared', tag: 'NotificationService');
  }

  Future<void> updateFCMToken() async {
    await saveFCMTokenForCurrentUser();
  }

  // Get notifications from Firestore
  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList(),
        );
  }

  // Get unread notifications count
  Stream<int> getUnreadNotificationsCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      Logger.logSuccess(
        'Notification marked as read: $notificationId',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.logError(
        'Failed to mark notification as read: $e',
        tag: 'NotificationService',
      );
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final batch = _firestore.batch();
        final unreadNotifications =
            await _firestore
                .collection('notifications')
                .where('userId', isEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .get();

        for (final doc in unreadNotifications.docs) {
          batch.update(doc.reference, {
            'isRead': true,
            'readAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
        Logger.logSuccess(
          'All notifications marked as read',
          tag: 'NotificationService',
        );
      }
    } catch (e) {
      Logger.logError(
        'Failed to mark all notifications as read: $e',
        tag: 'NotificationService',
      );
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      Logger.logSuccess(
        'Notification deleted: $notificationId',
        tag: 'NotificationService',
      );
    } catch (e) {
      Logger.logError(
        'Failed to delete notification: $e',
        tag: 'NotificationService',
      );
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Request to enable notifications if disabled
  Future<bool> requestEnableNotifications() async {
    final settings = await _requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
    _authStateSubscription?.cancel();

    _onMessageSubscription = null;
    _onMessageOpenedAppSubscription = null;
    _onTokenRefreshSubscription = null;
    _authStateSubscription = null;

    _isInitialized = false;
    Logger.logBasic(
      'PushNotificationService disposed',
      tag: 'NotificationService',
    );
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Configuration for notification channels
class NotificationChannels {
  NotificationChannels._();

  // Channel IDs
  static const String orderChannelId = 'order_channel';
  static const String chatChannelId = 'chat_channel';
  static const String promotionChannelId = 'promotion_channel';
  static const String systemChannelId = 'system_channel';

  // Channel Names
  static const String orderChannelName = 'Order Notifications';
  static const String chatChannelName = 'Chat Messages';
  static const String promotionChannelName = 'Promotions & Offers';
  static const String systemChannelName = 'System Notifications';

  // Channel Descriptions
  static const String orderChannelDescription = 'Notifications for order updates, delivery status, and order confirmations';
  static const String chatChannelDescription = 'Notifications for new messages from delivery partners and support';
  static const String promotionChannelDescription = 'Special offers, discounts, and promotional notifications';
  static const String systemChannelDescription = 'Important system updates and app notifications';

  // Create all Android notification channels
  static List<AndroidNotificationChannel> getAllChannels() {
    return [
      getOrderChannel(),
      getChatChannel(),
      getPromotionChannel(),
      getSystemChannel(),
    ];
  }

  // Order notification channel
  static AndroidNotificationChannel getOrderChannel() {
    return const AndroidNotificationChannel(
      orderChannelId,
      orderChannelName,
      description: orderChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );
  }

  // Chat notification channel
  static AndroidNotificationChannel getChatChannel() {
    return const AndroidNotificationChannel(
      chatChannelId,
      chatChannelName,
      description: chatChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
  }

  // Promotion notification channel
  static AndroidNotificationChannel getPromotionChannel() {
    return const AndroidNotificationChannel(
      promotionChannelId,
      promotionChannelName,
      description: promotionChannelDescription,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
      showBadge: true,
    );
  }

  // System notification channel
  static AndroidNotificationChannel getSystemChannel() {
    return const AndroidNotificationChannel(
      systemChannelId,
      systemChannelName,
      description: systemChannelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );
  }

  // Get channel ID based on notification type
  static String getChannelIdForType(String? type) {
    switch (type) {
      case 'order_update':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_ready':
      case 'order_picked':
      case 'order_delivered':
      case 'order_cancelled':
      case 'delivery_update':
      case 'delivery_assigned':
      case 'delivery_started':
      case 'delivery_arrived':
        return orderChannelId;

      case 'chat':
      case 'new_message':
      case 'support_message':
      case 'driver_message':
        return chatChannelId;

      case 'promotion':
      case 'offer':
      case 'discount':
      case 'special_offer':
      case 'new_restaurant':
      case 'featured':
        return promotionChannelId;

      case 'system':
      case 'app_update':
      case 'maintenance':
      case 'announcement':
        return systemChannelId;

      default:
        return orderChannelId; // Default to order channel
    }
  }

  // Get Android notification details for a specific type
  static AndroidNotificationDetails getAndroidDetailsForType(String? type) {
    final channelId = getChannelIdForType(type);

    switch (channelId) {
      case orderChannelId:
        return const AndroidNotificationDetails(
          orderChannelId,
          orderChannelName,
          channelDescription: orderChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

      case chatChannelId:
        return const AndroidNotificationDetails(
          chatChannelId,
          chatChannelName,
          channelDescription: chatChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

      case promotionChannelId:
        return const AndroidNotificationDetails(
          promotionChannelId,
          promotionChannelName,
          channelDescription: promotionChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

      case systemChannelId:
        return const AndroidNotificationDetails(
          systemChannelId,
          systemChannelName,
          channelDescription: systemChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

      default:
        return const AndroidNotificationDetails(
          orderChannelId,
          orderChannelName,
          channelDescription: orderChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );
    }
  }

  // Get iOS notification details (consistent across all types)
  static DarwinNotificationDetails getIOSDetails({
    bool presentAlert = true,
    bool presentBadge = true,
    bool presentSound = true,
  }) {
    return DarwinNotificationDetails(
      presentAlert: presentAlert,
      presentBadge: presentBadge,
      presentSound: presentSound,
    );
  }

  // Get complete notification details for a specific type
  static NotificationDetails getNotificationDetails(
    String? type, {
    String? androidIcon,
    bool presentAlert = true,
    bool presentBadge = true,
    bool presentSound = true,
  }) {
    var androidDetails = getAndroidDetailsForType(type);

    // Override icon if provided
    if (androidIcon != null) {
      final channelId = getChannelIdForType(type);
      final channel = getAllChannels().firstWhere(
        (c) => c.id == channelId,
        orElse: () => getOrderChannel(),
      );

      androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: androidDetails.importance,
        priority: androidDetails.priority,
        showWhen: true,
        enableVibration: true,
        icon: androidIcon,
      );
    }

    final iosDetails = getIOSDetails(
      presentAlert: presentAlert,
      presentBadge: presentBadge,
      presentSound: presentSound,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
}
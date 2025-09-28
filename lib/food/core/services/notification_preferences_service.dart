import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/logger.dart';
import 'hive_cache_service.dart';

/// Service to manage user notification preferences
/// Stores preferences locally using Hive for offline support
/// and syncs with Firestore for persistence across devices
class NotificationPreferencesService {
  static final NotificationPreferencesService _instance = NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveCacheService _cacheService = HiveCacheService.instance;

  static const String _preferencesKey = 'notification_preferences';
  static const String _collectionName = 'userPreferences';

  // Default notification types
  static const Map<String, bool> _defaultPreferences = {
    'order_update': true,
    'delivery_update': true,
    'new_message': true,
    'chat': true,
    'promotion': true,
    'offer': true,
    'general': true,
    'system': true,
  };

  Map<String, bool> _preferences = Map.from(_defaultPreferences);
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _pushEnabled = true;

  Future<void> initialize() async {
    try {
      await _loadPreferences();
      Logger.logSuccess('NotificationPreferencesService initialized', tag: 'NotificationPreferences');
    } catch (e) {
      Logger.logError('Failed to initialize NotificationPreferencesService: $e', tag: 'NotificationPreferences');
    }
  }

  Future<void> _loadPreferences() async {
    // Try to load from local cache first
    await _loadFromCache();

    // Then sync with Firestore
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _syncWithFirestore(userId);
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(_preferencesKey);
      if (cached != null) {
        final prefs = Map<String, dynamic>.from(cached);

        // Load notification type preferences
        if (prefs['types'] != null && prefs['types'] is Map) {
          _preferences = Map<String, bool>.from(prefs['types']);
        }

        // Load sound/vibration settings
        _soundEnabled = prefs['soundEnabled'] ?? true;
        _vibrationEnabled = prefs['vibrationEnabled'] ?? true;
        _pushEnabled = prefs['pushEnabled'] ?? true;

        Logger.logBasic('Loaded preferences from cache', tag: 'NotificationPreferences');
      }
    } catch (e) {
      Logger.logError('Failed to load preferences from cache: $e', tag: 'NotificationPreferences');
    }
  }

  Future<void> _syncWithFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final notificationPrefs = data['notifications'] as Map<String, dynamic>?;

        if (notificationPrefs != null) {
          // Update type preferences
          if (notificationPrefs['types'] != null && notificationPrefs['types'] is Map) {
            _preferences = Map<String, bool>.from(notificationPrefs['types']);
          }

          // Update settings
          _soundEnabled = notificationPrefs['soundEnabled'] ?? true;
          _vibrationEnabled = notificationPrefs['vibrationEnabled'] ?? true;
          _pushEnabled = notificationPrefs['pushEnabled'] ?? true;

          // Save to cache
          await _saveToCache();

          Logger.logSuccess('Synced preferences from Firestore', tag: 'NotificationPreferences');
        }
      } else {
        // Create default preferences in Firestore
        await _saveToFirestore(userId);
      }
    } catch (e) {
      Logger.logError('Failed to sync with Firestore: $e', tag: 'NotificationPreferences');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = {
        'types': _preferences,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
        'pushEnabled': _pushEnabled,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _cacheService.store(_preferencesKey, prefs);
      Logger.logBasic('Saved preferences to cache', tag: 'NotificationPreferences');
    } catch (e) {
      Logger.logError('Failed to save preferences to cache: $e', tag: 'NotificationPreferences');
    }
  }

  Future<void> _saveToFirestore(String userId) async {
    try {
      final prefs = {
        'notifications': {
          'types': _preferences,
          'soundEnabled': _soundEnabled,
          'vibrationEnabled': _vibrationEnabled,
          'pushEnabled': _pushEnabled,
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      };

      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set(prefs, SetOptions(merge: true));

      Logger.logSuccess('Saved preferences to Firestore', tag: 'NotificationPreferences');
    } catch (e) {
      Logger.logError('Failed to save preferences to Firestore: $e', tag: 'NotificationPreferences');
    }
  }

  // Check if a specific notification type is allowed
  Future<bool> isNotificationTypeAllowed(String type) async {
    // If push notifications are disabled globally, return false
    if (!_pushEnabled) {
      return false;
    }

    // Check specific type preference
    return _preferences[type] ?? _defaultPreferences[type] ?? true;
  }

  // Update preference for a specific notification type
  Future<void> setNotificationTypeAllowed(String type, bool allowed) async {
    _preferences[type] = allowed;

    // Save to cache and Firestore
    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logBasic('Updated notification preference: $type = $allowed', tag: 'NotificationPreferences');
  }

  // Get all notification preferences
  Map<String, bool> getPreferences() {
    return Map.from(_preferences);
  }

  // Update all preferences at once
  Future<void> setPreferences(Map<String, bool> preferences) async {
    _preferences = Map.from(preferences);

    // Save to cache and Firestore
    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logSuccess('Updated all notification preferences', tag: 'NotificationPreferences');
  }

  // Sound settings
  bool get soundEnabled => _soundEnabled;

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logBasic('Sound notifications: $enabled', tag: 'NotificationPreferences');
  }

  // Vibration settings
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logBasic('Vibration notifications: $enabled', tag: 'NotificationPreferences');
  }

  // Master push notification toggle
  bool get pushEnabled => _pushEnabled;

  Future<void> setPushEnabled(bool enabled) async {
    _pushEnabled = enabled;
    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logBasic('Push notifications: $enabled', tag: 'NotificationPreferences');
  }

  // Reset to default preferences
  Future<void> resetToDefaults() async {
    _preferences = Map.from(_defaultPreferences);
    _soundEnabled = true;
    _vibrationEnabled = true;
    _pushEnabled = true;

    await _saveToCache();

    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    Logger.logSuccess('Reset notification preferences to defaults', tag: 'NotificationPreferences');
  }

  // Get notification type display names
  static Map<String, String> getNotificationTypeDisplayNames() {
    return {
      'order_update': 'Order Updates',
      'delivery_update': 'Delivery Updates',
      'new_message': 'New Messages',
      'chat': 'Chat Notifications',
      'promotion': 'Promotions',
      'offer': 'Special Offers',
      'general': 'General Notifications',
      'system': 'System Updates',
    };
  }

  // Get notification type descriptions
  static Map<String, String> getNotificationTypeDescriptions() {
    return {
      'order_update': 'Get notified about order status changes',
      'delivery_update': 'Receive updates about your delivery',
      'new_message': 'Get alerts for new chat messages',
      'chat': 'Notifications from chat conversations',
      'promotion': 'Receive promotional notifications',
      'offer': 'Get notified about special offers and discounts',
      'general': 'General app notifications',
      'system': 'Important system and app updates',
    };
  }
}
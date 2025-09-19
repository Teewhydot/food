// ========================================================================
// Notification Service - FCM Notifications and Admin Alerts
// ========================================================================

const axios = require('axios');
const admin = require('firebase-admin');
const { GoogleAuth } = require('google-auth-library');
const {
  ENVIRONMENT,
  GOOGLE_SCOPES,
  TRANSACTION_TYPES,
  NOTIFICATION_TYPE_MAP,
  ADMIN_NOTIFICATION_TITLES,
  TARGET_ROLES
} = require('../utils/constants');
const { logger } = require('../utils/logger');
const { dbHelper } = require('../utils/database');

class NotificationService {
  constructor() {
    this.projectId = ENVIRONMENT.PROJECT_ID;
    this.fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`;
  }

  // ========================================================================
  // Authentication and Access Token Management
  // ========================================================================

  async getAccessToken(executionId = 'auth-token') {
    try {
      logger.info('Getting FCM access token', executionId);

      // Create a new GoogleAuth instance with ADC
      const auth = new GoogleAuth({
        scopes: GOOGLE_SCOPES
      });

      // Get a client with the credentials
      const client = await auth.getClient();

      // Get the access token
      const tokenResponse = await client.getAccessToken();

      if (!tokenResponse || !tokenResponse.token) {
        throw new Error('Failed to obtain access token');
      }

      logger.success('Successfully obtained access token', executionId);
      return tokenResponse.token;
    } catch (error) {
      logger.warning('Primary method failed, trying alternative', executionId);

      try {
        // Use the admin SDK to get an access token
        const token = await admin.credential.applicationDefault().getAccessToken();
        logger.success('Successfully obtained access token via alternative method', executionId);
        return token.access_token;
      } catch (altError) {
        logger.error('All access token methods failed', executionId, error);
        throw error;
      }
    }
  }

  // ========================================================================
  // User FCM Notifications
  // ========================================================================

  async sendNotificationToUser(userId, title, body, data = {}, executionId = 'fcm-user') {
    let userToken = null;

    try {
      logger.notification('SEND', userId, title, executionId);

      // Get user's FCM token and preferences from Firestore
      const { doc: userDoc, data: userData } = await dbHelper.getDocument('users', userId, executionId);
      if (!userDoc) {
        throw new Error('User not found');
      }

      const { token, fcmToken, notificationPreferences = ['general', 'payment', 'appUpdate'] } = userData;

      // Check both token and fcmToken fields for compatibility
      userToken = token || fcmToken;

      if (!userToken) {
        throw new Error('User does not have an FCM token');
      }

      // Check if notification type is allowed based on user preferences
      const notificationType = data.type || 'general';
      const preferenceCategory = this.mapNotificationTypeToPreference(notificationType);

      if (!notificationPreferences.includes(preferenceCategory)) {
        logger.warning(`Notification blocked for user ${userId} - type: ${notificationType}, category: ${preferenceCategory}`, executionId);
        return {
          success: false,
          reason: 'User has disabled this notification type'
        };
      }

      // Create notification document in Firestore
      const notificationRef = await dbHelper.addDocument(`users/${userId}/notifications`, {
        title,
        body,
        data: data || {},
        type: data.type || 'general',
        read: false,
        createdAt: dbHelper.getServerTimestamp()
      }, executionId);

      // Update unread count
      await dbHelper.updateDocument('users', userId, {
        unreadNotifications: dbHelper.increment(1)
      }, executionId);

      // Send FCM notification
      const result = await this.sendFCMMessage(userToken, title, body, {
        ...data,
        notificationId: notificationRef.id
      }, executionId);

      if (result.success) {
        logger.success(`FCM notification sent to user ${userId}`, executionId);
      }

      return result;
    } catch (error) {
      logger.error(`Failed to send notification to user ${userId}`, executionId, error);

      // Try to invalidate the token if it's invalid
      if (error.message.includes('invalid') && userToken) {
        await this.invalidateUserToken(userId, userToken, executionId);
      }

      return {
        success: false,
        error: error.message
      };
    }
  }

  async sendFCMMessage(token, title, body, data = {}, executionId = 'fcm-send') {
    try {
      // Get OAuth2 token for FCM
      const serverKey = await this.getAccessToken(executionId);

      // Prepare FCM message using the v1 API format
      // Ensure all data values are strings (FCM requirement)
      const stringifiedData = {};
      for (const [key, value] of Object.entries(data)) {
        stringifiedData[key] = String(value);
      }

      const message = {
        message: {
          token: token,
          notification: {
            title,
            body,
          },
          data: stringifiedData,
          android: {
            priority: 'high',
            notification: {
              sound: 'default',
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'default'
              }
            }
          }
        }
      };

      logger.apiCall('POST', this.fcmEndpoint, null, executionId);

      const fcmResponse = await axios.post(
        this.fcmEndpoint,
        message,
        {
          headers: {
            'Authorization': `Bearer ${serverKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 10000
        }
      );

      if (fcmResponse.status === 200) {
        logger.success('FCM message sent successfully', executionId, {
          messageId: fcmResponse.data.name
        });
        return {
          success: true,
          messageId: fcmResponse.data.name
        };
      } else {
        throw new Error(`FCM API error: ${fcmResponse.status}`);
      }
    } catch (error) {
      logger.error('Failed to send FCM message', executionId, error);
      return {
        success: false,
        error: error.message,
        details: error.response?.data || null
      };
    }
  }

  mapNotificationTypeToPreference(notificationType) {
    const typeMapping = {
      'booking': 'general',
      'booking_created': 'general',
      'food_order': 'general',
      'food_order_created': 'general',
      'food_order_success': 'general',
      'reminder': 'general',
      'promotion': 'general',
      'system': 'general',
      'payment': 'payment',
      'payment_success': 'payment',
      'payment_verified': 'payment',
      'appUpdate': 'appUpdate',
      'general': 'general'
    };

    return typeMapping[notificationType] || 'general';
  }

  // ========================================================================
  // Staff and Admin Notifications
  // ========================================================================

  async notifyStaffForNewOrder(orderReference, serviceType, orderDetails, executionId = 'staff-notify') {
    try {
      logger.processing(`Notifying staff for new ${serviceType} order: ${orderReference}`, executionId);

      // Map service types to required permissions
      const permissionMap = {
        'food_delivery': 'food_delivery.read',
        'laundry_service': 'laundry.read',
        'gym': 'gym.read',
        'swimming_pool': 'pool.read',
        'spa': 'spa.read',
        'concierge': 'concierge.read'
      };

      const requiredPermission = permissionMap[serviceType];
      if (!requiredPermission) {
        logger.warning(`No permission mapping for service type: ${serviceType}`, executionId);
        return;
      }

      // Query admins collection for staff with the required permission
      const staffMembers = await dbHelper.queryDocuments('admins', [
        { field: 'permissions', operator: 'array-contains', value: requiredPermission }
      ], null, null, executionId);

      if (staffMembers.length === 0) {
        logger.warning(`No staff found with permission: ${requiredPermission}`, executionId);
        return;
      }

      logger.info(`Found ${staffMembers.length} staff members with ${requiredPermission} permission`, executionId);

      // Prepare notification content
      const notificationTitle = `New ${serviceType.replace(/_/g, ' ').toUpperCase()} Order 🔔`;
      let notificationBody = `Order #${orderReference} requires attention`;

      // Customize notification based on service type
      notificationBody = this.generateStaffNotificationBody(serviceType, orderReference, orderDetails);

      const notificationData = {
        type: 'staff_order_notification',
        orderReference: orderReference,
        serviceType: serviceType,
        orderId: orderReference,
        action: 'view_order'
      };

      // Send notification to each qualified staff member
      const notificationPromises = staffMembers.map(staff =>
        this.sendNotificationToUser(staff.id, notificationTitle, notificationBody, notificationData, `${executionId}-${staff.id}`)
      );

      const results = await Promise.allSettled(notificationPromises);
      const successCount = results.filter(result => result.status === 'fulfilled' && result.value.success).length;

      logger.info(`Staff notifications sent: ${successCount}/${staffMembers.length} successful`, executionId);
    } catch (error) {
      logger.error(`Error notifying staff`, executionId, error);
    }
  }

  generateStaffNotificationBody(serviceType, orderReference, orderDetails) {
    switch (serviceType) {
      case 'food_delivery':
        if (orderDetails.items) {
          const itemCount = orderDetails.items.length;
          const deliverTo = orderDetails.deliverTo || 'delivery';
          return `New food order with ${itemCount} items for ${deliverTo}`;
        }
        break;
      case 'laundry_service':
        const customerName = orderDetails.userName || orderDetails.customerName || 'guest';
        return `New laundry service request from ${customerName}`;
      case 'gym':
      case 'swimming_pool':
      case 'spa':
        const bookingDate = orderDetails.bookingDate || orderDetails.sessionDate || 'today';
        return `New ${serviceType.replace(/_/g, ' ')} booking for ${bookingDate}`;
      default:
        return `Order #${orderReference} requires attention`;
    }
  }

  async createAdminNotification(transactionType, data, executionId = 'admin-notify') {
    try {
      const notificationData = {
        title: this.getAdminNotificationTitle(transactionType, data),
        message: this.getAdminNotificationMessage(transactionType, data),
        type: NOTIFICATION_TYPE_MAP[transactionType] || 'system',
        priority: 'high',
        relatedOrderId: data.reference,
        relatedUserId: data.userId,
        timestamp: dbHelper.getServerTimestamp(),
        isRead: false,
        targetRoles: TARGET_ROLES[transactionType] || ['admin'],
        metadata: {
          transactionType: transactionType,
          amount: data.amount,
          customerName: data.userName
        }
      };

      // Save to admin notifications collection
      await dbHelper.addDocument('notifications', notificationData, executionId);

      // Queue push notifications for relevant admin staff
      await this.queueAdminPushNotifications(transactionType, notificationData, executionId);

      logger.success(`Admin notification created for ${transactionType}: ${data.reference}`, executionId);
    } catch (error) {
      logger.error('Error creating admin notification', executionId, error);
    }
  }

  getAdminNotificationTitle(transactionType, data) {
    return ADMIN_NOTIFICATION_TITLES[transactionType] || 'New Service Request';
  }

  getAdminNotificationMessage(transactionType, data) {
    const messages = {
      'booking': `${data.userName} has made a new booking (${data.reference}) - ₦${data.amount.toLocaleString()}`,
      'food_order': `${data.userName} placed a food order (${data.reference}) - ₦${data.amount.toLocaleString()}`,
      'gym_session': `${data.userName} booked a gym session (${data.reference}) - ₦${data.amount.toLocaleString()}`,
      'pool_session': `${data.userName} booked a pool session (${data.reference}) - ₦${data.amount.toLocaleString()}`,
      'laundry_service': `${data.userName} requested laundry service (${data.reference}) - ₦${data.amount.toLocaleString()}`
    };

    return messages[transactionType] || `${data.userName} made a service request (${data.reference}) - ₦${data.amount.toLocaleString()}`;
  }

  async queueAdminPushNotifications(transactionType, notificationData, executionId = 'admin-push') {
    try {
      const targetRoles = notificationData.targetRoles || ['admin'];

      // Query for admin users with target roles
      const adminPromises = targetRoles.map(role =>
        dbHelper.queryDocuments('admins', [
          { field: 'role', operator: '==', value: role },
          { field: 'isActive', operator: '==', value: true }
        ], null, null, executionId)
      );

      const adminResults = await Promise.all(adminPromises);
      const allAdmins = adminResults.flat();

      if (allAdmins.length === 0) {
        logger.warning(`No active admins found for roles: ${targetRoles.join(', ')}`, executionId);
        return;
      }

      // Send push notifications to all relevant admins
      const pushPromises = allAdmins.map(admin =>
        this.sendNotificationToUser(
          admin.id,
          notificationData.title,
          notificationData.message,
          {
            type: 'admin_notification',
            priority: notificationData.priority,
            orderId: notificationData.relatedOrderId,
            action: 'view_admin_dashboard'
          },
          `${executionId}-${admin.id}`
        )
      );

      const results = await Promise.allSettled(pushPromises);
      const successCount = results.filter(result => result.status === 'fulfilled' && result.value.success).length;

      logger.info(`Admin push notifications sent: ${successCount}/${allAdmins.length} successful`, executionId);
    } catch (error) {
      logger.error('Error queuing admin push notifications', executionId, error);
    }
  }

  // ========================================================================
  // Notification Data Generation
  // ========================================================================

  generateNotificationData(transactionType, details, reference, amount, isSuccess = false) {
    const config = TRANSACTION_TYPES[transactionType];
    if (!config) return null;

    const baseData = {
      reference: reference,
      amount: amount.toString(),
      type: isSuccess ? `${transactionType}_success` : `${transactionType}_created`
    };

    switch (transactionType) {
      case 'booking':
        return {
          ...baseData,
          bookingId: reference,
          checkIn: details.checkInDate,
          checkOut: details.checkOutDate,
          ...(isSuccess && { paymentDate: new Date().toISOString() })
        };

      case 'food_order':
        return {
          ...baseData,
          orderId: reference,
          deliverTo: details.deliverTo || '',
          itemCount: String(details.items?.length || 0),
          ...(isSuccess && { paymentDate: new Date().toISOString() })
        };

      case 'gym_session':
      case 'pool_session':
      case 'spa_session':
        return {
          ...baseData,
          sessionId: reference,
          sessionDate: details.sessionDate || '',
          sessionTime: details.sessionTime || '',
          duration: String(details.duration || 60),
          ...(isSuccess && { paymentDate: new Date().toISOString() })
        };

      case 'laundry_service':
        return {
          ...baseData,
          laundryId: reference,
          pickupLocation: details.pickupLocation || '',
          itemCount: String(details.items?.length || 0),
          ...(isSuccess && { paymentDate: new Date().toISOString() })
        };

      default:
        return baseData;
    }
  }

  // ========================================================================
  // Token Management
  // ========================================================================

  async invalidateUserToken(userId, invalidToken, executionId = 'token-invalidate') {
    try {
      logger.warning(`Invalidating token for user ${userId}`, executionId);

      // Remove invalid token from user document
      await dbHelper.updateDocument('users', userId, {
        token: null,
        fcmToken: null,
        tokenInvalidatedAt: dbHelper.getServerTimestamp()
      }, executionId);

      logger.info(`Token invalidated for user ${userId}`, executionId);
    } catch (error) {
      logger.error(`Failed to invalidate token for user ${userId}`, executionId, error);
    }
  }

  async updateUserToken(userId, newToken, executionId = 'token-update') {
    try {
      await dbHelper.updateDocument('users', userId, {
        fcmToken: newToken,
        token: newToken,
        tokenUpdatedAt: dbHelper.getServerTimestamp()
      }, executionId);

      logger.success(`Token updated for user ${userId}`, executionId);
      return true;
    } catch (error) {
      logger.error(`Failed to update token for user ${userId}`, executionId, error);
      return false;
    }
  }

  // ========================================================================
  // Utility Methods
  // ========================================================================

  async testFCMConnection(executionId = 'fcm-test') {
    try {
      logger.info('Testing FCM connection', executionId);
      const token = await this.getAccessToken(executionId);

      if (token) {
        logger.success('FCM connection test successful', executionId);
        return true;
      } else {
        throw new Error('Failed to get access token');
      }
    } catch (error) {
      logger.error('FCM connection test failed', executionId, error);
      return false;
    }
  }

  async getUnreadNotificationCount(userId, executionId = 'unread-count') {
    try {
      const { data: userData } = await dbHelper.getDocument('users', userId, executionId);
      return userData?.unreadNotifications || 0;
    } catch (error) {
      logger.error(`Failed to get unread count for user ${userId}`, executionId, error);
      return 0;
    }
  }

  async markNotificationAsRead(userId, notificationId, executionId = 'mark-read') {
    try {
      await dbHelper.updateDocument(`users/${userId}/notifications`, notificationId, {
        read: true,
        readAt: dbHelper.getServerTimestamp()
      }, executionId);

      // Decrement unread count
      await dbHelper.updateDocument('users', userId, {
        unreadNotifications: dbHelper.increment(-1)
      }, executionId);

      logger.success(`Notification marked as read: ${notificationId}`, executionId);
      return true;
    } catch (error) {
      logger.error(`Failed to mark notification as read`, executionId, error);
      return false;
    }
  }
}

// Create default notification service instance
const notificationService = new NotificationService();

module.exports = {
  NotificationService,
  notificationService
};
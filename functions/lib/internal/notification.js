const { sendFCMNotification } = require('../../utils/fcm');
const { getTargetRolesForTransaction, getAdminNotificationTitle, getAdminNotificationMessage } = require('./helpers');

async function createAdminNotification(transactionType, data, db) {
  try {
    const notificationData = {
      title: getAdminNotificationTitle(transactionType, data),
      message: getAdminNotificationMessage(transactionType, data),
      type: mapTransactionTypeToNotificationType(transactionType),
      priority: 'high',
      relatedOrderId: data.reference,
      relatedUserId: data.userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      targetRoles: getTargetRolesForTransaction(transactionType),
      metadata: {
        transactionType: transactionType,
        amount: data.amount,
        customerName: data.userName
      }
    };

    await db.collection('notifications').add(notificationData);
    await queueAdminPushNotifications(transactionType, notificationData, db);

  } catch (error) {
    console.error('Error creating admin notification:', error);
  }
}

async function createAdminPaymentNotification(data, db) {
  try {
    const notificationData = {
      title: 'Payment Confirmed',
      message: `Payment confirmed for ${data.transactionType.replace('_', ' ')} ${data.reference} - ₦${data.amount.toLocaleString()}`,
      type: 'payment',
      priority: 'medium',
      relatedOrderId: data.reference,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      targetRoles: getTargetRolesForTransaction(data.transactionType),
      metadata: {
        transactionType: data.transactionType,
        amount: data.amount,
        customerName: data.userName,
        paymentConfirmed: true
      }
    };

    await db.collection('notifications').add(notificationData);
    await queueAdminPushNotifications(data.transactionType, notificationData, db);

  } catch (error) {
    console.error('Error creating admin payment notification:', error);
  }
}

async function notifyStaffForNewOrder(orderReference, serviceType, orderDetails, executionId, db) {
  try {
    const permissionMap = {
      'food_delivery': 'food_delivery.read',
      'laundry_service': 'laundry.read',
      'gym': 'gym.read',
      'swimming_pool': 'pool.read',
      'spa': 'spa.read',
      'concierge': 'concierge.read'
    };
    
    const requiredPermission = permissionMap[serviceType];
    if (!requiredPermission) return;

    const adminsSnapshot = await db.collection('admins')
      .where('permissions', 'array-contains', requiredPermission)
      .get();
    
    if (adminsSnapshot.empty) return;

    const notificationTitle = `New ${serviceType.replace(/_/g, ' ').toUpperCase()} Order 🔔`;
    let notificationBody = `Order #${orderReference} requires attention`;

    // Customize notification based on service type
    if (serviceType === 'food_delivery' && orderDetails.items) {
      const itemCount = orderDetails.items.length;
      const deliverTo = orderDetails.deliverTo || 'delivery';
      notificationBody = `New food order with ${itemCount} items for ${deliverTo}`;
    }

    for (const doc of adminsSnapshot.docs) {
      const staffData = doc.data();
      const staffToken = staffData.fcmToken || staffData.token;
      
      if (staffToken) {
        const notificationData = {
          type: 'new_service_order',
          serviceType: serviceType,
          orderReference: orderReference,
          customerName: orderDetails.userName || orderDetails.customerName || 'Guest',
          amount: String(orderDetails.amount || orderDetails.total || 0),
          timestamp: new Date().toISOString(),
          orderId: orderReference,
          clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        };
        
        await sendFCMNotification(staffToken, notificationTitle, notificationBody, notificationData);
      }
    }
    
  } catch (error) {
    console.error(`Error notifying staff:`, error);
  }
}

async function queueAdminPushNotifications(transactionType, notificationData, db) {
  try {
    const targetRoles = getTargetRolesForTransaction(transactionType);
    const adminUsers = await db.collection('admin_users')
      .where('role', 'in', targetRoles)
      .where('isActive', '==', true)
      .get();

    const batch = db.batch();
    adminUsers.docs.forEach(doc => {
      const adminData = doc.data();
      if (adminData.fcmToken) {
        const pushRef = db.collection('admin_push_queue').doc();
        batch.set(pushRef, {
          token: adminData.fcmToken,
          title: notificationData.title,
          body: notificationData.message,
          data: {
            type: notificationData.type,
            orderId: notificationData.relatedOrderId,
            timestamp: new Date().toISOString()
          },
          processed: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    });

    await batch.commit();
  } catch (error) {
    console.error('Error queueing admin push notifications:', error);
  }
}

function mapTransactionTypeToNotificationType(transactionType) {
  const typeMap = {
    'booking': 'booking',
    'food_order': 'food',
    'gym_session': 'amenities',
    'pool_session': 'amenities',
    'spa_session': 'amenities',
    'laundry_service': 'laundry',
    'default': 'system'
  };
  return typeMap[transactionType] || typeMap.default;
}

module.exports = {
  createAdminNotification,
  createAdminPaymentNotification,
  notifyStaffForNewOrder,
  queueAdminPushNotifications
};
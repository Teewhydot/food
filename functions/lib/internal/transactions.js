const { TRANSACTION_TYPES } = require('../../config/constants');
const { createAdminNotification } = require('./notifications');
const { notifyStaffForNewOrder } = require('./notifications');

async function createServiceRecord(userId, userName, email, reference, transactionType, details, amount, timestamp, db) {
  const config = TRANSACTION_TYPES[transactionType];
  if (!config) {
    throw new Error(`Unknown transaction type: ${transactionType}`);
  }

  const baseRecord = {
    userId: userId,
    userName: userName,
    userEmail: email,
    amount: amount,
    reference: reference,
    status: "pending",
    service_status: "pending",
    time_created: timestamp,
    transactionType: config.transactionType,
    serviceType: config.serviceType
  };

  let serviceRecord;

  switch (transactionType) {
    case 'booking':
      const { cleanBookingDetails } = require('../../utils/firestore');
      serviceRecord = {
        ...baseRecord,
        bookingDetails: cleanBookingDetails(details)
      };
      break;

    case 'food_order':
      serviceRecord = {
        ...baseRecord,
        customerId: userId,
        customerName: userName,
        items: details.items || [],
        service_items: details.service_items || details.items || [],
        total: details.total || amount,
        deliverTo: (details.deliverTo && details.deliverTo.trim()) || "Room 101",
        specialInstructions: details.specialInstructions,
        createdAt: timestamp,
        updatedAt: timestamp
      };
      break;

    // Other transaction types...
    default:
      serviceRecord = {
        ...baseRecord,
        serviceDetails: details,
        items: details.items || [],
        service_items: details.service_items || details.items || [],
        createdAt: timestamp,
        updatedAt: timestamp
      };
  }

  await db.collection(config.collectionName)
    .doc(reference)
    .set(serviceRecord);
  
  if (config.serviceType && transactionType !== 'booking') {
    await notifyStaffForNewOrder(reference, config.serviceType, serviceRecord, 'create', db);
  }

  await createAdminNotification(transactionType, {
    userId: userId,
    userName: userName,
    reference: reference,
    amount: amount,
    details: details,
    timestamp: timestamp
  }, db);
}

module.exports = {
  createServiceRecord
};
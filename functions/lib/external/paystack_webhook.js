const { validateWebhookSignature } = require('../../utils/paystack');
const { findDocumentWithPrefix } = require('../../utils/firestore');
const { createAdminPaymentNotification } = require('../internal/notifications');
const { updateAvailabilityForSuccessfulBooking } = require('../internal/booking-availability');
const { updateBookingStats } = require('../internal/booking-stats');
const { deductFoodQuantities } = require('../internal/food-quantity');
const { sendEnhancedEmail } = require('../../utils/email');
const { sendFCMNotification, getFCMTokenForUser } = require('../../utils/fcm');
const { generateNotificationData } = require('../../utils/helpers');
const { TRANSACTION_TYPES } = require('../../config/constants');

async function handlePaystackWebhook(req, res, db) {
  try {
    const event = req.body;
    const paystackSignature = req.headers["x-paystack-signature"];
    
    if (!validateWebhookSignature(event, paystackSignature)) {
      return res.status(400).send("Invalid paystack signature");
    }

    if (event.event === "charge.success" && event.data.status === "success") {
      await handleSuccessfulCharge(event.data, db);
    } else if (["charge.failed", "charge.failure", "transfer.failed", "invoice.payment_failed"].includes(event.event)) {
      await handleFailedCharge(event.data, db);
    } else if (event.event === "charge.abandoned") {
      await handleAbandonedCharge(event.data, db);
    }

    return res.status(200).send("Webhook received");
  } catch (error) {
    console.error("Error processing Paystack webhook:", error);
    return res.status(200).send("Webhook received with error");
  }
}

async function handleSuccessfulCharge(eventData, db) {
  const { reference, status, paid_at, amount, metadata } = eventData;
  const { userId, userName } = metadata;
  const amountPaid = amount / 100;
  
  const { actualReference, transactionType, orderDetails, userEmail } = await findDocumentWithPrefix(reference, db);
  
  const config = TRANSACTION_TYPES[transactionType];
  if (config) {
    const updateData = {
      status: status,
      time_created: paid_at,
      amount: amountPaid,
    };
    
    if (config.transactionType === 'service') {
      updateData.updatedAt = paid_at;
    }
    
    await db.collection(config.collectionName)
      .doc(actualReference)
      .update(updateData);
  }

  await db.collection('pending_transactions').doc(actualReference).delete();

  if (userEmail) {
    await sendEnhancedEmail(transactionType, orderDetails, reference, userName, amountPaid, paid_at, userEmail);
  }

  try {
    const notificationTitle = config.notificationTitle.success;
    let notificationBody;
    
    if (transactionType === 'booking') {
      notificationBody = `Your payment for booking ${reference} has been confirmed. See you on ${new Date(orderDetails.checkInDate).toLocaleDateString()}!`;
    } else {
      // Custom messages for different service types
    }
    
    const notificationData = generateNotificationData(transactionType, orderDetails, reference, amountPaid, true);
    notificationData.paymentDate = paid_at;

    const userToken = await getFCMTokenForUser(userId, db);
    await sendFCMNotification(userToken, notificationTitle, notificationBody, notificationData);
    
  } catch (notificationError) {
    console.error(`Failed to send success notification:`, notificationError);
  }

  if (status === 'success') {
    await createAdminPaymentNotification({
      transactionType: transactionType,
      reference: actualReference,
      userName: userName,
      amount: amountPaid,
      userEmail: userEmail
    }, db);
  }

  if (transactionType === 'booking') {
    await updateAvailabilityForSuccessfulBooking(actualReference, userId, 'webhook', db);
    await updateBookingStats(actualReference, 'webhook', db);
  } else if (transactionType === 'food_order') {
    await deductFoodQuantities(actualReference, 'webhook', db);
  }

  if (transactionType !== 'booking' && config && config.serviceType) {
    const orderDoc = await db.collection(config.collectionName).doc(actualReference).get();
    if (orderDoc.exists) {
      await notifyStaffForNewOrder(actualReference, config.serviceType, orderDoc.data(), 'payment_success', db);
    }
  }
}

async function handleFailedCharge(eventData, db) {
  // Implementation for failed charges
}

async function handleAbandonedCharge(eventData, db) {
  // Implementation for abandoned charges
}

module.exports = {
  handlePaystackWebhook
};
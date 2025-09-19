
const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require("axios");
const crypto = require("node:crypto");

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Set global options for cost control
setGlobalOptions({ maxInstances: 10 });

// Paystack Configuration
// In production, this reads from Firebase Functions config
// Set with: firebase functions:config:set paystack.secret_key="sk_test_xxx"
const config = require("firebase-functions").config();
const PAYSTACK_SECRET_KEY = config.paystack?.secret_key || process.env.PAYSTACK_SECRET_KEY;
const PAYSTACK_BASE_URL = "https://api.paystack.co";

// =============================================================================
// PAYSTACK PAYMENT INTEGRATION FUNCTIONS
// =============================================================================

/**
 * Creates a new Paystack payment transaction for food orders
 * Initializes payment and returns transaction reference
 */
exports.createPaystackTransaction = onRequest({
  cors: true,
  maxInstances: 5
}, async (req, res) => {
  try {
    // Validate request method
    if (req.method !== 'POST') {
      return res.status(405).json({
        success: false,
        message: 'Method not allowed'
      });
    }

    // Validate authentication
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const userId = decodedToken.uid;

    // Validate request body
    const { orderId, amount, email, currency = 'NGN' } = req.body;

    if (!orderId || !amount || !email) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: orderId, amount, email'
      });
    }

    // Validate order exists and belongs to user
    const orderDoc = await db.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const orderData = orderDoc.data();
    if (orderData.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied to this order'
      });
    }

    // Initialize Paystack transaction
    const paystackData = {
      amount: Math.round(amount * 100), // Convert to kobo
      email: email,
      currency: currency,
      reference: `food_${orderId}_${Date.now()}`,
      callback_url: `https://your-app.com/payment-callback`,
      metadata: {
        orderId: orderId,
        userId: userId,
        custom_fields: [
          {
            display_name: "Order ID",
            variable_name: "order_id",
            value: orderId
          }
        ]
      }
    };

    const response = await axios.post(
      `${PAYSTACK_BASE_URL}/transaction/initialize`,
      paystackData,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (response.data.status) {
      // Store transaction in Firestore
      const transactionData = {
        reference: paystackData.reference,
        orderId: orderId,
        userId: userId,
        amount: paystackData.amount,
        currency: currency,
        email: email,
        status: 'pending',
        authorization_url: response.data.data.authorization_url,
        access_code: response.data.data.access_code,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        metadata: paystackData.metadata
      };

      await db.collection('paystack_transactions').doc(paystackData.reference).set(transactionData);

      // Update order with payment information
      await db.collection('orders').doc(orderId).update({
        paymentProvider: 'paystack',
        paystackReference: paystackData.reference,
        paymentStatus: 'pending',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      logger.info(`Paystack transaction created: ${paystackData.reference}`, {
        orderId: orderId,
        userId: userId,
        amount: amount
      });

      return res.status(200).json({
        success: true,
        data: {
          reference: paystackData.reference,
          authorization_url: response.data.data.authorization_url,
          access_code: response.data.data.access_code
        }
      });
    } else {
      throw new Error(response.data.message || 'Failed to initialize transaction');
    }

  } catch (error) {
    logger.error('Error creating Paystack transaction:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Verifies Paystack payment status and updates order
 */
exports.verifyPaystackPayment = onRequest({
  cors: true,
  maxInstances: 5
}, async (req, res) => {
  try {
    // Validate request method
    if (req.method !== 'POST') {
      return res.status(405).json({
        success: false,
        message: 'Method not allowed'
      });
    }

    // Validate authentication
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const userId = decodedToken.uid;

    // Validate request body
    const { reference } = req.body;

    if (!reference) {
      return res.status(400).json({
        success: false,
        message: 'Transaction reference is required'
      });
    }

    // Get transaction from Firestore
    const transactionDoc = await db.collection('paystack_transactions').doc(reference).get();
    if (!transactionDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    const transactionData = transactionDoc.data();
    if (transactionData.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied to this transaction'
      });
    }

    // Verify with Paystack
    const response = await axios.get(
      `${PAYSTACK_BASE_URL}/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`
        }
      }
    );

    if (response.data.status && response.data.data) {
      const paymentData = response.data.data;

      // Update transaction in Firestore
      const updateData = {
        status: paymentData.status,
        amount: paymentData.amount,
        fees: paymentData.fees || 0,
        currency: paymentData.currency,
        channel: paymentData.channel,
        ip_address: paymentData.ip_address,
        paid_at: paymentData.paid_at ? new Date(paymentData.paid_at) : null,
        gateway_response: paymentData.gateway_response,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      };

      if (paymentData.authorization) {
        updateData.authorization = paymentData.authorization;
      }

      if (paymentData.customer) {
        updateData.customer = paymentData.customer;
      }

      await db.collection('paystack_transactions').doc(reference).update(updateData);

      // Update order status based on payment status
      let orderStatus = 'pending';
      let paymentStatus = paymentData.status;

      if (paymentData.status === 'success') {
        orderStatus = 'confirmed';
        paymentStatus = 'success';
      } else if (paymentData.status === 'failed') {
        orderStatus = 'cancelled';
        paymentStatus = 'failed';
      }

      await db.collection('orders').doc(transactionData.orderId).update({
        status: orderStatus,
        paymentStatus: paymentStatus,
        paymentFees: paymentData.fees || 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      logger.info(`Payment verified: ${reference}`, {
        status: paymentData.status,
        orderId: transactionData.orderId,
        amount: paymentData.amount
      });

      return res.status(200).json({
        success: true,
        data: {
          reference: reference,
          status: paymentData.status,
          amount: paymentData.amount,
          currency: paymentData.currency,
          paid_at: paymentData.paid_at,
          order_status: orderStatus
        }
      });
    } else {
      throw new Error(response.data.message || 'Failed to verify payment');
    }

  } catch (error) {
    logger.error('Error verifying Paystack payment:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Handles Paystack webhook notifications
 */
exports.paystackWebhook = onRequest({
  maxInstances: 10
}, async (req, res) => {
  try {
    // Validate request method
    if (req.method !== 'POST') {
      return res.status(405).send('Method not allowed');
    }

    // Verify webhook signature
    const hash = crypto.createHmac('sha512', PAYSTACK_SECRET_KEY)
                      .update(JSON.stringify(req.body))
                      .digest('hex');

    if (hash !== req.headers['x-paystack-signature']) {
      logger.warn('Invalid webhook signature');
      return res.status(400).send('Invalid signature');
    }

    const event = req.body;
    logger.info(`Paystack webhook received: ${event.event}`, { data: event.data });

    // Handle different webhook events
    switch (event.event) {
      case 'charge.success':
        await handleSuccessfulPayment(event.data);
        break;

      case 'charge.failed':
        await handleFailedPayment(event.data);
        break;

      case 'transfer.success':
        await handleSuccessfulTransfer(event.data);
        break;

      case 'transfer.failed':
        await handleFailedTransfer(event.data);
        break;

      default:
        logger.info(`Unhandled webhook event: ${event.event}`);
    }

    return res.status(200).send('OK');

  } catch (error) {
    logger.error('Error processing webhook:', error);
    return res.status(500).send('Internal server error');
  }
});

/**
 * Gets current transaction status
 */
exports.getTransactionStatus = onRequest({
  cors: true,
  maxInstances: 5
}, async (req, res) => {
  try {
    // Validate request method
    if (req.method !== 'GET') {
      return res.status(405).json({
        success: false,
        message: 'Method not allowed'
      });
    }

    // Validate authentication
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const userId = decodedToken.uid;

    // Get reference from query parameters
    const reference = req.query.reference;

    if (!reference) {
      return res.status(400).json({
        success: false,
        message: 'Transaction reference is required'
      });
    }

    // Get transaction from Firestore
    const transactionDoc = await db.collection('paystack_transactions').doc(reference).get();
    if (!transactionDoc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found'
      });
    }

    const transactionData = transactionDoc.data();
    if (transactionData.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied to this transaction'
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        reference: reference,
        status: transactionData.status,
        amount: transactionData.amount,
        currency: transactionData.currency,
        orderId: transactionData.orderId,
        created_at: transactionData.created_at,
        paid_at: transactionData.paid_at || null
      }
    });

  } catch (error) {
    logger.error('Error getting transaction status:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
});

/**
 * Scheduled function to verify pending transactions
 * Runs every 5 minutes to check for pending payments
 */
exports.verifyPendingTransactions = onSchedule({
  schedule: 'every 5 minutes',
  timeoutSeconds: 540
}, async (context) => {
  try {
    logger.info('Starting verification of pending transactions');

    // Get pending transactions older than 2 minutes
    const twoMinutesAgo = new Date(Date.now() - (2 * 60 * 1000));

    const pendingTransactions = await db.collection('paystack_transactions')
      .where('status', '==', 'pending')
      .where('created_at', '<=', twoMinutesAgo)
      .limit(50)
      .get();

    if (pendingTransactions.empty) {
      logger.info('No pending transactions to verify');
      return;
    }

    const verificationPromises = [];

    pendingTransactions.forEach(doc => {
      const transaction = doc.data();
      verificationPromises.push(verifyPendingTransaction(doc.id, transaction));
    });

    const results = await Promise.allSettled(verificationPromises);

    let successCount = 0;
    let errorCount = 0;

    results.forEach((result, index) => {
      if (result.status === 'fulfilled') {
        successCount++;
      } else {
        errorCount++;
        logger.error(`Failed to verify transaction ${pendingTransactions.docs[index].id}:`, result.reason);
      }
    });

    logger.info(`Pending transaction verification completed: ${successCount} success, ${errorCount} errors`);

  } catch (error) {
    logger.error('Error in scheduled verification:', error);
  }
});

/**
 * Scheduled function to cleanup old transactions
 * Runs daily at 2 AM to remove old completed transactions
 */
exports.cleanupOldTransactions = onSchedule({
  schedule: 'every day 02:00',
  timeoutSeconds: 540
}, async (context) => {
  try {
    logger.info('Starting cleanup of old transactions');

    // Remove transactions older than 90 days
    const ninetyDaysAgo = new Date(Date.now() - (90 * 24 * 60 * 60 * 1000));

    const oldTransactions = await db.collection('paystack_transactions')
      .where('created_at', '<=', ninetyDaysAgo)
      .where('status', 'in', ['success', 'failed', 'abandoned'])
      .limit(500)
      .get();

    if (oldTransactions.empty) {
      logger.info('No old transactions to cleanup');
      return;
    }

    const batch = db.batch();
    let deleteCount = 0;

    oldTransactions.forEach(doc => {
      batch.delete(doc.ref);
      deleteCount++;
    });

    await batch.commit();

    logger.info(`Cleaned up ${deleteCount} old transactions`);

  } catch (error) {
    logger.error('Error in cleanup function:', error);
  }
});

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Handles successful payment webhook
 */
async function handleSuccessfulPayment(paymentData) {
  try {
    const reference = paymentData.reference;

    // Update transaction status
    await db.collection('paystack_transactions').doc(reference).update({
      status: 'success',
      amount: paymentData.amount,
      fees: paymentData.fees || 0,
      paid_at: new Date(paymentData.paid_at),
      authorization: paymentData.authorization || null,
      customer: paymentData.customer || null,
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });

    // Get transaction to find order ID
    const transactionDoc = await db.collection('paystack_transactions').doc(reference).get();
    if (transactionDoc.exists) {
      const transaction = transactionDoc.data();

      // Update order status
      await db.collection('orders').doc(transaction.orderId).update({
        status: 'confirmed',
        paymentStatus: 'success',
        paymentFees: paymentData.fees || 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      logger.info(`Order confirmed via webhook: ${transaction.orderId}`);
    }

  } catch (error) {
    logger.error('Error handling successful payment:', error);
    throw error;
  }
}

/**
 * Handles failed payment webhook
 */
async function handleFailedPayment(paymentData) {
  try {
    const reference = paymentData.reference;

    // Update transaction status
    await db.collection('paystack_transactions').doc(reference).update({
      status: 'failed',
      gateway_response: paymentData.gateway_response || 'Payment failed',
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });

    // Get transaction to find order ID
    const transactionDoc = await db.collection('paystack_transactions').doc(reference).get();
    if (transactionDoc.exists) {
      const transaction = transactionDoc.data();

      // Update order status
      await db.collection('orders').doc(transaction.orderId).update({
        status: 'cancelled',
        paymentStatus: 'failed',
        paymentFailureReason: paymentData.gateway_response || 'Payment failed',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      logger.info(`Order cancelled due to payment failure: ${transaction.orderId}`);
    }

  } catch (error) {
    logger.error('Error handling failed payment:', error);
    throw error;
  }
}

/**
 * Handles successful transfer webhook
 */
async function handleSuccessfulTransfer(transferData) {
  try {
    logger.info(`Transfer successful: ${transferData.reference}`, transferData);
    // Handle transfer logic if needed for refunds
  } catch (error) {
    logger.error('Error handling successful transfer:', error);
    throw error;
  }
}

/**
 * Handles failed transfer webhook
 */
async function handleFailedTransfer(transferData) {
  try {
    logger.info(`Transfer failed: ${transferData.reference}`, transferData);
    // Handle failed transfer logic if needed
  } catch (error) {
    logger.error('Error handling failed transfer:', error);
    throw error;
  }
}

/**
 * Verifies a single pending transaction
 */
async function verifyPendingTransaction(reference, transactionData) {
  try {
    // Verify with Paystack
    const response = await axios.get(
      `${PAYSTACK_BASE_URL}/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`
        }
      }
    );

    if (response.data.status && response.data.data) {
      const paymentData = response.data.data;

      // Update transaction
      const updateData = {
        status: paymentData.status,
        amount: paymentData.amount,
        fees: paymentData.fees || 0,
        currency: paymentData.currency,
        channel: paymentData.channel,
        ip_address: paymentData.ip_address,
        paid_at: paymentData.paid_at ? new Date(paymentData.paid_at) : null,
        gateway_response: paymentData.gateway_response,
        updated_at: admin.firestore.FieldValue.serverTimestamp()
      };

      if (paymentData.authorization) {
        updateData.authorization = paymentData.authorization;
      }

      if (paymentData.customer) {
        updateData.customer = paymentData.customer;
      }

      await db.collection('paystack_transactions').doc(reference).update(updateData);

      // Update order status
      let orderStatus = 'pending';
      if (paymentData.status === 'success') {
        orderStatus = 'confirmed';
      } else if (paymentData.status === 'failed') {
        orderStatus = 'cancelled';
      }

      await db.collection('orders').doc(transactionData.orderId).update({
        status: orderStatus,
        paymentStatus: paymentData.status,
        paymentFees: paymentData.fees || 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      logger.info(`Scheduled verification completed: ${reference} - ${paymentData.status}`);
    }

  } catch (error) {
    logger.error(`Error verifying pending transaction ${reference}:`, error);
    throw error;
  }
}

// ========================================================================
// Food Delivery App Firebase Functions - Modular Services
// ========================================================================

// Load environment variables from .env file
require('dotenv').config();

// Firebase Functions
const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');

// External Dependencies
const axios = require('axios');
const admin = require('firebase-admin');
const crypto = require('crypto');
const cors = require('cors')({ origin: true });

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();
db.settings({
  ignoreUndefinedProperties: true
});

// Import Utilities and Constants
const {
  ENVIRONMENT,
  CONTACT_INFO,
  TRANSACTION_PREFIX_MAP,
  TRANSACTION_TYPES,
  FUNCTIONS_CONFIG
} = require('./utils/constants');
const { logger } = require('./utils/logger');
const { RequestValidators, DatabaseValidators } = require('./utils/validation');
const { dbHelper } = require('./utils/database');

// Import Services
const { emailService } = require('./services/email-service');
const { paymentService } = require('./services/payment-service');
const { FlutterwaveService } = require('./services/flutterwave-service');
const { notificationService } = require('./services/notification-service');
const { statisticsService } = require('./services/statistics-service');
const { inventoryService } = require('./services/inventory-service');

// Legacy constants for backward compatibility
const PAYSTACK_SECRET_KEY = ENVIRONMENT.PAYSTACK_SECRET_KEY;
const PROJECT_ID = ENVIRONMENT.PROJECT_ID;
const gmailPassword = ENVIRONMENT.GMAIL_PASSWORD;

// Initialize Flutterwave service
const flutterwaveService = new FlutterwaveService();
const SUPPORT_EMAIL = CONTACT_INFO.SUPPORT_EMAIL;
const SUPPORT_PHONE = CONTACT_INFO.SUPPORT_PHONE;
const BUSINESS_LOCATION = CONTACT_INFO.BUSINESS_LOCATION;

// Log startup information
console.log('='.repeat(50));
console.log('Food Delivery App Firebase Functions - Modular Version');
console.log('='.repeat(50));
console.log('Contact Configuration:');
console.log('- Support Email:', SUPPORT_EMAIL);
console.log('- Support Phone:', SUPPORT_PHONE);
console.log(`Using project ID: ${PROJECT_ID}`);
console.log('='.repeat(50));

// ========================================================================
// Paystack Transaction Creation Function (Food Orders)
// ========================================================================
exports.createPaystackTransaction = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `create-${Date.now()}`;

      try {
        logger.startFunction('createTransaction', executionId);

        // Validate and sanitize request for food orders
        const validatedData = RequestValidators.validateTransactionRequest(req.body);
        const { orderId, amount, userId, email, metadata, userName } = validatedData;

        // Extract and structure the food order details from metadata
        const bookingDetails = {
          orderId: orderId,
          transactionType: 'food_order',
          items: metadata.items || [],
          subtotal: metadata.subtotal || amount,
          deliveryFee: metadata.deliveryFee || 500,
          tax: metadata.tax || 0,
          total: metadata.total || amount,
          itemsCount: metadata.orderItemsCount || 0,
          deliverTo: metadata.deliverTo || 'Room 101',
          specialInstructions: metadata.specialInstructions || '',
          // Include all other metadata
          ...metadata
        };

        // Initialize payment with Paystack
        const paymentResult = await paymentService.initializeTransaction(
          email,
          amount,
          { userId, bookingDetails, userName },
          executionId
        );

        if (!paymentResult.success) {
          logger.error('Payment initialization failed', executionId, null, paymentResult);
          return res.status(500).json({
            error: 'Failed to initialize payment',
            details: paymentResult.error
          });
        }

        // Determine transaction type and generate reference
        const transactionType = bookingDetails.transactionType || "booking";
        const reference = paymentService.generatePrefixedReference(transactionType, paymentResult.reference);
        const currentTimestamp = new Date().toISOString();

        logger.transaction('CREATE', reference, executionId, {
          transactionType,
          amount,
          email
        });

        // Create service record using database helper
        await dbHelper.createServiceRecord(
          userId,
          userName,
          email,
          reference,
          transactionType,
          bookingDetails,
          amount,
          currentTimestamp,
          executionId
        );

        // Send creation email (optional - can be enabled later)
        // await emailService.sendCreationEmail(
        //   transactionType, bookingDetails, reference, userName, amount, email, executionId
        // );

        // Send creation notification (optional - can be enabled later)
        // const notificationData = notificationService.generateNotificationData(
        //   transactionType, bookingDetails, reference, amount, false
        // );
        // await notificationService.sendNotificationToUser(
        //   userId, config.notificationTitle.creation, notificationBody, notificationData, executionId
        // );

        logger.success(`Transaction created successfully: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          reference: reference,
          authorization_url: paymentResult.authorizationUrl,
          access_code: paymentResult.accessCode
        });

      } catch (error) {
        logger.critical('Transaction creation failed', executionId, error);
        res.status(500).json({
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// ========================================================================
// Paystack Payment Verification Function
// ========================================================================
exports.verifyPaystackPayment = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `verify-${Date.now()}`;

      try {
        logger.startFunction('verifyPaystackPayment', executionId);

        const { reference, orderId } = req.body;
        if (!reference) {
          return res.status(400).json({
            success: false,
            error: 'Reference is required'
          });
        }

        // Verify payment with Paystack
        const verificationResult = await paymentService.verifyTransaction(reference, executionId);

        if (!verificationResult.success) {
          logger.error('Payment verification failed', executionId, null, verificationResult);
          return res.status(400).json({
            success: false,
            error: 'Payment verification failed',
            details: verificationResult.error
          });
        }

        logger.success(`Payment verified successfully: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          status: verificationResult.status,
          amount: verificationResult.amount,
          reference: reference,
          paidAt: verificationResult.paidAt,
          channel: verificationResult.channel
        });

      } catch (error) {
        logger.critical('Payment verification failed', executionId, error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// ========================================================================
// Transaction Status Function
// ========================================================================
exports.getTransactionStatus = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: 60,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `status-${Date.now()}`;

      try {
        logger.startFunction('getTransactionStatus', executionId);

        const { reference } = req.query;
        if (!reference) {
          return res.status(400).json({
            success: false,
            error: 'Reference is required'
          });
        }

        // Get transaction status from Paystack
        const verificationResult = await paymentService.verifyTransaction(reference, executionId);

        if (!verificationResult.success) {
          return res.status(400).json({
            success: false,
            error: 'Failed to get transaction status',
            details: verificationResult.error
          });
        }

        logger.success(`Transaction status retrieved: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          status: verificationResult.status,
          amount: verificationResult.amount,
          reference: reference,
          paidAt: verificationResult.paidAt
        });

      } catch (error) {
        logger.critical('Failed to get transaction status', executionId, error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// ========================================================================
// Paystack Webhook Handler (Refactored)
// ========================================================================
exports.paystackWebhook = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    const executionId = `webhook-${Date.now()}`;

    try {
      logger.startFunction('paystackWebhook', executionId);

      const event = req.body;
      const paystackSignature = req.headers["x-paystack-signature"];

      logger.info(`Received Paystack event: ${event.event} - ${event.data?.status}`, executionId);

      // Verify webhook signature
      if (!paymentService.verifyWebhookSignature(event, paystackSignature, executionId)) {
        logger.warning('Invalid webhook signature', executionId);
        return res.status(400).send("Invalid paystack signature");
      }

      // Process webhook event
      const processResult = paymentService.processWebhookEvent(event, executionId);
      if (!processResult.success) {
        logger.error('Failed to process webhook event', executionId);
        return res.status(400).send("Invalid event data");
      }

      const processedEvent = processResult.processedEvent;

      // Handle different event types
      if (event.event === "charge.success" && processedEvent.status === "success") {
        await handleSuccessfulPayment(processedEvent, executionId);
      } else if (event.event === "charge.failed") {
        await handleFailedPayment(processedEvent, executionId);
      } else if (event.event === "charge.abandoned") {
        await handleAbandonedPayment(processedEvent, executionId);
      }

      logger.success('Webhook processed successfully', executionId);
      res.status(200).send("Webhook received successfully");

    } catch (error) {
      logger.critical('Webhook processing failed', executionId, error);
      res.status(200).send("Webhook received with error");
    }
  }
);

// Helper function for successful payments
async function handleSuccessfulPayment(processedEvent, executionId) {
  const { reference, amount, paidAt, userId, userName, bookingDetails } = processedEvent;

  // Find document and update status
  const { actualReference, transactionType, orderDetails, userEmail } = await dbHelper.findDocumentWithPrefix(reference, executionId);

  // Update transaction status - default to food_order if transactionType not found
  const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['food_order'];

  if (!config) {
    logger.error(`No configuration found for transaction type: ${transactionType}`, executionId);
    return;
  }

  const updateData = {
    status: 'confirmed',
    time_created: paidAt,
    amount: amount,
    verified_at: dbHelper.getServerTimestamp()
  };

  if (config.transactionType === 'service') {
    updateData.updatedAt = paidAt;
  }

  await dbHelper.updateDocument(config.collectionName, actualReference, updateData, executionId);

  // Clear user cart after successful food order payment
  if (transactionType === 'food_order' && userId) {
    try {
      const clearResult = await dbHelper.clearUserCart(userId, executionId);
      logger.info(`Cart clearing result for user ${userId}: ${clearResult.success ? 'success' : 'failed'} - ${clearResult.itemCount || 0} items`, executionId);
    } catch (error) {
      logger.error(`Failed to clear cart for user: ${userId}`, executionId, error);
    }
  }

  // Send success notification
  const notificationData = notificationService.generateNotificationData(
    transactionType, orderDetails, actualReference, amount, true
  );

  if (userId && config) {
    await notificationService.sendNotificationToUser(
      userId,
      config.notificationTitle.success,
      `Your ${transactionType.replace('_', ' ')} payment of ₦${amount.toLocaleString()} has been confirmed!`,
      notificationData,
      executionId
    );
  }
}

// Helper function for failed payments
async function handleFailedPayment(processedEvent, executionId) {
  const { reference, amount, paidAt } = processedEvent;

  const { actualReference, transactionType } = await dbHelper.findDocumentWithPrefix(reference, executionId);
  const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['food_order'];

  if (!config) {
    logger.error(`No configuration found for transaction type: ${transactionType}`, executionId);
    return;
  }

  const updateData = {
    status: 'failed',
    time_created: paidAt,
    amount: amount,
  };

  await dbHelper.updateDocument(config.collectionName, actualReference, updateData, executionId);
  logger.info(`Payment failed for ${reference}`, executionId);
}

// Helper function for abandoned payments
async function handleAbandonedPayment(processedEvent, executionId) {
  const { reference, amount, paidAt } = processedEvent;

  const { actualReference, transactionType } = await dbHelper.findDocumentWithPrefix(reference, executionId);
  const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['food_order'];

  if (!config) {
    logger.error(`No configuration found for transaction type: ${transactionType}`, executionId);
    return;
  }

  const updateData = {
    status: 'abandoned',
    time_created: paidAt,
    amount: amount,
  };

  await dbHelper.updateDocument(config.collectionName, actualReference, updateData, executionId);
  logger.info(`Payment abandoned for ${reference}`, executionId);
}

// ========================================================================
// Email Service Function
// ========================================================================
exports.sendEmail = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: 60,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `email-${Date.now()}`;

      try {
        const validatedData = RequestValidators.validateEmailRequest(req.body);
        const { to, subject, text } = validatedData;

        const success = await emailService.sendEmail(to, subject, text, null, [], executionId);

        if (success) {
          res.status(200).send('Email sent successfully');
        } else {
          res.status(500).send('Error sending email');
        }
      } catch (error) {
        logger.error('Email sending failed', executionId, error);
        res.status(500).send('Error sending email');
      }
    });
  }
);

// ========================================================================
// FCM Configuration Check
// ========================================================================
exports.checkFCMConfig = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: 60,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `fcm-check-${Date.now()}`;

      try {
        const config = {
          projectId: PROJECT_ID,
          envProjectId: process.env.GOOGLE_CLOUD_PROJECT,
          gcloudProjectId: process.env.GCLOUD_PROJECT,
          adminProjectId: admin.instanceId().app.options.projectId,
        };

        const connectionTest = await notificationService.testFCMConnection(executionId);

        res.status(200).json({
          success: true,
          config: config,
          connectionTest: connectionTest,
          timestamp: new Date().toISOString()
        });
      } catch (error) {
        logger.error('FCM config check failed', executionId, error);
        res.status(500).json({
          success: false,
          error: error.message
        });
      }
    });
  }
);

// ========================================================================
// FCM Notification Function
// ========================================================================
exports.sendFCMNotification = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: 60,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `fcm-${Date.now()}`;

      try {
        const validatedData = RequestValidators.validateNotificationRequest(req.body);
        const { userId, title, body, data } = validatedData;

        const result = await notificationService.sendNotificationToUser(userId, title, body, data, executionId);

        if (result.success) {
          res.status(200).json({
            success: true,
            messageId: result.messageId
          });
        } else {
          res.status(400).json({
            success: false,
            error: result.reason || result.error
          });
        }
      } catch (error) {
        logger.error('FCM notification failed', executionId, error);
        res.status(500).json({
          success: false,
          error: error.message
        });
      }
    });
  }
);

// ========================================================================
// Scheduled Functions
// ========================================================================

// Verify pending transactions
exports.verifyPendingTransactions = onSchedule(
  {
    schedule: 'every 10 minutes',
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (context) => {
    const executionId = `verify-${Date.now()}`;

    try {
      logger.startFunction('verifyPendingTransactions', executionId);

      // Get pending transactions from the last 24 hours
      const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

      const pendingFoodOrders = await dbHelper.queryDocuments('food_orders',
        [
          { field: 'status', operator: '==', value: 'pending' },
          { field: 'time_created', operator: '>=', value: oneDayAgo.toISOString() }
        ],
        null, 50, executionId
      );

      const pendingDeliveries = await dbHelper.queryDocuments('delivery_orders',
        [
          { field: 'status', operator: '==', value: 'pending' },
          { field: 'time_created', operator: '>=', value: oneDayAgo.toISOString() }
        ],
        null, 50, executionId
      );

      const allPending = [...pendingFoodOrders, ...pendingDeliveries];

      logger.info(`Found ${allPending.length} pending transactions to verify`, executionId);

      let verifiedCount = 0;
      for (const transaction of allPending) {
        try {
          const originalReference = paymentService.extractOriginalReference(transaction.id);
          const verificationResult = await paymentService.verifyTransaction(originalReference, `${executionId}-${transaction.id}`);

          if (verificationResult.success && verificationResult.status === 'success') {
            await handleSuccessfulPayment({
              reference: originalReference,
              amount: verificationResult.amount,
              paidAt: verificationResult.paidAt,
              userId: transaction.data.userId,
              userName: transaction.data.userName,
              bookingDetails: transaction.data.bookingDetails || {}
            }, `${executionId}-${transaction.id}`);

            verifiedCount++;
          }
        } catch (error) {
          logger.error(`Failed to verify transaction ${transaction.id}`, executionId, error);
        }
      }

      logger.success(`Verification completed: ${verifiedCount}/${allPending.length} transactions verified`, executionId);

    } catch (error) {
      logger.error('Scheduled verification failed', executionId, error);
    }
  }
);

// Cleanup old pending transactions
exports.cleanupOldPendingTransactions = onSchedule(
  {
    schedule: 'every 24 hours',
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY
  },
  async (context) => {
    const executionId = `cleanup-${Date.now()}`;

    try {
      logger.startFunction('cleanupOldPendingTransactions', executionId);

      // Clean up transactions older than 7 days
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

      const oldPendingFoodOrders = await dbHelper.queryDocuments('food_orders',
        [
          { field: 'status', operator: '==', value: 'pending' },
          { field: 'time_created', operator: '<', value: sevenDaysAgo.toISOString() }
        ],
        null, 100, executionId
      );

      const oldPendingDeliveries = await dbHelper.queryDocuments('delivery_orders',
        [
          { field: 'status', operator: '==', value: 'pending' },
          { field: 'time_created', operator: '<', value: sevenDaysAgo.toISOString() }
        ],
        null, 100, executionId
      );

      const allOldPending = [...oldPendingFoodOrders, ...oldPendingDeliveries];

      logger.info(`Found ${allOldPending.length} old pending transactions to cleanup`, executionId);

      const batch = dbHelper.createBatch();
      let cleanedCount = 0;

      for (const transaction of allOldPending) {
        const collection = transaction.id.startsWith('F-') ? 'food_orders' : 'delivery_orders';
        dbHelper.batchUpdate(batch, collection, transaction.id, {
          status: 'expired',
          expiredAt: dbHelper.getServerTimestamp()
        });
        cleanedCount++;
      }

      if (cleanedCount > 0) {
        await dbHelper.commitBatch(batch, cleanedCount, executionId);
      }

      logger.success(`Cleanup completed: ${cleanedCount} transactions marked as expired`, executionId);

    } catch (error) {
      logger.error('Scheduled cleanup failed', executionId, error);
    }
  }
);
 // Keep Parcelam backend alive (prevents Render shutdown after 15 minutes of inactivity)                                                               
  exports.keepBackendAlive = onSchedule(
    {
      schedule: 'every 14 minutes',
      region: FUNCTIONS_CONFIG.REGION,
      timeoutSeconds: 60,
      memory: '128MB'
    },
    async (context) => {
      const executionId = `keepalive-${Date.now()}`;

      try {
        logger.info('Pinging Parcelam backend...', executionId);

        const parcel_response = await axios.post(
          "https://parcel-rag-backend.onrender.com/query",
          {
            tenant_id: "keepalive",
            question: "How does a snake swallow 36 million naira?",
          },
          {
            timeout: 10000,
            validateStatus: () => true,
            headers: {
              'Content-Type': 'application/json'
            }
          }
        );

        logger.success(`Parcelam backend pinged successfully - Status: ${parcel_response.status}`, executionId);

      } catch (error) {
        logger.info(`Parcelam ping completed (with error) - ${error.message}`, executionId);
      }
    }
  );  
// ========================================================================
// Flutterwave Payment Functions
// ========================================================================

// Flutterwave Payment Initialization Function
exports.initializeFlutterwavePayment = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY,
    env: [
      'FLUTTERWAVE_SECRET_KEY',
      'FLUTTERWAVE_PUBLIC_KEY',
      'FLUTTERWAVE_ENCRYPTION_KEY',
      'FLUTTERWAVE_SECRET_HASH'
    ]
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `flw-init-${Date.now()}`;

      try {
        logger.startFunction('initializeFlutterwavePayment', executionId);

        // Validate and sanitize request for food orders
        const validatedData = RequestValidators.validateTransactionRequest(req.body);
        const { orderId, amount, userId, email, metadata, userName } = validatedData;

        // Extract and structure the food order details from metadata
        const bookingDetails = {
          orderId: orderId,
          transactionType: 'food_order',
          items: metadata.items || [],
          subtotal: metadata.subtotal || amount,
          deliveryFee: metadata.deliveryFee || 500,
          tax: metadata.tax || 0,
          total: metadata.total || amount,
          itemsCount: metadata.orderItemsCount || 0,
          deliverTo: metadata.deliverTo || 'Room 101',
          specialInstructions: metadata.specialInstructions || '',
          // Include all other metadata
          ...metadata
        };

        // Initialize payment with Flutterwave
        const paymentResult = await flutterwaveService.initializePayment(
          email,
          amount,
          {
            userId,
            bookingDetails,
            userName,
            orderId,
            redirectUrl: metadata.redirectUrl || 'https://example.com/success'
          },
          executionId
        );

        if (!paymentResult.success) {
          logger.error('Flutterwave payment initialization failed', executionId, null, paymentResult);
          return res.status(500).json({
            error: 'Failed to initialize payment',
            details: paymentResult.error
          });
        }

        // Determine transaction type and generate reference
        const transactionType = bookingDetails.transactionType || "food_order";
        const reference = flutterwaveService.generatePrefixedReference(transactionType, paymentResult.reference);
        const currentTimestamp = new Date().toISOString();

        logger.transaction('CREATE', reference, executionId, {
          transactionType,
          amount,
          email
        });

        // Create service record using database helper
        await dbHelper.createServiceRecord(
          userId,
          userName,
          email,
          reference,
          transactionType,
          bookingDetails,
          amount,
          currentTimestamp,
          executionId
        );

        logger.success(`Flutterwave transaction created successfully: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          reference: reference,
          authorization_url: paymentResult.authorizationUrl,
          access_code: paymentResult.accessCode,
          tx_ref: paymentResult.reference,
          paymentData: paymentResult.paymentData,
          fullResponse: paymentResult.fullResponse || paymentResult.paymentData
        });

      } catch (error) {
        logger.critical('Flutterwave transaction creation failed', executionId, error);
        res.status(500).json({
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// Flutterwave Payment Verification Function
exports.verifyFlutterwavePayment = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY,
    env: [
      'FLUTTERWAVE_SECRET_KEY',
      'FLUTTERWAVE_PUBLIC_KEY',
      'FLUTTERWAVE_ENCRYPTION_KEY',
      'FLUTTERWAVE_SECRET_HASH'
    ]
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `flw-verify-${Date.now()}`;

      try {
        logger.startFunction('verifyFlutterwavePayment', executionId);

        const { reference, orderId } = req.body;
        if (!reference) {
          return res.status(400).json({
            success: false,
            error: 'Reference is required'
          });
        }

        // Extract original Flutterwave reference if prefixed
        const originalReference = flutterwaveService.extractOriginalReference(reference);

        // Verify payment with Flutterwave
        const verificationResult = await flutterwaveService.verifyTransaction(originalReference, executionId);

        if (!verificationResult.success) {
          logger.error('Flutterwave payment verification failed', executionId, null, verificationResult);
          return res.status(400).json({
            success: false,
            error: 'Payment verification failed',
            details: verificationResult.error
          });
        }

        logger.success(`Flutterwave payment verified successfully: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          status: verificationResult.status,
          amount: verificationResult.amount,
          reference: reference,
          tx_ref: verificationResult.reference,
          flw_ref: verificationResult.flutterwaveReference,
          paidAt: verificationResult.paidAt,
          channel: verificationResult.channel,
          currency: verificationResult.currency
        });

      } catch (error) {
        logger.critical('Flutterwave payment verification failed', executionId, error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// Flutterwave Transaction Status Function
exports.getFlutterwaveTransactionStatus = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: 60,
    memory: FUNCTIONS_CONFIG.MEMORY,
    env: [
      'FLUTTERWAVE_SECRET_KEY',
      'FLUTTERWAVE_PUBLIC_KEY',
      'FLUTTERWAVE_ENCRYPTION_KEY',
      'FLUTTERWAVE_SECRET_HASH'
    ]
  },
  async (req, res) => {
    cors(req, res, async () => {
      const executionId = `flw-status-${Date.now()}`;

      try {
        logger.startFunction('getFlutterwaveTransactionStatus', executionId);

        const { reference } = req.query;
        if (!reference) {
          return res.status(400).json({
            success: false,
            error: 'Reference is required'
          });
        }

        // Extract original Flutterwave reference if prefixed
        const originalReference = flutterwaveService.extractOriginalReference(reference);

        // Get transaction status from Flutterwave
        const statusResult = await flutterwaveService.getTransactionStatus(originalReference, executionId);

        if (!statusResult.success) {
          return res.status(400).json({
            success: false,
            error: 'Failed to get transaction status',
            details: statusResult.error
          });
        }

        logger.success(`Flutterwave transaction status retrieved: ${reference}`, executionId);

        res.status(200).json({
          success: true,
          status: statusResult.status,
          amount: statusResult.amount,
          reference: reference,
          tx_ref: statusResult.reference,
          paidAt: statusResult.paidAt,
          details: statusResult.details
        });

      } catch (error) {
        logger.critical('Failed to get Flutterwave transaction status', executionId, error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
          message: error.message
        });
      }
    });
  }
);

// Flutterwave Webhook Handler
exports.flutterwaveWebhook = onRequest(
  {
    region: FUNCTIONS_CONFIG.REGION,
    timeoutSeconds: FUNCTIONS_CONFIG.TIMEOUT_SECONDS,
    memory: FUNCTIONS_CONFIG.MEMORY,
    env: [
      'FLUTTERWAVE_SECRET_KEY',
      'FLUTTERWAVE_PUBLIC_KEY',
      'FLUTTERWAVE_ENCRYPTION_KEY',
      'FLUTTERWAVE_SECRET_HASH'
    ]
  },
  async (req, res) => {
    const executionId = `flw-webhook-${Date.now()}`;

    try {
      logger.startFunction('flutterwaveWebhook', executionId);

      // Get raw body for signature verification
      const rawBody = req.rawBody ? req.rawBody.toString() : JSON.stringify(req.body);
      const event = req.body;
      const flutterwaveSignature = req.headers["flutterwave-signature"];

      logger.info(`Received Flutterwave v3 event: ${event.event} - ${event.data?.status}`, executionId, {
        hasSignature: !!flutterwaveSignature,
        bodySize: rawBody.length
      });

      // Verify webhook signature using raw body (per Flutterwave v4 documentation)
      if (!flutterwaveService.verifyWebhookSignature(rawBody, flutterwaveSignature, executionId)) {
        logger.warning('Invalid Flutterwave webhook signature', executionId);
        return res.status(401).send("Invalid signature");
      }

      // Process webhook event
      const processResult = flutterwaveService.processWebhookEvent(event, executionId);
      if (!processResult.success) {
        logger.error('Failed to process Flutterwave webhook event', executionId);
        return res.status(400).send("Invalid event data");
      }

      const processedEvent = processResult.processedEvent;

      // Handle different event types
      // Flutterwave v3 webhook events for Standard payments
      const eventType = event.event;
      const eventStatus = processedEvent.status;

      logger.info(`Processing Flutterwave event: ${eventType} with status: ${eventStatus}`, executionId);

      if (eventType === "charge.completed" && eventStatus === "successful") {
        await handleSuccessfulFlutterwavePayment(processedEvent, executionId);
      } else if (eventType === "charge.failed") {
        await handleFailedFlutterwavePayment(processedEvent, executionId);
      } else if (eventType === "transfer.success" && eventStatus === "successful") {
        await handleSuccessfulFlutterwavePayment(processedEvent, executionId);
      } else if (eventType === "transfer.failed") {
        await handleFailedFlutterwavePayment(processedEvent, executionId);
      } else if (eventType === "payment.completed" && eventStatus === "successful") {
        await handleSuccessfulFlutterwavePayment(processedEvent, executionId);
      } else if (eventType === "payment.failed") {
        await handleFailedFlutterwavePayment(processedEvent, executionId);
      } else {
        logger.info(`Unhandled Flutterwave event type: ${eventType} with status: ${eventStatus}`, executionId, {
          fullEvent: JSON.stringify(event)
        });
      }

      logger.success('Flutterwave webhook processed successfully', executionId);
      res.status(200).send("OK");

    } catch (error) {
      logger.critical('Flutterwave webhook processing failed', executionId, error);
      // Always return 200 to prevent retry loops for non-recoverable errors
      res.status(200).send("Webhook received with error");
    }
  }
);


// Helper function for successful Flutterwave payments
async function handleSuccessfulFlutterwavePayment(processedEvent, executionId) {
  const { reference, amount, paidAt, userId, userName, bookingDetails } = processedEvent;

  // Find document and update status
  const { actualReference, transactionType, orderDetails, userEmail } = await dbHelper.findDocumentWithPrefix(reference, executionId);

  // Update transaction status
  const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['food_order'];
  const updateData = {
    status: 'confirmed',
    time_created: paidAt,
    amount: amount,
    verified_at: dbHelper.getServerTimestamp(),
    flutterwave_ref: processedEvent.flutterwaveReference
  };

  if (config.transactionType === 'service') {
    updateData.updatedAt = paidAt;
  }

  await dbHelper.updateDocument(config.collectionName, actualReference, updateData, executionId);

  // Clear user cart after successful food order payment
  if (transactionType === 'food_order' && userId) {
    try {
      const clearResult = await dbHelper.clearUserCart(userId, executionId);
      logger.info(`Cart clearing result for user ${userId}: ${clearResult.success ? 'success' : 'failed'} - ${clearResult.itemCount || 0} items`, executionId);
    } catch (error) {
      logger.error(`Failed to clear cart for user: ${userId}`, executionId, error);
    }
  }

  // Send success notification
  const notificationData = notificationService.generateNotificationData(
    transactionType, orderDetails, actualReference, amount, true
  );

  if (userId) {
    const config = TRANSACTION_TYPES[transactionType];
    await notificationService.sendNotificationToUser(
      userId,
      config.notificationTitle.success,
      `Your ${transactionType.replace('_', ' ')} payment of ₦${amount.toLocaleString()} has been confirmed!`,
      notificationData,
      executionId
    );
  }
}

// Helper function for failed Flutterwave payments
async function handleFailedFlutterwavePayment(processedEvent, executionId) {
  const { reference, amount, paidAt } = processedEvent;

  const { actualReference, transactionType } = await dbHelper.findDocumentWithPrefix(reference, executionId);
  const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['food_order'];

  const updateData = {
    status: 'failed',
    time_created: paidAt,
    amount: amount,
    flutterwave_ref: processedEvent.flutterwaveReference
  };

  await dbHelper.updateDocument(config.collectionName, actualReference, updateData, executionId);
  logger.info(`Flutterwave payment failed for ${reference}`, executionId);
}


// ========================================================================
// Legacy Support - Export services for advanced usage
// NOTE: Commented out to prevent circular reference issues during deployment
// ========================================================================
// exports.services = {
//   email: emailService,
//   payment: paymentService,
//   notification: notificationService,
//   statistics: statisticsService,
//   inventory: inventoryService,
//   database: dbHelper,
//   logger: logger
// };

console.log('✅ Food Delivery App Firebase Functions initialized successfully');
console.log('📦 All services loaded and ready');
console.log('🚀 Modular architecture active');
console.log('='.repeat(50));
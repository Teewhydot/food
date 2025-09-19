
const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const functions = require('firebase-functions');
const axios = require('axios');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
const crypto = require('crypto');
const cors = require('cors')({ origin: true });
const nodemailer = require('nodemailer');
const QRCode = require('qrcode');

// Use environment variables for configuration.
const gmailPassword = process.env.PASSWORD;
db.settings({
  ignoreUndefinedProperties: true
});
const PAYSTACK_SECRET_KEY = process.env.PAYSTACK_SECRET_KEY;

// Contact information configuration (can be updated remotely)
const SUPPORT_EMAIL = process.env.SUPPORT_EMAIL || 'support@fmhhotel.com';
const SUPPORT_PHONE = process.env.SUPPORT_PHONE || '+234 XXX XXX XXXX';
const HOTEL_LOCATION = process.env.HOTEL_LOCATION || 'Lagos, Nigeria';

console.log('Contact Configuration:');
console.log('- Support Email:', SUPPORT_EMAIL);
console.log('- Support Phone:', SUPPORT_PHONE);
console.log('- Hotel Location:', HOTEL_LOCATION);

// Ensure project ID is set correctly
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'fmh-hotel';
console.log(`Using project ID: ${PROJECT_ID}`);
// ========================================================================
// createTransaction Function
// ========================================================================
exports.createTransaction = onRequest(
  { region: 'us-central1', timeoutSeconds: 560, memory: '256MB' },
  async (req, res) => {
    // Wrap CORS manually.
    cors(req, res, async () => {
      // Expecting the request body paysto contain:
      // { amount, userId, email, bookingDetails }
      // where bookingDetails is an object: { productId, name, quantity }
      const { amount, userId, email, bookingDetails, userName } = req.body;
      try {
        const response = await axios.post(
          'https://api.paystack.co/transaction/initialize',
          {
            email: email,
            amount: amount * 100, // Amount in kobo.
            metadata: {
              userId: userId,
              bookingDetails: bookingDetails,
              userName: userName
            },
          },
          {
            headers: {
              Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
              'Content-Type': 'application/json',
            },
          }
        )

        const paystackReference = response.data.data.reference;
        const currentTimestamp = new Date().toISOString();

        // Determine transaction type based on bookingDetails
        const transactionType = bookingDetails.transactionType || "booking";

        // Add prefix to reference based on transaction type
        const prefixMap = {
          'booking': 'B-',
          'food_order': 'F-',
          'gym_session': 'G-',
          'pool_session': 'P-',
          'laundry_service': 'L-',
        };

        const prefix = prefixMap[transactionType] || '';
        const reference = prefix + paystackReference;

        console.log('Creating transaction with type:', transactionType);
        console.log('Booking details:', JSON.stringify(bookingDetails, null, 2));

        // Create service-specific record (transactions are managed in main collections only)
        await createServiceRecord(userId, userName, email, reference, transactionType, bookingDetails, amount, currentTimestamp);

        // Send creation email using scalable system
        // try {
        //   const emailContent = generateCreationEmail(transactionType, bookingDetails, reference, userName, amount);
        //   if (emailContent) {
        //     await sendEmailInternal(email, emailContent.subject, emailContent.body);
        //     console.log(`${transactionType} creation email sent to ${email}`);
        //   }
        // } catch (emailError) {
        //   console.error('Failed to send creation email:', emailError);
        // }

        // Send creation push notification using scalable system
        // try {
        //   const config = TRANSACTION_TYPES[transactionType];
        //   if (config) {
        //     const notificationTitle = config.notificationTitle.creation;
        //     const notificationBody = `Your ${transactionType.replace('_', ' ')} ${reference} has been created. Please complete payment to confirm.`;
        //     const notificationData = generateNotificationData(transactionType, bookingDetails, reference, amount, false);

        //     await sendFCMNotificationInternal(userId, notificationTitle, notificationBody, notificationData);
        //     console.log(`${transactionType} creation notification sent to user ${userId}`);
        //   }
        // } catch (notificationError) {
        //   console.error(`Failed to send creation notification for ${transactionType}:`, notificationError);
        //   console.error('Notification error details:', {
        //     userId: userId,
        //     transactionType: transactionType,
        //     reference: reference,
        //     error: notificationError.message,
        //     stack: notificationError.stack
        //   });
        // }

        // Add to pending transactions queue for verification
        await db.collection('pending_transactions')
          .doc(reference)
          .set({
            reference: reference,
            userId: userId,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            last_checked: null,
            check_count: 0,
            max_checks: 20, // Stop checking after 20 attempts (about 24 hours)
            transactionType: transactionType,
            serviceType: bookingDetails.serviceType,
          });

        console.log("Transaction created successfully with reference:", reference);
        res.status(200).send({
          authorization_url: response.data.data.authorization_url,
          reference: reference,
        });
      } catch (error) {
        console.error('Error Creating Transaction:', error);
        res.status(500).send('Internal server error.');
      }
    });
  }
);

// ========================================================================
// paystackWebhook Function
// ========================================================================

exports.paystackWebhook = onRequest(
  { region: 'us-central1', timeoutSeconds: 60, memory: '256MB' },
  async (req, res) => {
    cors(req, res, async () => {
      // Log headers and body for debugging
      console.log("Headers:", req.headers);
      console.log("Initial req.body:", req.body);

      // If req.body is empty, try to parse it manually
      if (!req.body || Object.keys(req.body).length === 0) {
        let data = '';
        req.on('data', chunk => { data += chunk; });
        req.on('end', async () => {
          try {
            req.body = JSON.parse(data);
            console.log("Parsed body from raw data:", req.body);
            await handlePaystackWebhook(req, res);
          } catch (e) {
            console.error("Failed to parse body:", e);
            return res.status(400).send("Invalid JSON");
          }
        });
        return;
      }
      // If body is present, proceed
      await handlePaystackWebhook(req, res);
    });
  }
);

// Clean bookingDetails for user transaction: remove reviews, imageUrls, videoUrls from each room but keep amenities
function cleanBookingDetails(details) {
  if (!details.selectedRooms) return details;
  return {
    ...details,
    selectedRooms: details.selectedRooms.map(room => {
      const { reviews, imageUrls, videoUrls, ...rest } = room;
      return rest;
    })
  };
}

// Helper function to find the correct prefixed reference and transaction details
async function findDocumentWithPrefix(reference) {
  console.log(`Finding document for reference: ${reference}`);

  // Define prefix mapping for transaction types
  const prefixMapping = {
    'B-': { type: 'booking', collection: 'bookings' },
    'F-': { type: 'food_order', collection: 'service_orders' },
    'G-': { type: 'gym_session', collection: 'service_orders' },
    'P-': { type: 'pool_session', collection: 'service_orders' },
    'L-': { type: 'laundry_service', collection: 'service_orders' },
    'C-': { type: 'concierge_request', collection: 'concierge_requests' },
  };

  // Try each prefix to find the document
  for (const [prefix, config] of Object.entries(prefixMapping)) {
    const prefixedReference = `${prefix}${reference}`;

    try {
      const doc = await db.collection(config.collection).doc(prefixedReference).get();
      if (doc.exists) {
        console.log(`Found document with reference: ${prefixedReference} in collection: ${config.collection}`);
        const orderDetails = doc.data();
        let transactionType = config.type;

        // For service orders, determine specific transaction type based on serviceType
        if (config.collection === 'service_orders') {
          const serviceType = orderDetails.serviceType;
          switch (serviceType) {
            case 'food_delivery':
              transactionType = 'food_order';
              break;
            case 'gym':
              transactionType = 'gym_session';
              break;
            case 'swimming_pool':
              transactionType = 'pool_session';
              break;
            case 'spa':
              transactionType = 'spa_session';
              break;
            case 'laundry_service':
              transactionType = 'laundry_service';
              break;
          }
        }

        return {
          actualReference: prefixedReference,
          transactionType: transactionType,
          orderDetails: orderDetails,
          userEmail: orderDetails.userEmail || ''
        };
      }
    } catch (prefixError) {
      console.log(`No document found with prefix ${prefix} for reference ${reference}`);
    }
  }

  console.error(`No document found for reference ${reference} with any known prefix. Tried: B-, F-, G-, P-, L-`);
  return {
    actualReference: reference,
    transactionType: 'booking',
    orderDetails: {},
    userEmail: ''
  };
}

// Extracted handler logic for clarity
async function handlePaystackWebhook(req, res) {
  try {
    const event = req.body;
    console.log("Received Paystack event:", event.event, event.data && event.data.status);
    const paystackSignature = req.headers["x-paystack-signature"];
    const secret = PAYSTACK_SECRET_KEY;
    const hash = crypto
      .createHmac("sha512", secret)
      .update(JSON.stringify(event))
      .digest("hex");
    if (hash !== paystackSignature) {
      console.error("Invalid Paystack webhook signature");
      return res.status(400).send("Invalid paystack signature");
    }
    if (event && event.event === "charge.success" && event.data.status === "success") {
      // Payment successful
      const { reference, status, paid_at, amount, metadata } = event.data;
      const { userId, userName } = metadata;
      const bookingDetails = metadata.bookingDetails || {};
      const amountPaid = amount / 100;

      // Find the document with the correct prefix
      const { actualReference, transactionType, orderDetails, userEmail } = await findDocumentWithPrefix(reference);

      // Transaction status is now managed directly in the main collections (bookings, service_orders)
      console.log(`Skipping user transaction subcollection update for ${reference} - using main collection instead`);

      // Update the appropriate collection using scalable system
      const config = TRANSACTION_TYPES[transactionType];
      if (config) {
        const updateData = {
          status: status,
          time_created: paid_at,
          amount: amountPaid,
        };

        // Add updatedAt for service records
        if (config.transactionType === 'service') {
          updateData.updatedAt = paid_at;
        }

        await db.collection(config.collectionName)
          .doc(actualReference)
          .update(updateData);
      } else {
        // Fallback to booking collection for unknown types
        await db.collection('bookings')
          .doc(actualReference)
          .update({
            status: status,
            time_created: paid_at,
            amount: amountPaid,
          });
      }

      // Remove from pending transactions queue using actualReference (with prefix)
      await db.collection('pending_transactions').doc(actualReference).delete();

      // Send success email using scalable system
      if (userEmail) {
        try {
          const emailContent = await generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paid_at);
          if (emailContent) {
            await sendEmailInternal(userEmail, emailContent.subject, emailContent.body, emailContent.html, emailContent.attachments);
            console.log(`${transactionType} success email sent to ${userEmail}`);
          }
        } catch (emailError) {
          console.error('Failed to send success email:', emailError);
        }
    }

      // Send push notification for successful payment using scalable system
      try {
        const config = TRANSACTION_TYPES[transactionType];
        if (config) {
          const notificationTitle = config.notificationTitle.success;
          let notificationBody;

          if (transactionType === 'booking') {
            notificationBody = `Your payment for booking ${reference} has been confirmed. See you on ${new Date(bookingDetails.checkInDate).toLocaleDateString()}!`;
          } else {
            // Customized messages based on service type
            switch (transactionType) {
              case 'food_order':
                notificationBody = `Your payment for food order ${reference} has been confirmed. Our kitchen is preparing your delicious meal!`;
                break;
              case 'gym_session':
                notificationBody = `Your payment for gym session ${reference} has been confirmed. Get ready to crush your workout goals!`;
                break;
              case 'pool_session':
                notificationBody = `Your payment for pool session ${reference} has been confirmed. Time to dive in and enjoy your swim!`;
                break;
              case 'spa_session':
                notificationBody = `Your payment for spa session ${reference} has been confirmed. Prepare for ultimate relaxation and rejuvenation!`;
                break;
              case 'laundry_service':
                notificationBody = `Your payment for laundry service ${reference} has been confirmed. We'll take great care of your clothes!`;
                break;
              default:
                notificationBody = `Your payment for ${transactionType.replace('_', ' ')} ${reference} has been confirmed. Your service is being prepared!`;
            }
          }

          const notificationData = generateNotificationData(transactionType, orderDetails, reference, amountPaid, true);
          notificationData.paymentDate = paid_at;

          await sendFCMNotificationInternal(userId, notificationTitle, notificationBody, notificationData);
          console.log(`${transactionType} success notification sent to user ${userId}`);
        }
      } catch (notificationError) {
        console.error(`Failed to send success notification for ${transactionType}:`, notificationError);
        console.error('Success notification error details:', {
          userId: userId,
          transactionType: transactionType,
          reference: reference,
          error: notificationError.message,
          stack: notificationError.stack
        });
      }

      // Notify admin of successful payment
      if (status === 'success') {
        await createAdminPaymentNotification({
          transactionType: transactionType,
          reference: actualReference,
          userName: userName,
          amount: amountPaid,
          userEmail: userEmail
        });
      }

      // Update availability only for successful room booking payment
      if (transactionType === 'booking') {
        await updateAvailabilityForSuccessfulBooking(actualReference, userId, 'webhook');

        // Update booking stats
        console.log("Updating booking stats...");
        await updateBookingStats(actualReference, 'webhook');

        console.log("Booking, availability, and stats updated. Payment processed successfully.");
      } else if (transactionType === 'food_order') {
        // Deduct food quantities for successful food orders
        console.log("🍽️ WEBHOOK: Food order payment successful - starting quantity deduction...");
        console.log("🍽️ WEBHOOK: Order reference:", actualReference);
        console.log("🍽️ WEBHOOK: Transaction type:", transactionType);
        console.log("🍽️ WEBHOOK: User ID:", userId);

        await deductFoodQuantities(actualReference, 'webhook');

        console.log("🍽️ WEBHOOK: Food order payment processed and quantity deduction completed.");
      } else {
        console.log("Service order payment processed successfully.");
      }

      // Notify staff about confirmed service orders (not bookings)
      if (transactionType !== 'booking' && config && config.serviceType) {
        try {
          console.log(`Notifying staff about confirmed ${config.serviceType} order: ${actualReference}`);
          // Get the updated order details from the database
          const orderDoc = await db.collection(config.collectionName).doc(actualReference).get();
          if (orderDoc.exists) {
            await notifyStaffForNewOrder(actualReference, config.serviceType, orderDoc.data(), 'payment_success');
            console.log(`Staff notified about confirmed ${config.serviceType} order`);
          }
        } catch (staffNotifyError) {
          console.error(`Failed to notify staff about ${config.serviceType} order:`, staffNotifyError);
          // Don't throw - continue processing even if staff notification fails
        }
      }
    } else if (event && event.event === "charge.failed" || event.event === "charge.failure" || event.event === "transfer.failed" || event.event === "invoice.payment_failed") {
      // Payment failed
      const { reference, status, paid_at, amount, metadata } = event.data;
      const { userId, userName } = metadata;
      const bookingDetails = metadata.bookingDetails || {};
      const amountPaid = amount / 100;

      // Find the document with the correct prefix
      const { actualReference, transactionType, orderDetails, userEmail } = await findDocumentWithPrefix(reference);

      // Transaction status is now managed directly in the main collections (bookings, service_orders)
      console.log(`Skipping user transaction subcollection update for failed payment ${reference} - using main collection instead`);

      // Update the appropriate collection using scalable system for failed payments
      const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['booking'];
      const updateData = {
        status: status,
        time_created: paid_at,
        amount: amountPaid,
      };

      // Add updatedAt for service records
      if (config.transactionType === 'service') {
        updateData.updatedAt = paid_at;
      }

      await db.collection(config.collectionName)
        .doc(actualReference)
        .update(updateData);

      // Remove from pending transactions queue for failed payments
      await db.collection('pending_transactions').doc(actualReference).delete();

      console.log("Payment failed. Transaction and bookings updated, availability not changed.");
    } else if (event && event.event === "charge.abandoned") {
      // Payment abandoned (user closed/cancelled)
      const { reference, status, paid_at, amount, metadata } = event.data;
      const { userId, userName } = metadata;
      const bookingDetails = metadata.bookingDetails || {};
      const amountPaid = amount / 100;

      // Find the document with the correct prefix
      const { actualReference, transactionType, orderDetails, userEmail } = await findDocumentWithPrefix(reference);

      // Transaction status is now managed directly in the main collections (bookings, service_orders)
      console.log(`Skipping user transaction subcollection update for abandoned payment ${reference} - using main collection instead`);

      // Update the appropriate collection using scalable system for abandoned payments
      const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['booking'];
      const updateData = {
        status: status,
        time_created: paid_at,
        amount: amountPaid,
      };

      // Add updatedAt for service records
      if (config.transactionType === 'service') {
        updateData.updatedAt = paid_at;
      }

      await db.collection(config.collectionName)
        .doc(actualReference)
        .update(updateData);

      // Remove from pending transactions queue for abandoned payments
      await db.collection('pending_transactions').doc(actualReference).delete();

      console.log("Payment abandoned. Transaction and bookings updated, availability not changed.");
    } else {
      // Handle other events or ignore
      console.log("Unhandled Paystack event:", event.event, event.data && event.data.status);
    }
    // Always return 200 OK to acknowledge receipt (per Paystack docs)
    return res.status(200).send("Webhook received");
  } catch (error) {
    console.error("Error processing Paystack webhook:", error);
    // Still return 200 OK to prevent Paystack from retrying
    return res.status(200).send("Webhook received with error");
  }
}

// Configure the email transport using Nodemailer
const transporter = nodemailer.createTransport({
  host: 'mail.cyrextech.org',        // POP/IMAP server
  port: 587,                     // secure SMTP port
  secure: false,
  auth: {
    user: 'no-reply@cyrextech.org',
    pass: process.env.PASSWORD,
  },
});


exports.sendEmail = onRequest(
  { region: 'us-central1', timeoutSeconds: 60, memory: '256MB' },
  async (req, res) => {
    // Wrap with CORS
    cors(req, res, async () => {
      // Extract email details from the request
      const { to, subject, text } = req.body;

      // Validate input
      if (!to || !subject || !text) {
        return res.status(400).send('Missing required fields: to, subject, text.');
      }

      // Define the email options
      const mailOptions = {
        from: 'devs@cyrextech.org',
        to: to,
        subject: subject,
        text: text,
      };

      try {
        // Send the email
        await transporter.sendMail(mailOptions);
        console.log('Email sent successfully');
        return res.status(200).send('Email sent successfully');
      } catch (error) {
        console.error('Error sending email:', error);
        return res.status(500).send('Error sending email');
      }
    });
  }
);

// FCM diagnostic function
exports.checkFCMConfig = onRequest(
  { region: 'us-central1', timeoutSeconds: 60, memory: '256MB' },
  async (req, res) => {
    cors(req, res, async () => {
      try {
        // Check project configuration
        const config = {
          projectId: PROJECT_ID,
          envProjectId: process.env.GOOGLE_CLOUD_PROJECT,
          gcloudProjectId: process.env.GCLOUD_PROJECT,
          adminProjectId: admin.instanceId().app.options.projectId,
        };

        // Try to get access token
        let tokenStatus = 'Not tested';
        let tokenError = null;
        try {
          const token = await getAccessToken();
          tokenStatus = token ? 'Success' : 'Failed - no token returned';
        } catch (error) {
          tokenStatus = 'Failed';
          tokenError = error.message;
        }

        // Check if FCM API is accessible
        let fcmStatus = 'Not tested';
        let fcmError = null;
        try {
          const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`;
          const token = await getAccessToken();

          // Send a dry-run message to test API access
          const testMessage = {
            message: {
              token: 'dry_run_token',
              notification: {
                title: 'Test',
                body: 'Test'
              }
            },
            validate_only: true
          };

          await axios.post(fcmEndpoint, testMessage, {
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`,
            },
          });
          fcmStatus = 'API accessible';
        } catch (error) {
          if (error.response?.status === 400) {
            fcmStatus = 'API accessible (invalid token expected)';
          } else if (error.response?.status === 403) {
            fcmStatus = 'API FORBIDDEN - FCM API not enabled or permission denied';
            fcmError = error.response?.data;
          } else {
            fcmStatus = 'Failed';
            fcmError = error.message;
          }
        }

        return res.status(200).json({
          config,
          tokenStatus,
          tokenError,
          fcmStatus,
          fcmError,
          recommendation: fcmStatus.includes('FORBIDDEN')
            ? 'Enable FCM API in Google Cloud Console for project: ' + PROJECT_ID
            : 'Configuration looks correct'
        });
      } catch (error) {
        return res.status(500).json({
          error: error.message,
          stack: error.stack
        });
      }
    });
  }
);

exports.sendFCMNotification = onRequest(
  { region: 'us-central1', timeoutSeconds: 120, memory: '256MB' },
  async (req, res) => {
    cors(req, res, async () => {
      const { userId, title, body, data } = req.body;

      if (!userId || !title || !body) {
        return res.status(400).json({ error: 'Missing required fields.' });
      }

      try {
        console.log('=====>::::::::::: Sending Notification:', title);

        // Get user's FCM token from Firestore
        const userDoc = await db.collection('users').doc(userId).get();
        if (!userDoc.exists) {
          return res.status(404).json({ error: 'User not found.' });
        }

        const { token } = userDoc.data();
        if (!token) {
          return res.status(400).json({ error: 'User does not have an FCM token.' });
        }

        // Create notification document in Firestore
        const notificationRef = await db.collection('users').doc(userId).collection('notifications').add({
          title,
          body,
          data: data || {},
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        // Update unread count
        const userNotificationsRef = db.collection('users').doc(userId);
        await userNotificationsRef.update({
          unreadNotifications: admin.firestore.FieldValue.increment(1)
        });

        // Use the configured project ID
        const projectId = PROJECT_ID;

        // Get OAuth2 token for FCM
        const serverKey = await getAccessToken();
        const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

        console.log(`Using FCM endpoint: ${fcmEndpoint}`);

        // Prepare FCM message using the v1 API format
        const message = {
          message: {
            token: token,
            notification: {
              title,
              body,
            },
            data: {
              ...(data || {}),
              notificationId: notificationRef.id
            },
          }
        };

        // Send FCM notification using the v1 API
        const fcmResponse = await axios.post(
          fcmEndpoint,
          message,
          {
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${serverKey}`,
            },
          }
        );

        console.log('FCM message sent successfully');
        return res.status(200).json({
          message: 'Notification sent successfully',
          fcmResponse: fcmResponse.data,
          notificationId: notificationRef.id
        });
      } catch (error) {
        console.error('Failed to send FCM message:', error.code || error.message);
        if (error.response) {
          console.error('Response error data:', error.response.data);
          console.error('Response error status:', error.response.status);
        }
        return res.status(500).json({
          error: 'Failed to send notification',
          details: error.message,
        });
      }
    });
  }
);


// ========================================================================
// Scheduled Transaction Verification Function
// ========================================================================
exports.verifyPendingTransactions = onSchedule(
  {
    schedule: 'every 1 minutes',
    timeZone: 'UTC',
    region: 'us-central1',
    timeoutSeconds: 540,
    memory: '256MB'
  },
  async (event) => {
    const startTime = Date.now();
    const executionId = `exec_${startTime}_${Math.random().toString(36).substr(2, 9)}`;

    try {
      console.log(`[${executionId}] ========== PENDING TRANSACTION VERIFICATION STARTED ==========`);
      console.log(`[${executionId}] Execution Time: ${new Date().toISOString()}`);

      // Get pending transactions that need checking
      const now = admin.firestore.Timestamp.now();

      // Remove the time constraint for testing - check all pending transactions
      const pendingQuery = await db.collection('pending_transactions')
        .where('check_count', '<', 20)
        .limit(50) // Process max 50 at a time to control costs
        .get();

      if (pendingQuery.empty) {
        console.log(`[${executionId}] No pending transactions found in queue`);
        console.log(`[${executionId}] ========== VERIFICATION COMPLETED (No transactions) ==========`);
        return;
      }

      console.log(`[${executionId}] Found ${pendingQuery.size} pending transactions to verify`);
      console.log(`[${executionId}] Transaction References:`, pendingQuery.docs.map(doc => doc.id));

      // Process each pending transaction
      const batch = db.batch();
      const verificationPromises = [];
      const transactionDetails = [];

      for (const doc of pendingQuery.docs) {
        const data = doc.data();
        const transactionInfo = {
          reference: data.reference,
          userId: data.userId,
          checkCount: data.check_count || 0,
          createdAt: data.created_at?.toDate?.()?.toISOString() || 'unknown',
          lastChecked: data.last_checked?.toDate?.()?.toISOString() || 'never'
        };
        transactionDetails.push(transactionInfo);

        console.log(`[${executionId}] Queuing verification for transaction:`, transactionInfo);
        verificationPromises.push(verifyTransaction(data.reference, data.userId, batch, doc.ref, executionId));
      }

      // Execute all verifications
      console.log(`[${executionId}] Starting parallel verification of ${verificationPromises.length} transactions...`);
      const results = await Promise.allSettled(verificationPromises);

      // Log results summary
      const successCount = results.filter(r => r.status === 'fulfilled').length;
      const failureCount = results.filter(r => r.status === 'rejected').length;

      console.log(`[${executionId}] Verification Results Summary:`);
      console.log(`[${executionId}] - Successful verifications: ${successCount}`);
      console.log(`[${executionId}] - Failed verifications: ${failureCount}`);

      if (failureCount > 0) {
        console.error(`[${executionId}] Failed verifications:`,
          results.filter(r => r.status === 'rejected').map(r => r.reason));
      }

      // Commit batch updates
      console.log(`[${executionId}] Committing batch updates to Firestore...`);
      await batch.commit();
      console.log(`[${executionId}] Batch commit successful`);

      const executionTime = Date.now() - startTime;
      console.log(`[${executionId}] ========== VERIFICATION COMPLETED ==========`);
      console.log(`[${executionId}] Total execution time: ${executionTime}ms`);
      console.log(`[${executionId}] Transactions processed: ${pendingQuery.size}`);

    } catch (error) {
      console.error(`[${executionId}] ========== VERIFICATION FAILED ==========`);
      console.error(`[${executionId}] Critical error in scheduled transaction verification:`, error);
      console.error(`[${executionId}] Error stack:`, error.stack);
      console.error(`[${executionId}] Execution time before failure: ${Date.now() - startTime}ms`);
    }
  }
);

// Verify individual transaction with Paystack API
async function verifyTransaction(reference, userId, batch, pendingDocRef, executionId = 'manual') {
  const verificationStartTime = Date.now();

  try {
    console.log(`[${executionId}] ---------- Verifying Transaction: ${reference} ----------`);
    console.log(`[${executionId}] User ID: ${userId}`);
    console.log(`[${executionId}] Starting Paystack API call...`);

    // Call Paystack verification API
    const response = await axios.get(
      `https://api.paystack.co/transaction/verify/${reference}`,
      {
        headers: {
          Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log(`[${executionId}] Paystack API Response Status: ${response.status}`);
    console.log(`[${executionId}] Paystack API Response Success: ${response.data.status}`);

    const transactionData = response.data.data;
    const status = transactionData.status;
    const amountPaid = transactionData.amount / 100;
    const paidAt = transactionData.paid_at || transactionData.created_at;
    const channel = transactionData.channel;
    const currency = transactionData.currency;

    console.log(`[${executionId}] Transaction Details:`);
    console.log(`[${executionId}] - Reference: ${reference}`);
    console.log(`[${executionId}] - Status: ${status}`);
    console.log(`[${executionId}] - Amount: ${currency} ${amountPaid}`);
    console.log(`[${executionId}] - Channel: ${channel}`);
    console.log(`[${executionId}] - Paid At: ${paidAt}`);
    console.log(`[${executionId}] - Gateway Response: ${transactionData.gateway_response}`);

    // Find the document with the correct prefix
    const { actualReference, transactionType, orderDetails, userEmail } = await findDocumentWithPrefix(reference);

    // Update transaction status in main collection only using scalable system
    console.log(`[${executionId}] Skipping user transaction subcollection update for ${reference} - using main collection instead`);
    const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['booking'];
    const serviceRef = db.collection(config.collectionName).doc(actualReference);

    const updateData = {
      status: status,
      time_created: paidAt,
      amount: amountPaid,
      verified_at: admin.firestore.FieldValue.serverTimestamp(),
      gateway_response: transactionData.gateway_response,
      channel: channel
    };

    // Add updatedAt for service records
    if (config.transactionType === 'service') {
      updateData.updatedAt = paidAt;
    }

    console.log(`[${executionId}] Updating Firestore documents with status: ${status}`);
    batch.update(serviceRef, updateData);

    // If transaction is successful, update availability and send success email
    if (status === 'success') {
      console.log(`[${executionId}] Transaction SUCCESSFUL - Processing post-payment tasks...`);

      // Update availability only for bookings
      if (transactionType === 'booking') {
        console.log(`[${executionId}] Updating availability index...`);
        await updateAvailabilityForSuccessfulBooking(actualReference, userId, executionId);

        // Update booking stats
        console.log(`[${executionId}] Updating booking stats...`);
        await updateBookingStats(actualReference, executionId);
      } else if (transactionType === 'food_order') {
        // Deduct food quantities for successful food orders
        console.log(`🍽️ SCHEDULED VERIFICATION: Food order payment verified - starting quantity deduction...`);
        console.log(`🍽️ SCHEDULED VERIFICATION: Order reference: ${actualReference}`);
        console.log(`🍽️ SCHEDULED VERIFICATION: Transaction type: ${transactionType}`);
        console.log(`🍽️ SCHEDULED VERIFICATION: Execution ID: ${executionId}`);

        await deductFoodQuantities(actualReference, executionId);

        console.log(`🍽️ SCHEDULED VERIFICATION: Food order quantity deduction completed.`);
      }

      // Send success email for verified transactions using scalable system
      try {
        console.log(`[${executionId}] Fetching transaction details for email...`);
        const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['booking'];
        const serviceDoc = await db.collection(config.collectionName).doc(actualReference).get();

        if (serviceDoc.exists) {
          const serviceData = serviceDoc.data();
          const serviceUserEmail = serviceData.userEmail;
          const serviceOrderDetails = serviceData;

          if (serviceUserEmail) {
            console.log(`[${executionId}] Sending confirmation email to: ${serviceUserEmail}`);

            const emailContent = await generateEnhancedSuccessEmail(transactionType, serviceOrderDetails, actualReference, serviceData.userName || 'Guest', amountPaid, paidAt);
            if (emailContent) {
              await sendEmailInternal(serviceUserEmail, emailContent.subject, emailContent.body, emailContent.html, emailContent.attachments);
              console.log(`[${executionId}] Confirmation email sent successfully to ${serviceUserEmail}`);
            }
          } else {
            console.warn(`[${executionId}] No email address found for ${transactionType} ${actualReference}`);
          }
        } else {
          console.error(`[${executionId}] ${transactionType} document not found: ${actualReference}`);
        }
      } catch (emailError) {
        console.error(`[${executionId}] Failed to send confirmation email:`, emailError.message);
      }

      // Send push notification using scalable system
      try {
        console.log(`[${executionId}] Sending push notification to user: ${userId}`);
        const config = TRANSACTION_TYPES[transactionType] || TRANSACTION_TYPES['booking'];
        const serviceDoc = await db.collection(config.collectionName).doc(reference).get();
        const serviceDetails = serviceDoc.data() || {};

        const notificationTitle = 'Payment Verified! ✅';
        let notificationBody;

        // Customized messages based on service type for verification notifications
        switch (transactionType) {
          case 'booking':
            notificationBody = `Your payment for booking ${reference} has been verified. Your reservation is confirmed!`;
            break;
          case 'food_order':
            notificationBody = `Your payment for food order ${reference} has been verified. Our kitchen is preparing your delicious meal!`;
            break;
          case 'gym_session':
            notificationBody = `Your payment for gym session ${reference} has been verified. Get ready to crush your workout goals!`;
            break;
          case 'pool_session':
            notificationBody = `Your payment for pool session ${reference} has been verified. Time to dive in and enjoy your swim!`;
            break;
          case 'spa_session':
            notificationBody = `Your payment for spa session ${reference} has been verified. Prepare for ultimate relaxation and rejuvenation!`;
            break;
          case 'laundry_service':
            notificationBody = `Your payment for laundry service ${reference} has been verified. We'll take great care of your clothes!`;
            break;
          default:
            notificationBody = `Your payment for ${transactionType.replace('_', ' ')} ${reference} has been verified. Your service is confirmed!`;
        }
        const notificationData = generateNotificationData(transactionType, serviceDetails, actualReference, amountPaid, true);
        notificationData.verifiedAt = new Date().toISOString();
        notificationData.type = 'payment_verified';
        // This function gets triggered inside the verify_transaction function, this function runs preriodically and is usefull for updating transactions that
        // takes a long time to verify, So for transactions that the notification is not sent, we can send it here
        await sendFCMNotificationInternal(userId, notificationTitle, notificationBody, notificationData);
        console.log(`[${executionId}] Push notification sent successfully`);
      } catch (notificationError) {
        console.error(`[${executionId}] Failed to send push notification:`, notificationError.message);
      }
    } else if (status === 'failed') {
      console.log(`[${executionId}] Transaction FAILED - Gateway response: ${transactionData.gateway_response}`);
    } else if (status === 'abandoned') {
      console.log(`[${executionId}] Transaction ABANDONED by user`);
    } else {
      console.log(`[${executionId}] Transaction still PENDING`);
    }

    // Remove from pending queue if transaction is resolved
    if (['success', 'failed', 'abandoned'].includes(status)) {
      batch.delete(pendingDocRef);
      console.log(`[${executionId}] Removed resolved transaction ${reference} from pending queue (status: ${status})`);
    } else {
      // Increment check count for still pending transactions
      const pendingUpdate = {
        check_count: admin.firestore.FieldValue.increment(1),
        last_checked: admin.firestore.FieldValue.serverTimestamp(),
        last_status: status
      };
      batch.update(pendingDocRef, pendingUpdate);
      console.log(`[${executionId}] Transaction still pending - incremented check count`);
    }

    const verificationTime = Date.now() - verificationStartTime;
    console.log(`[${executionId}] Transaction verification completed in ${verificationTime}ms`);
    console.log(`[${executionId}] ---------- End Verification: ${reference} ----------`);

  } catch (error) {
    const verificationTime = Date.now() - verificationStartTime;
    console.error(`[${executionId}] ---------- VERIFICATION ERROR: ${reference} ----------`);
    console.error(`[${executionId}] Error Type: ${error.name}`);
    console.error(`[${executionId}] Error Message: ${error.message}`);

    if (error.response) {
      console.error(`[${executionId}] API Response Status: ${error.response.status}`);
      console.error(`[${executionId}] API Response Data:`, JSON.stringify(error.response.data));
    }

    console.error(`[${executionId}] Verification failed after ${verificationTime}ms`);

    // Increment check count even on error to prevent infinite retries
    batch.update(pendingDocRef, {
      check_count: admin.firestore.FieldValue.increment(1),
      last_checked: admin.firestore.FieldValue.serverTimestamp(),
      last_error: error.message,
      last_error_time: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`[${executionId}] Updated pending transaction with error information`);
    console.error(`[${executionId}] ---------- End Error: ${reference} ----------`);
  }
}

// Helper function to update availability for successful booking
async function updateAvailabilityForSuccessfulBooking(reference, userId, executionId = 'manual') {
  try {
    console.log(`[${executionId}] Starting availability update for booking: ${reference}`);

    // Get booking details
    const bookingDoc = await db.collection('bookings').doc(reference).get();
    if (!bookingDoc.exists) {
      console.error(`[${executionId}] Booking document not found for availability update: ${reference}`);
      return;
    }

    const bookingData = bookingDoc.data();
    const { bookingDetails } = bookingData;
    const { selectedRooms, checkInDate, checkOutDate } = bookingDetails;

    if (selectedRooms && checkInDate && checkOutDate) {
      console.log(`[${executionId}] Booking details found:`);
      console.log(`[${executionId}] - Check-in: ${checkInDate}`);
      console.log(`[${executionId}] - Check-out: ${checkOutDate}`);
      console.log(`[${executionId}] - Rooms count: ${selectedRooms.length}`);
      console.log(`[${executionId}] - Room IDs: ${selectedRooms.map(r => r.id).join(', ')}`);

      const start = new Date(checkInDate);
      const end = new Date(checkOutDate);
      let totalDatesUpdated = 0;

      for (const room of selectedRooms) {
        console.log(`[${executionId}] Processing room ${room.id} - ${room.name}`);
        let current = new Date(start);
        let datesForRoom = 0;

        while (current <= end) {
          const dateStr = current.toISOString().split('T')[0];
          const checkInStr = new Date(checkInDate).toISOString().split('T')[0];
          const checkOutStr = new Date(checkOutDate).toISOString().split('T')[0];
          const bookingId = `${userId}_${room.id}_${checkInStr}_${checkOutStr}`;

          const bookingRef = {
            room_id: room.id.toString(),
            booking_id: bookingId,
            check_in: checkInStr,
            check_out: checkOutStr,
          };

          await db.collection('availability_index')
            .doc(dateStr)
            .set({
              date: dateStr,
              bookings: admin.firestore.FieldValue.arrayUnion(bookingRef)
            }, { merge: true });

          datesForRoom++;
          totalDatesUpdated++;
          current.setDate(current.getDate() + 1);
        }

        console.log(`[${executionId}] Room ${room.id}: Updated ${datesForRoom} dates in availability index`);
      }

      console.log(`[${executionId}] Successfully updated availability for booking ${reference}`);
      console.log(`[${executionId}] Total dates updated: ${totalDatesUpdated}`);
      console.log(`[${executionId}] Availability index update completed`);
    } else {
      console.warn(`[${executionId}] Missing booking details for availability update:`);
      console.warn(`[${executionId}] - selectedRooms: ${selectedRooms ? 'present' : 'missing'}`);
      console.warn(`[${executionId}] - checkInDate: ${checkInDate || 'missing'}`);
      console.warn(`[${executionId}] - checkOutDate: ${checkOutDate || 'missing'}`);
    }
  } catch (error) {
    console.error(`[${executionId}] Error updating availability for booking ${reference}:`, error.message);
    console.error(`[${executionId}] Error stack:`, error.stack);
  }
}

// ========================================================================
// Cleanup Function - Remove old pending transactions that exceeded max checks
// ========================================================================
exports.cleanupOldPendingTransactions = onSchedule(
  {
    schedule: 'every 24 hours',
    timeZone: 'UTC',
    region: 'us-central1',
    timeoutSeconds: 300,
    memory: '256MB'
  },
  async (event) => {
    try {
      console.log('Starting cleanup of old pending transactions...');

      // Get transactions that have exceeded max checks or are older than 48 hours
      const twoDaysAgo = admin.firestore.Timestamp.fromMillis(Date.now() - (48 * 60 * 60 * 1000));

      const oldTransactionsQuery = await db.collection('pending_transactions')
        .where('created_at', '<', twoDaysAgo)
        .limit(100)
        .get();

      const exceededChecksQuery = await db.collection('pending_transactions')
        .where('check_count', '>=', 20)
        .limit(100)
        .get();

      const toDelete = new Set();

      // Collect documents to delete
      oldTransactionsQuery.docs.forEach(doc => toDelete.add(doc.ref));
      exceededChecksQuery.docs.forEach(doc => toDelete.add(doc.ref));

      if (toDelete.size === 0) {
        console.log('No old pending transactions to clean up');
        return;
      }

      console.log(`Cleaning up ${toDelete.size} old pending transactions`);

      // Delete in batches
      const batch = db.batch();
      let count = 0;

      for (const docRef of toDelete) {
        batch.delete(docRef);
        count++;

        // Commit batch every 500 operations (Firestore limit)
        if (count % 500 === 0) {
          await batch.commit();
          const newBatch = db.batch();
          Object.assign(batch, newBatch);
        }
      }

      // Commit remaining operations
      if (count % 500 !== 0) {
        await batch.commit();
      }

      console.log(`Cleaned up ${count} old pending transactions`);
    } catch (error) {
      console.error('Error in cleanup function:', error);
    }
  }
);

// Get OAuth access token for FCM using Application Default Credentials
async function getAccessToken() {
  try {
    // Use the Google Auth Library for authentication
    const { GoogleAuth } = require('google-auth-library');

    // Define the scopes needed for FCM
    const SCOPES = [
      'https://www.googleapis.com/auth/firebase.messaging'
    ];

    // Create a new GoogleAuth instance with ADC
    const auth = new GoogleAuth({
      scopes: SCOPES
    });

    // Get a client with the credentials
    const client = await auth.getClient();

    // Get the access token
    const tokenResponse = await client.getAccessToken();

    if (!tokenResponse || !tokenResponse.token) {
      throw new Error('Failed to obtain access token');
    }

    console.log('Successfully obtained access token');
    return tokenResponse.token;
  } catch (error) {
    console.error('Error getting access token:', error);

    // Try alternative method if first one fails
    try {
      console.log('Trying alternative method for getting access token...');
      // Use the admin SDK to get an access token
      const token = await admin.credential.applicationDefault().getAccessToken();
      console.log('Successfully obtained access token via alternative method');
      return token.access_token;
    } catch (altError) {
      console.error('Alternative method also failed:', altError);
      throw error; // Throw the original error
    }
  }
}




// Internal function to send FCM notifications
async function sendFCMNotificationInternal(userId, title, body, data = {}) {
  let userToken = null; // Define userToken in outer scope

  try {
    console.log(`Starting FCM notification for user ${userId}:`, { title, body, data });

    // Get user's FCM token and preferences from Firestore
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const userData = userDoc.data();
    const { token, fcmToken, notificationPreferences = ['general', 'payment', 'appUpdate'] } = userData;

    console.log(`User data tokens:`, { token: token ? 'exists' : 'missing', fcmToken: fcmToken ? 'exists' : 'missing' });

    // Check both token and fcmToken fields for compatibility
    userToken = token || fcmToken;

    if (!userToken) {
      throw new Error('User does not have an FCM token');
    }

    // Check if notification type is allowed based on user preferences
    const notificationType = data.type || 'general';
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

    const preferenceCategory = typeMapping[notificationType] || 'general';

    if (!notificationPreferences.includes(preferenceCategory)) {
      console.log(`Notification blocked for user ${userId} - type: ${notificationType}, category: ${preferenceCategory}`);
      return {
        success: false,
        reason: 'User has disabled this notification type'
      };
    }

    // Create notification document in Firestore
    const notificationRef = await db.collection('users').doc(userId).collection('notifications').add({
      title,
      body,
      data: data || {},
      type: data.type || 'general',
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Update unread count
    const userNotificationsRef = db.collection('users').doc(userId);
    await userNotificationsRef.update({
      unreadNotifications: admin.firestore.FieldValue.increment(1)
    });

    // Use the configured project ID
    const projectId = PROJECT_ID;

    // Get OAuth2 token for FCM
    const serverKey = await getAccessToken();
    const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    // Prepare FCM message using the v1 API format
    // Ensure all data values are strings (FCM requirement)
    const stringifiedData = {};
    for (const [key, value] of Object.entries(data)) {
      stringifiedData[key] = String(value);
    }

    const message = {
      message: {
        token: userToken,
        notification: {
          title,
          body,
        },
        data: {
          ...stringifiedData,
          notificationId: notificationRef.id
        },
      }
    };

    // Send FCM notification using the v1 API
    console.log(`Sending FCM notification to project ${projectId}:`, message);
    const fcmResponse = await axios.post(
      fcmEndpoint,
      message,
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${serverKey}`,
        },
      }
    );

    console.log('FCM message sent successfully through internal function:', fcmResponse.data);
    return {
      success: true,
      notificationId: notificationRef.id
    };
  } catch (error) {
    console.error('Failed to send internal FCM message:', error);
    console.error('FCM Error details:', {
      userId: userId,
      hasToken: !!userToken,
      title: title,
      body: body,
      data: data,
      error: error.message,
      response: error.response?.data || 'No response data',
      status: error.response?.status || 'No status'
    });
    throw error;
  }
}

// Function to notify staff members about new service orders
async function notifyStaffForNewOrder(orderReference, serviceType, orderDetails, executionId = 'order') {
  try {
    console.log(`[${executionId}] Notifying staff for new ${serviceType} order: ${orderReference}`);

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
      console.log(`[${executionId}] No permission mapping for service type: ${serviceType}`);
      return;
    }

    // Query admins collection for staff with the required permission
    const adminsSnapshot = await db.collection('admins')
      .where('permissions', 'array-contains', requiredPermission)
      .get();

    if (adminsSnapshot.empty) {
      console.log(`[${executionId}] No staff found with permission: ${requiredPermission}`);
      return;
    }

    console.log(`[${executionId}] Found ${adminsSnapshot.size} staff members with ${requiredPermission} permission`);

    // Prepare notification content
    const notificationTitle = `New ${serviceType.replace(/_/g, ' ').toUpperCase()} Order 🔔`;
    let notificationBody = `Order #${orderReference} requires attention`;

    // Customize notification based on service type
    if (serviceType === 'food_delivery' && orderDetails.items) {
      const itemCount = orderDetails.items.length;
      const deliverTo = orderDetails.deliverTo || 'delivery';
      notificationBody = `New food order with ${itemCount} items for ${deliverTo}`;
    } else if (serviceType === 'laundry_service') {
      const customerName = orderDetails.userName || orderDetails.customerName || 'guest';
      notificationBody = `New laundry service request from ${customerName}`;
    } else if (['gym', 'swimming_pool', 'spa'].includes(serviceType)) {
      const bookingDate = orderDetails.bookingDate || orderDetails.sessionDate || 'today';
      notificationBody = `New ${serviceType.replace(/_/g, ' ')} booking for ${bookingDate}`;
    }

    // Send FCM notification to each qualified staff member
    const notificationPromises = [];
    for (const doc of adminsSnapshot.docs) {
      const staffData = doc.data();
      const staffId = doc.id;

      // Check for FCM token (could be fcmToken or token field)
      const staffToken = staffData.fcmToken || staffData.token;

      if (staffToken) {
        console.log(`[${executionId}] Sending notification to staff: ${staffData.name || staffId}`);

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

        // Send notification directly using FCM API since staff are in admins collection, not users
        try {
          const projectId = PROJECT_ID;
          const serverKey = await getAccessToken();
          const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

          // Ensure all data values are strings
          const stringifiedData = {};
          for (const [key, value] of Object.entries(notificationData)) {
            stringifiedData[key] = String(value);
          }

          const message = {
            message: {
              token: staffToken,
              notification: {
                title: notificationTitle,
                body: notificationBody,
              },
              data: stringifiedData,
              android: {
                priority: 'high',
                notification: {
                  sound: 'default',
                  priority: 'high',
                  defaultSound: true,
                  defaultVibrateTimings: true
                }
              },
              apns: {
                payload: {
                  aps: {
                    sound: 'default',
                    badge: 1
                  }
                }
              }
            }
          };

          await axios.post(fcmEndpoint, message, {
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${serverKey}`,
            },
          });

          console.log(`[${executionId}] Successfully notified staff: ${staffData.name || staffId}`);
        } catch (notifError) {
          console.error(`[${executionId}] Failed to notify staff ${staffId}:`, notifError.message);
        }
      } else {
        console.log(`[${executionId}] Staff ${staffData.name || staffId} has no FCM token`);
      }
    }

    console.log(`[${executionId}] Staff notification process completed`);

  } catch (error) {
    console.error(`[${executionId}] Error notifying staff:`, error);
    // Don't throw - continue with order processing even if notifications fail
  }
}



// ========================================================================

  // In the createServiceRecord function (around line 1428), add:

  // Add new function to create admin notifications
  async function createAdminNotification(transactionType, data) {
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

      // Save to admin notifications collection
      await db.collection('notifications').add(notificationData);

      // Queue push notifications for relevant admin staff
      await queueAdminPushNotifications(transactionType,
  notificationData);

      console.log(`Admin notification created for
  ${transactionType}: ${data.reference}`);
    } catch (error) {
      console.error('Error creating admin notification:', error);
    }
  }
  function getAdminNotificationTitle(transactionType, data) {
    switch (transactionType) {
      case 'booking':
        return 'New Room Booking';
      case 'food_order':
        return 'New Food Order';
      case 'gym_session':
        return 'New Gym Session';
      case 'pool_session':
        return 'New Pool Session';
      case 'laundry_service':
        return 'New Laundry Service';
      default:
        return 'New Service Request';
    }
  }

  function getAdminNotificationMessage(transactionType, data) {
    switch (transactionType) {
      case 'booking':
        return `${data.userName} has made a new booking
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
      case 'food_order':
        return `${data.userName} placed a food order
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
      case 'gym_session':
        return `${data.userName} booked a gym session
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
      case 'pool_session':
        return `${data.userName} booked a pool session
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
      case 'laundry_service':
        return `${data.userName} requested laundry service
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
      default:
        return `${data.userName} made a service request
  (${data.reference}) - ₦${data.amount.toLocaleString()}`;
    }
  }

  function mapTransactionTypeToNotificationType(transactionType) {
    switch (transactionType) {
      case 'booking': return 'booking';
      case 'food_order': return 'food';
      case 'gym_session':
      case 'pool_session':
      case 'spa_session': return 'amenities';
      case 'laundry_service': return 'laundry';
      default: return 'system';
    }
  }

  function getTargetRolesForTransaction(transactionType) {
    switch (transactionType) {
      case 'booking':
        return ['Super Admin', 'Admin', 'Reception'];
      case 'food_order':
        return ['Super Admin', 'Admin', 'Kitchen Staff'];
      case 'gym_session':
      case 'pool_session':
      case 'spa_session':
        return ['Super Admin', 'Admin', 'Amenities Manager'];
      case 'laundry_service':
        return ['Super Admin', 'Admin', 'Laundry Staff'];
      default:
        return ['Super Admin', 'Admin'];
    }
  }

  async function queueAdminPushNotifications(transactionType,
  notificationData) {
    try {
      // Get admin users with appropriate roles
      const targetRoles =
  getTargetRolesForTransaction(transactionType);

      // Query admin users collection (you'll need to create this)
      const adminUsers = await db.collection('admin_users')
        .where('role', 'in', targetRoles)
        .where('isActive', '==', true)
        .get();

      // Queue push notifications
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
      console.error('Error queueing admin push notifications:',
  error);
    }
  }

  async function createAdminPaymentNotification(data) {
    try {
      const notificationData = {
        title: 'Payment Confirmed',
        message: `Payment confirmed for
  ${data.transactionType.replace('_', ' ')} ${data.reference} -
  ₦${data.amount.toLocaleString()}`,
        type: 'payment',
        priority: 'medium',
        relatedOrderId: data.reference,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
        targetRoles:
  getTargetRolesForTransaction(data.transactionType),
        metadata: {
          transactionType: data.transactionType,
          amount: data.amount,
          customerName: data.userName,
          paymentConfirmed: true
        }
      };

      await db.collection('notifications').add(notificationData);
      await queueAdminPushNotifications(data.transactionType,
  notificationData);

    } catch (error) {
      console.error('Error creating admin payment notification:',
  error);
    }}
// ========================================================================

// Internal function to send emails
async function sendEmailInternal(to, subject, text, html = null, attachments = []) {
  try {
    console.log(`Attempting to send email to: ${to}`);
    console.log(`Subject: ${subject}`);

    // Define the email options
    const mailOptions = {
      from: '"FMH Hotel" <no-reply@cyrextech.org>',
      to: to,
      subject: subject,
      text: text,
      html: html || text, // Use HTML if provided, otherwise fallback to text
      attachments: attachments // Include attachments (for embedded QR codes)
    };

    // Send the email
    const result = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', {
      messageId: result.messageId,
      to: to,
      subject: subject,
      accepted: result.accepted,
      rejected: result.rejected
    });
    return true;
  } catch (error) {
    console.error('Error sending internal email:', error);
    console.error('Failed email details:', { to, subject });
    throw error;
  }
}

// ========================================================================
// SCALABLE TRANSACTION SYSTEM
// ========================================================================

// Transaction type configuration
const TRANSACTION_TYPES = {
  booking: {
    collectionName: 'bookings',
    transactionType: 'booking',
    serviceType: null,
    emailSubject: {
      creation: 'Booking Created',
      success: 'Booking Confirmed'
    },
    notificationTitle: {
      creation: 'Booking Created',
      success: 'Booking Confirmed! 🎉'
    },
    emoji: '🏨'
  },
  food_order: {
    collectionName: 'service_orders',
    transactionType: 'service',
    serviceType: 'food_delivery',
    emailSubject: {
      creation: 'Food Order Created',
      success: 'Food Order Confirmed'
    },
    notificationTitle: {
      creation: 'Food Order Created',
      success: 'Food Order Confirmed! 🍽️'
    },
    emoji: '🍽️'
  },
  gym_session: {
    collectionName: 'service_orders',
    transactionType: 'service',
    serviceType: 'gym',
    emailSubject: {
      creation: 'Gym Session Booked',
      success: 'Gym Session Confirmed'
    },
    notificationTitle: {
      creation: 'Gym Session Booked',
      success: 'Gym Session Confirmed! 💪'
    },
    emoji: '💪'
  },
  pool_session: {
    collectionName: 'service_orders',
    transactionType: 'service',
    serviceType: 'swimming_pool',
    emailSubject: {
      creation: 'Pool Session Booked',
      success: 'Pool Session Confirmed'
    },
    notificationTitle: {
      creation: 'Pool Session Booked',
      success: 'Pool Session Confirmed! 🏊‍♂️'
    },
    emoji: '🏊‍♂️'
  },
  spa_session: {
    collectionName: 'service_orders',
    transactionType: 'service',
    serviceType: 'spa',
    emailSubject: {
      creation: 'Spa Session Booked',
      success: 'Spa Session Confirmed'
    },
    notificationTitle: {
      creation: 'Spa Session Booked',
      success: 'Spa Session Confirmed! 🧘‍♀️'
    },
    emoji: '🧘‍♀️'
  },
  laundry_service: {
    collectionName: 'service_orders',
    transactionType: 'service',
    serviceType: 'laundry_service',
    emailSubject: {
      creation: 'Laundry Service Booked',
      success: 'Laundry Service Confirmed'
    },
    notificationTitle: {
      creation: 'Laundry Service Booked',
      success: 'Laundry Service Confirmed! 👔'
    },
    emoji: '👔'
  },
  concierge_request: {
    collectionName: 'concierge_requests',
    transactionType: 'concierge',
    serviceType: 'concierge',
    emailSubject: {
      creation: 'Concierge Request Created',
      success: 'Concierge Request Confirmed'
    },
    notificationTitle: {
      creation: 'Concierge Request Created',
      success: 'Concierge Request Confirmed! 🛎️'
    },
    emoji: '🛎️'
  }
};

// Note: Transaction records are now managed directly in main collections (bookings, service_orders)
// User transactions subcollection has been removed to avoid NOT_FOUND errors

// Create service-specific record in appropriate collection
async function createServiceRecord(userId, userName, email, reference, transactionType, details, amount, timestamp) {
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
    status: "pending", // Payment status
    service_status: "pending", // Service fulfillment status (pending, processing, completed)
    time_created: timestamp,
    transactionType: config.transactionType,
    serviceType: config.serviceType
  };

  let serviceRecord;

  switch (transactionType) {
    case 'booking':
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

    case 'gym_session':
    case 'pool_session':
    case 'spa_session':
      serviceRecord = {
        ...baseRecord,
        sessionType: details.sessionType || 'regular',
        sessionDate: details.sessionDate,
        sessionTime: details.sessionTime,
        duration: details.duration || 60,
        participants: details.participants || 1,
        specialRequests: details.specialRequests,
        amenityType: details.amenityType,
        packageType: details.packageType,
        categoryName: details.categoryName,
        session: details.session,
        notes: details.notes,
        pricingId: details.pricingId,
        customerName: details.customerName,
        gender: details.gender,
        bookingDate: details.bookingDate,
        items: details.items || [],
        service_items: details.service_items || details.items || [],
        createdAt: timestamp,
        updatedAt: timestamp
      };
      break;

    case 'laundry_service':
      serviceRecord = {
        ...baseRecord,
        items: details.items || [],
        service_items: details.service_items || details.items || [],
        pickupLocation: details.pickupLocation || "unset",
        deliveryLocation: details.deliveryLocation || "unset",
        serviceType: details.serviceType || 'laundry_service',
        laundryServiceType: details.laundryServiceType,
        specialInstructions: details.specialInstructions,
        createdAt: timestamp,
        updatedAt: timestamp
      };
      break;

    case 'concierge_request':
      serviceRecord = {
        ...baseRecord,
        requestType: details.requestType || 'general',
        description: details.description,
        priority: details.priority || 'normal',
        createdAt: timestamp,
        updatedAt: timestamp
      };
      break;

    default:
      // Generic service record for new service types
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

  // Notify relevant staff members about the new order (excluding bookings)
  if (config.serviceType && transactionType !== 'booking') {
    console.log(`Notifying staff for new ${config.serviceType} order: ${reference}`);
    await notifyStaffForNewOrder(reference, config.serviceType, serviceRecord, 'create');
  }

  // Notify admin about the new order
  await createAdminNotification(transactionType, {
    userId: userId,
    userName: userName,
    reference: reference,
    amount: amount,
    details: details,
    timestamp: timestamp
  });
}

// Generate creation email content
function generateCreationEmail(transactionType, details, reference, userName, amount) {
  const config = TRANSACTION_TYPES[transactionType];
  if (!config) return null;

  const subject = `${config.emailSubject.creation} - ${reference}`;
  let body;

  switch (transactionType) {
    case 'booking':
      body = `Dear ${userName},

Your booking has been created successfully!

Booking Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Check-in: ${details.checkInDate}
- Check-out: ${details.checkOutDate}
- Guests: ${details.guestCount}
- Total Amount: ₦${amount.toLocaleString()}

Please complete your payment to confirm your reservation.

Best regards,
FMH Hotel Team`;
      break;

    case 'food_order':
      const itemsList = details.items?.map(item =>
        `- ${item.name} x${item.quantity} - ₦${item.total?.toLocaleString() || (item.price * item.quantity).toLocaleString()}`
      ).join('\n') || 'No items listed';

      body = `Dear ${userName},

Your food order has been created successfully!

Order Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Delivery To: ${details.deliverTo || 'Room 101'}
- Items Ordered:
${itemsList}
- Total Amount: ₦${amount.toLocaleString()}
${details.specialInstructions ? `- Special Instructions: ${details.specialInstructions}` : ''}

Please complete your payment to confirm your order.

Best regards,
FMH Hotel Team`;
      break;

    case 'gym_session':
      body = `Dear ${userName},

Your gym session has been booked successfully!

Session Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${details.sessionDate}
- Session Time: ${details.sessionTime}
- Duration: ${details.duration || 60} minutes
- Participants: ${details.participants || 1}
- Total Amount: ₦${amount.toLocaleString()}
${details.specialRequests ? `- Special Requests: ${details.specialRequests}` : ''}

Please complete your payment to confirm your session.

Best regards,
FMH Hotel Team`;
      break;

    case 'pool_session':
      body = `Dear ${userName},

Your swimming pool session has been booked successfully!

Session Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${details.sessionDate}
- Session Time: ${details.sessionTime}
- Duration: ${details.duration || 60} minutes
- Participants: ${details.participants || 1}
- Total Amount: ₦${amount.toLocaleString()}
${details.specialRequests ? `- Special Requests: ${details.specialRequests}` : ''}

Please complete your payment to confirm your session.

Best regards,
FMH Hotel Team`;
      break;

    case 'spa_session':
      body = `Dear ${userName},

Your spa session has been booked successfully!

Session Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${details.sessionDate}
- Session Time: ${details.sessionTime}
- Duration: ${details.duration || 60} minutes
- Service Type: ${details.sessionType || 'Regular'}
- Total Amount: ₦${amount.toLocaleString()}
${details.specialRequests ? `- Special Requests: ${details.specialRequests}` : ''}

Please complete your payment to confirm your session.

Best regards,
FMH Hotel Team`;
      break;

    case 'laundry_service':
      const laundryItems = details.items?.map(item =>
        `- ${item.name} x${item.quantity}`
      ).join('\n') || 'No items listed';

      body = `Dear ${userName},

Your laundry service has been booked successfully!

Service Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Service Type: ${details.serviceType || 'Wash and Fold'}
- Pickup Location: ${details.pickupLocation || 'Room 101'}
- Delivery Location: ${details.deliveryLocation || 'Room 101'}
- Items:
${laundryItems}
- Total Amount: ₦${amount.toLocaleString()}
${details.specialInstructions ? `- Special Instructions: ${details.specialInstructions}` : ''}

Please complete your payment to confirm your service.

Best regards,
FMH Hotel Team`;
      break;

    default:
      body = `Dear ${userName},

Your ${transactionType.replace('_', ' ')} has been created successfully!

Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Total Amount: ₦${amount.toLocaleString()}

Please complete your payment to confirm your service.

Best regards,
FMH Hotel Team`;
  }

  return { subject, body };
}

// Generate success email content
function generateSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt) {
  const config = TRANSACTION_TYPES[transactionType];
  if (!config) return null;

  const subject = `${config.emailSubject.success} - ${reference}`;
  let body;

  switch (transactionType) {
    case 'booking':
      const checkInDate = new Date(orderDetails.bookingDetails?.checkInDate).toLocaleDateString();
      const checkOutDate = new Date(orderDetails.bookingDetails?.checkOutDate).toLocaleDateString();

      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your booking is now confirmed.

Booking Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Check-in: ${checkInDate}
- Check-out: ${checkOutDate}
- Guests: ${orderDetails.bookingDetails?.guestCount}
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Your reservation is secured. Please present this reference number during check-in.

We look forward to welcoming you to FMH Hotel!

Best regards,
FMH Hotel Team`;
      break;

    case 'food_order':
      const itemsList = orderDetails.items?.map(item =>
        `- ${item.name} x${item.quantity} - ₦${item.total?.toLocaleString() || (item.price * item.quantity).toLocaleString()}`
      ).join('\n') || 'No items listed';

      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your food order is now confirmed.

Order Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Delivery To: ${orderDetails.deliverTo || 'Room 101'}
- Items Ordered:
${itemsList}
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}
${orderDetails.specialInstructions ? `- Special Instructions: ${orderDetails.specialInstructions}` : ''}

Your order is being prepared and will be delivered to your room shortly.

Thank you for choosing FMH Hotel!

Best regards,
FMH Hotel Team`;
      break;

    case 'gym_session':
      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your gym session is now confirmed.

Session Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${orderDetails.sessionDate}
- Session Time: ${orderDetails.sessionTime}
- Duration: ${orderDetails.duration || 60} minutes
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Please arrive 10 minutes early for your session. Bring comfortable workout attire.

We look forward to seeing you at the gym!

Best regards,
FMH Hotel Team`;
      break;

    case 'pool_session':
      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your swimming pool session is now confirmed.

Session Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${orderDetails.sessionDate}
- Session Time: ${orderDetails.sessionTime}
- Duration: ${orderDetails.duration || 60} minutes
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Please arrive 10 minutes early for your session. Don't forget to bring your swimwear!

We look forward to seeing you at the pool!

Best regards,
FMH Hotel Team`;
      break;

    case 'spa_session':
      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your spa session is now confirmed.

Session Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Session Date: ${orderDetails.bookingDate || orderDetails.sessionDate}
- Session Time: ${orderDetails.session || orderDetails.sessionTime}
- Duration: ${orderDetails.duration || 60} minutes
- Service Type: ${orderDetails.sessionType || orderDetails.amenityType || 'Spa Session'}
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Please arrive 15 minutes early for your session to complete the consultation.

We look forward to providing you with a relaxing experience!

Best regards,
FMH Hotel Team`;
      break;

    case 'laundry_service':
      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your laundry service is now confirmed.

Service Confirmation:
- Reference: ${reference}
- Hotel: FMH Hotel
- Service Type: ${orderDetails.serviceType || 'Wash and Fold'}
- Pickup Location: ${orderDetails.pickupLocation || 'Room 101'}
- Delivery Location: ${orderDetails.deliveryLocation || 'Room 101'}
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Your laundry will be collected and returned within 24 hours.

Thank you for choosing FMH Hotel!

Best regards,
FMH Hotel Team`;
      break;

    default:
      body = `Dear ${userName},

Congratulations! Your payment has been successfully processed and your ${transactionType.replace('_', ' ')} is now confirmed.

Confirmation Details:
- Reference: ${reference}
- Hotel: FMH Hotel
- Total Amount Paid: ₦${amountPaid.toLocaleString()}
- Payment Date: ${new Date(paidAt).toLocaleDateString()}

Thank you for choosing FMH Hotel!

Best regards,
FMH Hotel Team`;
  }

  return { subject, body };
}

// Generate QR code buffer for email attachment
async function generateQRCodeBuffer(data) {
  try {
    const qrDataString = typeof data === 'object'
      ? Object.entries(data).map(([key, value]) => `${key}:${value}`).join('\n')
      : data;

    // Generate QR code as buffer for email attachment
    const qrCodeBuffer = await QRCode.toBuffer(qrDataString, {
      errorCorrectionLevel: 'M',
      type: 'png',
      quality: 0.92,
      margin: 1,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      },
      width: 200
    });

    return qrCodeBuffer;
  } catch (error) {
    console.error('Error generating QR code:', error);
    return null;
  }
}

// Generate HTML email template
function generateHTMLEmailTemplate(content) {
  const { title, headerColor = '#1a365d', logoUrl = '', sections = [], footer = '', hasQRCode = false } = content;

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; margin: 0; padding: 0; background-color: #f7fafc; }
    .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
    .header { background: linear-gradient(135deg, ${headerColor} 0%, #2c5282 100%); color: #ffffff; padding: 40px 30px; text-align: center; }
    .logo { width: 120px; height: auto; margin-bottom: 20px; }
    .content { padding: 40px 30px; }
    .section { margin-bottom: 30px; }
    .section-title { font-size: 18px; font-weight: 600; color: #2d3748; margin-bottom: 15px; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; }
    .details-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
    .detail-row { border-bottom: 1px solid #f1f5f9; }
    .detail-label { color: #718096; font-size: 14px; padding: 10px 0; vertical-align: top; }
    .detail-value { color: #2d3748; font-weight: 500; font-size: 14px; text-align: right; padding: 10px 0; vertical-align: top; }
    .highlight { background-color: #fef5e7; padding: 15px; border-left: 4px solid #f39c12; margin: 20px 0; }
    .qr-container { text-align: center; margin: 30px 0; padding: 20px; background-color: #f8fafc; border-radius: 8px; }
    .qr-code { width: 150px; height: 150px; }
    .footer { background-color: #2d3748; color: #ffffff; padding: 30px; text-align: center; font-size: 12px; }
    .button { display: inline-block; padding: 12px 30px; background-color: #3182ce; color: #ffffff; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .items-list { margin: 15px 0; }
    .item-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; }
    .item-name { color: #4a5568; font-size: 14px; }
    .item-details { color: #2d3748; font-size: 14px; text-align: right; }
    @media (max-width: 600px) {
      .content { padding: 20px 15px; }
      .header { padding: 30px 20px; }
      .detail-row { flex-direction: column; }
      .detail-value { text-align: left; margin-top: 5px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      ${logoUrl ? `<img src="${logoUrl}" alt="FMH Hotel" class="logo">` : ''}
      <h1 style="margin: 0; font-size: 28px; font-weight: 300;">FMH Hotel</h1>
      <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 14px;">Luxury & Comfort Redefined</p>
    </div>

    <div class="content">
      ${sections.map(section => `
        <div class="section">
          ${section.title ? `<div class="section-title">${section.title}</div>` : ''}
          ${section.type === 'text' ? `
            <p style="color: #4a5568; line-height: 1.6; margin: 10px 0;">${section.content}</p>
          ` : ''}
          ${section.type === 'details' ? `
            <table class="details-table">
              ${section.items.map(item => `
                <tr class="detail-row">
                  <td class="detail-label">${item.label}</td>
                  <td class="detail-value">${item.value}</td>
                </tr>
              `).join('')}
            </table>
          ` : ''}
          ${section.type === 'items' ? `
            <div class="items-list">
              ${section.items.map(item => `
                <div class="item-row">
                  <span class="item-name">${item.name}</span>
                  <span class="item-details">${item.details}</span>
                </div>
              `).join('')}
            </div>
          ` : ''}
          ${section.type === 'highlight' ? `
            <div class="highlight">
              ${section.content}
            </div>
          ` : ''}
          ${section.type === 'button' ? `
            <div style="text-align: center;">
              <a href="${section.url}" class="button">${section.text}</a>
            </div>
          ` : ''}
        </div>
      `).join('')}

      ${hasQRCode ? `
        <div class="qr-container">
          <p style="margin: 0 0 15px 0; color: #718096; font-size: 12px;">Scan for Quick Verification</p>
          <img src="cid:qr-code" alt="QR Code" class="qr-code">
          <p style="margin: 15px 0 0 0; color: #a0aec0; font-size: 11px;">Present this code at reception</p>
        </div>
      ` : ''}
    </div>

    <div class="footer">
      <p style="margin: 0 0 10px 0;">© 2024 FMH Hotel. All rights reserved.</p>
      <p style="margin: 0 0 10px 0;">${HOTEL_LOCATION} | ${SUPPORT_PHONE}</p>
      <p style="margin: 0; opacity: 0.8; font-size: 11px;">
        ${footer || 'This is an automated message. Please do not reply to this email.'}
      </p>
    </div>
  </div>
</body>
</html>
  `;
}

// Generate enhanced success email with HTML
async function generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt) {
  const config = TRANSACTION_TYPES[transactionType];
  if (!config) return null;

  const subject = `${config.emailSubject.success} - ${reference}`;
  let sections = [];
  let qrData = {};

  // Common QR data
  qrData = {
    reference: reference,
    type: transactionType,
    amount: amountPaid,
    date: new Date(paidAt).toISOString(),
    hotel: 'FMH Hotel'
  };

  switch (transactionType) {
    case 'booking':
      const checkInDate = new Date(orderDetails.bookingDetails?.checkInDate);
      const checkOutDate = new Date(orderDetails.bookingDetails?.checkOutDate);

      qrData.checkIn = checkInDate.toISOString().split('T')[0];
      qrData.checkOut = checkOutDate.toISOString().split('T')[0];
      qrData.guests = orderDetails.bookingDetails?.guestCount;

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Congratulations! Your booking has been confirmed. We're delighted to welcome you to FMH Hotel.`
        },
        {
          type: 'details',
          title: 'Booking Details',
          items: [
            { label: 'Reference Number', value: reference },
            { label: 'Check-in Date', value: checkInDate.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) },
            { label: 'Check-out Date', value: checkOutDate.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) },
            { label: 'Number of Guests', value: orderDetails.bookingDetails?.guestCount || 1 },
            { label: 'Total Amount Paid', value: `₦${amountPaid.toLocaleString()}` },
            { label: 'Payment Date', value: new Date(paidAt).toLocaleDateString() }
          ]
        },
        {
          type: 'highlight',
          content: '<strong>Important:</strong> Please present this email and the QR code at check-in for quick verification.'
        },
        {
          type: 'text',
          content: 'We look forward to making your stay memorable!'
        }
      ];
      break;

    case 'food_order':
      qrData.deliveryLocation = orderDetails.deliverTo;
      qrData.itemCount = orderDetails.items?.length || 0;

      const foodItems = orderDetails.items?.map(item => ({
        name: `${item.name} (x${item.quantity})`,
        details: `₦${(item.price * item.quantity).toLocaleString()}`
      })) || [];

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your food order has been confirmed! Our kitchen is preparing your delicious meal.`
        },
        {
          type: 'details',
          title: 'Order Information',
          items: [
            { label: 'Order Reference', value: reference },
            { label: 'Delivery Location', value: orderDetails.deliverTo || 'Room 101' },
            { label: 'Order Date', value: new Date(paidAt).toLocaleDateString() },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` }
          ]
        },
        {
          type: 'items',
          title: 'Items Ordered',
          items: foodItems
        }
      ];

      if (orderDetails.specialInstructions) {
        sections.push({
          type: 'highlight',
          content: `<strong>Special Instructions:</strong> ${orderDetails.specialInstructions}`
        });
      }

      sections.push({
        type: 'text',
        content: 'Your order will be delivered within 30-45 minutes. Enjoy your meal!'
      });
      break;

    case 'laundry_service':
      qrData.serviceType = orderDetails.laundryServiceType || orderDetails.serviceType;
      qrData.pickup = orderDetails.pickupLocation;
      qrData.delivery = orderDetails.deliveryLocation;
      qrData.turnaround = orderDetails.turnaroundTime || 'Standard (24 Hours)';

      const laundryItems = orderDetails.service_items?.map(item => ({
        name: `${item.name} (x${item.quantity})`,
        details: `₦${(item.price * item.quantity).toLocaleString()}`
      })) || [];

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your laundry service request has been confirmed! We'll take excellent care of your garments.`
        },
        {
          type: 'details',
          title: 'Service Details',
          items: [
            { label: 'Service Reference', value: reference },
            { label: 'Service Type', value: orderDetails.laundryServiceType || 'Wash & Iron' },
            { label: 'Pickup Location', value: orderDetails.pickupLocation || 'Room 101' },
            { label: 'Delivery Location', value: orderDetails.deliveryLocation || 'Room 101' },
            { label: 'Turnaround Time', value: orderDetails.turnaroundTime || 'Standard (24 Hours)' },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` }
          ]
        }
      ];

      if (laundryItems.length > 0) {
        sections.push({
          type: 'items',
          title: 'Items',
          items: laundryItems
        });
      }

      sections.push({
        type: 'text',
        content: 'Our team will collect your items shortly. Thank you for using our laundry service!'
      });
      break;

    case 'gym_session':
      qrData.sessionDate = orderDetails.bookingDate || orderDetails.sessionDate;
      qrData.session = orderDetails.session;
      qrData.participants = orderDetails.participants;

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your gym session has been confirmed! Get ready for an energizing workout.`
        },
        {
          type: 'details',
          title: 'Session Details',
          items: [
            { label: 'Session Reference', value: reference },
            { label: 'Session Type', value: orderDetails.amenityType || 'Gym Session' },
            { label: 'Package', value: orderDetails.packageType || 'Standard' },
            { label: 'Session Date', value: new Date(orderDetails.bookingDate || orderDetails.sessionDate).toLocaleDateString() },
            { label: 'Session Time', value: orderDetails.session || 'Morning' },
            { label: 'Participants', value: orderDetails.participants || 1 },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` }
          ]
        },
        {
          type: 'highlight',
          content: '<strong>Remember:</strong> Please arrive 10 minutes early and bring comfortable workout attire.'
        }
      ];
      break;

    case 'pool_session':
      qrData.sessionDate = orderDetails.bookingDate || orderDetails.sessionDate;
      qrData.session = orderDetails.session;
      qrData.participants = orderDetails.participants;

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your pool session has been confirmed! Time to make a splash!`
        },
        {
          type: 'details',
          title: 'Session Details',
          items: [
            { label: 'Session Reference', value: reference },
            { label: 'Session Type', value: 'Swimming Pool' },
            { label: 'Package', value: orderDetails.packageType || 'Standard' },
            { label: 'Session Date', value: new Date(orderDetails.bookingDate || orderDetails.sessionDate).toLocaleDateString() },
            { label: 'Session Time', value: orderDetails.session || 'Morning' },
            { label: 'Participants', value: orderDetails.participants || 1 },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` }
          ]
        },
        {
          type: 'highlight',
          content: '<strong>Don\'t forget:</strong> Bring your swimwear and arrive 10 minutes early!'
        }
      ];
      break;

    case 'spa_session':
      qrData.sessionDate = orderDetails.bookingDate || orderDetails.sessionDate;
      qrData.session = orderDetails.session;
      qrData.participants = orderDetails.participants;
      qrData.serviceType = orderDetails.amenityType || 'Spa';

      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your spa session has been confirmed! Prepare for ultimate relaxation and rejuvenation.`
        },
        {
          type: 'details',
          title: 'Session Details',
          items: [
            { label: 'Session Reference', value: reference },
            { label: 'Session Type', value: orderDetails.amenityType || 'Spa Session' },
            { label: 'Package', value: orderDetails.packageType || 'Standard' },
            { label: 'Session Date', value: new Date(orderDetails.bookingDate || orderDetails.sessionDate).toLocaleDateString() },
            { label: 'Session Time', value: orderDetails.session || 'Morning' },
            { label: 'Participants', value: orderDetails.participants || 1 },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` }
          ]
        },
        {
          type: 'highlight',
          content: '<strong>Please Note:</strong> Arrive 15 minutes early for your consultation. Wear comfortable clothing.'
        },
        {
          type: 'text',
          content: 'Our professional therapists are ready to provide you with a memorable spa experience.'
        }
      ];
      break;

    default:
      sections = [
        {
          type: 'text',
          content: `Dear ${userName},<br><br>Your ${transactionType.replace('_', ' ')} has been confirmed!`
        },
        {
          type: 'details',
          title: 'Transaction Details',
          items: [
            { label: 'Reference', value: reference },
            { label: 'Service Type', value: transactionType.replace('_', ' ') },
            { label: 'Total Amount', value: `₦${amountPaid.toLocaleString()}` },
            { label: 'Payment Date', value: new Date(paidAt).toLocaleDateString() }
          ]
        }
      ];
  }

  // Generate QR code buffer for attachment
  const qrCodeBuffer = await generateQRCodeBuffer(qrData);

  // Prepare attachments array
  const attachments = [];
  if (qrCodeBuffer) {
    attachments.push({
      filename: 'qr-code.png',
      content: qrCodeBuffer,
      cid: 'qr-code', // Content-ID for embedding in HTML
      contentType: 'image/png'
    });
  }

  // Generate HTML email
  const htmlContent = generateHTMLEmailTemplate({
    title: `${config.emailSubject.success} - ${reference}`,
    headerColor: '#1a365d',
    sections: sections,
    hasQRCode: qrCodeBuffer !== null,
    footer: `For support, contact us at ${SUPPORT_EMAIL} or call ${SUPPORT_PHONE}`
  });

  // Also generate plain text version for fallback
  const plainText = generateSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt).body;

  return { subject, body: plainText, html: htmlContent, attachments };
}

// Generate notification data
function generateNotificationData(transactionType, details, reference, amount, isSuccess = false) {
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
        serviceId: reference,
        pickupLocation: details.pickupLocation,
        deliveryLocation: details.deliveryLocation,
        serviceType: details.serviceType,
        ...(isSuccess && { paymentDate: new Date().toISOString() })
      };

    default:
      return {
        ...baseData,
        serviceId: reference,
        ...(isSuccess && { paymentDate: new Date().toISOString() })
      };
  }
}

// Update monthly booking stats for revenue and bookings chart
async function updateMonthlyBookingStats(bookingAmount, executionId = 'manual') {
  try {
    console.log(`[${executionId}] Starting monthly booking stats update with amount: ₦${bookingAmount}`);

    // Get current date information
    const now = new Date();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    const currentMonth = monthNames[now.getMonth()];
    const currentYear = now.getFullYear();
    const monthIndex = now.getMonth();

    // Create document ID in YYYY-MM format for consistent ordering
    const docId = `${currentYear}-${monthIndex.toString().padStart(2, '0')}`;

    console.log(`[${executionId}] Updating monthly stats for document: ${docId} (${currentMonth} ${currentYear})`);

    // Prepare month data structure
    const monthData = {
      month: currentMonth,
      monthIndex: monthIndex,
      revenue: admin.firestore.FieldValue.increment(bookingAmount),
      bookings: admin.firestore.FieldValue.increment(1),
      date: `${currentMonth} ${currentYear}`,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      year: currentYear // Add year field for easier querying
    };

    // Update or create monthly document
    const monthlyStatsRef = db.collection('total_bookings').doc(docId);
    await monthlyStatsRef.set(monthData, { merge: true });

    console.log(`[${executionId}] Successfully updated monthly stats: +1 booking, +₦${bookingAmount} revenue for ${currentMonth} ${currentYear}`);

  } catch (error) {
    console.error(`[${executionId}] Failed to update monthly booking stats:`, error);
    console.error(`[${executionId}] Monthly stats error details:`, {
      bookingAmount: bookingAmount,
      error: error.message,
      stack: error.stack
    });
    // Don't throw error to avoid disrupting the main booking flow
  }
}

// Update booking stats when a booking payment is successful
async function updateBookingStats(reference, executionId = 'manual') {
  try {
    console.log(`[${executionId}] Starting booking stats update for: ${reference}`);

    // Get booking details to extract room types, user ID, and amount
    const bookingDoc = await db.collection('bookings').doc(reference).get();
    if (!bookingDoc.exists) {
      console.error(`[${executionId}] Booking document not found for stats update: ${reference}`);
      return;
    }

    const bookingData = bookingDoc.data();
    const { bookingDetails, userId, amount } = bookingData;
    const { selectedRooms } = bookingDetails;

    if (!selectedRooms || !Array.isArray(selectedRooms)) {
      console.error(`[${executionId}] No selected rooms found in booking: ${reference}`);
      return;
    }

    // Log the structure of selected rooms for debugging
    console.log(`[${executionId}] Selected rooms structure:`, JSON.stringify(selectedRooms.slice(0, 1), null, 2));

    // Extract room types - the Room model uses 'category' field
    const roomTypes = selectedRooms.map(room => {
      const type = room.category || room.type || room.roomType || room.roomCategory;
      if (!type) {
        console.warn(`[${executionId}] No room type found for room:`, JSON.stringify(room, null, 2));
      }
      return type;
    }).filter(type => type);

    const uniqueRoomTypes = [...new Set(roomTypes)]; // Remove duplicates

    // Convert amount to number if it's a string
    const bookingAmount = typeof amount === 'string' ? parseFloat(amount) : (amount || 0);

    console.log(`[${executionId}] Extracted room types: ${roomTypes.join(', ')}`);
    console.log(`[${executionId}] Unique room types: ${uniqueRoomTypes.join(', ')}`);
    console.log(`[${executionId}] Updating stats for room types: ${uniqueRoomTypes.join(', ')}, user: ${userId}, amount: ₦${bookingAmount}`);

    // Update total bookings in rooms_and_users_stat/stats
    const statsRef = db.collection('rooms_and_users_stat').doc('stats');
    await statsRef.set({
      totalBookings: admin.firestore.FieldValue.increment(1),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log(`[${executionId}] Successfully incremented totalBookings count`);

    // Update room type specific counts in room_bookings_stat/{roomType}
    const batch = db.batch();

    for (const roomType of uniqueRoomTypes) {
      // Normalize room type to lowercase for consistent document IDs
      const normalizedRoomType = roomType.toLowerCase().replace(/\s+/g, '_');
      const roomTypeRef = db.collection('room_bookings_stat').doc(normalizedRoomType);

      batch.set(roomTypeRef, {
        count: admin.firestore.FieldValue.increment(1),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        roomType: normalizedRoomType,
        originalRoomType: roomType, // Keep original for reference
      }, { merge: true });

      console.log(`[${executionId}] Queued increment for room type: ${roomType} (doc: ${normalizedRoomType})`);
    }

    // Commit all room type updates
    if (uniqueRoomTypes.length > 0) {
      await batch.commit();
      console.log(`[${executionId}] Successfully updated room type stats for: ${uniqueRoomTypes.join(', ')}`);
    } else {
      console.warn(`[${executionId}] No room types found to update stats for booking: ${reference}`);
    }

    // Update user-specific booking stats
    if (userId) {
      console.log(`[${executionId}] Updating user ${userId} booking stats with amount: ₦${bookingAmount}`);

      const userRef = db.collection('users').doc(userId);

      // Always update totalBookings, but only update totalAmountSpent if amount > 0
      const updateData = {
        totalBookings: admin.firestore.FieldValue.increment(1),
        lastBookingDate: admin.firestore.FieldValue.serverTimestamp(),
        statsUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (bookingAmount > 0) {
        updateData.totalAmountSpent = admin.firestore.FieldValue.increment(bookingAmount);
      } else {
        // Initialize totalAmountSpent if not updating it, to ensure field exists
        updateData.totalAmountSpent = admin.firestore.FieldValue.increment(0);
      }

      await userRef.set(updateData, { merge: true });

      console.log(`[${executionId}] Successfully updated user ${userId} stats: +1 booking, +₦${bookingAmount}`);
    } else {
      console.warn(`[${executionId}] Skipping user stats update - no userId provided`);
    }

    // Update monthly revenue and booking stats for dashboard analytics
    console.log(`[${executionId}] Updating monthly revenue and booking stats...`);
    await updateMonthlyBookingStats(bookingAmount, executionId);

    console.log(`[${executionId}] All booking stats updates completed for: ${reference}`);

  } catch (error) {
    console.error(`[${executionId}] Failed to update booking stats for ${reference}:`, error);
    console.error(`[${executionId}] Stats update error details:`, {
      reference: reference,
      error: error.message,
      stack: error.stack
    });
    // Don't throw error to avoid disrupting the main booking flow
  }
}


// ========================================================================
// Food Quantity Deduction Function
// ========================================================================
async function deductFoodQuantities(orderReference, executionId = 'webhook') {
  console.log(`[${executionId}] ========== FOOD QUANTITY DEDUCTION STARTED ==========`);
  console.log(`[${executionId}] Order Reference: ${orderReference}`);
  console.log(`[${executionId}] Execution ID: ${executionId}`);
  console.log(`[${executionId}] Timestamp: ${new Date().toISOString()}`);

  try {
    // Get the order details from service_orders collection
    console.log(`[${executionId}] Fetching order document from service_orders collection...`);
    const orderDoc = await db.collection('service_orders').doc(orderReference).get();

    if (!orderDoc.exists) {
      console.error(`[${executionId}] ❌ Order document not found: ${orderReference}`);
      console.error(`[${executionId}] Make sure the order was created properly in service_orders collection`);
      return;
    }

    const orderData = orderDoc.data();
    console.log(`[${executionId}] ✅ Order document found successfully`);
    console.log(`[${executionId}] Order serviceType: "${orderData.serviceType}"`);
    console.log(`[${executionId}] Order status: "${orderData.status}"`);
    console.log(`[${executionId}] Order has 'items' field: ${!!orderData.items}`);
    console.log(`[${executionId}] Order has 'service_items' field: ${!!orderData.service_items}`);
    console.log(`[${executionId}] Order customerId: ${orderData.customerId}`);
    console.log(`[${executionId}] Order customerName: ${orderData.customerName}`);

    // Only process food delivery orders
    if (orderData.serviceType !== 'food_delivery') {
      console.warn(`[${executionId}] ⚠️ Skipping quantity deduction - not a food order`);
      console.warn(`[${executionId}] Expected: "food_delivery", Got: "${orderData.serviceType}"`);
      return;
    }

    const orderedItems = orderData.items || orderData.service_items || [];
    console.log(`[${executionId}] Items found: ${orderedItems.length}`);

    if (!orderedItems || orderedItems.length === 0) {
      console.error(`[${executionId}] ❌ No items found in order!`);
      console.error(`[${executionId}] Order data keys:`, Object.keys(orderData));
      console.error(`[${executionId}] Items field value:`, orderData.items);
      console.error(`[${executionId}] Service_items field value:`, orderData.service_items);
      return;
    }

    console.log(`[${executionId}] 📋 Processing ${orderedItems.length} items for quantity deduction`);

    // Log each item structure
    orderedItems.forEach((item, index) => {
      console.log(`[${executionId}] Item ${index + 1}:`, JSON.stringify(item, null, 2));
    });

    // Process each item for quantity deduction
    console.log(`[${executionId}] 🔄 Starting item processing loop...`);
    const batch = db.batch();
    let processedItems = 0;
    let skippedItems = 0;

    for (let i = 0; i < orderedItems.length; i++) {
      const item = orderedItems[i];
      console.log(`[${executionId}] 🔍 Processing item ${i + 1}/${orderedItems.length}`);

      const { itemId, quantity } = item;
      console.log(`[${executionId}] Item details - itemId: "${itemId}", quantity: ${quantity} (type: ${typeof quantity})`);

      if (!itemId) {
        console.error(`[${executionId}] ❌ Missing itemId for item ${i + 1}:`, JSON.stringify(item, null, 2));
        skippedItems++;
        continue;
      }

      if (!quantity || quantity <= 0) {
        console.error(`[${executionId}] ❌ Invalid quantity for item ${i + 1} (${itemId}): ${quantity}`);
        skippedItems++;
        continue;
      }

      try {
        console.log(`[${executionId}] 📄 Fetching food item from database: ${itemId}`);
        const foodItemRef = db.collection('food_items').doc(itemId);
        const foodItemDoc = await foodItemRef.get();

        if (!foodItemDoc.exists) {
          console.error(`[${executionId}] ❌ Food item not found in database: ${itemId}`);
          console.error(`[${executionId}] Make sure the food item exists in the food_items collection`);
          skippedItems++;
          continue;
        }

        const foodItemData = foodItemDoc.data();
        console.log(`[${executionId}] 📊 Food item "${foodItemData.name || itemId}" data:`);
        console.log(`[${executionId}] - Available fields: [${Object.keys(foodItemData).join(', ')}]`);
        console.log(`[${executionId}] - Current quantity: ${foodItemData.quantity} (type: ${typeof foodItemData.quantity})`);
        console.log(`[${executionId}] - Is available: ${foodItemData.isAvailable}`);

        const currentQuantity = foodItemData.quantity;

        // Check if item has quantity tracking (null = no tracking, skip deduction)
        if (currentQuantity === null || currentQuantity === undefined) {
          console.log(`[${executionId}] ⏭️ Skipping quantity deduction for "${foodItemData.name || itemId}": No quantity tracking enabled`);
          console.log(`[${executionId}] - Item quantity field is null/undefined (no tracking)`);
          console.log(`[${executionId}] - This item does not require stock management`);
          skippedItems++;
          continue;
        }

        // Check if there's a valid quantity field
        if (typeof currentQuantity !== 'number') {
          console.error(`[${executionId}] ❌ Quantity field is not a number for ${itemId}:`);
          console.error(`[${executionId}] - Current quantity: ${currentQuantity} (type: ${typeof currentQuantity})`);
          skippedItems++;
          continue;
        }

        if (currentQuantity <= 0) {
          console.warn(`[${executionId}] ⚠️ Item ${itemId} already out of stock (quantity: ${currentQuantity})`);
          skippedItems++;
          continue;
        }

        // Calculate new quantity (ensure it doesn't go below 0)
        const orderedQuantity = parseInt(quantity);
        const newQuantity = Math.max(0, currentQuantity - orderedQuantity);

        console.log(`[${executionId}] 📉 Deducting quantity for "${foodItemData.name || itemId}":`);
        console.log(`[${executionId}] - Ordered: ${orderedQuantity}`);
        console.log(`[${executionId}] - Current stock: ${currentQuantity}`);
        console.log(`[${executionId}] - New stock: ${newQuantity}`);

        // Add to batch update
        const updateData = {
          quantity: newQuantity,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };

        // If quantity reaches 0, mark as unavailable
        if (newQuantity === 0) {
          updateData.isAvailable = false;
          updateData.outOfStock = true;
          console.log(`[${executionId}] 🚫 Item will be marked as out of stock`);
        }

        batch.update(foodItemRef, updateData);
        processedItems++;
        console.log(`[${executionId}] ✅ Item ${i + 1} queued for update`);

      } catch (itemError) {
        console.error(`[${executionId}] ❌ Error processing item ${itemId}:`, itemError.message);
        console.error(`[${executionId}] Error stack:`, itemError.stack);
        skippedItems++;
      }
    }

    console.log(`[${executionId}] 📈 Processing summary:`);
    console.log(`[${executionId}] - Items processed: ${processedItems}`);
    console.log(`[${executionId}] - Items skipped: ${skippedItems}`);
    console.log(`[${executionId}] - Total items: ${orderedItems.length}`);

    // Commit all quantity updates
    if (processedItems > 0) {
      console.log(`[${executionId}] 💾 Committing ${processedItems} quantity updates...`);
      await batch.commit();
      console.log(`[${executionId}] ✅ Successfully updated quantities for ${processedItems} food items`);
    } else {
      console.warn(`[${executionId}] ⚠️ No items processed for quantity deduction - check the logs above`);
    }

  } catch (error) {
    console.error(`[${executionId}] ❌ CRITICAL ERROR in deductFoodQuantities:`);
    console.error(`[${executionId}] - Order Reference: ${orderReference}`);
    console.error(`[${executionId}] - Error Message: ${error.message}`);
    console.error(`[${executionId}] - Error Stack:`, error.stack);
    console.error(`[${executionId}] - Error Details:`, {
      orderReference: orderReference,
      executionId: executionId,
      timestamp: new Date().toISOString(),
      error: error.message
    });
    // Don't throw error to avoid disrupting the main payment flow
  } finally {
    console.log(`[${executionId}] ========== FOOD QUANTITY DEDUCTION ENDED ==========`);
  }
}

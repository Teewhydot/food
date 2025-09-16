const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// Configuration
const config = {
  paystack: {
    secretKey: process.env.PAYSTACK_SECRET_KEY
  },
  email: {
    host: 'mail.cyrextech.org',
    port: 587,
    secure: false,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD
    },
    from: {
      name: 'FMH Hotel',
      email: 'noreply@cyrextech.org'
    }
  },
  fcm: {
    // Firebase Admin SDK is auto-initialized with default credentials
    databaseURL: `https://${process.env.GCLOUD_PROJECT}.firebaseio.com`
  }
};

// Initialize services
const TransactionRepository = require('./core/repositories/transaction.repository');
const PaystackService = require('./infrastructure/external/paystack.service');
const NotificationService = require('./infrastructure/notifications/notification.service');
const TransactionService = require('./core/services/transaction.service');
const TransactionController = require('./interfaces/http/transaction.controller');
const TransactionScheduler = require('./interfaces/schedulers/transaction.scheduler');

// Create instances
const transactionRepository = new TransactionRepository(db);
const paystackService = new PaystackService(config.paystack.secretKey);
const notificationService = new NotificationService({
  email: config.email,
  fcm: config.fcm
});

const transactionService = new TransactionService({
  transactionRepository,
  paystackService,
  notificationService
});

// Initialize controllers
const transactionController = new TransactionController(transactionService);
const transactionScheduler = new TransactionScheduler(transactionService);

// Export HTTP endpoints
exports.createTransaction = transactionController.createTransaction();
exports.paystackWebhook = transactionController.handleWebhook();

// Export scheduled functions
exports.verifyPendingTransactions = transactionScheduler.verifyPendingTransactions();
exports.cleanupOldTransactions = transactionScheduler.cleanupOldTransactions();

// Export services for testing
exports._test = {
  transactionService,
  paystackService,
  notificationService,
  transactionRepository
};

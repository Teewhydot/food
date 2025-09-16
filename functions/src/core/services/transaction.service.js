const Transaction = require('../models/transaction.model');

class TransactionService {
  constructor({ transactionRepository, paystackService, notificationService }) {
    this.transactionRepository = transactionRepository;
    this.paystackService = paystackService;
    this.notificationService = notificationService;
    this.TRANSACTION_TYPES = {
      booking: {
        collection: 'bookings',
        notificationTitle: {
          creation: 'Booking Created',
          success: 'Booking Confirmed!',
          failure: 'Booking Failed'
        }
      },
      food_order: {
        collection: 'service_orders',
        notificationTitle: {
          creation: 'Food Order Placed',
          success: 'Order Confirmed!',
          failure: 'Order Failed'
        }
      },
      // Add other transaction types as needed
    };
  }

  async createTransaction(transactionData) {
    const {
      amount,
      userId,
      email,
      bookingDetails = {},
      userName,
      transactionType = 'booking'
    } = transactionData;

    // Generate a reference with appropriate prefix
    const reference = this.generateReference(transactionType);
    
    // Initialize Paystack payment
    const paymentData = await this.paystackService.initializeTransaction({
      email,
      amount,
      reference,
      metadata: {
        userId,
        bookingDetails,
        userName
      }
    });

    // Create transaction record
    const transaction = new Transaction({
      reference,
      userId,
      userName,
      email,
      amount,
      status: 'pending',
      transactionType,
      bookingDetails,
      metadata: {
        authorizationUrl: paymentData.authorization_url
      }
    });

    // Save to database
    await this.transactionRepository.create(transaction);

    // Add to pending transactions
    await this.transactionRepository.addToPending(reference, {
      userId,
      transactionType,
      serviceType: bookingDetails.serviceType
    });

    // Send creation notifications
    await this.sendCreationNotifications(transaction);

    return {
      authorization_url: paymentData.authorization_url,
      reference: reference
    };
  }

  async handleWebhookEvent(event) {
    const { event: eventType, data } = event;
    
    if (eventType === 'charge.success' && data.status === 'success') {
      const { reference, amount, metadata, status, paid_at } = data;
      const { userId, bookingDetails = {}, userName } = metadata;
      
      // Find the transaction
      const transaction = await this.transactionRepository.findByReference(reference);
      if (!transaction) {
        throw new Error(`Transaction not found: ${reference}`);
      }

      // Update transaction status
      transaction.status = status;
      transaction.updatedAt = new Date().toISOString();
      transaction.paidAt = paid_at;
      
      // Update in database
      await this.transactionRepository.updateStatus(reference, status);
      
      // Remove from pending
      await this.transactionRepository.removeFromPending(reference);
      
      // Process the successful payment
      await this.processSuccessfulPayment(transaction);
      
      return { success: true };
    }
    
    return { processed: false };
  }

  async processPendingTransactions() {
    const pendingTransactions = await this.transactionRepository.findPendingTransactions(50);
    
    for (const pendingTx of pendingTransactions) {
      try {
        const { reference } = pendingTx;
        const transaction = await this.transactionRepository.findByReference(reference);
        
        if (!transaction) {
          await this.transactionRepository.removeFromPending(reference);
          continue;
        }

        // Verify with Paystack
        const verification = await this.paystackService.verifyTransaction(reference);
        
        if (verification.data.status === 'success') {
          // Process successful payment
          transaction.status = 'success';
          transaction.paidAt = verification.data.paid_at;
          await this.transactionRepository.updateStatus(reference, 'success');
          await this.processSuccessfulPayment(transaction);
        } else if (verification.data.status === 'failed') {
          // Handle failed payment
          transaction.status = 'failed';
          await this.transactionRepository.updateStatus(reference, 'failed');
          await this.sendFailureNotifications(transaction);
        }
        
        // Update check count
        await this.transactionRepository.updatePendingCheckCount(reference);
        
      } catch (error) {
        console.error(`Error processing pending transaction ${pendingTx.reference}:`, error);
      }
    }
  }

  // Helper methods
  generateReference(transactionType) {
    const prefixMap = {
      booking: 'B-',
      food_order: 'F-',
      gym_session: 'G-',
      pool_session: 'P-',
      laundry_service: 'L-',
      concierge_request: 'C-',
    };
    
    const prefix = prefixMap[transactionType] || '';
    const randomString = Math.random().toString(36).substring(2, 10).toUpperCase();
    return `${prefix}${randomString}${Date.now().toString().slice(-4)}`;
  }

  async sendCreationNotifications(transaction) {
    const { transactionType } = transaction;
    const config = this.TRANSACTION_TYPES[transactionType];
    
    if (!config) return;

    // Send email
    try {
      const emailContent = this.generateEmailContent('creation', transaction);
      if (emailContent) {
        await this.notificationService.sendEmail({
          to: transaction.email,
          ...emailContent
        });
      }
    } catch (error) {
      console.error('Failed to send creation email:', error);
    }

    // Send push notification
    try {
      const notificationTitle = config.notificationTitle.creation;
      const notificationBody = `Your ${transactionType.replace('_', ' ')} ${transaction.reference} has been created.`;
      
      await this.notificationService.sendPushNotification({
        userId: transaction.userId,
        title: notificationTitle,
        body: notificationBody,
        data: {
          type: transactionType,
          reference: transaction.reference,
          status: 'pending'
        }
      });
    } catch (error) {
      console.error('Failed to send creation notification:', error);
    }
  }

  async processSuccessfulPayment(transaction) {
    const { transactionType } = transaction;
    const config = this.TRANSACTION_TYPES[transactionType];
    
    if (!config) return;

    // Update the appropriate collection
    const updateData = {
      status: 'success',
      time_created: transaction.paidAt,
      amount: transaction.amount,
      updatedAt: new Date().toISOString()
    };

    // Save to the appropriate collection
    await admin.firestore()
      .collection(config.collection)
      .doc(transaction.reference)
      .update(updateData);

    // Send success notifications
    await this.sendSuccessNotifications(transaction);

    // Additional processing based on transaction type
    if (transactionType === 'booking') {
      await this.processBookingPayment(transaction);
    } else if (transactionType === 'food_order') {
      await this.processFoodOrderPayment(transaction);
    }
  }

  async sendSuccessNotifications(transaction) {
    const { transactionType } = transaction;
    const config = this.TRANSACTION_TYPES[transactionType];
    
    if (!config) return;

    // Send success email
    try {
      const emailContent = this.generateEmailContent('success', transaction);
      if (emailContent) {
        await this.notificationService.sendEmail({
          to: transaction.email,
          ...emailContent
        });
      }
    } catch (error) {
      console.error('Failed to send success email:', error);
    }

    // Send success push notification
    try {
      const notificationTitle = config.notificationTitle.success;
      let notificationBody = `Your payment for ${transactionType.replace('_', ' ')} ${transaction.reference} has been confirmed.`;
      
      // Customize notification message based on transaction type
      if (transactionType === 'booking' && transaction.bookingDetails.checkInDate) {
        notificationBody = `Your booking ${transaction.reference} is confirmed! See you on ${new Date(transaction.bookingDetails.checkInDate).toLocaleDateString()}!`;
      }
      
      await this.notificationService.sendPushNotification({
        userId: transaction.userId,
        title: notificationTitle,
        body: notificationBody,
        data: {
          type: transactionType,
          reference: transaction.reference,
          status: 'success',
          paymentDate: transaction.paidAt
        }
      });
    } catch (error) {
      console.error('Failed to send success notification:', error);
    }
  }

  // Additional processing methods
  async processBookingPayment(transaction) {
    // Update room availability
    await this.updateRoomAvailability(transaction);
    // Update booking statistics
    await this.updateBookingStats(transaction);
  }

  async processFoodOrderPayment(transaction) {
    // Deduct food quantities
    await this.deductFoodQuantities(transaction);
  }

  // Placeholder methods - implement these based on your requirements
  async updateRoomAvailability(transaction) {
    // Implement room availability update logic
  }

  async updateBookingStats(transaction) {
    // Implement booking statistics update logic
  }

  async deductFoodQuantities(transaction) {
    // Implement food quantity deduction logic
  }

  generateEmailContent(type, transaction) {
    // Implement email content generation based on type and transaction
    return {};
  }
}

module.exports = TransactionService;

// ========================================================================
// Payment Service - Paystack Integration and Transaction Management
// ========================================================================

const axios = require('axios');
const crypto = require('crypto');
const admin = require('firebase-admin');
const { ENVIRONMENT, PAYSTACK, TRANSACTION_PREFIX_MAP } = require('../utils/constants');
const { logger } = require('../utils/logger');
const { ReferenceUtils } = require('../utils/validation');

class PaymentService {
  constructor() {
    this.apiKey = ENVIRONMENT.PAYSTACK_SECRET_KEY;
    this.baseUrl = PAYSTACK.API_BASE_URL;
  }

  // ========================================================================
  // Transaction Initialization
  // ========================================================================

  async initializeTransaction(email, amount, metadata, executionId = 'payment-init') {
    try {
      logger.apiCall('POST', `${this.baseUrl}${PAYSTACK.ENDPOINTS.INITIALIZE_TRANSACTION}`, null, executionId);
      logger.payment('INITIALIZE', 'new-transaction', amount, executionId);

      const response = await axios.post(
        `${this.baseUrl}${PAYSTACK.ENDPOINTS.INITIALIZE_TRANSACTION}`,
        {
          email: email,
          amount: amount * 100, // Convert to kobo
          metadata: metadata
        },
        {
          headers: {
            Authorization: `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000 // 30 second timeout
        }
      );

      if (response.status === 200 && response.data.status) {
        const paystackReference = response.data.data.reference;
        const authorizationUrl = response.data.data.authorization_url;
        const accessCode = response.data.data.access_code;

        logger.success(`Transaction initialized: ${paystackReference}`, executionId, {
          reference: paystackReference,
          amount: amount,
          email: email
        });

        return {
          success: true,
          reference: paystackReference,
          authorizationUrl: authorizationUrl,
          accessCode: accessCode,
          amount: amount
        };
      } else {
        throw new Error(`Paystack API error: ${response.data.message || 'Unknown error'}`);
      }
    } catch (error) {
      logger.error('Failed to initialize transaction', executionId, error, {
        email: email,
        amount: amount
      });

      return {
        success: false,
        error: error.message,
        details: error.response?.data || null
      };
    }
  }

  // ========================================================================
  // Transaction Verification
  // ========================================================================

  async verifyTransaction(reference, executionId = 'payment-verify') {
    const verificationStartTime = Date.now();

    try {
      logger.payment('VERIFY', reference, null, executionId);
      logger.apiCall('GET', `${this.baseUrl}${PAYSTACK.ENDPOINTS.VERIFY_TRANSACTION}/${reference}`, null, executionId);

      const response = await axios.get(
        `${this.baseUrl}${PAYSTACK.ENDPOINTS.VERIFY_TRANSACTION}/${reference}`,
        {
          headers: {
            Authorization: `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000
        }
      );

      const verificationEndTime = Date.now();
      const verificationDuration = verificationEndTime - verificationStartTime;

      logger.info(`Paystack API Response: ${response.status} - ${response.data.status}`, executionId);
      logger.info(`Verification took ${verificationDuration}ms`, executionId);

      if (response.status === 200 && response.data.status) {
        const transactionData = response.data.data;
        const verificationResult = this.processVerificationResponse(transactionData, executionId);

        logger.success(`Transaction verified: ${reference}`, executionId, verificationResult);
        return {
          success: true,
          ...verificationResult
        };
      } else {
        throw new Error(`Verification failed: ${response.data.message || 'Unknown error'}`);
      }
    } catch (error) {
      const verificationEndTime = Date.now();
      const verificationDuration = verificationEndTime - verificationStartTime;

      logger.error(`Transaction verification failed after ${verificationDuration}ms`, executionId, error, {
        reference: reference
      });

      return {
        success: false,
        error: error.message,
        details: error.response?.data || null
      };
    }
  }

  processVerificationResponse(transactionData, executionId = 'process-verification') {
    const {
      reference,
      status,
      amount,
      paid_at,
      created_at,
      channel,
      currency,
      gateway_response,
      metadata
    } = transactionData;

    const processedData = {
      reference: reference,
      status: status,
      amount: amount / 100, // Convert from kobo
      amountInKobo: amount,
      paidAt: paid_at || created_at,
      channel: channel,
      currency: currency,
      gatewayResponse: gateway_response,
      metadata: metadata || {},
      timestamp: new Date().toISOString()
    };

    logger.info('Transaction verification details', executionId, {
      reference: processedData.reference,
      status: processedData.status,
      amount: `${processedData.currency} ${processedData.amount}`,
      channel: processedData.channel,
      paidAt: processedData.paidAt
    });

    return processedData;
  }

  // ========================================================================
  // Webhook Verification
  // ========================================================================

  verifyWebhookSignature(requestBody, signature, executionId = 'webhook-verify') {
    try {
      logger.info('Verifying webhook signature', executionId);

      if (!signature) {
        logger.warning('No signature provided in webhook', executionId);
        return false;
      }

      const hash = crypto
        .createHmac('sha512', this.apiKey)
        .update(JSON.stringify(requestBody))
        .digest('hex');

      const isValid = hash === signature;

      if (isValid) {
        logger.success('Webhook signature verified', executionId);
      } else {
        logger.warning('Invalid webhook signature', executionId, {
          expected: hash.substring(0, 20) + '...',
          received: signature.substring(0, 20) + '...'
        });
      }

      return isValid;
    } catch (error) {
      logger.error('Error verifying webhook signature', executionId, error);
      return false;
    }
  }

  processWebhookEvent(eventData, executionId = 'webhook-process') {
    try {
      const { event, data } = eventData;

      logger.info(`Processing webhook event: ${event}`, executionId, {
        event: event,
        status: data?.status,
        reference: data?.reference
      });

      if (!data) {
        throw new Error('No data found in webhook event');
      }

      const processedEvent = {
        eventType: event,
        reference: data.reference,
        status: data.status,
        amount: data.amount ? data.amount / 100 : 0,
        paidAt: data.paid_at,
        metadata: data.metadata || {},
        channel: data.channel,
        currency: data.currency,
        gatewayResponse: data.gateway_response
      };

      // Extract user information from metadata
      if (processedEvent.metadata) {
        processedEvent.userId = processedEvent.metadata.userId;
        processedEvent.userName = processedEvent.metadata.userName;
        processedEvent.bookingDetails = processedEvent.metadata.bookingDetails || {};
      }

      logger.success(`Webhook event processed: ${event}`, executionId, {
        reference: processedEvent.reference,
        status: processedEvent.status,
        amount: processedEvent.amount
      });

      return {
        success: true,
        processedEvent: processedEvent
      };
    } catch (error) {
      logger.error('Failed to process webhook event', executionId, error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  // ========================================================================
  // Reference Management
  // ========================================================================

  generatePrefixedReference(transactionType, paystackReference) {
    return ReferenceUtils.generatePrefixedReference(transactionType, paystackReference);
  }

  extractOriginalReference(prefixedReference) {
    return ReferenceUtils.removePrefixFromReference(prefixedReference);
  }

  getTransactionTypeFromReference(reference) {
    return ReferenceUtils.getTransactionTypeFromReference(reference);
  }

  // ========================================================================
  // Payment Status Management
  // ========================================================================

  isSuccessfulPayment(status) {
    return status === 'success';
  }

  isFailedPayment(status) {
    return status === 'failed';
  }

  isPendingPayment(status) {
    return status === 'pending';
  }

  isAbandonedPayment(status) {
    return status === 'abandoned';
  }

  getPaymentStatusDescription(status) {
    const statusMap = {
      'success': 'Payment completed successfully',
      'failed': 'Payment failed',
      'pending': 'Payment is pending',
      'abandoned': 'Payment was abandoned',
      'ongoing': 'Payment is in progress',
      'reversed': 'Payment has been reversed'
    };

    return statusMap[status] || `Unknown status: ${status}`;
  }

  // ========================================================================
  // Batch Payment Operations
  // ========================================================================

  async verifyMultipleTransactions(references, executionId = 'batch-verify') {
    logger.processing(`Verifying ${references.length} transactions`, executionId);

    const results = [];
    for (const reference of references) {
      try {
        const result = await this.verifyTransaction(reference, `${executionId}-${reference}`);
        results.push(result);
      } catch (error) {
        logger.error(`Failed to verify transaction: ${reference}`, executionId, error);
        results.push({
          success: false,
          reference: reference,
          error: error.message
        });
      }
    }

    const successCount = results.filter(r => r.success).length;
    const failureCount = results.length - successCount;

    logger.info(`Batch verification completed: ${successCount} successful, ${failureCount} failed`, executionId);

    return {
      total: results.length,
      successful: successCount,
      failed: failureCount,
      results: results
    };
  }

  // ========================================================================
  // Error Handling and Retry Logic
  // ========================================================================

  async verifyTransactionWithRetry(reference, maxRetries = 3, executionId = 'payment-verify-retry') {
    let lastError;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        logger.info(`Verification attempt ${attempt}/${maxRetries} for ${reference}`, executionId);

        const result = await this.verifyTransaction(reference, `${executionId}-attempt-${attempt}`);

        if (result.success) {
          logger.success(`Transaction verified on attempt ${attempt}`, executionId);
          return result;
        } else {
          lastError = new Error(result.error || 'Verification failed');
        }
      } catch (error) {
        lastError = error;
        logger.warning(`Verification attempt ${attempt} failed: ${error.message}`, executionId);

        if (attempt < maxRetries) {
          const delay = Math.pow(2, attempt) * 1000; // Exponential backoff
          logger.info(`Retrying in ${delay}ms...`, executionId);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    logger.error(`All verification attempts failed for ${reference}`, executionId, lastError);
    throw lastError;
  }

  // ========================================================================
  // Utility Methods
  // ========================================================================

  formatAmount(amount, currency = 'NGN') {
    return `${currency} ${amount.toLocaleString()}`;
  }

  convertToKobo(nairaAmount) {
    return Math.round(nairaAmount * 100);
  }

  convertFromKobo(koboAmount) {
    return koboAmount / 100;
  }

  async testConnection(executionId = 'payment-test') {
    try {
      logger.info('Testing Paystack connection', executionId);

      // Test with a simple API call (get banks)
      const response = await axios.get(
        `${this.baseUrl}/bank`,
        {
          headers: {
            Authorization: `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 10000
        }
      );

      if (response.status === 200) {
        logger.success('Paystack connection test successful', executionId);
        return true;
      } else {
        throw new Error(`Unexpected response: ${response.status}`);
      }
    } catch (error) {
      logger.error('Paystack connection test failed', executionId, error);
      return false;
    }
  }
}

// Create default payment service instance
const paymentService = new PaymentService();

module.exports = {
  PaymentService,
  paymentService
};
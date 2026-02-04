// ========================================================================
// Flutterwave Service - Flutterwave v3 API Integration and Transaction Management
// ========================================================================

const axios = require('axios');
const crypto = require('crypto');
const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');
const { ENVIRONMENT, FLUTTERWAVE, TRANSACTION_PREFIX_MAP } = require('../utils/constants');
const { logger } = require('../utils/logger');
const { ReferenceUtils } = require('../utils/validation');

class FlutterwaveService {
  constructor() {
    // v3 API configuration with Secret Key authentication
    this.baseUrl = FLUTTERWAVE.API_BASE_URL_V3;
    this.secretKey = ENVIRONMENT.FLUTTERWAVE_SECRET_KEY;

    // Log service initialization details
    console.log('=== Flutterwave Service Initialization (v3) ===');
    console.log(`Base URL: ${this.baseUrl}`);
    console.log(`Secret Key: ${this.secretKey ? this.secretKey.substring(0, 15) + '...' : 'NOT YET LOADED (will load at runtime)'}`);
    console.log(`Available Endpoints:`, Object.keys(FLUTTERWAVE.ENDPOINTS));
    console.log('============================================');

    // Validate environment (only if secret key is present)
    if (this.secretKey) {
      const isTestKey = this.secretKey.startsWith('FLWSECK_TEST-');
      const isLiveKey = this.secretKey.startsWith('FLWSECK-') && !isTestKey;
      this.isProduction = isLiveKey;
      console.log(`Environment: ${this.isProduction ? 'Production (LIVE)' : 'Sandbox (TEST)'}`);
    } else {
      // Secret key will be loaded from environment at runtime
      console.log('Warning: Secret Key not found during initialization. Will be loaded at runtime from .env.yaml');
      this.isProduction = false; // Default to sandbox
    }
  }


  // ========================================================================
  // Payment Initialization using v3 Charges Endpoint
  // ========================================================================

  async initializePayment(email, amount, metadata, executionId = 'flw-init') {
    try {
      // Validate secret key before making API call
      if (!this.secretKey) {
        throw new Error('Flutterwave v3 Secret Key (FLUTTERWAVE_SECRET_KEY) is not configured. Please add it to .env.yaml or Firebase Functions config.');
      }

      console.log(`[${executionId}] Flutterwave v3 Standard Payment Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Environment: ${this.isProduction ? 'Production' : 'Sandbox'}`);

      logger.payment('INITIALIZE', 'flutterwave-v3-standard', amount, executionId);

      // Generate unique transaction reference
      const txRef = `FLW${Date.now()}${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

      // Validate and prepare customer name fields
      const nameParts = (metadata.userName || 'Customer User').split(' ');
      const firstName = nameParts[0] || 'Customer';
      const lastName = nameParts[1] || 'User';

      // Clean phone number to digits only (7-10 chars)
      const rawPhone = (metadata.phoneNumber || '08012345678').replace(/[^\d]/g, '');
      const cleanPhone = rawPhone.replace(/^234/, '');
      let validPhone = cleanPhone;
      if (validPhone.length < 7) {
        validPhone = '08012345678';
      } else if (validPhone.length > 10) {
        validPhone = validPhone.substring(0, 10);
      }

      // Flutterwave v3 Standard Payment payload
      const payload = {
        tx_ref: txRef,
        amount: amount,
        currency: 'NGN',
        redirect_url: metadata.redirectUrl || 'https://example.com/success',
        customer: {
          email: email,
          name: `${firstName} ${lastName}`,
          phonenumber: validPhone
        },
        customizations: {
          title: 'Food Order Payment',
          description: `Payment for order ${metadata.orderId}`,
          logo: 'https://via.placeholder.com/150'
        },
        meta: {
          order_id: metadata.orderId,
          user_id: metadata.userId,
          source: 'food_app'
        }
      };

      console.log(`[${executionId}] Flutterwave v3 Standard payload:`, JSON.stringify(payload, null, 2));

      // Call Flutterwave v3 Standard Payment endpoint
      const response = await axios.post(`${this.baseUrl}/v3/payments`, payload, {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.secretKey}`
        },
        timeout: 60000
      });

      console.log(`[${executionId}] Response status: ${response.status}`);
      console.log(`[${executionId}] Response data:`, JSON.stringify(response.data, null, 2));

      if (response.data.status === 'success' && response.data.data && response.data.data.link) {
        const checkoutLink = response.data.data.link;

        logger.success(`Flutterwave v3 Standard payment created: ${txRef}`, executionId, {
          txRef: txRef,
          amount: amount,
          email: email,
          checkoutLink: checkoutLink
        });

        return {
          success: true,
          reference: txRef,
          authorizationUrl: checkoutLink,
          accessCode: null,
          amount: amount,
          authMode: 'standard',
          paymentData: response.data
        };
      } else {
        throw new Error(`Flutterwave v3 API error: ${response.data.message || 'Unknown error'}`);
      }
    } catch (error) {
      // Log the complete error details including response data
      console.log(`[${executionId}] Full error details:`, {
        message: error.message,
        code: error.code,
        status: error.response?.status,
        statusText: error.response?.statusText,
        responseData: error.response?.data,
        headers: error.response?.headers,
        isTimeout: error.code === 'ECONNABORTED' || error.message.includes('timeout')
      });

      // Specific handling for timeout errors
      if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
        logger.critical('Flutterwave v3 API request timeout - increase timeout or check network', executionId, error, {
          email: email,
          amount: amount,
          apiVersion: 'v3',
          timeoutDuration: '60000ms'
        });

        return {
          success: false,
          error: 'Request timeout - please try again',
          errorType: 'TIMEOUT',
          details: { message: 'The request to Flutterwave v3 API timed out after 60 seconds' }
        };
      }

      logger.error('Failed to initialize Flutterwave v3 charge', executionId, error, {
        email: email,
        amount: amount,
        apiVersion: 'v3',
        errorCode: error.code
      });

      return {
        success: false,
        error: error.message,
        errorType: 'API_ERROR',
        details: error.response?.data || null
      };
    }
  }

  // ========================================================================
  // Transaction Verification (v3)
  // ========================================================================

  async verifyTransaction(transactionId, executionId = 'flw-verify') {
    const verificationStartTime = Date.now();

    try {
      // Validate secret key before making API call
      if (!this.secretKey) {
        throw new Error('Flutterwave v3 Secret Key (FLUTTERWAVE_SECRET_KEY) is not configured. Please add it to .env.yaml or Firebase Functions config.');
      }

      logger.payment('VERIFY', transactionId, null, executionId);

      // v3 verification endpoint: /v3/transactions/{id}/verify
      const endpoint = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.VERIFY_TRANSACTION.replace(':id', transactionId)}`;

      // Detailed verification endpoint logging
      console.log(`[${executionId}] Flutterwave v3 Verification Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Verification URL: ${endpoint}`);

      logger.apiCall('GET', endpoint, null, executionId);

      // Prepare headers with Secret Key
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.secretKey}`
      };

      // Log the verification request
      console.log(`[${executionId}] Making HTTP GET request to: ${endpoint}`);

      const response = await axios.get(endpoint, {
        headers: headers,
        timeout: 60000,
        maxRedirects: 0,
        validateStatus: function (status) {
          return status < 500;
        }
      });

      console.log(`[${executionId}] Verification response status: ${response.status}`);

      const verificationEndTime = Date.now();
      const verificationDuration = verificationEndTime - verificationStartTime;

      logger.performance('VERIFICATION', verificationDuration, executionId, {
        transactionId: transactionId,
        apiVersion: 'v3'
      });

      if (response.status === 200) {
        const transactionData = response.data.data;

        const result = {
          success: true,
          status: transactionData.status,
          amount: parseFloat(transactionData.amount),
          currency: transactionData.currency,
          reference: transactionData.tx_ref || transactionData.reference,
          flutterwaveReference: transactionData.flw_ref || transactionData.id,
          paidAt: transactionData.created_at || transactionData.created_datetime,
          channel: transactionData.payment_type,
          customer: {
            email: transactionData.customer?.email,
            name: transactionData.customer?.name
          },
          meta: transactionData.meta || {}
        };

        logger.success(`Flutterwave v3 transaction verified: ${transactionId}`, executionId, {
          status: result.status,
          amount: result.amount,
          reference: result.reference,
          apiVersion: 'v3'
        });

        return result;
      } else {
        const errorMessage = response.data.message || 'Unknown error';
        throw new Error(`Flutterwave v3 verification failed: ${errorMessage}`);
      }
    } catch (error) {
      logger.error('Flutterwave v3 verification failed', executionId, error, {
        transactionId: transactionId,
        apiVersion: 'v3'
      });

      return {
        success: false,
        error: error.message,
        details: error.response?.data || null
      };
    }
  }

  // ========================================================================
  // Transaction Status Query
  // ========================================================================

  async getTransactionStatus(reference, executionId = 'flw-status') {
    try {
      logger.payment('STATUS_CHECK', reference, null, executionId);

      // For Flutterwave v3, we use the same verification endpoint to get status
      const verificationResult = await this.verifyTransaction(reference, executionId);

      if (verificationResult.success) {
        return {
          success: true,
          status: verificationResult.status,
          amount: verificationResult.amount,
          reference: verificationResult.reference,
          paidAt: verificationResult.paidAt,
          details: {
            currency: verificationResult.currency,
            channel: verificationResult.channel,
            customer: verificationResult.customer,
            meta: verificationResult.meta
          }
        };
      } else {
        return verificationResult;
      }
    } catch (error) {
      logger.error('Failed to get Flutterwave v3 transaction status', executionId, error, {
        reference: reference
      });

      return {
        success: false,
        error: error.message
      };
    }
  }

  // ========================================================================
  // Webhook Signature Verification
  // ========================================================================

  verifyWebhookSignature(rawBody, signature, executionId = 'flw-webhook-verify') {
    try {
      // Flutterwave uses HMAC SHA256 for webhook signature verification
      const secretHash = ENVIRONMENT.FLUTTERWAVE_SECRET_HASH;

      if (!secretHash) {
        logger.warning('No Flutterwave secret hash configured for webhook verification', executionId);
        return false;
      }

      // Generate hash using the raw body (string format)
      const hash = crypto
        .createHmac('sha256', secretHash)
        .update(rawBody)
        .digest('base64');

      const isValid = hash === signature;

      if (isValid) {
        logger.security('WEBHOOK_VERIFIED', 'Flutterwave v3 webhook signature valid', executionId, {
          signatureLength: signature?.length,
          hashLength: hash?.length
        });
      } else {
        logger.security('WEBHOOK_INVALID', 'Flutterwave v3 webhook signature invalid', executionId, {
          receivedSignature: signature?.substring(0, 10) + '...',
          computedSignature: hash?.substring(0, 10) + '...'
        });
      }

      return isValid;
    } catch (error) {
      logger.error('Webhook signature verification failed', executionId, error);
      return false;
    }
  }

  // ========================================================================
  // Webhook Event Processing (v3)
  // ========================================================================

  processWebhookEvent(event, executionId = 'flw-webhook-process') {
    try {
      // v3 uses 'event' field instead of 'event-type'
      const eventType = event.event;
      logger.webhook('PROCESS', eventType || 'unknown', executionId);

      const data = event.data;

      if (!eventType || !data) {
        return { success: false, error: 'Invalid event structure' };
      }

      // Extract transaction information
      const processedEvent = {
        eventType: eventType,
        reference: data.tx_ref,
        flutterwaveReference: data.flw_ref,
        transactionId: data.id,
        status: data.status,
        amount: parseFloat(data.amount || 0),
        currency: data.currency,
        paidAt: data.created_at,
        customer: {
          email: data.customer?.email,
          name: data.customer?.name
        },
        meta: data.meta || {},
        userId: data.meta?.userId,
        userName: data.customer?.name,
        bookingDetails: data.meta || {}
      };

      logger.success('Flutterwave v3 webhook event processed', executionId, {
        eventType: eventType,
        reference: processedEvent.reference,
        status: processedEvent.status
      });

      return { success: true, processedEvent: processedEvent };
    } catch (error) {
      logger.error('Failed to process Flutterwave v3 webhook event', executionId, error);
      return { success: false, error: error.message };
    }
  }

  // ========================================================================
  // API Version and Configuration Utilities
  // ========================================================================

  getApiInfo(executionId = 'flw-api-info') {
    const info = {
      apiVersion: 'v3',
      baseUrl: this.baseUrl,
      environment: this.isProduction ? 'Production' : 'Sandbox',
      hasSecretKey: !!ENVIRONMENT.FLUTTERWAVE_SECRET_KEY,
      hasSecretHash: !!ENVIRONMENT.FLUTTERWAVE_SECRET_HASH
    };

    return info;
  }

  // ========================================================================
  // Reference Generation and Utility Methods
  // ========================================================================

  generatePrefixedReference(transactionType, originalReference) {
    const prefix = TRANSACTION_PREFIX_MAP[transactionType] || 'FLW-';
    return `${prefix}${originalReference}`;
  }

  extractOriginalReference(prefixedReference) {
    // Remove known prefixes to get the original Flutterwave reference
    for (const [type, prefix] of Object.entries(TRANSACTION_PREFIX_MAP)) {
      if (prefixedReference.startsWith(prefix)) {
        return prefixedReference.substring(prefix.length);
      }
    }
    return prefixedReference;
  }

  // ========================================================================
  // Health Check and Service Status
  // ========================================================================

  async testConnection(executionId = 'flw-health-check') {
    try {
      // Test by verifying a dummy transaction or checking API health
      // For v3, we can just check if credentials are present
      const isHealthy = !!this.secretKey;

      logger.health('FLUTTERWAVE_API', isHealthy ? 'HEALTHY' : 'UNHEALTHY', executionId, {
        apiVersion: 'v3',
        baseUrl: this.baseUrl,
        hasSecretKey: isHealthy
      });
      return isHealthy;
    } catch (error) {
      logger.health('FLUTTERWAVE_API', 'UNHEALTHY', executionId, error);
      return false;
    }
  }
}

module.exports = { FlutterwaveService };

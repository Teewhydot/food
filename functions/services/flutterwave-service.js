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
    console.log(`Secret Key: ${this.secretKey ? this.secretKey.substring(0, 15) + '...' : 'MISSING'}`);
    console.log(`Available Endpoints:`, Object.keys(FLUTTERWAVE.ENDPOINTS));
    console.log('============================================');

    // Validate Secret Key
    if (!this.secretKey) {
      console.error('Missing Flutterwave v3 Secret Key');
      throw new Error('Flutterwave v3 Secret Key (FLUTTERWAVE_SECRET_KEY) is required for v3 API');
    }

    // Validate environment
    const isTestKey = this.secretKey.startsWith('FLWSECK_TEST-');
    const isLiveKey = this.secretKey.startsWith('FLWSECK-') && !isTestKey;
    this.isProduction = isLiveKey;
    console.log(`Environment: ${this.isProduction ? 'Production (LIVE)' : 'Sandbox (TEST)'}`);
  }


  // ========================================================================
  // Payment Initialization using v3 Charges Endpoint
  // ========================================================================

  async initializePayment(email, amount, metadata, executionId = 'flw-init') {
    try {
      console.log(`[${executionId}] Flutterwave v3 Charges API Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Environment: ${this.isProduction ? 'Production' : 'Sandbox'}`);

      logger.payment('INITIALIZE', 'new-flutterwave-v3-charge', amount, executionId);

      // Generate unique alphanumeric transaction reference (no underscores or special chars)
      const txRef = `FLW${Date.now()}${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
      const idempotencyKey = uuidv4();
      const traceId = `flw_${executionId}_${Date.now()}`;

      // Use v3 charges endpoint with card type
      const chargesUrl = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.CHARGES}?type=card`;
      console.log(`[${executionId}] - Charges Endpoint: ${chargesUrl}`);

      // Prepare headers with Secret Key (Bearer token)
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.secretKey}`,
        'X-Idempotency-Key': idempotencyKey,
        'X-Trace-Id': traceId
      };

      console.log(`[${executionId}] Request headers prepared:`, {
        'Content-Type': headers['Content-Type'],
        'Authorization': headers.Authorization ? 'Bearer ***' + headers.Authorization.slice(-8) : 'MISSING',
        'X-Idempotency-Key': headers['X-Idempotency-Key'],
        'X-Trace-Id': headers['X-Trace-Id']
      });

      // Validate and prepare customer name fields
      const nameParts = (metadata.userName || 'Customer User').split(' ');
      const firstName = nameParts[0] || 'Customer';
      const lastName = nameParts[1] || 'User';

      // Clean phone number to digits only (7-10 chars) - strict validation
      const rawPhone = (metadata.phoneNumber || '08012345678').replace(/[^\d]/g, '');
      const cleanPhone = rawPhone.replace(/^234/, ''); // Remove country code if present
      let validPhone = cleanPhone;
      if (validPhone.length < 7) {
        validPhone = '08012345678'; // Default fallback
      } else if (validPhone.length > 10) {
        validPhone = validPhone.substring(0, 10); // Truncate to 10 digits
      }

      // Flutterwave v3 Direct Card Charge payload structure
      const payload = {
        tx_ref: txRef,
        amount: amount,
        currency: 'NGN',
        customer: {
          email: email,
          name: `${firstName} ${lastName}`,
          phonenumber: validPhone
        },
        payment_options: 'card',
        redirect_url: metadata.redirectUrl || 'https://example.com/success',
        meta: {
          order_id: metadata.orderId,
          user_id: metadata.userId,
          source: 'food_app'
        }
      };

      // Add card details if provided
      if (metadata.card_number) {
        payload.card = {
          card_number: metadata.card_number.replace(/\s/g, ''),
          cvv: metadata.cvv,
          expiry_month: metadata.expiry_month.toString().padStart(2, '0'),
          expiry_year: metadata.expiry_year.toString()
        };
      }

      // Log the complete payload for debugging
      console.log(`[${executionId}] Complete v3 payload:`, JSON.stringify({
        ...payload,
        card: payload.card ? { card_number: '***REDACTED***', cvv: '***' } : undefined
      }, null, 2));

      // Log the actual request being made
      console.log(`[${executionId}] Making HTTP POST request to: ${chargesUrl}`);

      const response = await axios.post(chargesUrl, payload, {
        headers: headers,
        timeout: 60000, // 60 seconds
        maxRedirects: 0, // No redirects/retries
        validateStatus: function (status) {
          return status < 500; // Accept all status codes except 5xx server errors
        }
      });

      console.log(`[${executionId}] Response status: ${response.status}`);

      if (response.status === 200 || response.status === 201) {
        const paymentData = response.data;

        // Handle different authorization modes in v3
        let authorizationUrl = null;
        const authMode = paymentData.data?.meta?.authorization?.mode;

        if (authMode === 'redirect') {
          authorizationUrl = paymentData.data.meta.authorization.redirect;
        } else if (authMode === 'pin' || authMode === 'otp') {
          // For PIN/OTP, return the charge data for further validation
          console.log(`[${executionId}] Authorization mode: ${authMode} - additional validation required`);
        } else if (paymentData.data?.status === 'successful') {
          console.log(`[${executionId}] Payment completed successfully without additional authorization`);
        }

        console.log(`[${executionId}] Extracted authorization URL: ${authorizationUrl ? 'Found' : 'Not needed'}`);

        logger.success(`Flutterwave v3 charge initialized: ${txRef}`, executionId, {
          txRef: txRef,
          amount: amount,
          email: email,
          apiVersion: 'v3',
          authMode: authMode || 'none',
          idempotencyKey: idempotencyKey
        });

        return {
          success: true,
          reference: txRef,
          authorizationUrl: authorizationUrl,
          accessCode: paymentData.data?.flw_ref || null,
          amount: amount,
          idempotencyKey: idempotencyKey,
          traceId: traceId,
          authMode: authMode,
          paymentData: paymentData // Include full response for debugging
        };
      } else {
        console.log(`[${executionId}] Flutterwave v3 API Error Response:`, JSON.stringify(response.data, null, 2));
        const errorMessage = response.data.message || response.data.error || 'Unknown error';
        throw new Error(`Flutterwave v3 API error: ${errorMessage}`);
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

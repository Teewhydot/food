// ========================================================================
// Flutterwave Service - Flutterwave API Integration and Transaction Management
// ========================================================================

const axios = require('axios');
const crypto = require('crypto');
const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');
const { ENVIRONMENT, FLUTTERWAVE, FLUTTERWAVE_ENVIRONMENT, TRANSACTION_PREFIX_MAP } = require('../utils/constants');
const { logger } = require('../utils/logger');
const { ReferenceUtils } = require('../utils/validation');
const { oAuthTokenManager } = require('../utils/oauth-token-manager');

class FlutterwaveService {
  constructor() {
    // v4 API configuration with OAuth 2.0
    this.baseUrl = FLUTTERWAVE_ENVIRONMENT.getBaseUrl();
    this.oAuthManager = oAuthTokenManager;

    // Log service initialization details
    console.log('=== Flutterwave Service Initialization ===');
    console.log(`Base URL: ${this.baseUrl}`);
    console.log(`Environment: ${FLUTTERWAVE_ENVIRONMENT.getEnvironmentSuffix()}`);
    console.log(`Is Production: ${FLUTTERWAVE_ENVIRONMENT.IS_PRODUCTION}`);
    console.log(`OAuth Token URL: ${FLUTTERWAVE.OAUTH_TOKEN_URL}`);
    console.log(`Available Endpoints:`, Object.keys(FLUTTERWAVE.ENDPOINTS));
    console.log('============================================');

    // Validate OAuth credentials
    if (!ENVIRONMENT.FLUTTERWAVE_CLIENT_ID || !ENVIRONMENT.FLUTTERWAVE_CLIENT_SECRET) {
      console.error('Missing Flutterwave OAuth credentials');
      throw new Error('Flutterwave OAuth 2.0 credentials (CLIENT_ID and CLIENT_SECRET) are required for v4 API');
    }
  }

  // ========================================================================
  // Customer Management
  // ========================================================================

  async createOrGetCustomer(email, metadata, executionId = 'flw-customer') {
    try {
      const customerEndpoint = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.V4_CUSTOMERS}`;
      console.log(`[${executionId}] Customer endpoint: ${customerEndpoint}`);

      // Prepare headers with OAuth token
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': await this.oAuthManager.getAuthorizationHeader(executionId),
        'X-Trace-Id': `customer_${executionId}_${Date.now()}`,
        'X-Idempotency-Key': `customer_${uuidv4()}`
      };

      // Customer payload (v4 API structure - objects for name and phone)
      const customerPayload = {
        email: email,
        name: {
          first_name: (metadata.userName || 'Customer').split(' ')[0],
          last_name: (metadata.userName || 'Customer').split(' ')[1] || ''
        },
        phone: {
          country_code: '+234',
          number: (metadata.phoneNumber || '09000000000').replace(/^\+?234/, '')
        },
        address: {
          street: metadata.address?.street || 'No street provided',
          city: metadata.address?.city || 'Lagos',
          state: metadata.address?.state || 'Lagos',
          country: metadata.address?.country || 'Nigeria',
          postal_code: metadata.address?.postal_code || '100001'
        },
        meta: {
          user_id: metadata.userId,
          source: 'food_app'
        }
      };

      console.log(`[${executionId}] Creating customer:`, JSON.stringify(customerPayload, null, 2));

      const response = await axios.post(customerEndpoint, customerPayload, {
        headers: headers,
        timeout: 30000
      });

      if (response.status === 200 || response.status === 201) {
        const customerId = response.data.id || response.data.data?.id;
        console.log(`[${executionId}] Customer created/retrieved: ${customerId}`);
        return customerId;
      } else {
        console.log(`[${executionId}] Customer creation failed:`, response.data);
        // Fallback to using email as customer_id if customer creation fails
        return email.replace('@', '_').replace('.', '_');
      }
    } catch (error) {
      console.log(`[${executionId}] Customer creation error:`, error.response?.data || error.message);
      // Fallback to using email as customer_id
      return email.replace('@', '_').replace('.', '_');
    }
  }

  // ========================================================================
  // Payment Initialization
  // ========================================================================

  async initializePayment(email, amount, metadata, executionId = 'flw-init') {
    try {
      // Detailed endpoint logging
      console.log(`[${executionId}] Flutterwave API Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Environment: ${FLUTTERWAVE_ENVIRONMENT.getEnvironmentSuffix()}`);

      logger.payment('INITIALIZE', 'new-flutterwave-payment', amount, executionId);

      // Generate unique transaction reference
      const txRef = `FLW_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const idempotencyKey = uuidv4();
      const traceId = `flw_${executionId}_${Date.now()}`;

      // Step 1: Create or get customer
      const customerId = await this.createOrGetCustomer(email, metadata, executionId);
      console.log(`[${executionId}] Customer ID: ${customerId}`);

      // Step 2: Create charge with proper customer_id
      const endpoint = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.V4_CHARGES}`;
      console.log(`[${executionId}] - Charge Endpoint: ${endpoint}`);

      // Prepare headers with OAuth token
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': await this.oAuthManager.getAuthorizationHeader(executionId),
        'X-Idempotency-Key': idempotencyKey,
        'X-Trace-Id': traceId
      };

      // v4 API payload structure (according to official docs)
      const payload = {
        amount: amount,
        currency: 'NGN',
        reference: txRef,
        customer_id: customerId,
        payment_method_id: 'card', // Default to card payment
        redirect_url: metadata.redirectUrl || 'https://example.com/success',
        meta: {
          order_id: metadata.orderId,
          email: email,
          name: metadata.userName || 'Customer',
          phone: metadata.phoneNumber || '09000000000',
          ...metadata.bookingDetails
        }
      };

      // Log the complete payload for debugging
      console.log(`[${executionId}] Complete request payload:`, JSON.stringify(payload, null, 2));

      // Log the actual request being made
      console.log(`[${executionId}] Making HTTP POST request to: ${endpoint}`);
      console.log(`[${executionId}] Request headers:`, Object.keys(headers));
      console.log(`[${executionId}] Request payload amount: ${payload.amount}`);

      const response = await axios.post(endpoint, payload, {
        headers: headers,
        timeout: 30000
      });

      console.log(`[${executionId}] Response status: ${response.status}`);
      console.log(`[${executionId}] Response received from: ${endpoint}`);

      if (response.status === 200 || response.status === 201) {
        const paymentData = response.data;
        const authorizationUrl = paymentData.link || paymentData.authorization_url;

        logger.success(`Flutterwave payment initialized: ${txRef}`, executionId, {
          txRef: txRef,
          amount: amount,
          email: email,
          apiVersion: 'v4',
          idempotencyKey: idempotencyKey
        });

        return {
          success: true,
          reference: txRef,
          authorizationUrl: authorizationUrl,
          accessCode: paymentData.access_code || null,
          amount: amount,
          idempotencyKey: idempotencyKey,
          traceId: traceId
        };
      } else {
        console.log(`[${executionId}] Flutterwave API Error Response:`, JSON.stringify(response.data, null, 2));
        const errorMessage = response.data.message || response.data.error || 'Unknown error';
        throw new Error(`Flutterwave API error: ${errorMessage}`);
      }
    } catch (error) {
      // Log the complete error details including response data
      console.log(`[${executionId}] Full error details:`, {
        message: error.message,
        status: error.response?.status,
        statusText: error.response?.statusText,
        responseData: error.response?.data,
        headers: error.response?.headers
      });

      logger.error('Failed to initialize Flutterwave payment', executionId, error, {
        email: email,
        amount: amount,
        apiVersion: 'v4',
        endpoint: endpoint
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

  async verifyTransaction(transactionId, executionId = 'flw-verify') {
    const verificationStartTime = Date.now();

    try {
      logger.payment('VERIFY', transactionId, null, executionId);

      const endpoint = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.V4_TRANSACTIONS}/${transactionId}`;

      // Detailed verification endpoint logging
      console.log(`[${executionId}] Flutterwave Verification Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Verification Path: ${FLUTTERWAVE.ENDPOINTS.V4_TRANSACTIONS}/${transactionId}`);
      console.log(`[${executionId}] - Full Verification URL: ${endpoint}`);

      logger.apiCall('GET', endpoint, null, executionId);

      // Prepare headers with OAuth token
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': await this.oAuthManager.getAuthorizationHeader(executionId)
      };

      // Log the verification request
      console.log(`[${executionId}] Making HTTP GET request to: ${endpoint}`);
      console.log(`[${executionId}] Verification headers:`, Object.keys(headers));

      const response = await axios.get(endpoint, {
        headers: headers,
        timeout: 30000
      });

      console.log(`[${executionId}] Verification response status: ${response.status}`);
      console.log(`[${executionId}] Verification response received from: ${endpoint}`);

      const verificationEndTime = Date.now();
      const verificationDuration = verificationEndTime - verificationStartTime;

      logger.performance('VERIFICATION', verificationDuration, executionId, {
        transactionId: transactionId,
        apiVersion: 'v4'
      });

      if (response.status === 200) {
        const transactionData = response.data;

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

        logger.success(`Flutterwave transaction verified: ${transactionId}`, executionId, {
          status: result.status,
          amount: result.amount,
          reference: result.reference,
          apiVersion: 'v4'
        });

        return result;
      } else {
        const errorMessage = response.data.message || 'Unknown error';
        throw new Error(`Flutterwave verification failed: ${errorMessage}`);
      }
    } catch (error) {
      logger.error('Flutterwave verification failed', executionId, error, {
        transactionId: transactionId,
        apiVersion: 'v4'
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

      // For Flutterwave, we use the same verification endpoint to get status
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
      logger.error('Failed to get Flutterwave transaction status', executionId, error, {
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
        logger.security('WEBHOOK_VERIFIED', 'Flutterwave webhook signature valid', executionId, {
          signatureLength: signature?.length,
          hashLength: hash?.length
        });
      } else {
        logger.security('WEBHOOK_INVALID', 'Flutterwave webhook signature invalid', executionId, {
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
  // Webhook Event Processing
  // ========================================================================

  processWebhookEvent(event, executionId = 'flw-webhook-process') {
    try {
      logger.webhook('PROCESS', event['event-type'] || 'unknown', executionId);

      const eventType = event['event-type'];
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

      logger.success('Flutterwave webhook event processed', executionId, {
        eventType: eventType,
        reference: processedEvent.reference,
        status: processedEvent.status
      });

      return { success: true, processedEvent: processedEvent };
    } catch (error) {
      logger.error('Failed to process Flutterwave webhook event', executionId, error);
      return { success: false, error: error.message };
    }
  }

  // ========================================================================
  // API Version and Configuration Utilities
  // ========================================================================

  getApiInfo(executionId = 'flw-api-info') {
    const info = {
      apiVersion: 'v4',
      baseUrl: this.baseUrl,
      environment: FLUTTERWAVE_ENVIRONMENT.getEnvironmentSuffix(),
      oAuthEnabled: true,
      hasCredentials: {
        clientId: !!ENVIRONMENT.FLUTTERWAVE_CLIENT_ID,
        clientSecret: !!ENVIRONMENT.FLUTTERWAVE_CLIENT_SECRET,
        secretHash: !!ENVIRONMENT.FLUTTERWAVE_SECRET_HASH
      }
    };

    info.tokenInfo = this.oAuthManager.getTokenInfo(executionId);

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
      // Test OAuth connection for v4 API
      const isHealthy = await this.oAuthManager.testOAuthConnection(executionId);

      logger.health('FLUTTERWAVE_API', isHealthy ? 'HEALTHY' : 'UNHEALTHY', executionId, {
        apiVersion: 'v4',
        baseUrl: this.baseUrl
      });
      return isHealthy;
    } catch (error) {
      logger.health('FLUTTERWAVE_API', 'UNHEALTHY', executionId, error);
      return false;
    }
  }
}

module.exports = { FlutterwaveService };
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
  // Payment Initialization using Direct Charges
  // ========================================================================

  async initializePayment(email, amount, metadata, executionId = 'flw-init') {
    try {
      // Detailed endpoint logging
      console.log(`[${executionId}] Flutterwave Direct Charges API Configuration:`);
      console.log(`[${executionId}] - Base URL: ${this.baseUrl}`);
      console.log(`[${executionId}] - Environment: ${FLUTTERWAVE_ENVIRONMENT.getEnvironmentSuffix()}`);

      logger.payment('INITIALIZE', 'new-flutterwave-direct-payment', amount, executionId);

      // Generate unique alphanumeric transaction reference (no underscores or special chars)
      const txRef = `FLW${Date.now()}${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
      const idempotencyKey = uuidv4();
      const traceId = `flw_${executionId}_${Date.now()}`;

      // Use direct-charges endpoint (no separate customer creation needed)
      const directChargesUrl = `${this.baseUrl}${FLUTTERWAVE.ENDPOINTS.V4_DIRECT_CHARGES}`;
      console.log(`[${executionId}] - Direct Charges Endpoint: ${directChargesUrl}`);

      // Prepare headers with OAuth token
      const authHeader = await this.oAuthManager.getAuthorizationHeader(executionId);
      console.log(`[${executionId}] OAuth Authorization Header: ${authHeader ? 'Bearer ***' + authHeader.slice(-8) : 'MISSING'}`);

      const headers = {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
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
      const middleName = nameParts[2] || 'N/A'; // Default middle name if not provided

      // Ensure name fields meet validation requirements (2-50 chars) - must not be empty/spaces/symbols only
      const validFirstName = firstName.length >= 2 ? firstName.substring(0, 50) : 'Customer';
      const validLastName = lastName.length >= 2 ? lastName.substring(0, 50) : 'User';
      // Middle name must be 2-50 chars, not just spaces or symbols
      let validMiddleName = middleName.length >= 2 ? middleName.substring(0, 50) : 'Middle';
      // Ensure middle name contains at least some letters
      if (!/[a-zA-Z]/.test(validMiddleName)) {
        validMiddleName = 'Middle';
      }

      // Clean phone number to digits only (7-10 chars) - strict validation
      const rawPhone = (metadata.phoneNumber || '08012345678').replace(/[^\d]/g, '');
      const cleanPhone = rawPhone.replace(/^234/, ''); // Remove country code if present
      // Ensure phone number is exactly between 7-10 digits
      let validPhone = cleanPhone;
      if (validPhone.length < 7) {
        validPhone = '08012345678'; // Default fallback
      } else if (validPhone.length > 10) {
        validPhone = validPhone.substring(0, 10); // Truncate to 10 digits
      }

      // Flutterwave Direct Charges API payload structure - exact match to documentation
      const payload = {
        currency: 'NGN',
        customer: {
          address: {
            city: metadata.address?.city || 'Lagos',
            country: metadata.address?.country || 'NG',
            line1: metadata.address?.street || metadata.address?.line1 || '123 Main Street',
            line2: metadata.address?.line2 || 'Apt 1A',
            postal_code: metadata.address?.postal_code || '100001',
            state: metadata.address?.state || 'Lagos'
          },
          meta: {
            user_id: metadata.userId,
            source: 'food_app'
          },
          name: {
            first: validFirstName,
            middle: validMiddleName,
            last: validLastName
          },
          phone: {
            country_code: '234',
            number: validPhone
          },
          email: email
        },
        meta: {
          order_id: metadata.orderId,
          user_id: metadata.userId,
          source: 'food_app'
        },
        payment_method: {
          card: {
            billing_address: {
              city: metadata.address?.city || 'Lagos',
              country: metadata.address?.country || 'NG',
              line1: metadata.address?.street || metadata.address?.line1 || '123 Main Street',
              line2: metadata.address?.line2 || 'Apt 1A',
              postal_code: metadata.address?.postal_code || '100001',
              state: metadata.address?.state || 'Lagos'
            },
            cof: {
              enabled: true,
              agreement_id: `Agreement${Date.now()}`,
              trace_id: `trace_${Date.now()}`
            },
            nonce: Math.random().toString(36).substring(2, 14), // 12 character alphanumeric
            encrypted_expiry_month: 'sQpvQEb7GrUCjPuEN/NmHiPl', // Demo encrypted value
            encrypted_expiry_year: 'sgHNEDkJ/RmwuWWq/RymToU5', // Demo encrypted value
            encrypted_card_number: 'sAE3hEDaDQ+yLzo4Py+Lx15OZjBGduHu/DcdILh3En0=', // Demo encrypted value
            encrypted_cvv: 'tAUzH7Qjma7diGdi7938F/ESNA==', // Demo encrypted value
            card_holder_name: `${validFirstName} ${validLastName}`
          },
          type: 'card'
        },
        authorization: {
          otp: {
            code: 'string'
          },
          type: 'otp'
        },
        amount: amount,
        reference: txRef,
        redirect_url: metadata.redirectUrl || 'https://example.com/success'
      };

      // Log the complete payload for debugging
      console.log(`[${executionId}] Complete direct charges payload:`, JSON.stringify(payload, null, 2));

      // Log the actual request being made
      console.log(`[${executionId}] Making HTTP POST request to: ${directChargesUrl}`);
      console.log(`[${executionId}] Request headers:`, Object.keys(headers));
      console.log(`[${executionId}] Request payload amount: ${payload.amount}`);

      // Critical: Verify Authorization header is included
      if (!headers.Authorization || !headers.Authorization.startsWith('Bearer ')) {
        throw new Error('CRITICAL: Missing or invalid Authorization header for Flutterwave API');
      }
      console.log(`[${executionId}] ✅ Authorization header verified: ${headers.Authorization.slice(0, 15)}...`);

      const response = await axios.post(directChargesUrl, payload, {
        headers: headers,
        timeout: 60000, // Increase to 60 seconds
        maxRedirects: 0, // No redirects/retries
        validateStatus: function (status) {
          return status < 500; // Accept all status codes except 5xx server errors
        }
      });

      console.log(`[${executionId}] Response status: ${response.status}`);
      console.log(`[${executionId}] Response received from: ${directChargesUrl}`);

      if (response.status === 200 || response.status === 201) {
        const paymentData = response.data;
        // Extract redirect URL from Flutterwave Direct Charges response structure
        const authorizationUrl = paymentData.data?.next_action?.redirect_url?.url ||
                                 paymentData.link ||
                                 paymentData.authorization_url ||
                                 paymentData.redirect_url;

        console.log(`[${executionId}] Extracted authorization URL: ${authorizationUrl ? 'Found' : 'NOT FOUND'}`);
        if (!authorizationUrl) {
          console.log(`[${executionId}] Payment data structure:`, JSON.stringify(paymentData, null, 2));
        }

        logger.success(`Flutterwave direct charge initialized: ${txRef}`, executionId, {
          txRef: txRef,
          amount: amount,
          email: email,
          apiVersion: 'v4-direct',
          idempotencyKey: idempotencyKey
        });

        return {
          success: true,
          reference: txRef,
          authorizationUrl: authorizationUrl,
          accessCode: paymentData.access_code || null,
          amount: amount,
          idempotencyKey: idempotencyKey,
          traceId: traceId,
          paymentData: paymentData // Include full response for debugging
        };
      } else {
        console.log(`[${executionId}] Flutterwave Direct Charges API Error Response:`, JSON.stringify(response.data, null, 2));
        const errorMessage = response.data.message || response.data.error || 'Unknown error';
        throw new Error(`Flutterwave Direct Charges API error: ${errorMessage}`);
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
        logger.critical('Flutterwave API request timeout - increase timeout or check network', executionId, error, {
          email: email,
          amount: amount,
          apiVersion: 'v4-direct',
          timeoutDuration: '60000ms'
        });

        return {
          success: false,
          error: 'Request timeout - please try again',
          errorType: 'TIMEOUT',
          details: { message: 'The request to Flutterwave API timed out after 60 seconds' }
        };
      }

      logger.error('Failed to initialize Flutterwave direct charge', executionId, error, {
        email: email,
        amount: amount,
        apiVersion: 'v4-direct',
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
        timeout: 60000,
        maxRedirects: 0, // No redirects/retries
        validateStatus: function (status) {
          return status < 500; // Accept all status codes except 5xx server errors
        }
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
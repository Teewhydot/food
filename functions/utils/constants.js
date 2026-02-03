// ========================================================================
// Constants and Configuration
// ========================================================================

// Environment variables configuration (Firebase Functions v2)
const ENVIRONMENT = {
  GMAIL_PASSWORD: process.env.PASSWORD,
  PAYSTACK_SECRET_KEY: process.env.PAYSTACK_SECRET_KEY,
  // Flutterwave v3 Configuration (Secret Key authentication)
  FLUTTERWAVE_SECRET_KEY: process.env.FLUTTERWAVE_SECRET_KEY,
  FLUTTERWAVE_PUBLIC_KEY: process.env.FLUTTERWAVE_PUBLIC_KEY,
  FLUTTERWAVE_ENCRYPTION_KEY: process.env.FLUTTERWAVE_ENCRYPTION_KEY,
  FLUTTERWAVE_SECRET_HASH: process.env.FLUTTERWAVE_SECRET_HASH,
  PROJECT_ID: process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'food-delivery-app',
  // Backend Keep-Alive Configuration
  BACKEND_KEEPALIVE_URL: process.env.BACKEND_KEEPALIVE_URL
};

// Contact information configuration (can be updated remotely)
const CONTACT_INFO = {
  SUPPORT_EMAIL: process.env.SUPPORT_EMAIL || 'support@fooddelivery.com',
  SUPPORT_PHONE: process.env.SUPPORT_PHONE || '+234 XXX XXX XXXX',
  BUSINESS_LOCATION: process.env.BUSINESS_LOCATION || 'Lagos, Nigeria'
};

// Transaction reference prefix mapping
const TRANSACTION_PREFIX_MAP = {
  'food_order': 'F-',
  'subscription': 'S-',
  'delivery': 'D-'
};

// Transaction type configuration for food delivery system
const TRANSACTION_TYPES = {
  food_order: {
    collectionName: 'food_orders',
    transactionType: 'food_order',
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
  subscription: {
    collectionName: 'subscriptions',
    transactionType: 'subscription',
    serviceType: 'subscription',
    emailSubject: {
      creation: 'Subscription Created',
      success: 'Subscription Confirmed'
    },
    notificationTitle: {
      creation: 'Subscription Created',
      success: 'Subscription Confirmed! ⭐'
    },
    emoji: '⭐'
  },
  delivery: {
    collectionName: 'delivery_orders',
    transactionType: 'delivery',
    serviceType: 'delivery',
    emailSubject: {
      creation: 'Delivery Order Created',
      success: 'Delivery Order Confirmed'
    },
    notificationTitle: {
      creation: 'Delivery Order Created',
      success: 'Delivery Order Confirmed! 🚚'
    },
    emoji: '🚚'
  }
};

// Google API scopes for FCM
const GOOGLE_SCOPES = [
  'https://www.googleapis.com/auth/firebase.messaging'
];

// Paystack API configuration
const PAYSTACK = {
  API_BASE_URL: 'https://api.paystack.co',
  ENDPOINTS: {
    INITIALIZE_TRANSACTION: '/transaction/initialize',
    VERIFY_TRANSACTION: '/transaction/verify'
  }
};

// Flutterwave API configuration (v3)
const FLUTTERWAVE = {
  // v3 API configuration with Secret Key authentication
  API_BASE_URL_V3: 'https://api.flutterwave.com',
  ENDPOINTS: {
    // v3 Endpoints
    CHARGES: '/v3/charges',
    VALIDATE_CHARGE: '/v3/validate-charge',
    TRANSACTIONS: '/v3/transactions',
    VERIFY_TRANSACTION: '/v3/transactions/:id/verify'
  }
};

// Firebase Functions configuration
const FUNCTIONS_CONFIG = {
  REGION: 'us-central1',
  TIMEOUT_SECONDS: 560,
  MEMORY: '256MB'
};

// Flutterwave environment configuration (v3)
const FLUTTERWAVE_ENVIRONMENT = {
  // Determine if using production keys
  // v3 uses key prefix to determine environment:
  // - TEST keys: FLWSECK_TEST-xxx
  // - LIVE keys: FLWSECK-xxx
  IS_PRODUCTION: function() {
    const secretKey = ENVIRONMENT.FLUTTERWAVE_SECRET_KEY || '';
    return secretKey.startsWith('FLWSECK-') && !secretKey.startsWith('FLWSECK_TEST-');
  },

  // Get the base URL (v3 uses same URL for both environments)
  getBaseUrl() {
    return FLUTTERWAVE.API_BASE_URL_V3;
  },

  // Environment-specific configuration
  getEnvironmentSuffix() {
    return this.IS_PRODUCTION() ? 'production' : 'sandbox';
  }
};

// Email styling constants
const EMAIL_STYLES = {
  HEADER_COLOR: '#1a365d',
  LOGO_URL: '',
  BUSINESS_NAME: 'Food Delivery App',
  BUSINESS_TAGLINE: 'Fresh Food, Fast Delivery'
};

// Admin notification types mapping
const NOTIFICATION_TYPE_MAP = {
  'food_order': 'food_order',
  'subscription': 'subscription',
  'delivery': 'delivery'
};

// Admin notification titles
const ADMIN_NOTIFICATION_TITLES = {
  'food_order': 'New Food Order',
  'subscription': 'New Subscription',
  'delivery': 'New Delivery Order'
};

// Target roles for different transaction types
const TARGET_ROLES = {
  'food_order': ['admin', 'kitchen_staff', 'restaurant_manager'],
  'subscription': ['admin', 'customer_service'],
  'delivery': ['admin', 'delivery_staff', 'dispatch']
};

module.exports = {
  ENVIRONMENT,
  CONTACT_INFO,
  TRANSACTION_PREFIX_MAP,
  TRANSACTION_TYPES,
  GOOGLE_SCOPES,
  PAYSTACK,
  FLUTTERWAVE,
  FLUTTERWAVE_ENVIRONMENT,
  FUNCTIONS_CONFIG,
  EMAIL_STYLES,
  NOTIFICATION_TYPE_MAP,
  ADMIN_NOTIFICATION_TITLES,
  TARGET_ROLES
};
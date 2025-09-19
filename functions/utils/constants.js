// ========================================================================
// Constants and Configuration
// ========================================================================

// Environment variables configuration
const ENVIRONMENT = {
  GMAIL_PASSWORD: process.env.PASSWORD,
  PAYSTACK_SECRET_KEY: process.env.PAYSTACK_SECRET_KEY,
  PROJECT_ID: process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT || 'fmh-hotel'
};

// Contact information configuration (can be updated remotely)
const CONTACT_INFO = {
  SUPPORT_EMAIL: process.env.SUPPORT_EMAIL || 'support@fmhhotel.com',
  SUPPORT_PHONE: process.env.SUPPORT_PHONE || '+234 XXX XXX XXXX',
  HOTEL_LOCATION: process.env.HOTEL_LOCATION || 'Lagos, Nigeria'
};

// Transaction reference prefix mapping
const TRANSACTION_PREFIX_MAP = {
  'booking': 'B-',
  'food_order': 'F-',
  'gym_session': 'G-',
  'pool_session': 'P-',
  'laundry_service': 'L-'
};

// Transaction type configuration for scalable system
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

// Firebase Functions configuration
const FUNCTIONS_CONFIG = {
  REGION: 'us-central1',
  TIMEOUT_SECONDS: 560,
  MEMORY: '256MB'
};

// Email styling constants
const EMAIL_STYLES = {
  HEADER_COLOR: '#1a365d',
  LOGO_URL: '',
  HOTEL_NAME: 'FMH Hotel',
  HOTEL_TAGLINE: 'Luxury & Comfort Redefined'
};

// Admin notification types mapping
const NOTIFICATION_TYPE_MAP = {
  'booking': 'booking',
  'food_order': 'food',
  'gym_session': 'amenities',
  'pool_session': 'amenities',
  'spa_session': 'amenities',
  'laundry_service': 'laundry'
};

// Admin notification titles
const ADMIN_NOTIFICATION_TITLES = {
  'booking': 'New Room Booking',
  'food_order': 'New Food Order',
  'gym_session': 'New Gym Session',
  'pool_session': 'New Pool Session',
  'laundry_service': 'New Laundry Service'
};

// Target roles for different transaction types
const TARGET_ROLES = {
  'booking': ['admin', 'front_desk'],
  'food_order': ['admin', 'kitchen_staff'],
  'gym_session': ['admin', 'fitness_staff'],
  'pool_session': ['admin', 'pool_staff'],
  'spa_session': ['admin', 'spa_staff'],
  'laundry_service': ['admin', 'housekeeping']
};

module.exports = {
  ENVIRONMENT,
  CONTACT_INFO,
  TRANSACTION_PREFIX_MAP,
  TRANSACTION_TYPES,
  GOOGLE_SCOPES,
  PAYSTACK,
  FUNCTIONS_CONFIG,
  EMAIL_STYLES,
  NOTIFICATION_TYPE_MAP,
  ADMIN_NOTIFICATION_TITLES,
  TARGET_ROLES
};
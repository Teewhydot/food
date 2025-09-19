// ========================================================================
// Validation and Data Processing Utilities
// ========================================================================

const { TRANSACTION_TYPES, TRANSACTION_PREFIX_MAP } = require('./constants');

class ValidationError extends Error {
  constructor(message, field = null, value = null) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
    this.value = value;
  }
}

// Basic validation helpers
const Validators = {
  // Check if value is not null or undefined
  isRequired(value, fieldName) {
    if (value === null || value === undefined) {
      throw new ValidationError(`${fieldName} is required`, fieldName, value);
    }
    return true;
  },

  // Check if string is not empty
  isNotEmpty(value, fieldName) {
    this.isRequired(value, fieldName);
    if (typeof value === 'string' && value.trim().length === 0) {
      throw new ValidationError(`${fieldName} cannot be empty`, fieldName, value);
    }
    return true;
  },

  // Check if value is a valid email
  isEmail(email, fieldName = 'email') {
    this.isRequired(email, fieldName);
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new ValidationError(`${fieldName} must be a valid email address`, fieldName, email);
    }
    return true;
  },

  // Check if value is a positive number
  isPositiveNumber(value, fieldName) {
    this.isRequired(value, fieldName);
    const num = Number(value);
    if (isNaN(num) || num <= 0) {
      throw new ValidationError(`${fieldName} must be a positive number`, fieldName, value);
    }
    return true;
  },

  // Check if value is a valid amount (positive number)
  isValidAmount(amount, fieldName = 'amount') {
    return this.isPositiveNumber(amount, fieldName);
  },

  // Check if array exists and has items
  isNonEmptyArray(array, fieldName) {
    this.isRequired(array, fieldName);
    if (!Array.isArray(array)) {
      throw new ValidationError(`${fieldName} must be an array`, fieldName, array);
    }
    if (array.length === 0) {
      throw new ValidationError(`${fieldName} cannot be empty`, fieldName, array);
    }
    return true;
  },

  // Check if value is a valid transaction type
  isValidTransactionType(transactionType) {
    this.isRequired(transactionType, 'transactionType');
    if (!TRANSACTION_TYPES[transactionType]) {
      throw new ValidationError(`Invalid transaction type: ${transactionType}`, 'transactionType', transactionType);
    }
    return true;
  },

  // Check if Firebase document exists
  documentExists(doc, documentName) {
    if (!doc || !doc.exists) {
      throw new ValidationError(`${documentName} not found`, documentName, null);
    }
    return true;
  },

  // Check if service type matches expected type
  isValidServiceType(serviceType, expectedType, fieldName = 'serviceType') {
    this.isRequired(serviceType, fieldName);
    if (serviceType !== expectedType) {
      throw new ValidationError(`Expected ${fieldName}: "${expectedType}", Got: "${serviceType}"`, fieldName, serviceType);
    }
    return true;
  },

  // Check if reference has valid prefix
  hasValidPrefix(reference, fieldName = 'reference') {
    this.isRequired(reference, fieldName);
    const prefixes = Object.keys(TRANSACTION_PREFIX_MAP);
    const hasValidPrefix = prefixes.some(prefix => reference.startsWith(prefix));
    if (!hasValidPrefix) {
      throw new ValidationError(`${fieldName} must have a valid prefix (${prefixes.join(', ')})`, fieldName, reference);
    }
    return true;
  }
};

// Data cleaning utilities
const DataCleaners = {
  // Clean booking details: remove reviews, imageUrls, videoUrls from rooms but keep amenities
  cleanBookingDetails(details) {
    if (!details || !details.selectedRooms) {
      return details;
    }

    return {
      ...details,
      selectedRooms: details.selectedRooms.map(room => {
        const { reviews, imageUrls, videoUrls, ...rest } = room;
        return rest;
      })
    };
  },

  // Sanitize email address
  sanitizeEmail(email) {
    if (!email) return email;
    return email.trim().toLowerCase();
  },

  // Sanitize string input
  sanitizeString(str) {
    if (!str || typeof str !== 'string') return str;
    return str.trim();
  },

  // Sanitize phone number
  sanitizePhoneNumber(phone) {
    if (!phone) return phone;
    // Remove all non-digit characters except +
    return phone.replace(/[^\d+]/g, '');
  },

  // Clean transaction metadata
  cleanTransactionMetadata(metadata) {
    if (!metadata) return metadata;

    const cleaned = { ...metadata };

    // Remove null or undefined values
    Object.keys(cleaned).forEach(key => {
      if (cleaned[key] === null || cleaned[key] === undefined) {
        delete cleaned[key];
      }
    });

    return cleaned;
  },

  // Extract items from order data (handles both 'items' and 'service_items' fields)
  extractOrderItems(orderData) {
    if (!orderData) return [];
    return orderData.items || orderData.service_items || [];
  }
};

// Request validation utilities
const RequestValidators = {
  // Validate transaction creation request (supports both old and new formats)
  validateTransactionRequest(requestBody) {
    // Handle new format from Flutter app (orderId, amount, email, userId, metadata)
    if (requestBody.orderId && !requestBody.bookingDetails) {
      const { orderId, amount, email, userId, metadata = {} } = requestBody;

      Validators.isValidAmount(amount, 'amount');
      Validators.isNotEmpty(userId, 'userId');
      Validators.isEmail(email, 'email');
      Validators.isNotEmpty(orderId, 'orderId');

      return {
        orderId: DataCleaners.sanitizeString(orderId),
        amount: Number(amount),
        userId: DataCleaners.sanitizeString(userId),
        email: DataCleaners.sanitizeEmail(email),
        metadata: DataCleaners.cleanTransactionMetadata(metadata),
        userName: metadata.userName || 'Customer' // Default if not provided
      };
    }

    // Handle old format (amount, userId, email, bookingDetails, userName)
    const { amount, userId, email, bookingDetails, userName } = requestBody;

    Validators.isValidAmount(amount, 'amount');
    Validators.isNotEmpty(userId, 'userId');
    Validators.isEmail(email, 'email');
    Validators.isRequired(bookingDetails, 'bookingDetails');
    Validators.isNotEmpty(userName, 'userName');

    if (bookingDetails.transactionType) {
      Validators.isValidTransactionType(bookingDetails.transactionType);
    }

    return {
      amount: Number(amount),
      userId: DataCleaners.sanitizeString(userId),
      email: DataCleaners.sanitizeEmail(email),
      bookingDetails: DataCleaners.cleanTransactionMetadata(bookingDetails),
      userName: DataCleaners.sanitizeString(userName)
    };
  },

  // Validate email sending request
  validateEmailRequest(requestBody) {
    const { to, subject, text } = requestBody;

    Validators.isEmail(to, 'to');
    Validators.isNotEmpty(subject, 'subject');
    Validators.isNotEmpty(text, 'text');

    return {
      to: DataCleaners.sanitizeEmail(to),
      subject: DataCleaners.sanitizeString(subject),
      text: DataCleaners.sanitizeString(text)
    };
  },

  // Validate FCM notification request
  validateNotificationRequest(requestBody) {
    const { userId, title, body } = requestBody;

    Validators.isNotEmpty(userId, 'userId');
    Validators.isNotEmpty(title, 'title');
    Validators.isNotEmpty(body, 'body');

    return {
      userId: DataCleaners.sanitizeString(userId),
      title: DataCleaners.sanitizeString(title),
      body: DataCleaners.sanitizeString(body),
      data: DataCleaners.cleanTransactionMetadata(requestBody.data || {})
    };
  }
};

// Database validation utilities
const DatabaseValidators = {
  // Validate order document and extract required data
  validateOrderDocument(orderDoc, orderReference, executionId = 'validation') {
    Validators.documentExists(orderDoc, `Order document ${orderReference}`);

    const orderData = orderDoc.data();
    const orderedItems = DataCleaners.extractOrderItems(orderData);

    return {
      orderData,
      orderedItems,
      hasItems: orderedItems.length > 0
    };
  },

  // Validate food order for quantity deduction
  validateFoodOrder(orderData, orderReference, executionId = 'validation') {
    Validators.isValidServiceType(orderData.serviceType, 'food_delivery');

    const orderedItems = DataCleaners.extractOrderItems(orderData);
    Validators.isNonEmptyArray(orderedItems, 'orderedItems');

    return orderedItems;
  },

  // Validate service document for specific service type
  validateServiceDocument(serviceDoc, serviceReference, expectedServiceType = null) {
    Validators.documentExists(serviceDoc, `Service document ${serviceReference}`);

    const serviceData = serviceDoc.data();

    if (expectedServiceType) {
      Validators.isValidServiceType(serviceData.serviceType, expectedServiceType);
    }

    return serviceData;
  }
};

// Transaction reference utilities
const ReferenceUtils = {
  // Extract transaction type from reference prefix
  getTransactionTypeFromReference(reference) {
    Validators.hasValidPrefix(reference);

    for (const [transactionType, prefix] of Object.entries(TRANSACTION_PREFIX_MAP)) {
      if (reference.startsWith(prefix)) {
        return transactionType;
      }
    }

    return null;
  },

  // Generate prefixed reference
  generatePrefixedReference(transactionType, paystackReference) {
    Validators.isValidTransactionType(transactionType);
    Validators.isNotEmpty(paystackReference, 'paystackReference');

    const prefix = TRANSACTION_PREFIX_MAP[transactionType] || '';
    return prefix + paystackReference;
  },

  // Remove prefix from reference
  removePrefixFromReference(reference) {
    Validators.hasValidPrefix(reference);

    for (const prefix of Object.values(TRANSACTION_PREFIX_MAP)) {
      if (reference.startsWith(prefix)) {
        return reference.substring(prefix.length);
      }
    }

    return reference;
  }
};

module.exports = {
  ValidationError,
  Validators,
  DataCleaners,
  RequestValidators,
  DatabaseValidators,
  ReferenceUtils
};
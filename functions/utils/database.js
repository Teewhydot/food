// ========================================================================
// Database Utilities and Firestore Helpers
// ========================================================================

const admin = require('firebase-admin');
const { TRANSACTION_TYPES, TRANSACTION_PREFIX_MAP } = require('./constants');
const { logger } = require('./logger');
const { DataCleaners } = require('./validation');

// Lazy-load Firestore instance (admin should be initialized in index.js)
let db;

function getFirestore() {
  if (!db) {
    try {
      db = admin.firestore();
    } catch (error) {
      console.error('Error getting Firestore instance:', error);
      throw error;
    }
  }
  return db;
}

// Database utility class
class DatabaseHelper {
  constructor() {
    // Use lazy loading for Firestore
  }

  get db() {
    return getFirestore();
  }

  // ========================================================================
  // Document Operations
  // ========================================================================

  // Get a document by reference
  async getDocument(collection, documentId, executionId = 'db-op') {
    try {
      logger.database('GET', collection, documentId, executionId);
      const doc = await this.db.collection(collection).doc(documentId).get();

      if (doc.exists) {
        logger.success(`Document found: ${collection}/${documentId}`, executionId);
        return { doc, data: doc.data() };
      } else {
        logger.warning(`Document not found: ${collection}/${documentId}`, executionId);
        return { doc: null, data: null };
      }
    } catch (error) {
      logger.error(`Failed to get document: ${collection}/${documentId}`, executionId, error);
      throw error;
    }
  }

  // Set a document
  async setDocument(collection, documentId, data, merge = true, executionId = 'db-op') {
    try {
      logger.database('SET', collection, documentId, executionId);
      await this.db.collection(collection).doc(documentId).set(data, { merge });
      logger.success(`Document set: ${collection}/${documentId}`, executionId);
    } catch (error) {
      logger.error(`Failed to set document: ${collection}/${documentId}`, executionId, error);
      throw error;
    }
  }

  // Update a document
  async updateDocument(collection, documentId, updateData, executionId = 'db-op') {
    try {
      logger.database('UPDATE', collection, documentId, executionId);
      await this.db.collection(collection).doc(documentId).update(updateData);
      logger.success(`Document updated: ${collection}/${documentId}`, executionId);
    } catch (error) {
      logger.error(`Failed to update document: ${collection}/${documentId}`, executionId, error);
      throw error;
    }
  }

  // Add a document to collection
  async addDocument(collection, data, executionId = 'db-op') {
    try {
      logger.database('ADD', collection, null, executionId);
      const docRef = await this.db.collection(collection).add(data);
      logger.success(`Document added: ${collection}/${docRef.id}`, executionId);
      return docRef;
    } catch (error) {
      logger.error(`Failed to add document to: ${collection}`, executionId, error);
      throw error;
    }
  }

  // Delete a document
  async deleteDocument(collection, documentId, executionId = 'db-op') {
    try {
      logger.database('DELETE', collection, documentId, executionId);
      await this.db.collection(collection).doc(documentId).delete();
      logger.success(`Document deleted: ${collection}/${documentId}`, executionId);
    } catch (error) {
      logger.error(`Failed to delete document: ${collection}/${documentId}`, executionId, error);
      throw error;
    }
  }

  // ========================================================================
  // Batch Operations
  // ========================================================================

  // Create a new batch
  createBatch() {
    return this.db.batch();
  }

  // Commit a batch operation
  async commitBatch(batch, operationCount, executionId = 'db-batch') {
    try {
      logger.batch('COMMIT', operationCount, executionId);
      await batch.commit();
      logger.success(`Batch committed: ${operationCount} operations`, executionId);
    } catch (error) {
      logger.error(`Failed to commit batch: ${operationCount} operations`, executionId, error);
      throw error;
    }
  }

  // Add set operation to batch
  batchSet(batch, collection, documentId, data, merge = true) {
    const docRef = this.db.collection(collection).doc(documentId);
    batch.set(docRef, data, { merge });
    return batch;
  }

  // Add update operation to batch
  batchUpdate(batch, collection, documentId, updateData) {
    const docRef = this.db.collection(collection).doc(documentId);
    batch.update(docRef, updateData);
    return batch;
  }

  // Add delete operation to batch
  batchDelete(batch, collection, documentId) {
    const docRef = this.db.collection(collection).doc(documentId);
    batch.delete(docRef);
    return batch;
  }

  // ========================================================================
  // Specialized Query Operations
  // ========================================================================

  // Find document with prefix (from original code)
  async findDocumentWithPrefix(reference, executionId = 'find-prefix') {
    logger.processing(`Finding document for reference: ${reference}`, executionId);

    // Define prefix mapping for transaction types
    const prefixMapping = {
      'F-': { type: 'food_order', collection: 'food_orders' },
      'D-': { type: 'delivery', collection: 'delivery_orders' },
      'S-': { type: 'subscription', collection: 'subscriptions' },
    };

    // Try each prefix to find the document
    for (const [prefix, config] of Object.entries(prefixMapping)) {
      const prefixedReference = `${prefix}${reference}`;

      try {
        const { doc, data } = await this.getDocument(config.collection, prefixedReference, executionId);
        if (doc && doc.exists) {
          logger.success(`Found document with reference: ${prefixedReference} in collection: ${config.collection}`, executionId);

          return {
            actualReference: prefixedReference,
            transactionType: config.type,
            orderDetails: data,
            userEmail: data.userEmail || ''
          };
        }
      } catch (prefixError) {
        logger.info(`No document found with prefix ${prefix} for reference ${reference}`, executionId);
      }
    }

    logger.error(`No document found for reference ${reference} with any known prefix. Tried: F-, D-, S-`, executionId);
    return {
      actualReference: reference,
      transactionType: 'food_order', // Default to food_order which exists in TRANSACTION_TYPES
      orderDetails: {},
      userEmail: ''
    };
  }

  // Query documents with conditions
  async queryDocuments(collection, conditions = [], orderBy = null, limit = null, executionId = 'query') {
    try {
      logger.database('QUERY', collection, null, executionId);
      let query = this.db.collection(collection);

      // Apply where conditions
      conditions.forEach(condition => {
        query = query.where(condition.field, condition.operator, condition.value);
      });

      // Apply ordering
      if (orderBy) {
        query = query.orderBy(orderBy.field, orderBy.direction || 'asc');
      }

      // Apply limit
      if (limit) {
        query = query.limit(limit);
      }

      const snapshot = await query.get();
      const documents = [];

      snapshot.forEach(doc => {
        documents.push({
          id: doc.id,
          data: doc.data()
        });
      });

      logger.success(`Query completed: ${documents.length} documents found in ${collection}`, executionId);
      return documents;
    } catch (error) {
      logger.error(`Failed to query collection: ${collection}`, executionId, error);
      throw error;
    }
  }

  // ========================================================================
  // Service Record Operations
  // ========================================================================

  // Create service record (from original code)
  async createServiceRecord(userId, userName, email, reference, transactionType, details, amount, timestamp, executionId = 'create-service') {
    const config = TRANSACTION_TYPES[transactionType];
    if (!config) {
      throw new Error(`Unknown transaction type: ${transactionType}`);
    }

    logger.info(`Creating service record for ${transactionType}: ${reference}`, executionId);

    const baseRecord = {
      userId: userId,
      userName: userName,
      userEmail: email,
      amount: amount,
      reference: reference,
      status: "pending", // Payment status
      service_status: "pending", // Service fulfillment status (pending, processing, completed)
      time_created: timestamp,
      transactionType: config.transactionType,
      serviceType: config.serviceType
    };

    let serviceRecord;

    switch (transactionType) {
      case 'booking':
        serviceRecord = {
          ...baseRecord,
          bookingDetails: DataCleaners.cleanBookingDetails(details)
        };
        break;

      case 'food_order':
        // Process and clean the items array to ensure all required fields are present
        const processedItems = (details.items || []).map(item => ({
          id: item.id || '',
          name: item.name || '',
          description: item.description || '',
          price: typeof item.price === 'number' ? item.price : 0,
          quantity: typeof item.quantity === 'number' ? item.quantity : 1,
          imageUrl: item.imageUrl || '',
          restaurantId: item.restaurantId || '',
          restaurantName: item.restaurantName || '',
          category: item.category || '',
          preparationTime: item.preparationTime || '15-30 mins',
          ingredients: Array.isArray(item.ingredients) ? item.ingredients : [],
          totalPrice: typeof item.totalPrice === 'number' ? item.totalPrice : (item.price * item.quantity),
        }));

        serviceRecord = {
          ...baseRecord,
          customerId: userId,
          customerName: userName,
          items: processedItems,
          service_items: processedItems, // Legacy compatibility
          itemsCount: processedItems.length,
          subtotal: typeof details.subtotal === 'number' ? details.subtotal : amount,
          deliveryFee: typeof details.deliveryFee === 'number' ? details.deliveryFee : 500,
          tax: typeof details.tax === 'number' ? details.tax : 0,
          total: details.total || amount,
          deliverTo: (details.deliverTo && details.deliverTo.trim()) || "Room 101",
          specialInstructions: details.specialInstructions || '',
          orderSummary: {
            itemsCount: processedItems.length,
            subtotal: details.subtotal || amount,
            deliveryFee: details.deliveryFee || 500,
            tax: details.tax || 0,
            total: details.total || amount
          },
          createdAt: timestamp,
          updatedAt: timestamp,
        };
        break;

      case 'gym_session':
      case 'pool_session':
      case 'spa_session':
        serviceRecord = {
          ...baseRecord,
          sessionDetails: details,
          bookingDate: details.bookingDate,
          timeSlot: details.timeSlot,
          packageType: details.packageType,
          createdAt: timestamp,
        };
        break;

      case 'laundry_service':
        serviceRecord = {
          ...baseRecord,
          laundryDetails: details,
          items: details.items || [],
          pickupLocation: details.pickupLocation,
          deliveryLocation: details.deliveryLocation,
          specialInstructions: details.specialInstructions,
          createdAt: timestamp,
        };
        break;

      case 'concierge_request':
        serviceRecord = {
          ...baseRecord,
          requestDetails: details,
          requestType: details.requestType,
          description: details.description,
          priority: details.priority || 'normal',
          createdAt: timestamp,
        };
        break;

      default:
        serviceRecord = {
          ...baseRecord,
          details: details
        };
    }

    // Save to appropriate collection
    await this.setDocument(config.collectionName, reference, serviceRecord, true, executionId);

    logger.success(`Service record created: ${config.collectionName}/${reference}`, executionId);
    return serviceRecord;
  }

  // ========================================================================
  // Statistics and Analytics Helpers
  // ========================================================================

  // Update user statistics
  async updateUserStats(userId, updateData, executionId = 'update-stats') {
    try {
      const userRef = this.db.collection('users').doc(userId);
      await userRef.set({
        ...updateData,
        statsUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });

      logger.stats('UPDATE', `user-${userId}`, JSON.stringify(updateData), executionId);
    } catch (error) {
      logger.error(`Failed to update user stats for ${userId}`, executionId, error);
      throw error;
    }
  }

  // Increment field values
  async incrementField(collection, documentId, fieldUpdates, executionId = 'increment') {
    try {
      const updateData = {};

      for (const [field, value] of Object.entries(fieldUpdates)) {
        updateData[field] = admin.firestore.FieldValue.increment(value);
      }

      await this.updateDocument(collection, documentId, updateData, executionId);
      logger.stats('INCREMENT', `${collection}/${documentId}`, JSON.stringify(fieldUpdates), executionId);
    } catch (error) {
      logger.error(`Failed to increment fields in ${collection}/${documentId}`, executionId, error);
      throw error;
    }
  }

  // ========================================================================
  // Cart Operations
  // ========================================================================

  // Clear all cart items for a user
  async clearUserCart(userId, executionId = 'clear-cart') {
    try {
      logger.info(`Starting cart clear for user: ${userId}`, executionId);

      // Get all cart items for the user from: users/{userId}/cart_items
      const cartItemsRef = this.db.collection('users').doc(userId).collection('cart_items');
      logger.info(`Querying cart items at path: users/${userId}/cart_items`, executionId);

      const snapshot = await cartItemsRef.get();
      logger.info(`Cart query result: ${snapshot.size} items found`, executionId);

      if (snapshot.empty) {
        logger.info(`Cart already empty for user: ${userId}`, executionId);
        return { success: true, itemCount: 0 };
      }

      // Delete all cart items using batch operation for efficiency
      const batch = this.db.batch();
      let itemCount = 0;

      snapshot.forEach((doc) => {
        batch.delete(doc.ref);
        itemCount++;
      });

      logger.info(`Batch deletion prepared: ${itemCount} items queued for deletion`, executionId);

      // Commit the batch deletion
      await batch.commit();

      logger.success(`Cart cleared successfully for user: ${userId} - ${itemCount} items deleted`, executionId);
      return { success: true, itemCount };

    } catch (error) {
      logger.error(`Failed to clear cart for user: ${userId}`, executionId, error);
      return { success: false, error: error.message };
    }
  }

  // ========================================================================
  // Utility Helpers
  // ========================================================================

  // Get server timestamp
  getServerTimestamp() {
    return admin.firestore.FieldValue.serverTimestamp();
  }

  // Get field value for increment
  increment(value) {
    return admin.firestore.FieldValue.increment(value);
  }

  // Get field value for array union
  arrayUnion(...elements) {
    return admin.firestore.FieldValue.arrayUnion(...elements);
  }

  // Get field value for array remove
  arrayRemove(...elements) {
    return admin.firestore.FieldValue.arrayRemove(...elements);
  }
}

// Create default database helper instance
const dbHelper = new DatabaseHelper();

module.exports = {
  DatabaseHelper,
  dbHelper,
  get db() {
    return getFirestore();
  }
};
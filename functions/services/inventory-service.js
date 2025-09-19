// ========================================================================
// Inventory Service - Quantity and Availability Management
// ========================================================================

const admin = require('firebase-admin');
const { logger } = require('../utils/logger');
const { dbHelper } = require('../utils/database');
const { DatabaseValidators } = require('../utils/validation');

class InventoryService {
  constructor() {
    this.collections = {
      FOOD_ITEMS: 'food_items',
      AVAILABILITY_INDEX: 'availability_index',
      BOOKINGS: 'bookings',
      SERVICE_ORDERS: 'service_orders'
    };
  }

  // ========================================================================
  // Food Inventory Management
  // ========================================================================

  async deductFoodQuantities(orderReference, executionId = 'food-deduction') {
    logger.startFunction('deductFoodQuantities', executionId, { orderReference });

    try {
      // Get and validate order document
      const { orderData, orderedItems } = await this.getAndValidateOrder(orderReference, executionId);

      if (orderedItems.length === 0) {
        logger.warning('No items found in order for quantity deduction', executionId);
        return { success: false, reason: 'No items found' };
      }

      logger.processing(`Processing ${orderedItems.length} items for quantity deduction`, executionId);

      const result = await this.processItemQuantityDeductions(orderedItems, executionId);

      logger.endFunction('deductFoodQuantities', executionId, {
        processedItems: result.processedItems,
        skippedItems: result.skippedItems
      });

      return result;
    } catch (error) {
      logger.critical('CRITICAL ERROR in deductFoodQuantities', executionId, error, {
        orderReference: orderReference
      });
      return { success: false, error: error.message };
    }
  }

  async getAndValidateOrder(orderReference, executionId) {
    // Get the order document
    const { doc: orderDoc, data: orderData } = await dbHelper.getDocument(
      this.collections.SERVICE_ORDERS,
      orderReference,
      executionId
    );

    // Validate order document
    const validationResult = DatabaseValidators.validateOrderDocument(orderDoc, orderReference, executionId);

    // Validate it's a food order
    const orderedItems = DatabaseValidators.validateFoodOrder(validationResult.orderData, orderReference, executionId);

    return { orderData: validationResult.orderData, orderedItems };
  }

  async processItemQuantityDeductions(orderedItems, executionId) {
    const batch = dbHelper.createBatch();
    let processedItems = 0;
    let skippedItems = 0;
    const processedItemDetails = [];

    for (let i = 0; i < orderedItems.length; i++) {
      const item = orderedItems[i];
      logger.processing(`Processing item ${i + 1}/${orderedItems.length}`, executionId);

      const result = await this.processIndividualItem(item, batch, i + 1, executionId);

      if (result.success) {
        processedItems++;
        processedItemDetails.push(result.details);
      } else {
        skippedItems++;
      }
    }

    // Commit all quantity updates
    if (processedItems > 0) {
      logger.saving(`Committing ${processedItems} quantity updates`, executionId);
      await dbHelper.commitBatch(batch, processedItems, executionId);
      logger.success(`Successfully updated quantities for ${processedItems} food items`, executionId);
    } else {
      logger.warning('No items processed for quantity deduction', executionId);
    }

    return {
      success: true,
      processedItems,
      skippedItems,
      totalItems: orderedItems.length,
      processedItemDetails
    };
  }

  async processIndividualItem(item, batch, itemIndex, executionId) {
    const { itemId, quantity } = item;

    logger.info(`Item details - itemId: "${itemId}", quantity: ${quantity}`, executionId);

    // Validate item data
    if (!itemId) {
      logger.error(`Missing itemId for item ${itemIndex}`, executionId, null, { item });
      return { success: false, reason: 'Missing itemId' };
    }

    if (!quantity || quantity <= 0) {
      logger.error(`Invalid quantity for item ${itemIndex} (${itemId}): ${quantity}`, executionId);
      return { success: false, reason: 'Invalid quantity' };
    }

    try {
      // Get food item document
      const { doc: foodItemDoc, data: foodItemData } = await dbHelper.getDocument(
        this.collections.FOOD_ITEMS,
        itemId,
        executionId
      );

      if (!foodItemDoc) {
        logger.error(`Food item not found in database: ${itemId}`, executionId);
        return { success: false, reason: 'Food item not found' };
      }

      // Process quantity deduction
      const deductionResult = this.calculateQuantityDeduction(foodItemData, quantity, itemId, executionId);

      if (!deductionResult.shouldDeduct) {
        return { success: false, reason: deductionResult.reason };
      }

      // Add to batch update
      this.addItemUpdateToBatch(batch, itemId, deductionResult.updateData, executionId);

      return {
        success: true,
        details: {
          itemId,
          itemName: foodItemData.name || itemId,
          orderedQuantity: deductionResult.orderedQuantity,
          previousStock: deductionResult.currentQuantity,
          newStock: deductionResult.newQuantity,
          outOfStock: deductionResult.newQuantity === 0
        }
      };

    } catch (itemError) {
      logger.error(`Error processing item ${itemId}`, executionId, itemError);
      return { success: false, reason: 'Processing error', error: itemError.message };
    }
  }

  calculateQuantityDeduction(foodItemData, quantity, itemId, executionId) {
    const currentQuantity = foodItemData.quantity;

    logger.info(`Food item "${foodItemData.name || itemId}" stock analysis`, executionId, {
      availableFields: Object.keys(foodItemData),
      currentQuantity,
      isAvailable: foodItemData.isAvailable
    });

    // Check if item has quantity tracking (null = no tracking, skip deduction)
    if (currentQuantity === null || currentQuantity === undefined) {
      logger.info(`Skipping quantity deduction for "${foodItemData.name || itemId}": No quantity tracking enabled`, executionId);
      return { shouldDeduct: false, reason: 'No quantity tracking' };
    }

    // Check if there's a valid quantity field
    if (typeof currentQuantity !== 'number') {
      logger.error(`Quantity field is not a number for ${itemId}: ${currentQuantity} (${typeof currentQuantity})`, executionId);
      return { shouldDeduct: false, reason: 'Invalid quantity type' };
    }

    if (currentQuantity <= 0) {
      logger.warning(`Item ${itemId} already out of stock (quantity: ${currentQuantity})`, executionId);
      return { shouldDeduct: false, reason: 'Already out of stock' };
    }

    // Calculate new quantity (ensure it doesn't go below 0)
    const orderedQuantity = parseInt(quantity);
    const newQuantity = Math.max(0, currentQuantity - orderedQuantity);

    logger.info(`Quantity deduction calculation for "${foodItemData.name || itemId}"`, executionId, {
      ordered: orderedQuantity,
      currentStock: currentQuantity,
      newStock: newQuantity
    });

    // Prepare update data
    const updateData = {
      quantity: newQuantity,
      lastUpdated: dbHelper.getServerTimestamp(),
    };

    // If quantity reaches 0, mark as unavailable
    if (newQuantity === 0) {
      updateData.isAvailable = false;
      updateData.outOfStock = true;
      logger.warning('Item will be marked as out of stock', executionId);
    }

    return {
      shouldDeduct: true,
      updateData,
      orderedQuantity,
      currentQuantity,
      newQuantity
    };
  }

  addItemUpdateToBatch(batch, itemId, updateData, executionId) {
    dbHelper.batchUpdate(batch, this.collections.FOOD_ITEMS, itemId, updateData);
    logger.success(`Item queued for update: ${itemId}`, executionId);
  }

  // ========================================================================
  // Room Availability Management
  // ========================================================================

  async updateAvailabilityForSuccessfulBooking(reference, userId, executionId = 'room-availability') {
    logger.startFunction('updateAvailabilityForSuccessfulBooking', executionId, { reference, userId });

    try {
      // Get booking details
      const { doc: bookingDoc, data: bookingData } = await dbHelper.getDocument(
        this.collections.BOOKINGS,
        reference,
        executionId
      );

      if (!bookingDoc) {
        logger.error(`Booking document not found for availability update: ${reference}`, executionId);
        return { success: false, reason: 'Booking not found' };
      }

      const { bookingDetails } = bookingData;
      const { selectedRooms, checkInDate, checkOutDate } = bookingDetails || {};

      if (!selectedRooms || !checkInDate || !checkOutDate) {
        logger.error('Missing required booking details for availability update', executionId, null, {
          hasSelectedRooms: !!selectedRooms,
          hasCheckInDate: !!checkInDate,
          hasCheckOutDate: !!checkOutDate
        });
        return { success: false, reason: 'Missing booking details' };
      }

      const result = await this.processRoomAvailabilityUpdate(
        selectedRooms,
        checkInDate,
        checkOutDate,
        userId,
        executionId
      );

      logger.endFunction('updateAvailabilityForSuccessfulBooking', executionId, result);
      return result;

    } catch (error) {
      logger.error(`Failed to update availability for booking ${reference}`, executionId, error);
      return { success: false, error: error.message };
    }
  }

  async processRoomAvailabilityUpdate(selectedRooms, checkInDate, checkOutDate, userId, executionId) {
    logger.info('Processing room availability update', executionId, {
      checkIn: checkInDate,
      checkOut: checkOutDate,
      roomsCount: selectedRooms.length,
      roomIds: selectedRooms.map(r => r.id).join(', ')
    });

    const start = new Date(checkInDate);
    const end = new Date(checkOutDate);
    let totalDatesUpdated = 0;

    for (const room of selectedRooms) {
      logger.processing(`Processing room ${room.id} - ${room.name}`, executionId);

      const roomDatesUpdated = await this.updateRoomAvailabilityDates(
        room,
        start,
        end,
        checkInDate,
        checkOutDate,
        userId,
        executionId
      );

      totalDatesUpdated += roomDatesUpdated;
    }

    logger.success(`Availability update completed`, executionId, {
      totalDatesUpdated,
      roomsProcessed: selectedRooms.length
    });

    return {
      success: true,
      totalDatesUpdated,
      roomsProcessed: selectedRooms.length
    };
  }

  async updateRoomAvailabilityDates(room, start, end, checkInDate, checkOutDate, userId, executionId) {
    let current = new Date(start);
    let datesForRoom = 0;

    while (current <= end) {
      const dateStr = current.toISOString().split('T')[0];
      const checkInStr = new Date(checkInDate).toISOString().split('T')[0];
      const checkOutStr = new Date(checkOutDate).toISOString().split('T')[0];
      const bookingId = `${userId}_${room.id}_${checkInStr}_${checkOutStr}`;

      const bookingRef = {
        room_id: room.id.toString(),
        booking_id: bookingId,
        check_in: checkInStr,
        check_out: checkOutStr,
      };

      await dbHelper.setDocument(
        this.collections.AVAILABILITY_INDEX,
        dateStr,
        {
          date: dateStr,
          bookings: dbHelper.arrayUnion(bookingRef)
        },
        true,
        executionId
      );

      datesForRoom++;
      current.setDate(current.getDate() + 1);
    }

    logger.info(`Updated ${datesForRoom} dates for room ${room.id}`, executionId);
    return datesForRoom;
  }

  // ========================================================================
  // Inventory Queries and Management
  // ========================================================================

  async getFoodItemStock(itemId, executionId = 'get-stock') {
    try {
      const { data: itemData } = await dbHelper.getDocument(this.collections.FOOD_ITEMS, itemId, executionId);

      if (!itemData) {
        return null;
      }

      return {
        itemId,
        name: itemData.name,
        quantity: itemData.quantity,
        isAvailable: itemData.isAvailable,
        outOfStock: itemData.outOfStock || false,
        hasQuantityTracking: itemData.quantity !== null && itemData.quantity !== undefined,
        lastUpdated: itemData.lastUpdated
      };
    } catch (error) {
      logger.error(`Failed to get stock for item ${itemId}`, executionId, error);
      return null;
    }
  }

  async getLowStockItems(threshold = 5, executionId = 'low-stock') {
    try {
      const lowStockItems = await dbHelper.queryDocuments(
        this.collections.FOOD_ITEMS,
        [
          { field: 'quantity', operator: '<=', value: threshold },
          { field: 'quantity', operator: '>', value: 0 }
        ],
        { field: 'quantity', direction: 'asc' },
        null,
        executionId
      );

      logger.success(`Found ${lowStockItems.length} items with low stock (≤ ${threshold})`, executionId);
      return lowStockItems.map(item => ({
        itemId: item.id,
        ...item.data,
        stockLevel: 'low'
      }));
    } catch (error) {
      logger.error('Failed to get low stock items', executionId, error);
      return [];
    }
  }

  async getOutOfStockItems(executionId = 'out-of-stock') {
    try {
      const outOfStockItems = await dbHelper.queryDocuments(
        this.collections.FOOD_ITEMS,
        [
          { field: 'quantity', operator: '==', value: 0 }
        ],
        { field: 'lastUpdated', direction: 'desc' },
        null,
        executionId
      );

      logger.success(`Found ${outOfStockItems.length} out of stock items`, executionId);
      return outOfStockItems.map(item => ({
        itemId: item.id,
        ...item.data,
        stockLevel: 'out'
      }));
    } catch (error) {
      logger.error('Failed to get out of stock items', executionId, error);
      return [];
    }
  }

  async restockItem(itemId, newQuantity, restockedBy = 'system', executionId = 'restock') {
    try {
      const updateData = {
        quantity: newQuantity,
        isAvailable: newQuantity > 0,
        outOfStock: newQuantity === 0,
        lastRestocked: dbHelper.getServerTimestamp(),
        restockedBy: restockedBy,
        lastUpdated: dbHelper.getServerTimestamp()
      };

      await dbHelper.updateDocument(this.collections.FOOD_ITEMS, itemId, updateData, executionId);

      logger.success(`Item restocked: ${itemId} -> ${newQuantity} units`, executionId);
      return { success: true, newQuantity };
    } catch (error) {
      logger.error(`Failed to restock item ${itemId}`, executionId, error);
      return { success: false, error: error.message };
    }
  }

  // ========================================================================
  // Room Availability Queries
  // ========================================================================

  async checkRoomAvailability(roomId, startDate, endDate, executionId = 'check-availability') {
    try {
      const start = new Date(startDate);
      const end = new Date(endDate);
      const unavailableDates = [];

      let current = new Date(start);
      while (current <= end) {
        const dateStr = current.toISOString().split('T')[0];

        const { data: availabilityData } = await dbHelper.getDocument(
          this.collections.AVAILABILITY_INDEX,
          dateStr,
          executionId
        );

        if (availabilityData && availabilityData.bookings) {
          const roomBookings = availabilityData.bookings.filter(
            booking => booking.room_id === roomId.toString()
          );

          if (roomBookings.length > 0) {
            unavailableDates.push({
              date: dateStr,
              bookings: roomBookings
            });
          }
        }

        current.setDate(current.getDate() + 1);
      }

      const isAvailable = unavailableDates.length === 0;

      logger.info(`Room availability check for ${roomId}`, executionId, {
        period: `${startDate} to ${endDate}`,
        isAvailable,
        conflictDates: unavailableDates.length
      });

      return {
        roomId,
        isAvailable,
        unavailableDates,
        period: { startDate, endDate }
      };
    } catch (error) {
      logger.error(`Failed to check room availability for ${roomId}`, executionId, error);
      return { roomId, isAvailable: false, error: error.message };
    }
  }

  async getBookingsForDate(date, executionId = 'get-bookings-date') {
    try {
      const { data: availabilityData } = await dbHelper.getDocument(
        this.collections.AVAILABILITY_INDEX,
        date,
        executionId
      );

      if (!availabilityData || !availabilityData.bookings) {
        return [];
      }

      logger.success(`Found ${availabilityData.bookings.length} bookings for ${date}`, executionId);
      return availabilityData.bookings;
    } catch (error) {
      logger.error(`Failed to get bookings for date ${date}`, executionId, error);
      return [];
    }
  }

  // ========================================================================
  // Utility Methods
  // ========================================================================

  async getInventorySummary(executionId = 'inventory-summary') {
    try {
      const [lowStockItems, outOfStockItems] = await Promise.all([
        this.getLowStockItems(5, executionId),
        this.getOutOfStockItems(executionId)
      ]);

      const summary = {
        lowStockCount: lowStockItems.length,
        outOfStockCount: outOfStockItems.length,
        lowStockItems: lowStockItems.slice(0, 10), // Top 10 low stock items
        outOfStockItems: outOfStockItems.slice(0, 10), // Top 10 out of stock items
        lastUpdated: new Date().toISOString()
      };

      logger.success('Inventory summary generated', executionId, {
        lowStock: summary.lowStockCount,
        outOfStock: summary.outOfStockCount
      });

      return summary;
    } catch (error) {
      logger.error('Failed to generate inventory summary', executionId, error);
      return null;
    }
  }

  formatStockLevel(quantity) {
    if (quantity === null || quantity === undefined) return 'No tracking';
    if (quantity === 0) return 'Out of stock';
    if (quantity <= 5) return 'Low stock';
    if (quantity <= 20) return 'Medium stock';
    return 'Good stock';
  }

  calculateStockValue(items, priceField = 'price') {
    return items.reduce((total, item) => {
      const quantity = item.quantity || 0;
      const price = item[priceField] || 0;
      return total + (quantity * price);
    }, 0);
  }
}

// Create default inventory service instance
const inventoryService = new InventoryService();

module.exports = {
  InventoryService,
  inventoryService
};
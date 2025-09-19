// ========================================================================
// Statistics Service - Analytics and Tracking
// ========================================================================

const admin = require('firebase-admin');
const { logger } = require('../utils/logger');
const { dbHelper } = require('../utils/database');

class StatisticsService {
  constructor() {
    this.monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  }

  // ========================================================================
  // Monthly Statistics
  // ========================================================================

  async updateMonthlyBookingStats(bookingAmount, executionId = 'monthly-stats') {
    try {
      logger.stats('UPDATE', 'monthly-booking-stats', bookingAmount, executionId);

      // Get current date information
      const now = new Date();
      const currentMonth = this.monthNames[now.getMonth()];
      const currentYear = now.getFullYear();
      const monthIndex = now.getMonth();

      // Create document ID in YYYY-MM format for consistent ordering
      const docId = `${currentYear}-${monthIndex.toString().padStart(2, '0')}`;

      logger.info(`Updating monthly stats for document: ${docId} (${currentMonth} ${currentYear})`, executionId);

      // Prepare month data structure
      const monthData = {
        month: currentMonth,
        monthIndex: monthIndex,
        revenue: dbHelper.increment(bookingAmount),
        bookings: dbHelper.increment(1),
        date: `${currentMonth} ${currentYear}`,
        lastUpdated: dbHelper.getServerTimestamp(),
        year: currentYear
      };

      // Update or create monthly document
      await dbHelper.setDocument('total_bookings', docId, monthData, true, executionId);

      logger.success(`Monthly stats updated: +1 booking, +₦${bookingAmount} revenue for ${currentMonth} ${currentYear}`, executionId);

    } catch (error) {
      logger.error('Failed to update monthly booking stats', executionId, error, {
        bookingAmount: bookingAmount
      });
    }
  }

  async getMonthlyStats(year = null, month = null, executionId = 'get-monthly-stats') {
    try {
      let query = [];

      if (year) {
        query.push({ field: 'year', operator: '==', value: year });
      }

      if (month !== null) {
        query.push({ field: 'monthIndex', operator: '==', value: month });
      }

      const orderBy = { field: 'monthIndex', direction: 'asc' };
      const stats = await dbHelper.queryDocuments('total_bookings', query, orderBy, null, executionId);

      logger.success(`Retrieved ${stats.length} monthly stats records`, executionId);
      return stats;
    } catch (error) {
      logger.error('Failed to get monthly stats', executionId, error);
      return [];
    }
  }

  async getYearlyStats(year, executionId = 'yearly-stats') {
    try {
      const monthlyStats = await this.getMonthlyStats(year, null, executionId);

      const yearlyData = {
        year: year,
        totalRevenue: 0,
        totalBookings: 0,
        monthlyBreakdown: monthlyStats,
        averageMonthlyRevenue: 0,
        averageMonthlyBookings: 0
      };

      // Calculate totals
      monthlyStats.forEach(month => {
        yearlyData.totalRevenue += month.data.revenue || 0;
        yearlyData.totalBookings += month.data.bookings || 0;
      });

      // Calculate averages
      const monthCount = monthlyStats.length || 1;
      yearlyData.averageMonthlyRevenue = yearlyData.totalRevenue / monthCount;
      yearlyData.averageMonthlyBookings = yearlyData.totalBookings / monthCount;

      logger.success(`Calculated yearly stats for ${year}`, executionId, {
        totalRevenue: yearlyData.totalRevenue,
        totalBookings: yearlyData.totalBookings
      });

      return yearlyData;
    } catch (error) {
      logger.error(`Failed to get yearly stats for ${year}`, executionId, error);
      return null;
    }
  }

  // ========================================================================
  // Booking Statistics
  // ========================================================================

  async updateBookingStats(reference, executionId = 'booking-stats') {
    try {
      logger.stats('UPDATE', 'booking-stats', reference, executionId);

      // Get booking details
      const { doc: bookingDoc, data: bookingData } = await dbHelper.getDocument('bookings', reference, executionId);
      if (!bookingDoc) {
        logger.error(`Booking document not found for stats update: ${reference}`, executionId);
        return;
      }

      const { bookingDetails, userId, amount } = bookingData;
      const { selectedRooms } = bookingDetails || {};

      if (!selectedRooms || !Array.isArray(selectedRooms)) {
        logger.error(`No selected rooms found in booking: ${reference}`, executionId);
        return;
      }

      // Extract room types
      const roomTypes = this.extractRoomTypes(selectedRooms, executionId);
      const uniqueRoomTypes = [...new Set(roomTypes)];

      // Convert amount to number if it's a string
      const bookingAmount = typeof amount === 'string' ? parseFloat(amount) : (amount || 0);

      logger.info(`Processing booking stats`, executionId, {
        roomTypes: uniqueRoomTypes,
        userId: userId,
        amount: bookingAmount
      });

      // Update overall booking statistics
      await this.updateOverallStats(executionId);

      // Update room type statistics
      await this.updateRoomTypeStats(uniqueRoomTypes, executionId);

      // Update user-specific statistics
      if (userId) {
        await this.updateUserStats(userId, bookingAmount, executionId);
      }

      // Update monthly statistics
      await this.updateMonthlyBookingStats(bookingAmount, executionId);

      logger.success(`All booking stats updates completed for: ${reference}`, executionId);

    } catch (error) {
      logger.error(`Failed to update booking stats for ${reference}`, executionId, error);
    }
  }

  extractRoomTypes(selectedRooms, executionId) {
    const roomTypes = selectedRooms.map(room => {
      const type = room.category || room.type || room.roomType || room.roomCategory;
      if (!type) {
        logger.warning(`No room type found for room`, executionId, { room: room });
      }
      return type;
    }).filter(type => type);

    return roomTypes;
  }

  async updateOverallStats(executionId = 'overall-stats') {
    try {
      await dbHelper.setDocument('rooms_and_users_stat', 'stats', {
        totalBookings: dbHelper.increment(1),
        lastUpdated: dbHelper.getServerTimestamp(),
      }, true, executionId);

      logger.success('Overall booking stats updated', executionId);
    } catch (error) {
      logger.error('Failed to update overall stats', executionId, error);
    }
  }

  async updateRoomTypeStats(roomTypes, executionId = 'room-type-stats') {
    try {
      if (roomTypes.length === 0) {
        logger.warning('No room types to update stats for', executionId);
        return;
      }

      const batch = dbHelper.createBatch();

      // Update stats for each unique room type
      roomTypes.forEach(roomType => {
        const roomStatsRef = dbHelper.db.collection('rooms_and_users_stat').doc(roomType);
        dbHelper.batchSet(batch, 'rooms_and_users_stat', roomType, {
          totalBookings: dbHelper.increment(1),
          lastUpdated: dbHelper.getServerTimestamp(),
          roomType: roomType
        }, true);
      });

      await dbHelper.commitBatch(batch, roomTypes.length, executionId);
      logger.success(`Room type stats updated for: ${roomTypes.join(', ')}`, executionId);
    } catch (error) {
      logger.error('Failed to update room type stats', executionId, error);
    }
  }

  // ========================================================================
  // User Statistics
  // ========================================================================

  async updateUserStats(userId, bookingAmount, executionId = 'user-stats') {
    try {
      logger.stats('UPDATE', `user-${userId}`, bookingAmount, executionId);

      const updateData = {
        totalBookings: dbHelper.increment(1),
        lastBookingDate: dbHelper.getServerTimestamp(),
        statsUpdatedAt: dbHelper.getServerTimestamp(),
      };

      if (bookingAmount > 0) {
        updateData.totalAmountSpent = dbHelper.increment(bookingAmount);
      } else {
        // Initialize totalAmountSpent if not updating it
        updateData.totalAmountSpent = dbHelper.increment(0);
      }

      await dbHelper.setDocument('users', userId, updateData, true, executionId);

      logger.success(`User stats updated: +1 booking, +₦${bookingAmount}`, executionId);
    } catch (error) {
      logger.error(`Failed to update user stats for ${userId}`, executionId, error);
    }
  }

  async getUserStats(userId, executionId = 'get-user-stats') {
    try {
      const { data: userData } = await dbHelper.getDocument('users', userId, executionId);

      if (!userData) {
        return null;
      }

      const userStats = {
        userId: userId,
        totalBookings: userData.totalBookings || 0,
        totalAmountSpent: userData.totalAmountSpent || 0,
        lastBookingDate: userData.lastBookingDate,
        statsUpdatedAt: userData.statsUpdatedAt,
        memberSince: userData.createdAt || userData.joinDate,
        averageBookingValue: 0
      };

      // Calculate average booking value
      if (userStats.totalBookings > 0) {
        userStats.averageBookingValue = userStats.totalAmountSpent / userStats.totalBookings;
      }

      logger.success(`Retrieved user stats for ${userId}`, executionId);
      return userStats;
    } catch (error) {
      logger.error(`Failed to get user stats for ${userId}`, executionId, error);
      return null;
    }
  }

  async getTopUsers(limit = 10, orderBy = 'totalAmountSpent', executionId = 'top-users') {
    try {
      const topUsers = await dbHelper.queryDocuments('users',
        [{ field: 'totalBookings', operator: '>', value: 0 }],
        { field: orderBy, direction: 'desc' },
        limit,
        executionId
      );

      logger.success(`Retrieved top ${topUsers.length} users by ${orderBy}`, executionId);
      return topUsers;
    } catch (error) {
      logger.error(`Failed to get top users`, executionId, error);
      return [];
    }
  }

  // ========================================================================
  // Service Statistics
  // ========================================================================

  async updateServiceStats(serviceType, amount, executionId = 'service-stats') {
    try {
      logger.stats('UPDATE', `service-${serviceType}`, amount, executionId);

      const serviceStatsData = {
        totalOrders: dbHelper.increment(1),
        totalRevenue: dbHelper.increment(amount),
        lastOrderDate: dbHelper.getServerTimestamp(),
        serviceType: serviceType
      };

      await dbHelper.setDocument('service_stats', serviceType, serviceStatsData, true, executionId);

      // Also update overall service statistics
      await dbHelper.setDocument('service_stats', 'overall', {
        totalOrders: dbHelper.increment(1),
        totalRevenue: dbHelper.increment(amount),
        lastUpdated: dbHelper.getServerTimestamp()
      }, true, executionId);

      logger.success(`Service stats updated for ${serviceType}: +1 order, +₦${amount}`, executionId);
    } catch (error) {
      logger.error(`Failed to update service stats for ${serviceType}`, executionId, error);
    }
  }

  async getServiceStats(serviceType = null, executionId = 'get-service-stats') {
    try {
      if (serviceType) {
        const { data } = await dbHelper.getDocument('service_stats', serviceType, executionId);
        return data;
      } else {
        const allStats = await dbHelper.queryDocuments('service_stats', [], null, null, executionId);
        return allStats;
      }
    } catch (error) {
      logger.error(`Failed to get service stats`, executionId, error);
      return null;
    }
  }

  // ========================================================================
  // Dashboard Analytics
  // ========================================================================

  async getDashboardStats(executionId = 'dashboard-stats') {
    try {
      logger.info('Generating dashboard statistics', executionId);

      // Get overall booking stats
      const { data: overallStats } = await dbHelper.getDocument('rooms_and_users_stat', 'stats', executionId);

      // Get current month stats
      const currentDate = new Date();
      const currentYear = currentDate.getFullYear();
      const currentMonth = currentDate.getMonth();
      const currentMonthStats = await this.getMonthlyStats(currentYear, currentMonth, executionId);

      // Get overall service stats
      const { data: serviceStats } = await dbHelper.getDocument('service_stats', 'overall', executionId);

      // Get top room types
      const topRoomTypes = await dbHelper.queryDocuments('rooms_and_users_stat',
        [{ field: 'totalBookings', operator: '>', value: 0 }],
        { field: 'totalBookings', direction: 'desc' },
        5,
        executionId
      );

      const dashboardData = {
        overview: {
          totalBookings: overallStats?.totalBookings || 0,
          totalServiceOrders: serviceStats?.totalOrders || 0,
          currentMonthRevenue: currentMonthStats.length > 0 ? currentMonthStats[0].data.revenue : 0,
          currentMonthBookings: currentMonthStats.length > 0 ? currentMonthStats[0].data.bookings : 0,
          lastUpdated: new Date().toISOString()
        },
        topRoomTypes: topRoomTypes.map(room => ({
          roomType: room.data.roomType,
          totalBookings: room.data.totalBookings,
          lastUpdated: room.data.lastUpdated
        })),
        monthlyTrend: await this.getMonthlyStats(currentYear, null, executionId)
      };

      logger.success('Dashboard statistics generated', executionId);
      return dashboardData;
    } catch (error) {
      logger.error('Failed to generate dashboard stats', executionId, error);
      return null;
    }
  }

  // ========================================================================
  // Revenue Analytics
  // ========================================================================

  async getRevenueAnalytics(startDate, endDate, executionId = 'revenue-analytics') {
    try {
      logger.info(`Generating revenue analytics from ${startDate} to ${endDate}`, executionId);

      // For now, we'll work with monthly aggregations
      // In the future, this could be enhanced for daily/weekly analytics
      const start = new Date(startDate);
      const end = new Date(endDate);

      const startYear = start.getFullYear();
      const endYear = end.getFullYear();

      const revenueData = {
        totalRevenue: 0,
        totalBookings: 0,
        periodStart: startDate,
        periodEnd: endDate,
        monthlyBreakdown: []
      };

      // Get stats for each year in the range
      for (let year = startYear; year <= endYear; year++) {
        const yearlyStats = await this.getMonthlyStats(year, null, executionId);

        yearlyStats.forEach(monthStat => {
          const monthDate = new Date(year, monthStat.data.monthIndex, 1);

          if (monthDate >= start && monthDate <= end) {
            revenueData.totalRevenue += monthStat.data.revenue || 0;
            revenueData.totalBookings += monthStat.data.bookings || 0;
            revenueData.monthlyBreakdown.push(monthStat.data);
          }
        });
      }

      // Calculate averages
      const monthCount = revenueData.monthlyBreakdown.length || 1;
      revenueData.averageMonthlyRevenue = revenueData.totalRevenue / monthCount;
      revenueData.averageMonthlyBookings = revenueData.totalBookings / monthCount;

      logger.success('Revenue analytics generated', executionId, {
        totalRevenue: revenueData.totalRevenue,
        totalBookings: revenueData.totalBookings
      });

      return revenueData;
    } catch (error) {
      logger.error('Failed to generate revenue analytics', executionId, error);
      return null;
    }
  }

  // ========================================================================
  // Utility Methods
  // ========================================================================

  async resetUserStats(userId, executionId = 'reset-user-stats') {
    try {
      await dbHelper.updateDocument('users', userId, {
        totalBookings: 0,
        totalAmountSpent: 0,
        lastBookingDate: null,
        statsUpdatedAt: dbHelper.getServerTimestamp()
      }, executionId);

      logger.success(`User stats reset for ${userId}`, executionId);
      return true;
    } catch (error) {
      logger.error(`Failed to reset user stats for ${userId}`, executionId, error);
      return false;
    }
  }

  async recalculateAllStats(executionId = 'recalculate-stats') {
    try {
      logger.processing('Starting complete stats recalculation', executionId);

      // This is a heavy operation that should be run carefully
      // Get all bookings and recalculate stats from scratch
      const allBookings = await dbHelper.queryDocuments('bookings', [], null, null, executionId);

      logger.info(`Recalculating stats for ${allBookings.length} bookings`, executionId);

      let processedCount = 0;
      for (const booking of allBookings) {
        try {
          await this.updateBookingStats(booking.id, `${executionId}-${booking.id}`);
          processedCount++;

          if (processedCount % 10 === 0) {
            logger.info(`Processed ${processedCount}/${allBookings.length} bookings`, executionId);
          }
        } catch (error) {
          logger.error(`Failed to recalculate stats for booking ${booking.id}`, executionId, error);
        }
      }

      logger.success(`Stats recalculation completed: ${processedCount}/${allBookings.length} successful`, executionId);
      return { processed: processedCount, total: allBookings.length };
    } catch (error) {
      logger.error('Failed to recalculate all stats', executionId, error);
      return null;
    }
  }

  formatCurrency(amount, currency = 'NGN') {
    return `${currency} ${amount.toLocaleString()}`;
  }

  calculateGrowthRate(current, previous) {
    if (previous === 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }
}

// Create default statistics service instance
const statisticsService = new StatisticsService();

module.exports = {
  StatisticsService,
  statisticsService
};
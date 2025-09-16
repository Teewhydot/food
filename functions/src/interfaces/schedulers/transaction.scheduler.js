const { onSchedule } = require('firebase-functions/v2/scheduler');

class TransactionScheduler {
  constructor(transactionService) {
    this.transactionService = transactionService;
  }

  verifyPendingTransactions() {
    return onSchedule(
      {
        schedule: 'every 1 minutes',
        timeZone: 'UTC',
        region: 'us-central1',
        timeoutSeconds: 540,
        memory: '1GB'
      },
      async (event) => {
        try {
          console.log('Starting to verify pending transactions...');
          await this.transactionService.processPendingTransactions();
          console.log('Completed verifying pending transactions');
          return null;
        } catch (error) {
          console.error('Error in verifyPendingTransactions:', error);
          throw error;
        }
      }
    );
  }

  cleanupOldTransactions() {
    return onSchedule(
      {
        schedule: 'every 24 hours',
        timeZone: 'UTC',
        region: 'us-central1'
      },
      async (event) => {
        try {
          console.log('Starting to clean up old transactions...');
          // Implement cleanup logic here
          console.log('Completed cleaning up old transactions');
          return null;
        } catch (error) {
          console.error('Error in cleanupOldTransactions:', error);
          throw error;
        }
      }
    );
  }
}

module.exports = TransactionScheduler;

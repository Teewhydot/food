const { onRequest } = require('firebase-functions/v2/https');
const cors = require('cors')({ origin: true });

class TransactionController {
  constructor(transactionService) {
    this.transactionService = transactionService;
  }

  createTransaction() {
    return onRequest(
      { region: 'us-central1', timeoutSeconds: 560, memory: '256MB' },
      async (req, res) => {
        return cors(req, res, async () => {
          try {
            const { amount, userId, email, bookingDetails, userName, transactionType } = req.body;
            
            if (!amount || !userId || !email) {
              return res.status(400).json({ 
                success: false, 
                message: 'Missing required fields' 
              });
            }

            const result = await this.transactionService.createTransaction({
              amount,
              userId,
              email,
              bookingDetails,
              userName,
              transactionType
            });

            res.status(200).json({ 
              success: true, 
              data: result 
            });
          } catch (error) {
            console.error('Error creating transaction:', error);
            res.status(500).json({ 
              success: false, 
              message: 'Failed to create transaction',
              error: error.message 
            });
          }
        });
      }
    );
  }

  handleWebhook() {
    return onRequest(
      { region: 'us-central1', timeoutSeconds: 60, memory: '256MB' },
      async (req, res) => {
        return cors(req, res, async () => {
          try {
            // Handle raw body for webhook verification
            let event = req.body;
            
            // If body is empty, try to parse it manually
            if (!req.body || Object.keys(req.body).length === 0) {
              let data = '';
              req.on('data', chunk => { data += chunk; });
              
              await new Promise((resolve) => {
                req.on('end', () => {
                  try {
                    event = JSON.parse(data);
                    resolve();
                  } catch (e) {
                    console.error("Failed to parse webhook body:", e);
                    res.status(400).json({ success: false, message: 'Invalid JSON' });
                  }
                });
              });
            }

            // Process the webhook event
            const result = await this.transactionService.handleWebhookEvent(event);
            
            if (result.processed === false) {
              return res.status(200).json({ success: true, message: 'Webhook received but not processed' });
            }
            
            res.status(200).json({ success: true, message: 'Webhook processed successfully' });
          } catch (error) {
            console.error('Error processing webhook:', error);
            res.status(500).json({ 
              success: false, 
              message: 'Failed to process webhook',
              error: error.message 
            });
          }
        });
      }
    );
  }
}

module.exports = TransactionController;

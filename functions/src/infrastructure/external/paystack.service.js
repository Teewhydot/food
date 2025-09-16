const axios = require('axios');

class PaystackService {
  constructor(apiKey) {
    this.axios = axios.create({
      baseURL: 'https://api.paystack.co',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      }
    });
  }

  async initializeTransaction({ email, amount, reference, metadata = {} }) {
    try {
      const response = await this.axios.post('/transaction/initialize', {
        email,
        amount: amount * 100, // Convert to kobo
        reference,
        metadata
      });
      
      return response.data;
    } catch (error) {
      console.error('Paystack initialization error:', error.response?.data || error.message);
      throw new Error('Failed to initialize Paystack transaction');
    }
  }

  async verifyTransaction(reference) {
    try {
      const response = await this.axios.get(`/transaction/verify/${reference}`);
      return response.data;
    } catch (error) {
      console.error('Paystack verification error:', error.response?.data || error.message);
      throw new Error('Failed to verify Paystack transaction');
    }
  }

  static validateWebhookSignature(signature, secret, requestBody) {
    const crypto = require('crypto');
    const hash = crypto
      .createHmac('sha512', secret)
      .update(JSON.stringify(requestBody))
      .digest('hex');
    return hash === signature;
  }
}

module.exports = PaystackService;

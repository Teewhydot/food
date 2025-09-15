const axios = require('axios');
const { PAYSTACK_SECRET_KEY } = require('../config/constants');

async function initializeTransaction(email, amount, metadata) {
  const response = await axios.post(
    'https://api.paystack.co/transaction/initialize',
    {
      email: email,
      amount: amount * 100,
      metadata: metadata,
    },
    {
      headers: {
        Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
        'Content-Type': 'application/json',
      },
    }
  );
  
  return response.data;
}

async function verifyTransaction(reference) {
  const response = await axios.get(
    `https://api.paystack.co/transaction/verify/${reference}`,
    {
      headers: {
        Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
        'Content-Type': 'application/json',
      },
    }
  );
  
  return response.data;
}

function validateWebhookSignature(event, signature) {
  const crypto = require('crypto');
  const hash = crypto
    .createHmac("sha512", PAYSTACK_SECRET_KEY)
    .update(JSON.stringify(event))
    .digest("hex");
  
  return hash === signature;
}

module.exports = {
  initializeTransaction,
  verifyTransaction,
  validateWebhookSignature
};
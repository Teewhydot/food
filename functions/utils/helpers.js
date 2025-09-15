const { GoogleAuth } = require('google-auth-library');
const admin = require('firebase-admin');
const { PROJECT_ID, SUPPORT_EMAIL, SUPPORT_PHONE, HOTEL_LOCATION } = require('../config/constants');
const { generateQRCodeBuffer } = require('./qrcode');

async function getAccessToken() {
  try {
    const SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];
    const auth = new GoogleAuth({ scopes: SCOPES });
    const client = await auth.getClient();
    const tokenResponse = await client.getAccessToken();

    if (!tokenResponse || !tokenResponse.token) {
      throw new Error('Failed to obtain access token');
    }

    return tokenResponse.token;
  } catch (error) {
    console.error('Error getting access token:', error);
    
    // Fallback method
    try {
      const token = await admin.credential.applicationDefault().getAccessToken();
      return token.access_token;
    } catch (altError) {
      console.error('Alternative method also failed:', altError);
      throw error;
    }
  }
}

function generateHTMLEmailTemplate(content) {
  // Implementation from original code
  // ... (copy the full function implementation)
}

async function generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt) {
  // Implementation from original code
  // ... (copy the full function implementation)
}

function generateNotificationData(transactionType, details, reference, amount, isSuccess = false) {
  // Implementation from original code
  // ... (copy the full function implementation)
}

module.exports = {
  getAccessToken,
  generateHTMLEmailTemplate,
  generateEnhancedSuccessEmail,
  generateNotificationData
};
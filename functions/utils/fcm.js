const admin = require('firebase-admin');
const axios = require('axios');
const { getAccessToken } = require('./helpers');
const { PROJECT_ID } = require('../config/constants');

async function sendFCMNotification(token, title, body, data = {}) {
  try {
    const serverKey = await getAccessToken();
    const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`;

    // Ensure all data values are strings
    const stringifiedData = {};
    for (const [key, value] of Object.entries(data)) {
      stringifiedData[key] = String(value);
    }

    const message = {
      message: {
        token: token,
        notification: { title, body },
        data: stringifiedData,
      }
    };

    const response = await axios.post(fcmEndpoint, message, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${serverKey}`,
      },
    });

    console.log('FCM message sent successfully');
    return response.data;
  } catch (error) {
    console.error('Failed to send FCM message:', error);
    throw error;
  }
}

async function getFCMTokenForUser(userId, db) {
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) {
    throw new Error('User not found');
  }

  const userData = userDoc.data();
  return userData.token || userData.fcmToken;
}

module.exports = {
  sendFCMNotification,
  getFCMTokenForUser
};
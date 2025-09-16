const nodemailer = require('nodemailer');
const { getAccessToken } = require('firebase-admin/app');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

class NotificationService {
  constructor(config) {
    this.emailConfig = config.email;
    this.fcmConfig = config.fcm;
    this.initializeEmailTransport();
    this.initializeFirebase();
  }

  initializeEmailTransport() {
    this.transporter = nodemailer.createTransport({
      host: this.emailConfig.host,
      port: this.emailConfig.port,
      secure: this.emailConfig.secure,
      auth: {
        user: this.emailConfig.auth.user,
        pass: this.emailConfig.auth.pass
      }
    });
  }

  initializeFirebase() {
    if (this.fcmConfig) {
      this.firebaseApp = initializeApp({
        credential: this.fcmConfig.credential,
        databaseURL: this.fcmConfig.databaseURL
      }, 'notification-service');
    }
  }

  async sendEmail({ to, subject, text, html }) {
    try {
      const mailOptions = {
        from: `"${this.emailConfig.from.name}" <${this.emailConfig.from.email}>`,
        to,
        subject,
        text,
        html
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Email sent:', info.messageId);
      return info;
    } catch (error) {
      console.error('Error sending email:', error);
      throw error;
    }
  }

  async sendPushNotification({ userId, title, body, data = {} }) {
    if (!this.fcmConfig) {
      console.warn('FCM not configured, skipping push notification');
      return null;
    }

    try {
      // Get FCM tokens for the user from your database
      const tokens = await this.getUserFcmTokens(userId);
      if (!tokens.length) return null;

      const message = {
        notification: { title, body },
        data,
        tokens // Send to multiple tokens for the user
      };

      const response = await getMessaging(this.firebaseApp).sendMulticast(message);
      
      // Clean up invalid tokens
      await this.cleanupInvalidTokens(userId, response.responses, tokens);
      
      return response;
    } catch (error) {
      console.error('Error sending push notification:', error);
      throw error;
    }
  }

  async getUserFcmTokens(userId) {
    // Implement logic to get FCM tokens for the user from your database
    // This is a placeholder - replace with your actual implementation
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    return userDoc.data()?.fcmTokens || [];
  }

  async cleanupInvalidTokens(userId, responses, sentTokens) {
    const invalidTokens = [];
    responses.forEach((response, idx) => {
      if (!response.success && response.error?.code === 'messaging/invalid-registration-token') {
        invalidTokens.push(sentTokens[idx]);
      }
    });

    if (invalidTokens.length > 0) {
      // Remove invalid tokens from user's FCM tokens
      await admin.firestore().collection('users').doc(userId).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens)
      });
    }
  }
}

module.exports = NotificationService;

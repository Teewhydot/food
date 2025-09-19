// ========================================================================
// Email Service - Templates, Generation and Sending
// ========================================================================

const nodemailer = require('nodemailer');
const QRCode = require('qrcode');
const { ENVIRONMENT, CONTACT_INFO, TRANSACTION_TYPES, EMAIL_STYLES } = require('../utils/constants');
const { logger } = require('../utils/logger');

// Configure the email transport using Nodemailer
const transporter = nodemailer.createTransport({
  host: 'mail.cyrextech.org',
  port: 587,
  secure: false,
  auth: {
    user: 'no-reply@cyrextech.org',
    pass: ENVIRONMENT.GMAIL_PASSWORD,
  },
});

class EmailService {
  constructor() {
    this.transporter = transporter;
    this.defaultFrom = '"FMH Hotel" <no-reply@cyrextech.org>';
  }

  // ========================================================================
  // QR Code Generation
  // ========================================================================

  async generateQRCodeBuffer(data) {
    try {
      const qrDataString = typeof data === 'object'
        ? Object.entries(data).map(([key, value]) => `${key}:${value}`).join('\n')
        : data;

      const qrCodeBuffer = await QRCode.toBuffer(qrDataString, {
        errorCorrectionLevel: 'M',
        type: 'png',
        quality: 0.92,
        margin: 1,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        },
        width: 200
      });

      return qrCodeBuffer;
    } catch (error) {
      logger.error('Error generating QR code', 'qr-generation', error);
      return null;
    }
  }

  // ========================================================================
  // HTML Email Template Generation
  // ========================================================================

  generateHTMLEmailTemplate(content) {
    const {
      title,
      headerColor = EMAIL_STYLES.HEADER_COLOR,
      logoUrl = EMAIL_STYLES.LOGO_URL,
      sections = [],
      footer = '',
      hasQRCode = false
    } = content;

    return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; margin: 0; padding: 0; background-color: #f7fafc; }
    .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; }
    .header { background: linear-gradient(135deg, ${headerColor} 0%, #2c5282 100%); color: #ffffff; padding: 40px 30px; text-align: center; }
    .logo { width: 120px; height: auto; margin-bottom: 20px; }
    .content { padding: 40px 30px; }
    .section { margin-bottom: 30px; }
    .section-title { font-size: 18px; font-weight: 600; color: #2d3748; margin-bottom: 15px; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; }
    .details-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
    .detail-row { border-bottom: 1px solid #f1f5f9; }
    .detail-label { color: #718096; font-size: 14px; padding: 10px 0; vertical-align: top; }
    .detail-value { color: #2d3748; font-weight: 500; font-size: 14px; text-align: right; padding: 10px 0; vertical-align: top; }
    .highlight { background-color: #fef5e7; padding: 15px; border-left: 4px solid #f39c12; margin: 20px 0; }
    .qr-container { text-align: center; margin: 30px 0; padding: 20px; background-color: #f8fafc; border-radius: 8px; }
    .qr-code { width: 150px; height: 150px; }
    .footer { background-color: #2d3748; color: #ffffff; padding: 30px; text-align: center; font-size: 12px; }
    .button { display: inline-block; padding: 12px 30px; background-color: #3182ce; color: #ffffff; text-decoration: none; border-radius: 6px; margin: 20px 0; }
    .items-list { margin: 15px 0; }
    .item-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f1f5f9; }
    .item-name { color: #4a5568; font-size: 14px; }
    .item-details { color: #2d3748; font-size: 14px; text-align: right; }
    @media (max-width: 600px) {
      .content { padding: 20px 15px; }
      .header { padding: 30px 20px; }
      .detail-row { flex-direction: column; }
      .detail-value { text-align: left; margin-top: 5px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      ${logoUrl ? `<img src="${logoUrl}" alt="FMH Hotel" class="logo">` : ''}
      <h1 style="margin: 0; font-size: 28px; font-weight: 300;">${EMAIL_STYLES.HOTEL_NAME}</h1>
      <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 14px;">${EMAIL_STYLES.HOTEL_TAGLINE}</p>
    </div>

    <div class="content">
      ${sections.map(section => `
        <div class="section">
          ${section.title ? `<div class="section-title">${section.title}</div>` : ''}
          ${section.type === 'text' ? `
            <p style="color: #4a5568; line-height: 1.6; margin: 10px 0;">${section.content}</p>
          ` : ''}
          ${section.type === 'details' ? `
            <table class="details-table">
              ${section.items.map(item => `
                <tr class="detail-row">
                  <td class="detail-label">${item.label}</td>
                  <td class="detail-value">${item.value}</td>
                </tr>
              `).join('')}
            </table>
          ` : ''}
          ${section.type === 'items' ? `
            <div class="items-list">
              ${section.items.map(item => `
                <div class="item-row">
                  <span class="item-name">${item.name}</span>
                  <span class="item-details">${item.details}</span>
                </div>
              `).join('')}
            </div>
          ` : ''}
          ${section.type === 'highlight' ? `
            <div class="highlight">
              ${section.content}
            </div>
          ` : ''}
          ${section.type === 'button' ? `
            <div style="text-align: center;">
              <a href="${section.url}" class="button">${section.text}</a>
            </div>
          ` : ''}
        </div>
      `).join('')}

      ${hasQRCode ? `
        <div class="qr-container">
          <p style="margin: 0 0 15px 0; color: #718096; font-size: 12px;">Scan for Quick Verification</p>
          <img src="cid:qr-code" alt="QR Code" class="qr-code">
          <p style="margin: 15px 0 0 0; color: #a0aec0; font-size: 11px;">Present this code at reception</p>
        </div>
      ` : ''}
    </div>

    <div class="footer">
      <p style="margin: 0 0 10px 0;">© 2024 FMH Hotel. All rights reserved.</p>
      <p style="margin: 0 0 10px 0;">${CONTACT_INFO.HOTEL_LOCATION} | ${CONTACT_INFO.SUPPORT_PHONE}</p>
      <p style="margin: 0; opacity: 0.8; font-size: 11px;">
        ${footer || 'This is an automated message. Please do not reply to this email.'}
      </p>
    </div>
  </div>
</body>
</html>
    `;
  }

  // ========================================================================
  // Email Content Generation
  // ========================================================================

  generateCreationEmail(transactionType, details, reference, userName, amount) {
    const config = TRANSACTION_TYPES[transactionType];
    if (!config) return null;

    const subject = `${config.emailSubject.creation} - ${reference}`;
    let body;

    switch (transactionType) {
      case 'booking':
        body = `Dear ${userName},\n\nYour booking has been created successfully!\n\nBooking Reference: ${reference}\nAmount: ₦${amount.toLocaleString()}\n\nPlease complete payment to confirm your booking.\n\nThank you for choosing FMH Hotel!`;
        break;
      case 'food_order':
        body = `Dear ${userName},\n\nYour food order has been created!\n\nOrder Reference: ${reference}\nAmount: ₦${amount.toLocaleString()}\n\nPlease complete payment to confirm your order.\n\nThank you!`;
        break;
      default:
        body = `Dear ${userName},\n\nYour ${transactionType.replace('_', ' ')} has been created!\n\nReference: ${reference}\nAmount: ₦${amount.toLocaleString()}\n\nPlease complete payment to confirm.\n\nThank you!`;
    }

    return { subject, body };
  }

  generateSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt) {
    const config = TRANSACTION_TYPES[transactionType];
    if (!config) return null;

    const subject = `${config.emailSubject.success} - ${reference}`;
    let body;

    switch (transactionType) {
      case 'booking':
        body = `Dear ${userName},\n\nYour booking has been confirmed!\n\nBooking Reference: ${reference}\nAmount Paid: ₦${amountPaid.toLocaleString()}\nPayment Date: ${new Date(paidAt).toLocaleString()}\n\nWe look forward to welcoming you!\n\nBest regards,\nFMH Hotel Team`;
        break;
      case 'food_order':
        body = `Dear ${userName},\n\nYour food order has been confirmed!\n\nOrder Reference: ${reference}\nAmount Paid: ₦${amountPaid.toLocaleString()}\nPayment Date: ${new Date(paidAt).toLocaleString()}\n\nYour order is being prepared.\n\nThank you!`;
        break;
      default:
        body = `Dear ${userName},\n\nYour ${transactionType.replace('_', ' ')} has been confirmed!\n\nReference: ${reference}\nAmount Paid: ₦${amountPaid.toLocaleString()}\nPayment Date: ${new Date(paidAt).toLocaleString()}\n\nThank you for your business!\n\nBest regards,\nFMH Hotel Team`;
    }

    return { subject, body };
  }

  async generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt) {
    const config = TRANSACTION_TYPES[transactionType];
    if (!config) return null;

    const subject = `${config.emailSubject.success} - ${reference}`;
    let sections = [];
    let qrData = {};

    // Common QR data
    qrData = {
      reference: reference,
      type: transactionType,
      customer: userName,
      amount: amountPaid,
      verified: true
    };

    // Transaction-specific sections
    switch (transactionType) {
      case 'booking':
        sections = [
          {
            type: 'text',
            content: `Dear ${userName}, your booking has been confirmed! We look forward to welcoming you to FMH Hotel.`
          },
          {
            title: 'Booking Details',
            type: 'details',
            items: [
              { label: 'Reference', value: reference },
              { label: 'Amount Paid', value: `₦${amountPaid.toLocaleString()}` },
              { label: 'Payment Date', value: new Date(paidAt).toLocaleDateString() },
              { label: 'Status', value: 'Confirmed' }
            ]
          },
          {
            type: 'highlight',
            content: 'Please present this confirmation at check-in. Have a wonderful stay!'
          }
        ];
        break;

      case 'food_order':
        sections = [
          {
            type: 'text',
            content: `Dear ${userName}, your food order has been confirmed and is being prepared!`
          },
          {
            title: 'Order Details',
            type: 'details',
            items: [
              { label: 'Order Reference', value: reference },
              { label: 'Amount Paid', value: `₦${amountPaid.toLocaleString()}` },
              { label: 'Delivery To', value: orderDetails.deliverTo || 'Room 101' },
              { label: 'Status', value: 'Confirmed' }
            ]
          }
        ];

        if (orderDetails.items && orderDetails.items.length > 0) {
          sections.push({
            title: 'Ordered Items',
            type: 'items',
            items: orderDetails.items.map(item => ({
              name: item.name || 'Food Item',
              details: `Qty: ${item.quantity || 1} - ₦${(item.price || 0).toLocaleString()}`
            }))
          });
        }
        break;

      default:
        sections = [
          {
            type: 'text',
            content: `Dear ${userName}, your ${transactionType.replace('_', ' ')} has been confirmed!`
          },
          {
            title: 'Transaction Details',
            type: 'details',
            items: [
              { label: 'Reference', value: reference },
              { label: 'Amount Paid', value: `₦${amountPaid.toLocaleString()}` },
              { label: 'Payment Date', value: new Date(paidAt).toLocaleDateString() },
              { label: 'Status', value: 'Confirmed' }
            ]
          }
        ];
    }

    // Generate QR code
    const qrCodeBuffer = await this.generateQRCodeBuffer(qrData);
    const attachments = qrCodeBuffer ? [{
      filename: 'qr-code.png',
      content: qrCodeBuffer,
      cid: 'qr-code'
    }] : [];

    // Generate HTML content
    const htmlContent = this.generateHTMLEmailTemplate({
      title: subject,
      sections: sections,
      hasQRCode: !!qrCodeBuffer
    });

    // Generate plain text fallback
    const plainText = sections.map(section => {
      if (section.type === 'text') return section.content;
      if (section.type === 'details') {
        return `${section.title}:\n${section.items.map(item => `${item.label}: ${item.value}`).join('\n')}`;
      }
      return '';
    }).filter(Boolean).join('\n\n');

    return { subject, body: plainText, html: htmlContent, attachments };
  }

  // ========================================================================
  // Email Sending
  // ========================================================================

  async sendEmail(to, subject, text, html = null, attachments = [], executionId = 'email-send') {
    try {
      logger.email('SEND', to, subject, executionId);

      const mailOptions = {
        from: this.defaultFrom,
        to: to,
        subject: subject,
        text: text,
        html: html || text,
        attachments: attachments
      };

      const result = await this.transporter.sendMail(mailOptions);

      logger.success(`Email sent successfully to ${to}`, executionId, {
        messageId: result.messageId,
        accepted: result.accepted,
        rejected: result.rejected
      });

      return true;
    } catch (error) {
      logger.error(`Failed to send email to ${to}`, executionId, error, { subject });
      throw error;
    }
  }

  async sendCreationEmail(transactionType, details, reference, userName, amount, recipientEmail, executionId = 'creation-email') {
    try {
      const emailContent = this.generateCreationEmail(transactionType, details, reference, userName, amount);
      if (!emailContent) {
        logger.warning(`No email template found for transaction type: ${transactionType}`, executionId);
        return false;
      }

      await this.sendEmail(recipientEmail, emailContent.subject, emailContent.body, null, [], executionId);
      logger.success(`Creation email sent for ${transactionType}: ${reference}`, executionId);
      return true;
    } catch (error) {
      logger.error(`Failed to send creation email for ${transactionType}: ${reference}`, executionId, error);
      return false;
    }
  }

  async sendSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt, recipientEmail, executionId = 'success-email') {
    try {
      const emailContent = await this.generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt);
      if (!emailContent) {
        logger.warning(`No email template found for transaction type: ${transactionType}`, executionId);
        return false;
      }

      await this.sendEmail(
        recipientEmail,
        emailContent.subject,
        emailContent.body,
        emailContent.html,
        emailContent.attachments || [],
        executionId
      );

      logger.success(`Success email sent for ${transactionType}: ${reference}`, executionId);
      return true;
    } catch (error) {
      logger.error(`Failed to send success email for ${transactionType}: ${reference}`, executionId, error);
      return false;
    }
  }

  // ========================================================================
  // Utility Methods
  // ========================================================================

  async testConnection(executionId = 'email-test') {
    try {
      logger.info('Testing email connection', executionId);
      await this.transporter.verify();
      logger.success('Email connection verified', executionId);
      return true;
    } catch (error) {
      logger.error('Email connection test failed', executionId, error);
      return false;
    }
  }
}

// Create default email service instance
const emailService = new EmailService();

module.exports = {
  EmailService,
  emailService
};
const nodemailer = require('nodemailer');
const { generateHTMLEmailTemplate } = require('./helpers');
const { SUPPORT_EMAIL, SUPPORT_PHONE, HOTEL_LOCATION } = require('../config/constants');

const transporter = nodemailer.createTransport({
  host: 'mail.cyrextech.org',
  port: 587,
  secure: false,
  auth: {
    user: 'no-reply@cyrextech.org',
    pass: process.env.PASSWORD,
  },
});

async function sendEmail(to, subject, text, html = null, attachments = []) {
  try {
    console.log(`Attempting to send email to: ${to}`);
    
    const mailOptions = {
      from: '"FMH Hotel" <no-reply@cyrextech.org>',
      to: to,
      subject: subject,
      text: text,
      html: html || text,
      attachments: attachments
    };

    const result = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', {
      messageId: result.messageId,
      to: to,
      subject: subject
    });
    return true;
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
}

async function sendEnhancedEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt, to) {
  const { generateEnhancedSuccessEmail } = require('./helpers');
  const emailContent = await generateEnhancedSuccessEmail(transactionType, orderDetails, reference, userName, amountPaid, paidAt);
  
  if (emailContent) {
    return await sendEmail(to, emailContent.subject, emailContent.body, emailContent.html, emailContent.attachments);
  }
  return false;
}

module.exports = {
  sendEmail,
  sendEnhancedEmail,
  transporter
};
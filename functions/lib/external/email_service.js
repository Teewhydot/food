const { sendEmail } = require('../../utils/email');

async function handleSendEmail(req, res) {
  const { to, subject, text } = req.body;

  if (!to || !subject || !text) {
    return res.status(400).send('Missing required fields: to, subject, text.');
  }

  try {
    await sendEmail(to, subject, text);
    return res.status(200).send('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
    return res.status(500).send('Error sending email');
  }
}

module.exports = {
  handleSendEmail
};
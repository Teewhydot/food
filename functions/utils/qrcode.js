const QRCode = require('qrcode');

async function generateQRCodeBuffer(data) {
  try {
    const qrDataString = typeof data === 'object' 
      ? Object.entries(data).map(([key, value]) => `${key}:${value}`).join('\n')
      : data;
    
    const qrCodeBuffer = await QRCode.toBuffer(qrDataString, {
      errorCorrectionLevel: 'M',
      type: 'png',
      quality: 0.92,
      margin: 1,
      color: { dark: '#000000', light: '#FFFFFF' },
      width: 200
    });
    
    return qrCodeBuffer;
  } catch (error) {
    console.error('Error generating QR code:', error);
    return null;
  }
}

module.exports = {
  generateQRCodeBuffer
};
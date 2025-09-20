# Flutterwave Payment Integration Guide

## Overview

This guide covers the complete Flutterwave payment integration implementation for the Food Delivery App. The integration follows the same patterns as the existing Paystack implementation and provides a seamless dual-payment gateway experience.

## Architecture

### Frontend (Flutter)
- **FlutterwavePaymentBloc**: State management for Flutterwave payments
- **FlutterwaveWebviewScreen**: In-app webview for payment processing
- **Payment Method Screen**: Unified UI for both Paystack and Flutterwave selection

### Backend (Firebase Cloud Functions)
- **initializeFlutterwavePayment**: Initialize Flutterwave payment sessions
- **verifyFlutterwavePayment**: Verify payment completion
- **getFlutterwaveTransactionStatus**: Get transaction status
- **flutterwaveWebhook**: Handle Flutterwave webhook events

## API Endpoints

### 1. Initialize Flutterwave Payment
```
POST /initializeFlutterwavePayment
```

**Request Body:**
```json
{
  "orderId": "order_123",
  "amount": 2500.00,
  "userId": "user_abc123",
  "email": "customer@example.com",
  "userName": "John Doe",
  "metadata": {
    "phoneNumber": "09012345678",
    "redirectUrl": "https://yourapp.com/success"
  }
}
```

**Response:**
```json
{
  "success": true,
  "reference": "F-FLW_1234567890_abc123def",
  "authorization_url": "https://checkout.flutterwave.com/v3/hosted/pay/abc123def456",
  "access_code": "flw_ac_abc123def",
  "tx_ref": "FLW_1234567890_abc123def"
}
```

### 2. Verify Flutterwave Payment
```
POST /verifyFlutterwavePayment
```

**Request Body:**
```json
{
  "reference": "F-FLW_1234567890_abc123def",
  "orderId": "order_123"
}
```

**Response:**
```json
{
  "success": true,
  "status": "successful",
  "amount": 2500.00,
  "reference": "F-FLW_1234567890_abc123def",
  "tx_ref": "FLW_1234567890_abc123def",
  "flw_ref": "flwRef123456789",
  "paidAt": "2025-01-20T10:30:00Z",
  "channel": "card",
  "currency": "NGN"
}
```

### 3. Get Transaction Status
```
GET /getFlutterwaveTransactionStatus?reference=F-FLW_1234567890_abc123def
```

**Response:**
```json
{
  "success": true,
  "status": "successful",
  "amount": 2500.00,
  "reference": "F-FLW_1234567890_abc123def",
  "tx_ref": "FLW_1234567890_abc123def",
  "paidAt": "2025-01-20T10:30:00Z",
  "details": {
    "currency": "NGN",
    "channel": "card",
    "customer": {
      "email": "customer@example.com",
      "name": "John Doe"
    }
  }
}
```

### 4. Webhook Handler
```
POST /flutterwaveWebhook
```

**Headers:**
- `verif-hash`: Flutterwave signature for verification

**Event Types Handled:**
- `charge.completed`: Payment successful
- `charge.failed`: Payment failed

## Environment Configuration

### Required Environment Variables

```bash
# Flutterwave API Keys (Test)
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-your_secret_key_here
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-your_public_key_here
FLUTTERWAVE_SECRET_HASH=your_secret_hash_for_webhooks

# Flutterwave API Keys (Production)
FLUTTERWAVE_SECRET_KEY=FLWSECK-your_live_secret_key_here
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK-your_live_public_key_here
```

### Getting Flutterwave Credentials

1. **Create Flutterwave Account**: Visit [https://flutterwave.com](https://flutterwave.com)
2. **Get API Keys**: Go to Settings > API Keys in your dashboard
3. **Configure Webhooks**: Set webhook URL to your Cloud Function endpoint
4. **Set Secret Hash**: Generate and configure webhook secret hash

## Flutter Integration Details

### BLoC Implementation

The `FlutterwavePaymentBloc` handles these events:
- `InitializeFlutterwavePaymentEvent`
- `VerifyFlutterwavePaymentEvent`
- `GetFlutterwaveTransactionStatusEvent`
- `ClearFlutterwavePaymentEvent`

### WebView Screen

`FlutterwaveWebviewScreen` provides:
- In-app payment processing
- Firebase listener for real-time status updates
- Automatic navigation on payment completion/cancellation
- Loading states and error handling

### Payment Flow

1. User selects Flutterwave payment method
2. App calls `initializeFlutterwavePayment` Cloud Function
3. Function returns authorization URL
4. WebView loads Flutterwave checkout page
5. User completes payment on Flutterwave
6. Webhook notifies backend of payment status
7. Firebase document updated with payment status
8. WebView listener detects status change
9. App navigates to success/failure screen

## Database Schema

### Food Orders Collection
```json
{
  "id": "F-FLW_1234567890_abc123def",
  "status": "success",
  "amount": 2500.00,
  "paymentMethod": "flutterwave",
  "flutterwave_ref": "flwRef123456789",
  "tx_ref": "FLW_1234567890_abc123def",
  "time_created": "2025-01-20T10:30:00Z",
  "verified_at": "2025-01-20T10:30:05Z",
  "userId": "user_abc123",
  "userEmail": "customer@example.com",
  "bookingDetails": {
    "orderId": "order_123",
    "transactionType": "food_order"
  }
}
```

## Security Considerations

### Webhook Verification
- All webhooks are verified using HMAC SHA256 signature
- Secret hash must match between Flutterwave dashboard and environment variables
- Invalid signatures are rejected with 400 status

### API Security
- All Flutterwave API calls use Bearer token authentication
- Sensitive data is not logged in production
- Environment variables are used for all credentials

### Transaction Validation
- All payments are verified server-side before providing value
- Client-side payment status is never trusted
- Database transactions are atomic

## Testing

### Test Mode
1. Use test API keys from Flutterwave dashboard
2. Use test card numbers provided by Flutterwave
3. Test webhook delivery using ngrok or similar tools

### Test Cards
```
Successful Card: 4187427415564246
CVV: 828
Expiry: 09/32
PIN: 3310

Failed Card: 4000000000000002
CVV: 812
Expiry: 01/23
```

## Monitoring and Logging

### Cloud Function Logs
- All transactions are logged with execution IDs
- Performance metrics are tracked
- Error details are captured for debugging

### Firebase Console
- Monitor function execution times
- Track success/failure rates
- View detailed error logs

## Deployment

### Prerequisites
1. Firebase project configured
2. Environment variables set in Firebase
3. Flutterwave webhook URL configured

### Deployment Steps
```bash
# Deploy Firebase Functions
firebase deploy --only functions

# Verify deployment
firebase functions:log
```

### Post-Deployment
1. Test payment flow end-to-end
2. Verify webhook delivery
3. Monitor logs for any issues

## Troubleshooting

### Common Issues

**Payment Initialization Fails**
- Check Flutterwave API keys
- Verify network connectivity
- Check request payload format

**Webhook Not Received**
- Verify webhook URL in Flutterwave dashboard
- Check secret hash configuration
- Test webhook signature verification

**Payment Verification Fails**
- Ensure transaction ID is correct
- Check API key permissions
- Verify transaction exists in Flutterwave

### Debug Mode
Enable debug logging by setting:
```javascript
const DEBUG_MODE = process.env.NODE_ENV === 'development';
```

## Support

### Flutterwave Documentation
- [API Documentation](https://developer.flutterwave.com/)
- [Webhook Guide](https://developer.flutterwave.com/docs/webhooks)
- [Test Cards](https://developer.flutterwave.com/docs/test-cards)

### Contact
- Flutterwave Support: [support@flutterwave.com](mailto:support@flutterwave.com)
- Developer Slack: [Flutterwave Developers](https://join.slack.com/t/flutterwave-developers/shared_invite/...)

## Changelog

### Version 1.0.0 (2025-01-20)
- Initial Flutterwave integration implementation
- Complete payment flow with webhook support
- Dual payment gateway architecture
- Comprehensive testing and documentation
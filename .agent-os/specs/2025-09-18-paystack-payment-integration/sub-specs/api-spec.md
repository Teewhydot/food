# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-09-18-paystack-payment-integration/spec.md

> Created: 2025-09-18
> Version: 1.0.0

## Firebase Cloud Functions Endpoints

### POST /createPaystackTransaction

**Purpose**: Initialize a new Paystack payment transaction

**Authentication**: Required (Firebase Auth)

**Request Format**:
```json
{
  "amount": 50000,
  "currency": "NGN",
  "email": "customer@example.com",
  "orderId": "order_12345",
  "metadata": {
    "customer_id": "user_abc123",
    "order_items": [
      {
        "id": "food_item_1",
        "name": "Jollof Rice",
        "quantity": 2,
        "price": 25000
      }
    ],
    "delivery_address": "123 Main St, Lagos, Nigeria"
  },
  "callback_url": "https://yourapp.com/payment/callback",
  "channels": ["card", "bank", "ussd", "qr", "mobile_money", "bank_transfer"]
}
```

**Response Format** (Success - 200):
```json
{
  "status": "success",
  "message": "Transaction initialized successfully",
  "data": {
    "access_code": "rpp_1234567890",
    "authorization_url": "https://checkout.paystack.com/rpp_1234567890",
    "reference": "T123456789",
    "transaction_id": "txn_abc123def456"
  }
}
```

**Response Format** (Error - 400):
```json
{
  "status": "error",
  "message": "Invalid request parameters",
  "errors": [
    {
      "field": "amount",
      "message": "Amount must be greater than 0"
    }
  ]
}
```

### POST /verifyPaystackPayment

**Purpose**: Verify payment status with Paystack and update order status

**Authentication**: Required (Firebase Auth)

**Request Format**:
```json
{
  "reference": "T123456789",
  "orderId": "order_12345"
}
```

**Response Format** (Success - 200):
```json
{
  "status": "success",
  "message": "Payment verified successfully",
  "data": {
    "transaction": {
      "id": 3194343434,
      "reference": "T123456789",
      "amount": 50000,
      "currency": "NGN",
      "status": "success",
      "gateway_response": "Successful",
      "paid_at": "2025-09-18T10:30:00.000Z",
      "created_at": "2025-09-18T10:25:00.000Z",
      "channel": "card",
      "authorization": {
        "authorization_code": "AUTH_abc123",
        "bin": "408408",
        "last4": "4081",
        "exp_month": "12",
        "exp_year": "2030",
        "channel": "card",
        "card_type": "visa DEBIT",
        "bank": "Test Bank",
        "country_code": "NG",
        "brand": "visa",
        "reusable": true,
        "signature": "SIG_abc123"
      }
    },
    "order": {
      "id": "order_12345",
      "status": "confirmed",
      "payment_status": "paid",
      "updated_at": "2025-09-18T10:30:00.000Z"
    }
  }
}
```

**Response Format** (Failed Payment - 200):
```json
{
  "status": "failed",
  "message": "Payment verification failed",
  "data": {
    "transaction": {
      "id": 3194343434,
      "reference": "T123456789",
      "amount": 50000,
      "currency": "NGN",
      "status": "failed",
      "gateway_response": "Declined by bank",
      "created_at": "2025-09-18T10:25:00.000Z"
    },
    "order": {
      "id": "order_12345",
      "status": "pending",
      "payment_status": "failed"
    }
  }
}
```

### POST /paystackWebhook

**Purpose**: Handle Paystack webhook notifications for real-time payment updates

**Authentication**: Webhook signature verification

**Request Format** (Paystack Webhook):
```json
{
  "event": "charge.success",
  "data": {
    "id": 3194343434,
    "domain": "test",
    "status": "success",
    "reference": "T123456789",
    "amount": 50000,
    "message": null,
    "gateway_response": "Successful",
    "paid_at": "2025-09-18T10:30:00.000Z",
    "created_at": "2025-09-18T10:25:00.000Z",
    "channel": "card",
    "currency": "NGN",
    "ip_address": "192.168.1.1",
    "metadata": {
      "customer_id": "user_abc123",
      "order_id": "order_12345"
    },
    "customer": {
      "id": 23070321,
      "first_name": "John",
      "last_name": "Doe",
      "email": "customer@example.com",
      "customer_code": "CUS_abc123",
      "phone": "+2348012345678"
    },
    "authorization": {
      "authorization_code": "AUTH_abc123",
      "bin": "408408",
      "last4": "4081",
      "exp_month": "12",
      "exp_year": "2030",
      "channel": "card",
      "card_type": "visa DEBIT",
      "bank": "Test Bank",
      "country_code": "NG",
      "brand": "visa",
      "reusable": true,
      "signature": "SIG_abc123"
    }
  }
}
```

**Response Format** (Success - 200):
```json
{
  "status": "success",
  "message": "Webhook processed successfully"
}
```

**Webhook Events to Handle**:
- `charge.success` - Payment successful
- `charge.failed` - Payment failed
- `transfer.success` - Transfer successful (for future refunds)
- `transfer.failed` - Transfer failed

### GET /getTransactionStatus

**Purpose**: Get current transaction status from database

**Authentication**: Required (Firebase Auth)

**Query Parameters**:
- `reference` (required): Transaction reference
- `orderId` (optional): Order ID for additional validation

**Response Format** (Success - 200):
```json
{
  "status": "success",
  "data": {
    "reference": "T123456789",
    "status": "success",
    "amount": 50000,
    "currency": "NGN",
    "payment_date": "2025-09-18T10:30:00.000Z",
    "order_id": "order_12345",
    "order_status": "confirmed",
    "gateway_response": "Successful"
  }
}
```

### POST /savePaystackCard

**Purpose**: Save tokenized card details from successful Paystack transaction

**Authentication**: Required (Firebase Auth)

**Request Format**:
```json
{
  "authorization_code": "AUTH_abc123",
  "card_details": {
    "bin": "408408",
    "last4": "4081",
    "exp_month": "12",
    "exp_year": "2030",
    "card_type": "visa DEBIT",
    "bank": "Test Bank",
    "brand": "visa"
  },
  "customer_id": "user_abc123"
}
```

**Response Format** (Success - 200):
```json
{
  "status": "success",
  "message": "Card saved successfully",
  "data": {
    "card_id": "card_abc123",
    "authorization_code": "AUTH_abc123",
    "last4": "4081",
    "brand": "visa",
    "bank": "Test Bank",
    "exp_month": "12",
    "exp_year": "2030",
    "created_at": "2025-09-18T10:30:00.000Z"
  }
}
```

## Error Handling and Status Codes

### HTTP Status Codes
- `200` - Success
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource not found)
- `500` - Internal Server Error

### Error Response Structure
```json
{
  "status": "error",
  "message": "Human-readable error message",
  "code": "ERROR_CODE_ENUM",
  "errors": [
    {
      "field": "field_name",
      "message": "Field-specific error message"
    }
  ],
  "timestamp": "2025-09-18T10:30:00.000Z"
}
```

### Error Codes
- `INVALID_AMOUNT` - Amount is invalid or below minimum
- `INVALID_EMAIL` - Email format is invalid
- `PAYMENT_FAILED` - Payment processing failed
- `TRANSACTION_NOT_FOUND` - Transaction reference not found
- `WEBHOOK_VERIFICATION_FAILED` - Webhook signature verification failed
- `CARD_SAVE_FAILED` - Card tokenization/saving failed
- `ORDER_NOT_FOUND` - Order ID not found
- `USER_NOT_AUTHENTICATED` - User authentication required

## Authentication Requirements

### Firebase Auth Token
All endpoints except webhooks require a valid Firebase Auth token in the Authorization header:
```
Authorization: Bearer <firebase_auth_token>
```

### Webhook Authentication
Webhook endpoints use Paystack signature verification:
```javascript
const crypto = require('crypto');

function verifyPaystackSignature(payload, signature, secret) {
  const hash = crypto.createHmac('sha512', secret)
    .update(JSON.stringify(payload))
    .digest('hex');
  return hash === signature;
}
```

## Integration with Existing Payment Flow

### PaymentRepository Integration
The new Paystack endpoints will extend the existing `PaymentRepository` interface:

```dart
abstract class PaymentRepository {
  // Existing methods...

  // New Paystack methods
  Future<Either<Failure, PaystackTransactionEntity>> initializePaystackTransaction({
    required double amount,
    required String email,
    required String orderId,
    required Map<String, dynamic> metadata,
  });

  Future<Either<Failure, PaystackVerificationEntity>> verifyPaystackPayment({
    required String reference,
    required String orderId,
  });

  Future<Either<Failure, TransactionStatusEntity>> getTransactionStatus(String reference);

  Future<Either<Failure, SavedCardEntity>> savePaystackCard({
    required String authorizationCode,
    required CardDetailsEntity cardDetails,
  });
}
```

### Firebase Functions Structure
```
functions/
├── index.js
├── src/
│   ├── paystack/
│   │   ├── createTransaction.js
│   │   ├── verifyPayment.js
│   │   ├── webhook.js
│   │   ├── getTransactionStatus.js
│   │   └── saveCard.js
│   ├── utils/
│   │   ├── paystackClient.js
│   │   ├── validation.js
│   │   └── auth.js
│   └── config/
│       └── paystack.js
```

### Environment Variables
```javascript
// Firebase Functions configuration
const paystackConfig = {
  publicKey: functions.config().paystack.public_key,
  secretKey: functions.config().paystack.secret_key,
  webhookSecret: functions.config().paystack.webhook_secret,
  baseUrl: 'https://api.paystack.co'
};
```

## Security Considerations

### API Key Management
- Store Paystack secret keys in Firebase Functions configuration
- Never expose secret keys in client-side code
- Use environment-specific keys (test/live)

### Webhook Security
- Verify all webhook signatures using Paystack secret
- Implement request rate limiting
- Log all webhook events for audit trails

### Payment Data Security
- Never store raw card details in database
- Use Paystack authorization codes for saved cards
- Implement PCI DSS compliance measures
- Encrypt sensitive data at rest

### Request Validation
- Validate all input parameters
- Implement request size limits
- Use Firebase Auth for user authentication
- Implement CORS policies appropriately

### Error Handling Strategy
- Log all errors with appropriate detail levels
- Return generic error messages to clients
- Implement retry mechanisms for transient failures
- Set up monitoring and alerting for critical failures
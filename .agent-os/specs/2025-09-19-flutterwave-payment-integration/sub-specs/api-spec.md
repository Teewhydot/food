# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-09-19-flutterwave-payment-integration/spec.md

> Created: 2025-09-19
> Version: 1.0.0

## Firebase Cloud Functions Endpoints

### POST /createFlutterwaveTransaction

**Purpose:** Initialize a new Flutterwave payment transaction
**Parameters:**
- `orderId` (string, required): Reference to the order being paid for
- `amount` (number, required): Payment amount in Naira
- `currency` (string, optional): Currency code, defaults to "NGN"
- `metadata` (object, optional): Additional transaction metadata

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "fw_trans_123456789",
    "reference": "FW_REF_ABC123",
    "authorizationUrl": "https://checkout.flutterwave.com/v3/hosted/pay/...",
    "accessCode": "fw_access_code_123"
  }
}
```

**Errors:**
- 400: Invalid parameters or missing required fields
- 401: User not authenticated
- 404: Order not found or not accessible by user
- 500: Internal server error during transaction creation

### POST /verifyFlutterwavePayment

**Purpose:** Verify and complete a Flutterwave payment transaction
**Parameters:**
- `transactionId` (string, required): Flutterwave transaction ID to verify
- `reference` (string, required): Transaction reference from Flutterwave

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "success",
    "transactionId": "fw_trans_123456789",
    "reference": "FW_REF_ABC123",
    "amount": 500000,
    "currency": "NGN",
    "paidAt": "2025-09-19T10:30:00Z"
  }
}
```

**Errors:**
- 400: Invalid transaction ID or reference
- 401: User not authenticated
- 404: Transaction not found
- 422: Payment verification failed
- 500: Internal server error during verification

### GET /getFlutterwaveTransactionStatus

**Purpose:** Retrieve current status of a Flutterwave transaction
**Parameters:**
- `transactionId` (string, required): Transaction ID to check

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "fw_trans_123456789",
    "status": "pending",
    "amount": 500000,
    "currency": "NGN",
    "createdAt": "2025-09-19T10:00:00Z",
    "lastChecked": "2025-09-19T10:35:00Z"
  }
}
```

**Errors:**
- 400: Invalid transaction ID format
- 401: User not authenticated
- 404: Transaction not found
- 500: Internal server error

### POST /flutterwaveWebhook

**Purpose:** Handle webhook notifications from Flutterwave
**Parameters:**
- Request body contains Flutterwave webhook payload
- `verif-hash` header for webhook signature verification

**Response:**
```json
{
  "success": true,
  "message": "Webhook processed successfully"
}
```

**Errors:**
- 400: Invalid webhook payload or signature
- 500: Internal server error during webhook processing

## Flutter Service Methods

### FlutterwaveService Class

#### initializePayment()

**Purpose:** Create a new payment transaction
**Method:** `Future<FlutterwaveTransactionEntity> initializePayment(PaymentRequest request)`
**Parameters:**
- `request.orderId`: Order ID for the payment
- `request.amount`: Payment amount in Naira
- `request.email`: User email address

**Returns:** FlutterwaveTransactionEntity with authorization URL and access code

#### verifyPayment()

**Purpose:** Verify payment completion status
**Method:** `Future<FlutterwaveTransactionEntity> verifyPayment(String transactionId, String reference)`
**Parameters:**
- `transactionId`: Transaction ID to verify
- `reference`: Flutterwave transaction reference

**Returns:** Updated FlutterwaveTransactionEntity with payment status

#### getTransactionStatus()

**Purpose:** Check current transaction status
**Method:** `Future<FlutterwaveTransactionEntity> getTransactionStatus(String transactionId)`
**Parameters:**
- `transactionId`: Transaction ID to check

**Returns:** FlutterwaveTransactionEntity with current status

## Error Handling

### Standard Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "Payment verification failed",
    "details": "Transaction was declined by the bank"
  }
}
```

### Error Codes

- `INVALID_PARAMETERS`: Missing or invalid request parameters
- `AUTHENTICATION_FAILED`: User authentication required
- `TRANSACTION_NOT_FOUND`: Referenced transaction does not exist
- `PAYMENT_FAILED`: Payment processing or verification failed
- `WEBHOOK_INVALID`: Webhook signature verification failed
- `SERVER_ERROR`: Internal server error occurred

## Rate Limiting

- **Transaction Creation**: 10 requests per minute per user
- **Verification Requests**: 30 requests per minute per user
- **Status Checks**: 60 requests per minute per user
- **Webhook Endpoint**: No rate limiting (handled by Flutterwave)
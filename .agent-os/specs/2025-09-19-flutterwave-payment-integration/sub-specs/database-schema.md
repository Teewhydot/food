# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-09-19-flutterwave-payment-integration/spec.md

> Created: 2025-09-19
> Version: 1.0.0

## Firebase Firestore Collections

### flutterwave_transactions Collection

**Purpose**: Store Flutterwave transaction records parallel to existing paystack_transactions

```javascript
{
  "transactionId": "string", // Auto-generated document ID
  "reference": "string", // Flutterwave transaction reference
  "orderId": "string", // Reference to order in orders collection
  "userId": "string", // Reference to user account
  "amount": "number", // Amount in kobo (NGN * 100)
  "currency": "string", // Currency code (NGN)
  "email": "string", // User email for transaction
  "status": "string", // pending|success|failed|cancelled|processing
  "authorizationUrl": "string", // Flutterwave payment URL
  "accessCode": "string", // Transaction access code
  "paymentMethod": "string", // card|bank_transfer|etc
  "createdAt": "timestamp", // Transaction creation time
  "paidAt": "timestamp", // Payment completion time (nullable)
  "metadata": {
    "orderId": "string",
    "userId": "string",
    "customerName": "string",
    "customerPhone": "string",
    "deliveryAddress": "string"
  }
}
```

### orders Collection (Existing - Modifications)

**New Fields to Add**: Support for Flutterwave payment method identification

```javascript
{
  // ... existing order fields ...
  "paymentProvider": "string", // "paystack" | "flutterwave"
  "flutterwaveTransactionId": "string", // Reference to flutterwave_transactions (nullable)
  // ... rest of existing fields unchanged ...
}
```

## Firestore Security Rules

### flutterwave_transactions Collection Rules

```javascript
match /flutterwave_transactions/{transactionId} {
  allow read, write: if request.auth != null &&
    request.auth.uid == resource.data.userId;
  allow create: if request.auth != null &&
    request.auth.uid == request.resource.data.userId;
}
```

### Updated orders Collection Rules

```javascript
match /orders/{orderId} {
  allow read, write: if request.auth != null &&
    (request.auth.uid == resource.data.userId ||
     request.auth.uid == resource.data.customerId);
  allow create: if request.auth != null &&
    (request.auth.uid == request.resource.data.userId ||
     request.auth.uid == request.resource.data.customerId);
}
```

## Firestore Indexes

### flutterwave_transactions Indexes

**Single Field Indexes:**
- userId (ascending)
- status (ascending)
- createdAt (descending)
- reference (ascending)

**Composite Indexes:**
- userId (ascending) + createdAt (descending)
- userId (ascending) + status (ascending)
- orderId (ascending) + status (ascending)

## Data Migration

**No data migration required** - This is a new integration that creates parallel data structures without affecting existing Paystack transactions or orders.

**Backwards Compatibility**: All existing orders and transactions remain unchanged. New orders can optionally use Flutterwave while existing Paystack functionality continues to work.

## Rationale

- **Separate Collections**: Maintains clear separation between payment providers while allowing for provider-specific optimizations
- **Reference Fields**: orderId links transactions to orders while paymentProvider field identifies the payment method used
- **Security**: Users can only access their own transaction records with proper authentication
- **Indexing**: Optimized for common query patterns (user transactions, order status, transaction lookup)
- **Metadata Structure**: Follows Flutterwave best practices for transaction metadata and webhook processing
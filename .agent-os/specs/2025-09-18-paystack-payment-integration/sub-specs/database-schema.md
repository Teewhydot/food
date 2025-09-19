# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-09-18-paystack-payment-integration/spec.md

> Created: 2025-09-18
> Version: 1.0.0

## Schema Changes

### 1. Firebase Firestore Updates

#### New Collections

##### paystack_transactions
```json
{
  "reference": "string (Paystack transaction reference)",
  "orderId": "string (reference to orders collection)",
  "userId": "string",
  "amount": "number (in kobo for NGN)",
  "currency": "string (NGN, USD, etc.)",
  "email": "string (customer email)",
  "status": "string (pending|success|failed|abandoned|processing)",
  "authorization": {
    "authorization_code": "string (for recurring payments)",
    "bin": "string (first 6 digits of card)",
    "last4": "string (last 4 digits of card)",
    "exp_month": "string",
    "exp_year": "string",
    "channel": "string (card|bank|ussd|qr|mobile_money|bank_transfer)",
    "card_type": "string (visa|mastercard|verve)",
    "bank": "string",
    "country_code": "string",
    "brand": "string",
    "reusable": "boolean"
  },
  "customer": {
    "id": "number (Paystack customer ID)",
    "first_name": "string",
    "last_name": "string",
    "email": "string",
    "customer_code": "string",
    "phone": "string",
    "metadata": "object"
  },
  "fees": "number (Paystack fees in kobo)",
  "fees_split": "object (fee breakdown)",
  "gateway_response": "string",
  "ip_address": "string",
  "paid_at": "timestamp",
  "created_at": "timestamp",
  "channel": "string",
  "log": {
    "start_time": "number",
    "time_spent": "number",
    "attempts": "number",
    "errors": "number",
    "success": "boolean",
    "mobile": "boolean",
    "input": "array",
    "history": "array"
  },
  "metadata": {
    "orderId": "string",
    "userId": "string",
    "custom_fields": "array"
  }
}
```

##### paystack_customers
```json
{
  "paystackCustomerId": "number",
  "customerCode": "string",
  "userId": "string (reference to app user)",
  "email": "string",
  "first_name": "string",
  "last_name": "string",
  "phone": "string",
  "metadata": "object",
  "domain": "string (test|live)",
  "customer_code": "string",
  "risk_action": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

##### paystack_saved_cards
```json
{
  "userId": "string",
  "authorization_code": "string",
  "bin": "string",
  "last4": "string",
  "exp_month": "string",
  "exp_year": "string",
  "channel": "string",
  "card_type": "string",
  "bank": "string",
  "country_code": "string",
  "brand": "string",
  "reusable": "boolean",
  "signature": "string",
  "account_name": "string (optional)",
  "isDefault": "boolean",
  "createdAt": "timestamp"
}
```

#### Updated Collections

##### orders (existing - add new fields)
```json
{
  // ... existing fields ...
  "paymentProvider": "string (cash|paystack|existing_gateway)", // NEW
  "paystackReference": "string (optional)", // NEW
  "paystackTransactionId": "string (optional)", // NEW
  "paymentFees": "number (payment gateway fees)", // NEW
  "paymentStatus": "string (pending|processing|success|failed)", // NEW
  "paymentFailureReason": "string (optional)", // NEW
  "refundStatus": "string (none|pending|processing|completed|failed)", // NEW
  "refundAmount": "number (optional)", // NEW
  "refundReference": "string (optional)" // NEW
}
```

##### payments (existing - add new fields)
```json
{
  // ... existing fields ...
  "provider": "string (paystack|existing_gateway)", // NEW
  "paystackReference": "string (optional)", // NEW
  "paystackTransactionId": "string (optional)", // NEW
  "authorizationCode": "string (optional - for recurring)", // NEW
  "channel": "string (card|bank|ussd|qr|mobile_money|bank_transfer)", // NEW
  "fees": "number (gateway fees)", // NEW
  "gatewayResponse": "string", // NEW
  "ipAddress": "string", // NEW
  "refundable": "boolean", // NEW
  "partiallyRefunded": "number (amount refunded)", // NEW
  "disputeStatus": "string (none|pending|resolved)" // NEW
}
```

### 2. Local Data Handling

#### Important Note
- **No sensitive payment data stored locally**
- Local storage only for transaction references and basic order status
- All payment details remain in Firebase for security compliance

#### Updated Entities

##### OrderFloorEntity (minimal new fields)
```dart
@Entity(tableName: 'orders')
class OrderFloorEntity {
  // ... existing fields ...
  final String paymentProvider; // NEW (cash|paystack|existing_gateway)
  final String? paystackReference; // NEW (transaction reference only)
  final String paymentStatus; // NEW (pending|processing|success|failed)
}
```

### 3. Database Indexes

#### Firestore Indexes

##### paystack_transactions
- Single field: `reference`
- Single field: `orderId`
- Single field: `userId`
- Single field: `status`
- Single field: `created_at` (descending)
- Composite: `userId` + `status`
- Composite: `userId` + `created_at` (descending)
- Composite: `orderId` + `status`

##### paystack_customers
- Single field: `paystackCustomerId`
- Single field: `customerCode`
- Single field: `userId`
- Single field: `email`

##### paystack_saved_cards
- Single field: `userId`
- Single field: `authorization_code`
- Composite: `userId` + `isDefault`
- Composite: `userId` + `createdAt` (descending)

##### orders (new indexes for Paystack fields)
- Single field: `paymentProvider`
- Single field: `paystackReference`
- Single field: `paymentStatus`
- Composite: `userId` + `paymentProvider`
- Composite: `userId` + `paymentStatus`

## Migrations

### 1. Firestore Migration Strategy

#### Phase 1: Add New Collections
1. Create `paystack_transactions` collection with proper indexes
2. Create `paystack_customers` collection with proper indexes
3. Create `paystack_saved_cards` collection with proper indexes

#### Phase 2: Update Existing Collections
1. Add new fields to `orders` collection:
   ```javascript
   // Cloud Function for migration
   const orders = await db.collection('orders').get();
   const batch = db.batch();

   orders.forEach(doc => {
     batch.update(doc.ref, {
       paymentProvider: 'existing_gateway', // default for existing orders
       paymentFees: 0,
       paymentStatus: 'success', // assume existing orders are successful
       refundStatus: 'none'
     });
   });

   await batch.commit();
   ```

2. Add new fields to `payments` collection:
   ```javascript
   const payments = await db.collection('payments').get();
   const batch = db.batch();

   payments.forEach(doc => {
     batch.update(doc.ref, {
       provider: 'existing_gateway',
       fees: 0,
       refundable: true,
       partiallyRefunded: 0,
       disputeStatus: 'none'
     });
   });

   await batch.commit();
   ```

### 2. Floor Database Migration

#### Migration Version: 2 → 3
```dart
final migration2to3 = Migration(2, 3, (database) async {
  // Add minimal new columns to existing orders table
  await database.execute('ALTER TABLE orders ADD COLUMN paymentProvider TEXT DEFAULT "existing_gateway"');
  await database.execute('ALTER TABLE orders ADD COLUMN paystackReference TEXT');
  await database.execute('ALTER TABLE orders ADD COLUMN paymentStatus TEXT DEFAULT "success"');
});
```

## Firestore Security Rules Updates

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Existing rules...

    // Paystack Transactions - users can only read their own transactions
    match /paystack_transactions/{transactionId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         request.auth.token.admin == true);
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }

    // Paystack Customers - users can only access their own customer data
    match /paystack_customers/{customerId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }

    // Paystack Saved Cards - users can only access their own cards
    match /paystack_saved_cards/{cardId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }

    // Update orders rules to include new Paystack fields
    match /orders/{orderId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         request.auth.token.admin == true);
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.userId &&
        validateOrderPaymentFields(request.resource.data);
      allow update: if request.auth != null &&
        (request.auth.uid == resource.data.userId ||
         request.auth.token.admin == true) &&
        validateOrderPaymentFields(request.resource.data);
    }

    // Helper function to validate payment fields
    function validateOrderPaymentFields(data) {
      return data.paymentProvider in ['cash', 'paystack', 'existing_gateway'] &&
             data.paymentStatus in ['pending', 'processing', 'success', 'failed'] &&
             data.refundStatus in ['none', 'pending', 'processing', 'completed', 'failed'];
    }
  }
}
```

## Data Validation Rules

### 1. Paystack Transaction Validation
- `reference` must be unique and match Paystack format
- `amount` must be positive integer (in kobo)
- `currency` must be valid ISO currency code
- `status` must be one of Paystack's valid statuses
- `email` must be valid email format

### 2. Customer Data Validation
- `paystackCustomerId` must be positive integer
- `customerCode` must match Paystack format
- `email` must be valid and match user's email
- `phone` must be valid international format

### 3. Saved Cards Validation
- `authorization_code` must be valid Paystack authorization code
- `last4` must be exactly 4 digits
- `exp_month` must be 01-12
- `exp_year` must be current year or future
- Only one card can be set as default per user

## Backup and Recovery Strategy

### 1. Data Backup
- Enable Firestore automatic backups
- Create daily exports of Paystack collections
- Maintain audit logs for all payment transactions

### 2. Disaster Recovery
- Implement transaction reconciliation with Paystack
- Maintain offline transaction queue for network failures
- Implement retry mechanisms for failed transactions

### 3. Data Integrity
- Implement checksums for critical payment data
- Regular validation of transaction states
- Automated alerts for data inconsistencies
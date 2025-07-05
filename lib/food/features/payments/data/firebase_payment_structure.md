# Firebase Structure for Payment System

## Collections

### 1. orders
```json
{
  "userId": "string",
  "restaurantId": "string", 
  "restaurantName": "string",
  "items": [
    {
      "foodId": "string",
      "foodName": "string",
      "price": "number",
      "quantity": "number",
      "total": "number",
      "specialInstructions": "string (optional)"
    }
  ],
  "subtotal": "number",
  "deliveryFee": "number",
  "tax": "number",
  "total": "number",
  "deliveryAddress": "string",
  "paymentMethod": "string",
  "status": "string (pending|confirmed|preparing|onTheWay|delivered|cancelled)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "deliveredAt": "timestamp (optional)",
  "cancelledAt": "timestamp (optional)",
  "deliveryPersonName": "string (optional)",
  "deliveryPersonPhone": "string (optional)",
  "trackingUrl": "string (optional)",
  "notes": "string (optional)"
}
```

### 2. payments
```json
{
  "transactionId": "string",
  "paymentMethodId": "string",
  "amount": "number",
  "currency": "string",
  "metadata": {
    "orderId": "string",
    "userId": "string",
    "description": "string"
  },
  "status": "string (succeeded|failed|pending|cancelled)",
  "createdAt": "timestamp"
}
```

### 3. users/{userId}/saved_cards
```json
{
  "cardName": "string",
  "cardType": "string (visa|mastercard)",
  "lastFourDigits": "string",
  "mExp": "number",
  "yExp": "number",
  "createdAt": "timestamp"
}
```

## Indexes Needed

### orders collection
- Single field: `userId`
- Single field: `restaurantId`
- Single field: `status`
- Single field: `createdAt` (descending)
- Composite: `userId` + `createdAt` (descending)
- Composite: `userId` + `status`
- Composite: `restaurantId` + `status`

### payments collection
- Single field: `transactionId`
- Single field: `status`
- Single field: `createdAt` (descending)
- Composite: `metadata.userId` + `createdAt` (descending)

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders - users can only read/write their own orders
    match /orders/{orderId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.token.admin == true);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.token.admin == true);
    }
    
    // Payments - users can only read their own payments
    match /payments/{paymentId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.metadata.userId || 
         request.auth.token.admin == true);
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
    
    // Saved cards - users can only access their own cards
    match /users/{userId}/saved_cards/{cardId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

## Payment Flow

1. User adds items to cart
2. User proceeds to checkout
3. User selects delivery address
4. User selects payment method (cash, card, or PayPal)
5. If card payment:
   - Use saved card or add new card
   - Process payment through payment gateway
6. Create order with pending status
7. Process payment
8. Update order status to confirmed
9. Restaurant receives order notification
10. Order status updates: preparing → onTheWay → delivered

## Order Status Flow

```
pending → confirmed → preparing → onTheWay → delivered
                 ↓
             cancelled (can happen at any stage before delivered)
```

## Important Notes

1. **Never store full card details** - Use payment tokenization
2. **PCI Compliance** - Follow payment card industry standards
3. **Encryption** - Encrypt sensitive payment data
4. **Audit Trail** - Log all payment transactions
5. **Idempotency** - Prevent duplicate payments
6. **Webhooks** - Set up payment gateway webhooks for status updates
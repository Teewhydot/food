# Golang Backend Endpoints Report
## Firebase to Golang Migration Endpoint Specification

This document outlines all endpoints needed to migrate from Firebase to a Golang backend.

---

## 🔐 Authentication Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Equivalent |
|--------|----------|-------------|--------------|----------|-------------------|
| POST | `/api/v1/auth/register` | Register new user | `{ email, password, firstName, lastName }` | `{ user, token }` | FirebaseAuth.createUserWithEmailAndPassword |
| POST | `/api/v1/auth/login` | Login user | `{ email, password }` | `{ user, token }` | FirebaseAuth.signInWithEmailAndPassword |
| POST | `/api/v1/auth/logout` | Logout user | `{ }` (requires token) | `{ success }` | FirebaseAuth.signOut |
| POST | `/api/v1/auth/forgot-password` | Send password reset | `{ email }` | `{ success }` | FirebaseAuth.sendPasswordResetEmail |
| POST | `/api/v1/auth/verify-email` | Send verification email | `{ }` (requires token) | `{ success }` | currentUser.sendEmailVerification |
| GET | `/api/v1/auth/verify-status` | Check email verification | Query: `userId` | `{ isVerified }` | currentUser.emailVerified |
| GET | `/api/v1/auth/current-user` | Get current user | `{ }` (requires token) | `{ user }` | FirebaseAuth.currentUser |
| DELETE | `/api/v1/auth/account` | Delete user account | `{ }` (requires token) | `{ success }` | currentUser.delete() |

---

## 👤 User Profile Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId` | Get user profile | - | `{ user }` | users/{userId} |
| PUT | `/api/v1/users/:userId` | Update user profile | `{ firstName, lastName, phoneNumber, bio, profileImageUrl }` | `{ user }` | users/{userId} |

**User Profile Schema:**
```json
{
  "id": "string",
  "firstName": "string",
  "lastName": "string",
  "email": "string",
  "profileImageUrl": "string",
  "phoneNumber": "string",
  "bio": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 🏠 Address Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId/addresses` | Get all user addresses | - | `{ addresses[] }` | users/{userId}/addresses |
| POST | `/api/v1/users/:userId/addresses` | Create new address | `{ title, street, city, state, zipCode, apartment, type, address, latitude, longitude, isDefault }` | `{ address }` | users/{userId}/addresses |
| PUT | `/api/v1/users/:userId/addresses/:addressId` | Update address | `{ title, fullAddress, latitude, longitude, isDefault }` | `{ address }` | users/{userId}/addresses/{id} |
| DELETE | `/api/v1/users/:userId/addresses/:addressId` | Delete address | - | `{ success }` | users/{userId}/addresses/{id} |
| GET | `/api/v1/users/:userId/addresses/default` | Get default address | - | `{ address }` | users/{userId}/addresses (where isDefault=true) |
| PUT | `/api/v1/users/:userId/addresses/:addressId/default` | Set default address | - | `{ success }` | users/{userId}/addresses/{id} |

### Stream Endpoints (WebSocket)

| Endpoint | Description | Event Data | Firebase Equivalent |
|----------|-------------|------------|-------------------|
| `ws://api/v1/users/:userId/addresses/stream` | Watch user addresses | `{ addresses[] }` | snapshots() on addresses collection |

**Address Schema:**
```json
{
  "id": "string",
  "title": "string",
  "street": "string",
  "city": "string",
  "state": "string",
  "zipCode": "string",
  "apartment": "string",
  "address": "string",
  "type": "string (home|work|other)",
  "latitude": "number",
  "longitude": "number",
  "isDefault": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## 🍽️ Restaurant Endpoints

### REST Endpoints

| Method | Endpoint | Description | Query Params | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/restaurants` | Get all restaurants | - | `{ restaurants[] }` | restaurants (orderBy createdAt desc) |
| GET | `/api/v1/restaurants/popular` | Get popular restaurants | - | `{ restaurants[] }` | restaurants (where rating>=4.0, limit 10) |
| GET | `/api/v1/restaurants/nearby` | Get nearby restaurants | `latitude, longitude, radius` | `{ restaurants[] }` | restaurants (with distance calculation) |
| GET | `/api/v1/restaurants/:id` | Get restaurant by ID | - | `{ restaurant }` | restaurants/{id} |
| GET | `/api/v1/restaurants/search` | Search restaurants | `query` | `{ restaurants[] }` | restaurants (client-side filter) |
| GET | `/api/v1/restaurants/category/:category` | Get by category | - | `{ restaurants[] }` | restaurants (where category=category) |
| GET | `/api/v1/restaurants/:id/menu` | Get restaurant menu | - | `{ categories[] }` | restaurants/{id}/categories |

**Restaurant Schema:**
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "location": "string",
  "distance": "number",
  "rating": "number",
  "deliveryTime": "string",
  "deliveryFee": "number",
  "imageUrl": "string",
  "category": "string[]",
  "isOpen": "boolean",
  "latitude": "number",
  "longitude": "number",
  "createdAt": "timestamp"
}
```

---

## 🍕 Food Endpoints

### REST Endpoints

| Method | Endpoint | Description | Query Params | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/foods` | Get all foods | - | `{ foods[] }` | foods (orderBy createdAt desc) |
| GET | `/api/v1/foods/popular` | Get popular foods | - | `{ foods[] }` | foods (where rating>=4.0, limit 10) |
| GET | `/api/v1/foods/recommended` | Get recommended foods | - | `{ foods[] }` | foods (where rating>=4.5, limit 6) |
| GET | `/api/v1/foods/:id` | Get food by ID | - | `{ food }` | foods/{id} |
| GET | `/api/v1/foods/search` | Search foods | `query` | `{ foods[] }` | foods (client-side filter) |
| GET | `/api/v1/foods/category/:category` | Get foods by category | - | `{ foods[] }` | foods (where category=category) |
| GET | `/api/v1/foods/restaurant/:restaurantId` | Get foods by restaurant | - | `{ foods[] }` | foods (where restaurantId=restaurantId) |

**Food Schema:**
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "rating": "number",
  "imageUrl": "string",
  "category": "string",
  "restaurantId": "string",
  "restaurantName": "string",
  "ingredients": "string[]",
  "isAvailable": "boolean",
  "preparationTime": "string",
  "calories": "number",
  "quantity": "number",
  "isVegetarian": "boolean",
  "isVegan": "boolean",
  "isGlutenFree": "boolean",
  "createdAt": "timestamp"
}
```

---

## ❤️ Favorites Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId/favorites/foods` | Get favorite foods | - | `{ foods[] }` | users/{userId}/favorites/foods |
| GET | `/api/v1/users/:userId/favorites/restaurants` | Get favorite restaurants | - | `{ restaurants[] }` | users/{userId}/favorites/restaurants |
| POST | `/api/v1/users/:userId/favorites/foods/:foodId` | Add food to favorites | - | `{ success }` | users/{userId}/favorites/foods |
| DELETE | `/api/v1/users/:userId/favorites/foods/:foodId` | Remove food from favorites | - | `{ success }` | users/{userId}/favorites/foods |
| POST | `/api/v1/users/:userId/favorites/restaurants/:restaurantId` | Add restaurant to favorites | - | `{ success }` | users/{userId}/favorites/restaurants |
| DELETE | `/api/v1/users/:userId/favorites/restaurants/:restaurantId` | Remove restaurant | - | `{ success }` | users/{userId}/favorites/restaurants |
| GET | `/api/v1/users/:userId/favorites/foods/:foodId/check` | Check if food is favorite | - | `{ isFavorite }` | users/{userId}/favorites/foods |
| GET | `/api/v1/users/:userId/favorites/restaurants/:restaurantId/check` | Check if restaurant is favorite | - | `{ isFavorite }` | users/{userId}/favorites/restaurants |
| POST | `/api/v1/users/:userId/favorites/foods/:foodId/toggle` | Toggle food favorite | - | `{ isFavorite }` | users/{userId}/favorites/foods |
| POST | `/api/v1/users/:userId/favorites/restaurants/:restaurantId/toggle` | Toggle restaurant favorite | - | `{ isFavorite }` | users/{userId}/favorites/restaurants |
| DELETE | `/api/v1/users/:userId/favorites/clear` | Clear all favorites | - | `{ success }` | users/{userId}/favorites |
| GET | `/api/v1/users/:userId/favorites/stats` | Get favorites statistics | - | `{ stats }` | users/{userId}/favorites |

### Stream Endpoints (WebSocket)

| Endpoint | Description | Event Data | Firebase Equivalent |
|----------|-------------|------------|-------------------|
| `ws://api/v1/users/:userId/favorites/foods/stream` | Watch favorite food IDs | `{ foodIds[] }` | snapshots() on foods favorites |
| `ws://api/v1/users/:userId/favorites/restaurants/stream` | Watch favorite restaurant IDs | `{ restaurantIds[] }` | snapshots() on restaurants favorites |

---

## 🛒 Cart Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId/cart` | Get user cart | - | `{ cart }` | users/{userId}/cart |
| POST | `/api/v1/users/:userId/cart/items` | Add item to cart | `{ foodId, quantity, ... }` | `{ cart }` | users/{userId}/cart |
| PUT | `/api/v1/users/:userId/cart/items/:itemId` | Update cart item | `{ quantity }` | `{ cart }` | users/{userId}/cart |
| DELETE | `/api/v1/users/:userId/cart/items/:itemId` | Remove from cart | - | `{ cart }` | users/{userId}/cart |
| DELETE | `/api/v1/users/:userId/cart` | Clear cart | - | `{ success }` | users/{userId}/cart |

---

## 📦 Order Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| POST | `/api/v1/orders` | Create new order | `{ userId, restaurantId, items[], deliveryAddress, paymentMethod, total, ... }` | `{ order }` | food_orders |
| GET | `/api/v1/orders/:orderId` | Get order by ID | - | `{ order }` | food_orders/{id} |
| GET | `/api/v1/users/:userId/orders` | Get user orders | - | `{ orders[] }` | food_orders (where userId=userId) |
| PUT | `/api/v1/orders/:orderId/cancel` | Cancel order | - | `{ order }` | food_orders/{id} |
| PUT | `/api/v1/orders/:orderId/status` | Update order status | `{ status, service_status }` | `{ order }` | food_orders/{id} |

### Stream Endpoints (WebSocket)

| Endpoint | Description | Event Data | Firebase Equivalent |
|----------|-------------|------------|-------------------|
| `ws://api/v1/users/:userId/orders/stream` | Stream user orders | `{ orders[] }` | snapshots() on user orders |
| `ws://api/v1/orders/:orderId/stream` | Stream order updates | `{ order }` | snapshots() on specific order |

**Order Schema:**
```json
{
  "id": "string",
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
      "specialInstructions": "string"
    }
  ],
  "subtotal": "number",
  "deliveryFee": "number",
  "tax": "number",
  "total": "number",
  "deliveryAddress": "string",
  "paymentMethod": "string",
  "status": "pending|confirmed|preparing|onTheWay|delivered|cancelled",
  "service_status": "pending|confirmed|preparing|onTheWay|delivered|cancelled",
  "createdAt": "timestamp",
  "deliveredAt": "timestamp",
  "cancelledAt": "timestamp",
  "deliveryPersonName": "string",
  "deliveryPersonPhone": "string",
  "trackingUrl": "string",
  "notes": "string"
}
```

---

## 💳 Payment Endpoints

### REST Endpoints (Paystack)

| Method | Endpoint | Description | Request Body | Response | External API |
|--------|----------|-------------|--------------|----------|--------------|
| POST | `/api/v1/payments/paystack/initialize` | Initialize Paystack payment | `{ orderId, amount, email, metadata }` | `{ authorizationUrl, reference }` | Paystack API |
| POST | `/api/v1/payments/paystack/verify` | Verify Paystack payment | `{ reference, orderId }` | `{ transaction }` | Paystack API |

### REST Endpoints (Flutterwave)

| Method | Endpoint | Description | Request Body | Response | External API |
|--------|----------|-------------|--------------|----------|--------------|
| POST | `/api/v1/payments/flutterwave/charge` | Charge card via Flutterwave | `{ cardNumber, cvv, expiryMonth, expiryYear, amount, email, ... }` | `{ transaction }` | Flutterwave API |
| POST | `/api/v1/payments/flutterwave/validate` | Validate Flutterwave payment | `{ flw_ref, otp }` | `{ transaction }` | Flutterwave API |

**Payment Transaction Schema:**
```json
{
  "transactionId": "string",
  "orderId": "string",
  "userId": "string",
  "amount": "number",
  "currency": "string",
  "paymentMethod": "paystack|flutterwave",
  "status": "succeeded|failed|pending|cancelled",
  "authorizationUrl": "string",
  "reference": "string",
  "createdAt": "timestamp"
}
```

---

## 💬 Chat Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId/chats` | Get user chats | - | `{ chats[] }` | chats (where participants contains userId) |
| GET | `/api/v1/chats/:chatId` | Get chat by ID | - | `{ chat }` | chats/{id} |
| POST | `/api/v1/chats` | Create or get chat | `{ userId, otherUserId, orderId }` | `{ chat }` | chats |
| GET | `/api/v1/chats/:chatId/messages` | Get chat messages | - | `{ messages[] }` | chats/{id}/messages |
| POST | `/api/v1/chats/:chatId/messages` | Send message | `{ senderId, receiverId, content }` | `{ message }` | chats/{id}/messages |
| PUT | `/api/v1/chats/:chatId` | Update last message | `{ lastMessage, timestamp }` | `{ success }` | chats/{id} |
| PUT | `/api/v1/messages/:messageId/read` | Mark message as read | - | `{ success }` | messages/{id} |
| DELETE | `/api/v1/messages/:messageId` | Delete message | - | `{ success }` | messages/{id} |

### Stream Endpoints (WebSocket)

| Endpoint | Description | Event Data | Firebase Equivalent |
|----------|-------------|------------|-------------------|
| `ws://api/v1/users/:userId/chats/stream` | Watch user chats | `{ chats[] }` | snapshots() on chats |
| `ws://api/v1/chats/:chatId/messages/stream` | Watch chat messages | `{ messages[] }` | snapshots() on messages |
| `ws://api/v1/chats/:chatId/messages/new` | Watch new messages | `{ message }` | snapshots().limit(1) |

**Chat Schema:**
```json
{
  "id": "string",
  "participants": ["userId1", "userId2"],
  "orderId": "string",
  "lastMessage": "string",
  "lastMessageTime": "timestamp",
  "createdAt": "timestamp",
  "participantDetails": {
    "userId1": {
      "id": "string",
      "name": "string",
      "imageUrl": "string"
    },
    "userId2": {
      "id": "string",
      "name": "string",
      "imageUrl": "string"
    }
  }
}
```

**Message Schema:**
```json
{
  "id": "string",
  "chatId": "string",
  "senderId": "string",
  "receiverId": "string",
  "content": "string",
  "timestamp": "timestamp",
  "isRead": "boolean"
}
```

---

## 🔔 Notification Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Firebase Collection |
|--------|----------|-------------|--------------|----------|-------------------|
| GET | `/api/v1/users/:userId/notifications` | Get user notifications | - | `{ notifications[] }` | users/{userId}/notifications |
| PUT | `/api/v1/notifications/:notificationId/read` | Mark notification as read | - | `{ success }` | notifications/{id} |
| DELETE | `/api/v1/notifications/:notificationId` | Delete notification | - | `{ success }` | notifications/{id} |

### Stream Endpoints (WebSocket)

| Endpoint | Description | Event Data | Firebase Equivalent |
|----------|-------------|------------|-------------------|
| `ws://api/v1/users/:userId/notifications/stream` | Watch notifications | `{ notifications[] }` | snapshots() on notifications |

---

## 📁 File Upload Endpoints

### REST Endpoints

| Method | Endpoint | Description | Request Body | Response | Service |
|--------|----------|-------------|--------------|----------|---------|
| POST | `/api/v1/upload/image` | Upload image | FormData: `{ file, folder }` | `{ url, fileId }` | ImageKit/Cloud Storage |
| DELETE | `/api/v1/upload/:fileId` | Delete uploaded file | - | `{ success }` | ImageKit/Cloud Storage |

---

## 🗺️ Geocoding Endpoints

### REST Endpoints

| Method | Endpoint | Description | Query Params | Response | External API |
|--------|----------|-------------|--------------|----------|--------------|
| GET | `/api/v1/geocode/reverse` | Reverse geocode coordinates | `latitude, longitude` | `{ address, placemark }` | OpenWeather/Google Maps |
| GET | `/api/v1/geocode/forward` | Forward geocode address | `address` | `{ coordinates }` | OpenWeather/Google Maps |

---

## 🔑 Authentication Strategy

### JWT Token Structure
```json
{
  "userId": "string",
  "email": "string",
  "role": "user|admin",
  "exp": "number (expiration timestamp)",
  "iat": "number (issued at timestamp)"
}
```

### Headers Required
- `Authorization: Bearer <jwt_token>` for authenticated endpoints
- `Content-Type: application/json` for JSON requests
- `Content-Type: multipart/form-data` for file uploads

---

## 🔌 WebSocket Connection Pattern

### Connection
```javascript
const ws = new WebSocket('ws://api.yourbackend.com/ws?token=<jwt_token>');
```

### Message Format
```json
{
  "type": "subscribe|unsubscribe|message",
  "channel": "orders|chats|notifications",
  "data": {}
}
```

### Subscribe to Channel
```json
{
  "type": "subscribe",
  "channel": "orders:userId123"
}
```

### Unsubscribe from Channel
```json
{
  "type": "unsubscribe",
  "channel": "orders:userId123"
}
```

---

## 📊 Implementation Priority

### Phase 1 (Critical)
1. ✅ Authentication endpoints
2. ✅ User profile endpoints
3. ✅ Restaurant endpoints
4. ✅ Food endpoints
5. ✅ Order endpoints (REST + WebSocket)

### Phase 2 (Important)
1. ✅ Cart endpoints
2. ✅ Address endpoints (REST + WebSocket)
3. ✅ Payment endpoints (Paystack & Flutterwave)
4. ✅ Favorites endpoints

### Phase 3 (Enhanced Features)
1. ✅ Chat endpoints (REST + WebSocket)
2. ✅ Notification endpoints (REST + WebSocket)
3. ✅ File upload endpoints
4. ✅ Geocoding endpoints

---

## 🛠️ Technology Stack Recommendations

### Backend
- **Language**: Golang 1.21+
- **Framework**: Gin or Fiber (for REST API)
- **WebSocket**: Gorilla WebSocket or ws
- **Database**: PostgreSQL or MongoDB
- **Cache**: Redis
- **Authentication**: JWT with RS256

### Infrastructure
- **API Gateway**: Kong or Traefik
- **Load Balancer**: Nginx
- **Container**: Docker + Docker Compose
- **Orchestration**: Kubernetes (optional)

### Golang Packages
```go
// Core
github.com/gin-gonic/gin              // Web framework
github.com/gorilla/websocket          // WebSocket
github.com/dgrijalva/jwt-go           // JWT auth

// Database
gorm.io/gorm                          // ORM
github.com/go-redis/redis/v8          // Redis client

// External Services
github.com/paystack/paystack-go       // Paystack SDK
github.com/flutterwave/flutterwave-go // Flutterwave SDK

// Utilities
github.com/joho/godotenv              // Environment variables
github.com/google/uuid                // UUID generation
```

---

## 📝 Migration Checklist

- [ ] Set up Golang project structure
- [ ] Implement JWT authentication middleware
- [ ] Create database schemas (PostgreSQL/MongoDB)
- [ ] Implement REST endpoints (Phase 1)
- [ ] Implement WebSocket handlers
- [ ] Set up Redis for caching
- [ ] Integrate Paystack & Flutterwave
- [ ] Implement file upload service
- [ ] Set up API documentation (Swagger)
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Deploy to staging environment
- [ ] Load testing
- [ ] Deploy to production
- [ ] Monitor and optimize

---

## 📚 Additional Notes

### Error Response Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": {}
  }
}
```

### Success Response Format
```json
{
  "data": {},
  "message": "Success message (optional)",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### Pagination
- Query params: `?page=1&limit=20`
- Response includes `meta` object with pagination info

### Filtering & Sorting
- Filter: `?category=pizza&rating=4.5`
- Sort: `?sort=createdAt:desc,rating:asc`

---

*Generated on: $(date)*
*Firebase Collections Analyzed: 10+*
*Total Endpoints: 80+*

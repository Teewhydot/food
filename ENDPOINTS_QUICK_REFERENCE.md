# Golang Backend - Quick Endpoints Reference

## 🔗 Base URL
```
Production: https://api.yourbackend.com/api/v1
Development: http://localhost:8080/api/v1
WebSocket: ws://api.yourbackend.com/ws
```

---

## 📋 Endpoints Summary

### Authentication (8 endpoints)
```
POST   /auth/register              - Register new user
POST   /auth/login                 - Login user
POST   /auth/logout                - Logout user
POST   /auth/forgot-password       - Password reset
POST   /auth/verify-email          - Send verification
GET    /auth/verify-status         - Check verification
GET    /auth/current-user          - Get current user
DELETE /auth/account               - Delete account
```

### Users (2 endpoints)
```
GET    /users/:userId              - Get user profile
PUT    /users/:userId              - Update profile
```

### Addresses (7 endpoints + 1 WS)
```
GET    /users/:userId/addresses                    - List addresses
POST   /users/:userId/addresses                    - Create address
PUT    /users/:userId/addresses/:id                - Update address
DELETE /users/:userId/addresses/:id                - Delete address
GET    /users/:userId/addresses/default            - Get default
PUT    /users/:userId/addresses/:id/default        - Set default

WS     /users/:userId/addresses/stream             - Watch addresses
```

### Restaurants (7 endpoints)
```
GET    /restaurants                - List all
GET    /restaurants/popular        - Popular only
GET    /restaurants/nearby         - By location
GET    /restaurants/:id            - Single restaurant
GET    /restaurants/search         - Search
GET    /restaurants/category/:cat  - By category
GET    /restaurants/:id/menu       - Get menu
```

### Foods (7 endpoints)
```
GET    /foods                      - List all
GET    /foods/popular              - Popular only
GET    /foods/recommended          - Recommended
GET    /foods/:id                  - Single food
GET    /foods/search               - Search
GET    /foods/category/:cat        - By category
GET    /foods/restaurant/:id       - By restaurant
```

### Favorites (14 endpoints + 2 WS)
```
GET    /users/:userId/favorites/foods              - List favorite foods
GET    /users/:userId/favorites/restaurants        - List favorite restaurants
POST   /users/:userId/favorites/foods/:id          - Add food
DELETE /users/:userId/favorites/foods/:id          - Remove food
POST   /users/:userId/favorites/restaurants/:id    - Add restaurant
DELETE /users/:userId/favorites/restaurants/:id    - Remove restaurant
GET    /users/:userId/favorites/foods/:id/check    - Check food
GET    /users/:userId/favorites/restaurants/:id/check - Check restaurant
POST   /users/:userId/favorites/foods/:id/toggle   - Toggle food
POST   /users/:userId/favorites/restaurants/:id/toggle - Toggle restaurant
DELETE /users/:userId/favorites/clear              - Clear all
GET    /users/:userId/favorites/stats              - Get stats

WS     /users/:userId/favorites/foods/stream       - Watch food favorites
WS     /users/:userId/favorites/restaurants/stream - Watch restaurant favorites
```

### Cart (5 endpoints)
```
GET    /users/:userId/cart         - Get cart
POST   /users/:userId/cart/items   - Add item
PUT    /users/:userId/cart/items/:id - Update item
DELETE /users/:userId/cart/items/:id - Remove item
DELETE /users/:userId/cart          - Clear cart
```

### Orders (5 endpoints + 2 WS)
```
POST   /orders                     - Create order
GET    /orders/:id                 - Get order
GET    /users/:userId/orders       - List user orders
PUT    /orders/:id/cancel          - Cancel order
PUT    /orders/:id/status          - Update status

WS     /users/:userId/orders/stream - Watch user orders
WS     /orders/:id/stream           - Watch order updates
```

### Payments - Paystack (2 endpoints)
```
POST   /payments/paystack/initialize - Initialize payment
POST   /payments/paystack/verify     - Verify payment
```

### Payments - Flutterwave (2 endpoints)
```
POST   /payments/flutterwave/charge   - Charge card
POST   /payments/flutterwave/validate - Validate payment
```

### Chat (8 endpoints + 3 WS)
```
GET    /users/:userId/chats        - List chats
GET    /chats/:id                  - Get chat
POST   /chats                      - Create/get chat
GET    /chats/:id/messages         - List messages
POST   /chats/:id/messages         - Send message
PUT    /chats/:id                  - Update last message
PUT    /messages/:id/read          - Mark read
DELETE /messages/:id               - Delete message

WS     /users/:userId/chats/stream      - Watch user chats
WS     /chats/:id/messages/stream       - Watch messages
WS     /chats/:id/messages/new          - Watch new messages
```

### Notifications (3 endpoints + 1 WS)
```
GET    /users/:userId/notifications    - List notifications
PUT    /notifications/:id/read         - Mark read
DELETE /notifications/:id              - Delete notification

WS     /users/:userId/notifications/stream - Watch notifications
```

### File Upload (2 endpoints)
```
POST   /upload/image               - Upload image
DELETE /upload/:fileId             - Delete file
```

### Geocoding (2 endpoints)
```
GET    /geocode/reverse            - Reverse geocode
GET    /geocode/forward            - Forward geocode
```

---

## 📊 Endpoint Count
- **REST Endpoints**: 80
- **WebSocket Streams**: 10
- **Total**: 90 endpoints

---

## 🔐 Authentication
All authenticated endpoints require:
```
Authorization: Bearer <jwt_token>
```

---

## 📦 Response Format

### Success
```json
{
  "data": {},
  "message": "Success",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

### Error
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message",
    "details": {}
  }
}
```

---

## 🔌 WebSocket Usage

### Connect
```javascript
const ws = new WebSocket('ws://api.backend.com/ws?token=<jwt>');
```

### Subscribe
```json
{
  "type": "subscribe",
  "channel": "orders:userId123"
}
```

### Message
```json
{
  "type": "message",
  "channel": "orders:userId123",
  "data": { "order": {...} }
}
```

---

## 🎯 Collections Map

| Flutter Collection | Golang Table/Collection |
|-------------------|------------------------|
| `users` | `users` |
| `users/{id}/addresses` | `addresses` |
| `users/{id}/favorites/foods` | `favorite_foods` |
| `users/{id}/favorites/restaurants` | `favorite_restaurants` |
| `restaurants` | `restaurants` |
| `restaurants/{id}/categories` | `restaurant_categories` |
| `foods` | `foods` |
| `food_orders` | `orders` |
| `chats` | `chats` |
| `chats/{id}/messages` | `messages` |

---

## 🛠️ Required Environment Variables

```env
# Server
PORT=8080
ENVIRONMENT=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=food_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRY=24h

# Paystack
PAYSTACK_SECRET_KEY=sk_test_xxx
PAYSTACK_PUBLIC_KEY=pk_test_xxx

# Flutterwave
FLUTTERWAVE_SECRET_KEY=FLWSECK_TEST-xxx
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_TEST-xxx
FLUTTERWAVE_ENCRYPTION_KEY=FLWSECK_TEST-xxx

# File Upload
IMAGEKIT_PUBLIC_KEY=xxx
IMAGEKIT_PRIVATE_KEY=xxx
IMAGEKIT_URL_ENDPOINT=https://ik.imagekit.io/xxx

# Geocoding
OPENWEATHER_API_KEY=xxx
```

---

## 📈 Performance Considerations

### Caching Strategy (Redis)
- User profiles: 1 hour TTL
- Restaurants/Foods: 30 minutes TTL
- Favorites: 5 minutes TTL
- Cart: No cache (real-time)
- Orders: No cache (real-time)

### Database Indexes
```sql
-- Users
CREATE INDEX idx_users_email ON users(email);

-- Addresses
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_is_default ON addresses(is_default);

-- Restaurants
CREATE INDEX idx_restaurants_rating ON restaurants(rating DESC);
CREATE INDEX idx_restaurants_category ON restaurants(category);

-- Foods
CREATE INDEX idx_foods_restaurant_id ON foods(restaurant_id);
CREATE INDEX idx_foods_rating ON foods(rating DESC);
CREATE INDEX idx_foods_category ON foods(category);

-- Orders
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- Favorites
CREATE INDEX idx_favorite_foods_user_id ON favorite_foods(user_id);
CREATE INDEX idx_favorite_restaurants_user_id ON favorite_restaurants(user_id);

-- Chats
CREATE INDEX idx_chats_participants ON chats USING GIN(participants);
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
```

---

## 🚀 Quick Start Commands

```bash
# Clone and setup
git clone <golang-backend-repo>
cd golang-backend

# Install dependencies
go mod download

# Run migrations
make migrate-up

# Seed database
make seed

# Run server
make run

# Run tests
make test

# Build for production
make build
```

---

*For detailed implementation, see GOLANG_BACKEND_ENDPOINTS.md*

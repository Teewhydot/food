# Firebase to Golang Backend Migration - Complete API Endpoints Report

Based on the comprehensive analysis of your Flutter food delivery application, here's the complete list of endpoints needed to migrate from Firebase to a Golang backend:

## **1. Authentication Endpoints**

### User Authentication
- `POST /auth/register` - User registration with email/password
- `POST /auth/login` - User login with email/password
- `POST /auth/logout` - User logout
- `DELETE /auth/delete-account` - Delete user account and associated data

### Email Management
- `POST /auth/send-password-reset` - Send password reset email
- `POST /auth/send-email-verification` - Send email verification
- `GET /auth/verify-email-status` - Check email verification status
- `GET /auth/current-user` - Get current authenticated user info

---

## **2. User Profile Endpoints**

### Profile Management
- `GET /users/{userId}` - Get user profile
- `PUT /users/{userId}` - Update user profile
- `PATCH /users/{userId}/{field}` - Update specific profile field
- `POST /users/{userId}/upload-image` - Upload profile image
- `DELETE /users/{userId}/profile-image` - Delete profile image
- `GET /users/{userId}/stream` - WebSocket/SSE for real-time profile updates
- `POST /users/{userId}/sync-profile` - Sync local profile changes

---

## **3. Restaurant Endpoints**

### Restaurant Data
- `GET /restaurants` - Get all restaurants (paginated)
- `GET /restaurants/{id}` - Get restaurant by ID
- `GET /restaurants/popular` - Get popular restaurants (rating >= 4.0)
- `GET /restaurants/nearby` - Get nearby restaurants (lat/lng query params)
- `GET /restaurants/search` - Search restaurants by name/category/description
- `GET /restaurants/category/{category}` - Get restaurants by category
- `GET /restaurants/{id}/menu` - Get restaurant menu/categories with foods

### Location-based
- `GET /restaurants/nearby?lat={lat}&lng={lng}&radius={km}` - Geolocation search

---

## **4. Food/Menu Endpoints**

### Food Data
- `GET /foods` - Get all foods (paginated)
- `GET /foods/{id}` - Get food item by ID
- `GET /foods/popular` - Get popular foods (rating >= 4.0)
- `GET /foods/recommended` - Get recommended foods (rating >= 4.5)
- `GET /foods/category/{category}` - Get foods by category
- `GET /foods/restaurant/{restaurantId}` - Get foods by restaurant
- `GET /foods/search` - Search foods by name/category/description/restaurant

---

## **5. Order Endpoints**

### Order Management
- `POST /orders` - Create new order
- `GET /orders/user/{userId}` - Get user's order history
- `GET /orders/{orderId}` - Get specific order details
- `PUT /orders/{orderId}/status` - Update order status
- `DELETE /orders/{orderId}` - Cancel order
- `GET /orders/{orderId}/track` - Get order tracking info

### Order Status Flow
Order statuses: `pending`, `confirmed`, `preparing`, `onTheWay`, `delivered`, `cancelled`

---

## **6. Payment Endpoints**

### Payment Methods
- `GET /payments/methods` - Get available payment methods
- `GET /payments/cards/{userId}` - Get user's saved cards
- `POST /payments/cards` - Save new payment card
- `DELETE /payments/cards/{cardId}` - Delete saved card

### Payment Processing
- `POST /payments/process` - Process payment for order
- `GET /payments/transaction/{transactionId}` - Get payment transaction details
- `POST /payments/refund` - Process refund

---

## **7. Address Management Endpoints**

### User Addresses
- `GET /users/{userId}/addresses` - Get user's saved addresses
- `POST /users/{userId}/addresses` - Save new address
- `PUT /users/{userId}/addresses/{addressId}` - Update address
- `DELETE /users/{userId}/addresses/{addressId}` - Delete address
- `GET /users/{userId}/addresses/default` - Get default address
- `PUT /users/{userId}/addresses/{addressId}/set-default` - Set default address
- `GET /users/{userId}/addresses/stream` - WebSocket for real-time address updates

---

## **8. Favorites Endpoints**

### Favorites Management
- `GET /users/{userId}/favorites/foods` - Get favorite foods
- `GET /users/{userId}/favorites/restaurants` - Get favorite restaurants
- `POST /users/{userId}/favorites/foods/{foodId}` - Add food to favorites
- `DELETE /users/{userId}/favorites/foods/{foodId}` - Remove food from favorites
- `POST /users/{userId}/favorites/restaurants/{restaurantId}` - Add restaurant to favorites
- `DELETE /users/{userId}/favorites/restaurants/{restaurantId}` - Remove restaurant from favorites
- `GET /users/{userId}/favorites/foods/{foodId}/status` - Check if food is favorite
- `GET /users/{userId}/favorites/restaurants/{restaurantId}/status` - Check if restaurant is favorite
- `POST /users/{userId}/favorites/foods/{foodId}/toggle` - Toggle food favorite status
- `POST /users/{userId}/favorites/restaurants/{restaurantId}/toggle` - Toggle restaurant favorite status
- `DELETE /users/{userId}/favorites` - Clear all favorites
- `GET /users/{userId}/favorites/stats` - Get favorites statistics
- `GET /users/{userId}/favorites/foods/stream` - WebSocket for favorite food IDs
- `GET /users/{userId}/favorites/restaurants/stream` - WebSocket for favorite restaurant IDs

---

## **9. Chat/Messaging Endpoints**

### Chat Management
- `GET /users/{userId}/chats` - Get user's chat list
- `GET /chats/{chatId}` - Get specific chat details
- `POST /chats` - Create or get chat (with userId, otherUserId, orderId)
- `PUT /chats/{chatId}/last-message` - Update last message info
- `GET /chats/{chatId}/messages` - Get chat messages
- `POST /chats/{chatId}/messages` - Send message
- `PUT /messages/{messageId}/read` - Mark message as read
- `DELETE /messages/{messageId}` - Delete message

### Real-time Messaging
- `GET /users/{userId}/chats/stream` - WebSocket for real-time chat list updates
- `GET /chats/{chatId}/messages/stream` - WebSocket for real-time messages
- `GET /chats/{chatId}/new-messages/stream` - WebSocket for new message notifications

---

## **10. Notification Endpoints**

### Notification Management
- `GET /users/{userId}/notifications` - Get user notifications (limit 50)
- `POST /notifications` - Send notification to user
- `PUT /notifications/{notificationId}/read` - Mark notification as read
- `DELETE /notifications/{notificationId}` - Delete notification
- `GET /users/{userId}/notifications/stream` - WebSocket for real-time notifications

### Push Notifications
- `POST /users/{userId}/fcm-token` - Update FCM token
- `GET /users/{userId}/fcm-token` - Get FCM token
- `POST /push-notifications/send` - Send push notification to user

---

## **11. File Upload Endpoints**

### Image Management
- `POST /upload/profile-image` - Upload profile images
- `POST /upload/food-image` - Upload food images  
- `POST /upload/restaurant-image` - Upload restaurant images
- `DELETE /upload/{imageId}` - Delete uploaded image

---

## **Database Collections Structure**

Based on the analysis, your Golang backend will need these main collections/tables:

1. **users** - User profiles and authentication data
2. **restaurants** - Restaurant information with geolocation
3. **foods** - Food items with restaurant relationships
4. **orders** - Order transactions and history
5. **payments** - Payment transaction logs
6. **chats** - Chat conversations
7. **messages** - Individual chat messages
8. **notifications** - User notifications
9. **favorites** (subcollections: foods, restaurants) - User favorites
10. **addresses** (user subcollection) - User saved addresses
11. **saved_cards** (user subcollection) - User saved payment methods

## **Request/Response Examples**

### Authentication
```json
// POST /auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}

// Response
{
  "id": "user_id_123",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "token": "jwt_token_here"
}
```

### Create Order
```json
// POST /orders
{
  "userId": "user_id_123",
  "restaurantId": "restaurant_id_456",
  "restaurantName": "Pizza Palace",
  "items": [
    {
      "foodId": "food_id_789",
      "foodName": "Margherita Pizza",
      "price": 12.99,
      "quantity": 2,
      "total": 25.98,
      "specialInstructions": "Extra cheese"
    }
  ],
  "subtotal": 25.98,
  "deliveryFee": 3.50,
  "tax": 2.34,
  "total": 31.82,
  "deliveryAddress": "123 Main St, City, State 12345",
  "paymentMethod": "card_id_101",
  "notes": "Ring the doorbell"
}
```

### Restaurant Search
```json
// GET /restaurants/search?query=pizza&lat=40.7128&lng=-74.0060&radius=5

// Response
{
  "restaurants": [
    {
      "id": "restaurant_id_456",
      "name": "Pizza Palace",
      "description": "Authentic Italian pizza",
      "location": "123 Pizza St",
      "distance": 2.5,
      "rating": 4.5,
      "deliveryTime": "25-35 min",
      "deliveryFee": 3.50,
      "imageUrl": "https://example.com/pizza-palace.jpg",
      "categories": ["Italian", "Pizza"],
      "isOpen": true,
      "latitude": 40.7589,
      "longitude": -73.9851
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "hasMore": false
  }
}
```

## **Key Migration Considerations**

### 1. Real-time Features
- Implement WebSocket connections for:
  - Chat messaging
  - Order status updates
  - Live notifications
  - Real-time location tracking

### 2. Database Design
- **PostgreSQL** recommended for ACID compliance and complex queries
- **PostGIS** extension for geolocation-based restaurant searches
- **Redis** for caching frequently accessed data (menus, popular items)

### 3. Authentication & Security
- JWT-based authentication system
- Rate limiting for API endpoints
- Input validation and sanitization
- CORS configuration for mobile app access

### 4. File Storage
- Cloud storage integration (AWS S3, Google Cloud Storage, etc.)
- Image optimization and resizing
- CDN for fast image delivery

### 5. Payment Integration
- Stripe, PayPal, or local payment gateway integration
- PCI DSS compliance for card data
- Webhook handling for payment status updates

### 6. Push Notifications
- Firebase Cloud Messaging (FCM) integration
- Background job processing for notification delivery
- Template-based notification system

### 7. Performance Optimization
- Database indexing for frequently queried fields
- Connection pooling
- Caching strategies
- API response compression

### 8. Monitoring & Logging
- Structured logging (JSON format)
- Application performance monitoring
- Error tracking and alerting
- Health check endpoints

## **API Response Standards**

### Success Response Format
```json
{
  "success": true,
  "data": {
    // response data
  },
  "message": "Operation completed successfully"
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "email",
      "issue": "Invalid email format"
    }
  }
}
```

### Pagination Response Format
```json
{
  "success": true,
  "data": [
    // array of items
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "hasMore": true,
    "nextPage": 2
  }
}
```

## **Migration Timeline Recommendation**

### Phase 1: Core Infrastructure (Week 1-2)
- Set up Golang project structure
- Database design and migrations
- Authentication system
- Basic CRUD endpoints for users, restaurants, foods

### Phase 2: Business Logic (Week 3-4)
- Order management system
- Payment integration
- Address management
- Search functionality

### Phase 3: Real-time Features (Week 5-6)
- WebSocket implementation for chat
- Push notification system
- Real-time order tracking

### Phase 4: Advanced Features (Week 7-8)
- Favorites system
- File upload service
- Performance optimization
- Testing and deployment

This comprehensive endpoint specification will ensure a smooth migration from Firebase to your custom Golang backend while maintaining all existing functionality and preparing for future scalability.
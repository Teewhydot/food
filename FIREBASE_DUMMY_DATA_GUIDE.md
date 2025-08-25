# Firebase Dummy Data Guide for Food Delivery App

## Table of Contents
1. [Overview](#overview)
2. [Firebase Structure](#firebase-structure)
3. [Dummy Data Samples](#dummy-data-samples)
4. [Implementation Scripts](#implementation-scripts)
5. [Testing Strategy](#testing-strategy)
6. [Best Practices](#best-practices)

## Overview

This guide provides comprehensive documentation for adding dummy data to Firebase for the Food Delivery App. The data structure supports restaurants, food items, orders, payments, chats, and user profiles.

## Firebase Structure

### Collections Hierarchy
```
firestore/
├── restaurants/
│   └── {restaurantId}/
│       └── categories/
├── foods/
├── orders/
├── payments/
├── chats/
│   └── {chatId}/
│       └── messages/
├── users/
│   └── {userId}/
│       ├── saved_cards/
│       ├── addresses/
│       └── favorites/
└── notifications/
```

## Dummy Data Samples

### 1. Users Collection
```json
{
  "users": {
    "user_001": {
      "uid": "user_001",
      "email": "john.doe@example.com",
      "displayName": "John Doe",
      "phoneNumber": "+1234567890",
      "photoURL": "https://api.dicebear.com/7.x/avataaars/svg?seed=john",
      "addresses": [
        {
          "id": "addr_001",
          "type": "home",
          "street": "123 Main Street",
          "city": "New York",
          "state": "NY",
          "zipCode": "10001",
          "country": "USA",
          "latitude": 40.7128,
          "longitude": -74.0060,
          "isDefault": true
        },
        {
          "id": "addr_002",
          "type": "work",
          "street": "456 Business Ave",
          "city": "New York",
          "state": "NY",
          "zipCode": "10002",
          "country": "USA",
          "latitude": 40.7260,
          "longitude": -73.9897,
          "isDefault": false
        }
      ],
      "createdAt": "2024-01-15T10:00:00Z",
      "updatedAt": "2024-01-15T10:00:00Z"
    },
    "user_002": {
      "uid": "user_002",
      "email": "jane.smith@example.com",
      "displayName": "Jane Smith",
      "phoneNumber": "+1234567891",
      "photoURL": "https://api.dicebear.com/7.x/avataaars/svg?seed=jane",
      "addresses": [
        {
          "id": "addr_003",
          "type": "home",
          "street": "789 Oak Drive",
          "city": "Los Angeles",
          "state": "CA",
          "zipCode": "90001",
          "country": "USA",
          "latitude": 34.0522,
          "longitude": -118.2437,
          "isDefault": true
        }
      ],
      "createdAt": "2024-01-16T11:00:00Z",
      "updatedAt": "2024-01-16T11:00:00Z"
    }
  }
}
```

### 2. Restaurants Collection
```json
{
  "restaurants": {
    "rest_001": {
      "id": "rest_001",
      "name": "Burger Palace",
      "description": "Best burgers in town with fresh ingredients",
      "location": "Downtown Manhattan",
      "distance": 2.5,
      "rating": 4.5,
      "deliveryTime": "25-35 min",
      "deliveryFee": 3.99,
      "imageUrl": "https://images.unsplash.com/photo-1571091718767-18b5b1457add",
      "category": "Fast Food",
      "isOpen": true,
      "latitude": 40.7128,
      "longitude": -74.0060,
      "cuisine": ["American", "Fast Food"],
      "priceRange": "$$",
      "workingHours": {
        "monday": "10:00-22:00",
        "tuesday": "10:00-22:00",
        "wednesday": "10:00-22:00",
        "thursday": "10:00-22:00",
        "friday": "10:00-23:00",
        "saturday": "11:00-23:00",
        "sunday": "11:00-21:00"
      },
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "rest_002": {
      "id": "rest_002",
      "name": "Pizza Heaven",
      "description": "Authentic Italian pizzas with wood-fired oven",
      "location": "Brooklyn Heights",
      "distance": 3.2,
      "rating": 4.7,
      "deliveryTime": "30-40 min",
      "deliveryFee": 4.99,
      "imageUrl": "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
      "category": "Italian",
      "isOpen": true,
      "latitude": 40.6950,
      "longitude": -73.9936,
      "cuisine": ["Italian", "Pizza"],
      "priceRange": "$$$",
      "workingHours": {
        "monday": "11:00-23:00",
        "tuesday": "11:00-23:00",
        "wednesday": "11:00-23:00",
        "thursday": "11:00-23:00",
        "friday": "11:00-00:00",
        "saturday": "11:00-00:00",
        "sunday": "12:00-22:00"
      },
      "createdAt": "2024-01-02T00:00:00Z"
    },
    "rest_003": {
      "id": "rest_003",
      "name": "Sushi Master",
      "description": "Fresh sushi and Japanese cuisine",
      "location": "Upper East Side",
      "distance": 4.1,
      "rating": 4.8,
      "deliveryTime": "35-45 min",
      "deliveryFee": 5.99,
      "imageUrl": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351",
      "category": "Japanese",
      "isOpen": true,
      "latitude": 40.7736,
      "longitude": -73.9566,
      "cuisine": ["Japanese", "Sushi"],
      "priceRange": "$$$$",
      "workingHours": {
        "monday": "12:00-22:00",
        "tuesday": "12:00-22:00",
        "wednesday": "12:00-22:00",
        "thursday": "12:00-22:00",
        "friday": "12:00-23:00",
        "saturday": "12:00-23:00",
        "sunday": "12:00-21:00"
      },
      "createdAt": "2024-01-03T00:00:00Z"
    },
    "rest_004": {
      "id": "rest_004",
      "name": "Taco Fiesta",
      "description": "Authentic Mexican street food",
      "location": "Queens",
      "distance": 5.5,
      "rating": 4.6,
      "deliveryTime": "20-30 min",
      "deliveryFee": 2.99,
      "imageUrl": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47",
      "category": "Mexican",
      "isOpen": true,
      "latitude": 40.7282,
      "longitude": -73.7949,
      "cuisine": ["Mexican", "Street Food"],
      "priceRange": "$",
      "workingHours": {
        "monday": "10:00-23:00",
        "tuesday": "10:00-23:00",
        "wednesday": "10:00-23:00",
        "thursday": "10:00-23:00",
        "friday": "10:00-00:00",
        "saturday": "10:00-00:00",
        "sunday": "11:00-22:00"
      },
      "createdAt": "2024-01-04T00:00:00Z"
    },
    "rest_005": {
      "id": "rest_005",
      "name": "Curry House",
      "description": "Traditional Indian cuisine with exotic spices",
      "location": "Greenwich Village",
      "distance": 1.8,
      "rating": 4.4,
      "deliveryTime": "25-35 min",
      "deliveryFee": 3.49,
      "imageUrl": "https://images.unsplash.com/photo-1585937421612-70a008356fbe",
      "category": "Indian",
      "isOpen": true,
      "latitude": 40.7336,
      "longitude": -74.0027,
      "cuisine": ["Indian", "Curry"],
      "priceRange": "$$",
      "workingHours": {
        "monday": "11:00-22:30",
        "tuesday": "11:00-22:30",
        "wednesday": "11:00-22:30",
        "thursday": "11:00-22:30",
        "friday": "11:00-23:00",
        "saturday": "11:00-23:00",
        "sunday": "12:00-22:00"
      },
      "createdAt": "2024-01-05T00:00:00Z"
    }
  }
}
```

### 3. Restaurant Categories (Subcollection)
```json
{
  "restaurants/rest_001/categories": {
    "cat_001": {
      "name": "Burgers",
      "order": 1
    },
    "cat_002": {
      "name": "Sides",
      "order": 2
    },
    "cat_003": {
      "name": "Beverages",
      "order": 3
    },
    "cat_004": {
      "name": "Desserts",
      "order": 4
    }
  }
}
```

### 4. Foods Collection
```json
{
  "foods": {
    "food_001": {
      "id": "food_001",
      "name": "Classic Beef Burger",
      "description": "Juicy beef patty with lettuce, tomato, onion, and special sauce",
      "price": 12.99,
      "rating": 4.6,
      "imageUrl": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
      "category": "Burgers",
      "restaurantId": "rest_001",
      "restaurantName": "Burger Palace",
      "ingredients": ["Beef", "Lettuce", "Tomato", "Onion", "Cheese", "Bun"],
      "isAvailable": true,
      "preparationTime": "15 min",
      "calories": 650,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 0,
      "allergens": ["Gluten", "Dairy"],
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "food_002": {
      "id": "food_002",
      "name": "Chicken Deluxe Burger",
      "description": "Crispy chicken breast with coleslaw and mayo",
      "price": 11.99,
      "rating": 4.5,
      "imageUrl": "https://images.unsplash.com/photo-1606755962773-d324e0a13086",
      "category": "Burgers",
      "restaurantId": "rest_001",
      "restaurantName": "Burger Palace",
      "ingredients": ["Chicken", "Coleslaw", "Mayo", "Pickles", "Bun"],
      "isAvailable": true,
      "preparationTime": "12 min",
      "calories": 580,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 1,
      "allergens": ["Gluten", "Eggs"],
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "food_003": {
      "id": "food_003",
      "name": "Margherita Pizza",
      "description": "Fresh mozzarella, tomato sauce, and basil",
      "price": 14.99,
      "rating": 4.7,
      "imageUrl": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
      "category": "Pizza",
      "restaurantId": "rest_002",
      "restaurantName": "Pizza Heaven",
      "ingredients": ["Mozzarella", "Tomato Sauce", "Basil", "Pizza Dough"],
      "isAvailable": true,
      "preparationTime": "20 min",
      "calories": 800,
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 0,
      "allergens": ["Gluten", "Dairy"],
      "sizes": ["Small", "Medium", "Large"],
      "createdAt": "2024-01-02T00:00:00Z"
    },
    "food_004": {
      "id": "food_004",
      "name": "Pepperoni Pizza",
      "description": "Classic pepperoni with mozzarella cheese",
      "price": 16.99,
      "rating": 4.8,
      "imageUrl": "https://images.unsplash.com/photo-1628840042765-356cda07504e",
      "category": "Pizza",
      "restaurantId": "rest_002",
      "restaurantName": "Pizza Heaven",
      "ingredients": ["Pepperoni", "Mozzarella", "Tomato Sauce", "Pizza Dough"],
      "isAvailable": true,
      "preparationTime": "20 min",
      "calories": 950,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 1,
      "allergens": ["Gluten", "Dairy"],
      "sizes": ["Small", "Medium", "Large"],
      "createdAt": "2024-01-02T00:00:00Z"
    },
    "food_005": {
      "id": "food_005",
      "name": "California Roll",
      "description": "Crab, avocado, and cucumber roll",
      "price": 8.99,
      "rating": 4.6,
      "imageUrl": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351",
      "category": "Sushi",
      "restaurantId": "rest_003",
      "restaurantName": "Sushi Master",
      "ingredients": ["Crab", "Avocado", "Cucumber", "Rice", "Nori"],
      "isAvailable": true,
      "preparationTime": "10 min",
      "calories": 255,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": true,
      "spicyLevel": 0,
      "allergens": ["Shellfish"],
      "pieces": 8,
      "createdAt": "2024-01-03T00:00:00Z"
    },
    "food_006": {
      "id": "food_006",
      "name": "Salmon Nigiri",
      "description": "Fresh salmon over seasoned rice",
      "price": 6.99,
      "rating": 4.9,
      "imageUrl": "https://images.unsplash.com/photo-1583623025817-d180a2221d0a",
      "category": "Sushi",
      "restaurantId": "rest_003",
      "restaurantName": "Sushi Master",
      "ingredients": ["Salmon", "Rice", "Wasabi"],
      "isAvailable": true,
      "preparationTime": "5 min",
      "calories": 120,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": true,
      "spicyLevel": 0,
      "allergens": ["Fish"],
      "pieces": 2,
      "createdAt": "2024-01-03T00:00:00Z"
    },
    "food_007": {
      "id": "food_007",
      "name": "Beef Tacos",
      "description": "Three soft tacos with seasoned beef, lettuce, cheese, and salsa",
      "price": 9.99,
      "rating": 4.5,
      "imageUrl": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47",
      "category": "Tacos",
      "restaurantId": "rest_004",
      "restaurantName": "Taco Fiesta",
      "ingredients": ["Beef", "Lettuce", "Cheese", "Salsa", "Tortilla"],
      "isAvailable": true,
      "preparationTime": "8 min",
      "calories": 450,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": false,
      "spicyLevel": 2,
      "allergens": ["Gluten", "Dairy"],
      "quantity": 3,
      "createdAt": "2024-01-04T00:00:00Z"
    },
    "food_008": {
      "id": "food_008",
      "name": "Chicken Tikka Masala",
      "description": "Tender chicken in creamy tomato curry sauce",
      "price": 15.99,
      "rating": 4.7,
      "imageUrl": "https://images.unsplash.com/photo-1565557623262-b51c2513a641",
      "category": "Main Course",
      "restaurantId": "rest_005",
      "restaurantName": "Curry House",
      "ingredients": ["Chicken", "Tomato", "Cream", "Spices", "Rice"],
      "isAvailable": true,
      "preparationTime": "25 min",
      "calories": 680,
      "isVegetarian": false,
      "isVegan": false,
      "isGlutenFree": true,
      "spicyLevel": 2,
      "allergens": ["Dairy"],
      "servingSize": "Regular",
      "createdAt": "2024-01-05T00:00:00Z"
    },
    "food_009": {
      "id": "food_009",
      "name": "French Fries",
      "description": "Crispy golden fries with sea salt",
      "price": 3.99,
      "rating": 4.4,
      "imageUrl": "https://images.unsplash.com/photo-1573080496219-bb080dd4f877",
      "category": "Sides",
      "restaurantId": "rest_001",
      "restaurantName": "Burger Palace",
      "ingredients": ["Potatoes", "Salt", "Oil"],
      "isAvailable": true,
      "preparationTime": "5 min",
      "calories": 320,
      "isVegetarian": true,
      "isVegan": true,
      "isGlutenFree": true,
      "spicyLevel": 0,
      "allergens": [],
      "sizes": ["Small", "Medium", "Large"],
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "food_010": {
      "id": "food_010",
      "name": "Chocolate Milkshake",
      "description": "Thick and creamy chocolate shake",
      "price": 5.99,
      "rating": 4.6,
      "imageUrl": "https://images.unsplash.com/photo-1572490122747-3968b75cc699",
      "category": "Beverages",
      "restaurantId": "rest_001",
      "restaurantName": "Burger Palace",
      "ingredients": ["Milk", "Chocolate", "Ice Cream", "Whipped Cream"],
      "isAvailable": true,
      "preparationTime": "3 min",
      "calories": 480,
      "isVegetarian": true,
      "isVegan": false,
      "isGlutenFree": true,
      "spicyLevel": 0,
      "allergens": ["Dairy"],
      "sizes": ["Regular", "Large"],
      "createdAt": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 5. Orders Collection
```json
{
  "orders": {
    "order_001": {
      "id": "order_001",
      "userId": "user_001",
      "restaurantId": "rest_001",
      "restaurantName": "Burger Palace",
      "items": [
        {
          "foodId": "food_001",
          "foodName": "Classic Beef Burger",
          "price": 12.99,
          "quantity": 2,
          "total": 25.98,
          "specialInstructions": "No onions please"
        },
        {
          "foodId": "food_009",
          "foodName": "French Fries",
          "price": 3.99,
          "quantity": 1,
          "total": 3.99,
          "specialInstructions": ""
        }
      ],
      "subtotal": 29.97,
      "deliveryFee": 3.99,
      "tax": 2.70,
      "total": 36.66,
      "deliveryAddress": "123 Main Street, New York, NY 10001",
      "paymentMethod": "card",
      "status": "delivered",
      "createdAt": "2024-01-20T14:30:00Z",
      "updatedAt": "2024-01-20T15:15:00Z",
      "deliveredAt": "2024-01-20T15:15:00Z",
      "deliveryPersonName": "Mike Johnson",
      "deliveryPersonPhone": "+1234567892",
      "trackingUrl": "https://track.example.com/order_001",
      "notes": "Leave at door"
    },
    "order_002": {
      "id": "order_002",
      "userId": "user_001",
      "restaurantId": "rest_002",
      "restaurantName": "Pizza Heaven",
      "items": [
        {
          "foodId": "food_003",
          "foodName": "Margherita Pizza",
          "price": 14.99,
          "quantity": 1,
          "total": 14.99,
          "specialInstructions": "Extra cheese"
        }
      ],
      "subtotal": 14.99,
      "deliveryFee": 4.99,
      "tax": 1.80,
      "total": 21.78,
      "deliveryAddress": "123 Main Street, New York, NY 10001",
      "paymentMethod": "cash",
      "status": "onTheWay",
      "createdAt": "2024-01-25T18:00:00Z",
      "updatedAt": "2024-01-25T18:35:00Z",
      "deliveryPersonName": "Sarah Wilson",
      "deliveryPersonPhone": "+1234567893",
      "trackingUrl": "https://track.example.com/order_002",
      "notes": "Call when arriving"
    },
    "order_003": {
      "id": "order_003",
      "userId": "user_002",
      "restaurantId": "rest_003",
      "restaurantName": "Sushi Master",
      "items": [
        {
          "foodId": "food_005",
          "foodName": "California Roll",
          "price": 8.99,
          "quantity": 2,
          "total": 17.98,
          "specialInstructions": ""
        },
        {
          "foodId": "food_006",
          "foodName": "Salmon Nigiri",
          "price": 6.99,
          "quantity": 3,
          "total": 20.97,
          "specialInstructions": "Extra wasabi"
        }
      ],
      "subtotal": 38.95,
      "deliveryFee": 5.99,
      "tax": 4.04,
      "total": 48.98,
      "deliveryAddress": "789 Oak Drive, Los Angeles, CA 90001",
      "paymentMethod": "paypal",
      "status": "preparing",
      "createdAt": "2024-01-25T19:30:00Z",
      "updatedAt": "2024-01-25T19:35:00Z",
      "notes": "Include chopsticks"
    }
  }
}
```

### 6. Payments Collection
```json
{
  "payments": {
    "pay_001": {
      "transactionId": "txn_abc123xyz",
      "paymentMethodId": "card_001",
      "amount": 36.66,
      "currency": "USD",
      "metadata": {
        "orderId": "order_001",
        "userId": "user_001",
        "description": "Payment for order at Burger Palace"
      },
      "status": "succeeded",
      "createdAt": "2024-01-20T14:30:00Z"
    },
    "pay_002": {
      "transactionId": "txn_def456uvw",
      "paymentMethodId": "paypal_001",
      "amount": 48.98,
      "currency": "USD",
      "metadata": {
        "orderId": "order_003",
        "userId": "user_002",
        "description": "Payment for order at Sushi Master"
      },
      "status": "succeeded",
      "createdAt": "2024-01-25T19:30:00Z"
    }
  }
}
```

### 7. Saved Cards (User Subcollection)
```json
{
  "users/user_001/saved_cards": {
    "card_001": {
      "id": "card_001",
      "cardName": "Personal Card",
      "cardType": "visa",
      "lastFourDigits": "4242",
      "mExp": 12,
      "yExp": 2025,
      "isDefault": true,
      "createdAt": "2024-01-15T10:00:00Z"
    },
    "card_002": {
      "id": "card_002",
      "cardName": "Business Card",
      "cardType": "mastercard",
      "lastFourDigits": "5555",
      "mExp": 6,
      "yExp": 2026,
      "isDefault": false,
      "createdAt": "2024-01-16T10:00:00Z"
    }
  }
}
```

### 8. Chats Collection
```json
{
  "chats": {
    "chat_001": {
      "id": "chat_001",
      "participants": ["user_001", "delivery_001"],
      "orderId": "order_001",
      "lastMessage": "Your order has been delivered",
      "lastMessageTime": "2024-01-20T15:15:00Z",
      "createdAt": "2024-01-20T14:45:00Z",
      "participantDetails": {
        "user_001": {
          "id": "user_001",
          "name": "John Doe",
          "imageUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=john"
        },
        "delivery_001": {
          "id": "delivery_001",
          "name": "Mike Johnson",
          "imageUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=mike"
        }
      }
    },
    "chat_002": {
      "id": "chat_002",
      "participants": ["user_001", "delivery_002"],
      "orderId": "order_002",
      "lastMessage": "On my way with your order",
      "lastMessageTime": "2024-01-25T18:40:00Z",
      "createdAt": "2024-01-25T18:20:00Z",
      "participantDetails": {
        "user_001": {
          "id": "user_001",
          "name": "John Doe",
          "imageUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=john"
        },
        "delivery_002": {
          "id": "delivery_002",
          "name": "Sarah Wilson",
          "imageUrl": "https://api.dicebear.com/7.x/avataaars/svg?seed=sarah"
        }
      }
    }
  }
}
```

### 9. Messages (Chat Subcollection)
```json
{
  "chats/chat_001/messages": {
    "msg_001": {
      "id": "msg_001",
      "senderId": "delivery_001",
      "receiverId": "user_001",
      "content": "Hi, I've picked up your order and I'm on my way",
      "timestamp": "2024-01-20T14:45:00Z",
      "isRead": true,
      "type": "text"
    },
    "msg_002": {
      "id": "msg_002",
      "senderId": "user_001",
      "receiverId": "delivery_001",
      "content": "Great! Please leave it at the door",
      "timestamp": "2024-01-20T14:46:00Z",
      "isRead": true,
      "type": "text"
    },
    "msg_003": {
      "id": "msg_003",
      "senderId": "delivery_001",
      "receiverId": "user_001",
      "content": "Will do! I'm about 5 minutes away",
      "timestamp": "2024-01-20T15:10:00Z",
      "isRead": true,
      "type": "text"
    },
    "msg_004": {
      "id": "msg_004",
      "senderId": "delivery_001",
      "receiverId": "user_001",
      "content": "Your order has been delivered",
      "timestamp": "2024-01-20T15:15:00Z",
      "isRead": true,
      "type": "text"
    }
  }
}
```

### 10. Notifications Collection
```json
{
  "notifications": {
    "notif_001": {
      "id": "notif_001",
      "userId": "user_001",
      "title": "Order Confirmed",
      "body": "Your order from Burger Palace has been confirmed",
      "type": "order_status",
      "data": {
        "orderId": "order_001",
        "status": "confirmed"
      },
      "isRead": true,
      "createdAt": "2024-01-20T14:31:00Z"
    },
    "notif_002": {
      "id": "notif_002",
      "userId": "user_001",
      "title": "Order Delivered",
      "body": "Your order from Burger Palace has been delivered",
      "type": "order_status",
      "data": {
        "orderId": "order_001",
        "status": "delivered"
      },
      "isRead": true,
      "createdAt": "2024-01-20T15:15:00Z"
    },
    "notif_003": {
      "id": "notif_003",
      "userId": "user_001",
      "title": "Special Offer",
      "body": "Get 20% off on your next order from Pizza Heaven",
      "type": "promotion",
      "data": {
        "restaurantId": "rest_002",
        "discountCode": "PIZZA20"
      },
      "isRead": false,
      "createdAt": "2024-01-24T10:00:00Z"
    }
  }
}
```

## Implementation Scripts

### Firebase Admin SDK Script (Node.js)
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path-to-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Function to add restaurants
async function addRestaurants() {
  const restaurants = [/* Restaurant data from above */];
  
  for (const restaurant of restaurants) {
    await db.collection('restaurants').doc(restaurant.id).set(restaurant);
    console.log(`Added restaurant: ${restaurant.name}`);
  }
}

// Function to add foods
async function addFoods() {
  const foods = [/* Food data from above */];
  
  for (const food of foods) {
    await db.collection('foods').doc(food.id).set(food);
    console.log(`Added food: ${food.name}`);
  }
}

// Function to add users
async function addUsers() {
  const users = [/* User data from above */];
  
  for (const user of users) {
    await db.collection('users').doc(user.uid).set(user);
    console.log(`Added user: ${user.displayName}`);
  }
}

// Run all functions
async function seedDatabase() {
  try {
    await addRestaurants();
    await addFoods();
    await addUsers();
    // Add other collections...
    console.log('Database seeded successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
  }
}

seedDatabase();
```

### Flutter Implementation Script
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDummyDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDatabase() async {
    try {
      // Add restaurants
      await _seedRestaurants();
      
      // Add foods
      await _seedFoods();
      
      // Add sample orders
      await _seedOrders();
      
      print('Database seeded successfully!');
    } catch (e) {
      print('Error seeding database: $e');
    }
  }

  Future<void> _seedRestaurants() async {
    final restaurants = [
      {
        'id': 'rest_001',
        'name': 'Burger Palace',
        'description': 'Best burgers in town with fresh ingredients',
        'location': 'Downtown Manhattan',
        'distance': 2.5,
        'rating': 4.5,
        'deliveryTime': '25-35 min',
        'deliveryFee': 3.99,
        'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add',
        'category': 'Fast Food',
        'isOpen': true,
        'latitude': 40.7128,
        'longitude': -74.0060,
        'createdAt': FieldValue.serverTimestamp(),
      },
      // Add more restaurants...
    ];

    for (final restaurant in restaurants) {
      await _firestore
          .collection('restaurants')
          .doc(restaurant['id'] as String)
          .set(restaurant);
    }
  }

  Future<void> _seedFoods() async {
    final foods = [
      {
        'id': 'food_001',
        'name': 'Classic Beef Burger',
        'description': 'Juicy beef patty with lettuce, tomato, onion, and special sauce',
        'price': 12.99,
        'rating': 4.6,
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
        'category': 'Burgers',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'ingredients': ['Beef', 'Lettuce', 'Tomato', 'Onion', 'Cheese', 'Bun'],
        'isAvailable': true,
        'preparationTime': '15 min',
        'calories': 650,
        'isVegetarian': false,
        'isVegan': false,
        'isGlutenFree': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      // Add more foods...
    ];

    for (final food in foods) {
      await _firestore
          .collection('foods')
          .doc(food['id'] as String)
          .set(food);
    }
  }

  Future<void> _seedOrders() async {
    // Add sample orders
    final orders = [
      {
        'id': 'order_001',
        'userId': 'user_001',
        'restaurantId': 'rest_001',
        'restaurantName': 'Burger Palace',
        'items': [
          {
            'foodId': 'food_001',
            'foodName': 'Classic Beef Burger',
            'price': 12.99,
            'quantity': 2,
            'total': 25.98,
          }
        ],
        'subtotal': 25.98,
        'deliveryFee': 3.99,
        'tax': 2.34,
        'total': 32.31,
        'status': 'delivered',
        'createdAt': FieldValue.serverTimestamp(),
      },
      // Add more orders...
    ];

    for (final order in orders) {
      await _firestore
          .collection('orders')
          .doc(order['id'] as String)
          .set(order);
    }
  }
}

// Usage
final seeder = FirebaseDummyDataSeeder();
await seeder.seedDatabase();
```

## Testing Strategy

### 1. Unit Testing
Test individual data models and entities:
```dart
test('Restaurant entity should parse correctly', () {
  final restaurantData = {
    'id': 'rest_001',
    'name': 'Test Restaurant',
    'rating': 4.5,
    // ... other fields
  };
  
  final restaurant = Restaurant.fromJson(restaurantData);
  expect(restaurant.name, 'Test Restaurant');
  expect(restaurant.rating, 4.5);
});
```

### 2. Integration Testing
Test Firebase operations:
```dart
test('Should fetch restaurants from Firebase', () async {
  final repository = RestaurantRepository();
  final restaurants = await repository.fetchRestaurants();
  
  expect(restaurants, isNotEmpty);
  expect(restaurants.first.name, isNotNull);
});
```

### 3. End-to-End Testing
Test complete user flows:
```dart
testWidgets('User can browse and order food', (tester) async {
  // Navigate to restaurant list
  await tester.pumpWidget(MyApp());
  
  // Select a restaurant
  await tester.tap(find.text('Burger Palace'));
  await tester.pumpAndSettle();
  
  // Add item to cart
  await tester.tap(find.text('Add to Cart'));
  
  // Proceed to checkout
  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();
  
  // Verify order creation
  expect(find.text('Order Confirmed'), findsOneWidget);
});
```

## Best Practices

### 1. Data Validation
- Always validate data before writing to Firebase
- Use Firebase Security Rules for server-side validation
- Implement client-side validation in Flutter

### 2. Performance Optimization
- Use pagination for large data sets
- Implement proper indexing in Firebase
- Cache frequently accessed data locally using Floor database

### 3. Security Considerations
- Never store sensitive data like full credit card numbers
- Use Firebase Authentication for user management
- Implement proper role-based access control

### 4. Data Consistency
- Use batch writes for related data updates
- Implement transaction support for critical operations
- Handle offline scenarios with Firebase offline persistence

### 5. Error Handling
```dart
try {
  await FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantId)
      .set(data);
} on FirebaseException catch (e) {
  // Handle Firebase-specific errors
  print('Firebase error: ${e.code} - ${e.message}');
} catch (e) {
  // Handle general errors
  print('General error: $e');
}
```

### 6. Environment-Specific Data
Create different data sets for:
- Development environment
- Staging environment
- Production environment (use carefully!)

### 7. Data Cleanup Script
```javascript
async function cleanupTestData() {
  const batch = db.batch();
  
  // Delete test restaurants
  const testRestaurants = await db.collection('restaurants')
    .where('name', '>=', 'TEST_')
    .where('name', '<', 'TEST_~')
    .get();
  
  testRestaurants.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log('Test data cleaned up');
}
```

## Monitoring and Analytics

### Track Key Metrics
1. Number of active restaurants
2. Popular food items
3. Order frequency
4. Average order value
5. User engagement metrics

### Firebase Analytics Events
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'add_to_cart',
  parameters: {
    'food_id': foodId,
    'food_name': foodName,
    'restaurant_id': restaurantId,
    'price': price,
  },
);
```

## Troubleshooting Common Issues

### 1. Permission Denied Errors
- Check Firebase Security Rules
- Verify user authentication status
- Ensure proper role assignments

### 2. Data Not Appearing
- Check Firebase Console for data
- Verify collection and document paths
- Check network connectivity

### 3. Performance Issues
- Implement proper indexing
- Use pagination for large lists
- Enable offline persistence

### 4. Data Inconsistencies
- Use transactions for critical updates
- Implement proper error handling
- Add retry logic for failed operations

## Conclusion

This comprehensive guide provides everything needed to populate your Firebase database with realistic dummy data for testing and development. Remember to:

1. Always use test data in development
2. Never use production credentials in test scripts
3. Clean up test data after testing
4. Follow security best practices
5. Monitor and optimize performance

For additional support or questions, refer to the official Firebase documentation or contact the development team.
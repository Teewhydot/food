# Firebase Structure for Food App

## Collections

### 1. restaurants
```json
{
  "name": "string",
  "description": "string",
  "location": "string",
  "distance": "number",
  "rating": "number",
  "deliveryTime": "string",
  "deliveryFee": "number",
  "imageUrl": "string",
  "category": "string",
  "isOpen": "boolean",
  "latitude": "number",
  "longitude": "number",
  "createdAt": "timestamp"
}
```

### 2. foods
```json
{
  "name": "string",
  "description": "string",
  "price": "number",
  "rating": "number",
  "imageUrl": "string",
  "category": "string",
  "restaurantId": "string",
  "restaurantName": "string",
  "ingredients": ["string"],
  "isAvailable": "boolean",
  "preparationTime": "string",
  "calories": "number",
  "isVegetarian": "boolean",
  "isVegan": "boolean",
  "isGlutenFree": "boolean",
  "createdAt": "timestamp"
}
```

### 3. restaurants/{restaurantId}/categories
```json
{
  "name": "string",
  "order": "number"
}
```

## Sample Data

### Restaurant Categories
- Fast Food
- Italian
- Chinese
- Indian
- Mexican
- American
- Japanese
- Mediterranean

### Food Categories
- Appetizers
- Main Course
- Desserts
- Beverages
- Salads
- Soups
- Breakfast
- Snacks

## Indexes Needed

### restaurants collection
- Single field: `rating` (descending)
- Single field: `category`
- Single field: `createdAt` (descending)
- Composite: `rating` (descending) + `createdAt` (descending)

### foods collection
- Single field: `rating` (descending)
- Single field: `category`
- Single field: `restaurantId`
- Single field: `createdAt` (descending)
- Composite: `rating` (descending) + `createdAt` (descending)
- Composite: `restaurantId` + `category`

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to restaurants and foods for all users
    match /restaurants/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    match /foods/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // User-specific data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
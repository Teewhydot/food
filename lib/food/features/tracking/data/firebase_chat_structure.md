# Firebase Structure for Chat System

## Collections

### 1. chats
```json
{
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

### 2. chats/{chatId}/messages
```json
{
  "senderId": "string",
  "receiverId": "string",
  "content": "string",
  "timestamp": "timestamp",
  "isRead": "boolean",
  "type": "string (text|image|location)", // for future extensions
  "metadata": {} // for future extensions like image URLs, location coords
}
```

## Indexes Needed

### chats collection
- Composite: `participants` (array-contains) + `lastMessageTime` (descending)
- Single field: `orderId`
- Single field: `createdAt` (descending)

### messages subcollection
- Single field: `timestamp` (ascending for chat order)
- Single field: `timestamp` (descending for latest message)

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Chat rules
    match /chats/{chatId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null && 
        request.auth.uid in request.resource.data.participants;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.participants &&
        request.resource.data.participants == resource.data.participants; // Can't change participants
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && 
          request.auth.uid == request.resource.data.senderId &&
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow update: if request.auth != null && 
          request.auth.uid == resource.data.senderId; // Only sender can update
        allow delete: if request.auth != null && 
          request.auth.uid == resource.data.senderId; // Only sender can delete
      }
    }
  }
}
```

## Chat Flow

1. **Order Placed**: When an order is confirmed, the system can create a chat between customer and delivery person
2. **Chat Creation**: Use `createOrGetChat` to ensure only one chat per order
3. **Real-time Messaging**: Messages are delivered in real-time using Firestore streams
4. **Read Receipts**: Messages can be marked as read when viewed
5. **Chat List**: Users see all their active chats sorted by last message time

## Integration Points

### With Order System
- Chat is linked to order via `orderId`
- Chat automatically created when order is assigned to delivery person
- Chat can be archived when order is completed

### With User Profiles
- Participant details are cached in chat document for quick access
- Profile updates should trigger chat participant details update

### With Notifications
- New message triggers push notification
- Notification includes sender name and message preview
- Tapping notification opens specific chat

## Future Enhancements

1. **Message Types**:
   - Image messages for sharing photos
   - Location messages for sharing delivery location
   - Voice messages

2. **Features**:
   - Message reactions
   - Typing indicators
   - Online/offline status
   - Message search
   - Chat archiving

3. **Admin Features**:
   - Monitor chats for customer support
   - Chat analytics
   - Automated responses
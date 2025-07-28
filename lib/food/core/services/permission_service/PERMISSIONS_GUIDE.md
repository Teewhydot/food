# Permissions Guide for Food Delivery App

## Android Permissions

### Required Permissions:
1. **INTERNET** - For API calls, real-time updates
2. **ACCESS_NETWORK_STATE** - Check network connectivity
3. **ACCESS_FINE_LOCATION** - Get precise location for delivery
4. **ACCESS_COARSE_LOCATION** - Get approximate location
5. **POST_NOTIFICATIONS** - Send order updates and promotions

### Optional Permissions:
1. **CAMERA** - Take photos for reviews, profile pictures
2. **READ_EXTERNAL_STORAGE** - Access saved images
3. **WRITE_EXTERNAL_STORAGE** - Save images
4. **CALL_PHONE** - Call restaurant or delivery person
5. **VIBRATE** - Notification vibrations
6. **WAKE_LOCK** - Keep app active during tracking
7. **READ_MEDIA_IMAGES** - Android 13+ photo access

## iOS Permissions

### Required Permissions:
1. **Location Services**
   - When In Use - Show nearby restaurants
   - Always - Track delivery in real-time
   
2. **Push Notifications** - Order updates

### Optional Permissions:
1. **Camera** - Profile photos, food reviews
2. **Photo Library** - Select images
3. **Microphone** - Voice messages in chat
4. **Face ID** - Secure payment authentication
5. **Contacts** - Share meals with friends
6. **Motion** - Health features

## When to Request Permissions

### On App Launch:
- Location (When In Use) - For showing nearby restaurants
- Notifications - For order updates

### Context-Based:
- Camera/Photos - When user taps to add profile picture or review photo
- Microphone - When user tries to send voice message
- Phone - When user taps to call restaurant/delivery
- Face ID - When setting up payment security

## Implementation Notes:

1. Use the existing `PermissionService` in the app
2. Always explain why you need the permission before requesting
3. Handle permission denial gracefully
4. Provide alternative options when permissions are denied
5. Don't request all permissions at once - use context-based requests

## Code Example:

```dart
// Check and request location permission
final locationStatus = await _permissionService.checkLocationPermission();
if (locationStatus != PermissionStatus.granted) {
  final granted = await _permissionService.requestLocationPermission();
  if (!granted) {
    // Show dialog explaining why location is needed
    // Offer manual address entry as alternative
  }
}
```
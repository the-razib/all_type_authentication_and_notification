# Push Notification Setup Guide

## What's Been Added

### Dependencies
- `firebase_messaging: ^15.1.5` - For Firebase Cloud Messaging
- `flutter_local_notifications: ^18.0.1` - For local notifications
- `http: ^1.1.0` - For downloading notification images
- `path_provider: ^2.1.1` - For temporary file storage

### Files Created/Modified

1. **lib/services/notification_service.dart** - Main notification service
2. **lib/main.dart** - Initialize notification service
3. **lib/screens/login_page.dart** - Added demo notification buttons
4. **lib/screens/home_page.dart** - Added FCM token display and test button
5. **android/app/src/main/AndroidManifest.xml** - Added notification permissions
6. **ios/Runner/AppDelegate.swift** - Added iOS notification setup

## How to Test

### 1. Local Notifications (Works Immediately)
- Run the app: `flutter run`
- On the login screen, tap "Test Notification" for basic notification
- Tap "Test with Image" for notification with image
- You should see notifications appear with proper image display

### 2. FCM Token (For Remote Notifications)
- On the login screen, tap "Show Token" to see your FCM token
- After logging in, the home page also displays the FCM token
- Copy this token to send remote notifications from Firebase Console

### 3. Remote Notifications (Requires Firebase Console)
1. Go to Firebase Console → Your Project → Cloud Messaging
2. Click "Send your first message"
3. Enter title and message
4. In "Target" section, select "Single device"
5. Paste the FCM token from your app
6. Send the notification

## Platform-Specific Notes

### Android
- Notification permissions are automatically requested
- Notifications work on Android 6.0+ (API level 23+)
- For Android 13+, POST_NOTIFICATIONS permission is required

### iOS
- Notification permissions are requested on app launch
- Requires physical device for testing (not simulator)
- Push notifications require Apple Developer account for production

## Features Implemented

✅ Local notifications
✅ **Image support in notifications** (Big Picture Style)
✅ FCM token generation
✅ Foreground message handling with images
✅ Background message handling
✅ Notification tap handling
✅ Permission requests
✅ Demo UI on login screen
✅ Token display on home screen
✅ Automatic image downloading and caching

## Next Steps for Production

1. **Custom Notification Channels** - Create different channels for different types
2. **Deep Linking** - Handle notification taps to navigate to specific screens
3. **Topic Subscriptions** - Subscribe users to notification topics
4. **Notification Scheduling** - Schedule local notifications
5. **Rich Notifications** - Add images, actions, and custom layouts
6. **Analytics** - Track notification open rates and engagement

## Troubleshooting

### No Notifications Appearing
1. Check device notification settings
2. Ensure app has notification permissions
3. Check Firebase project configuration
4. Verify google-services.json/GoogleService-Info.plist files

### FCM Token Issues
1. Ensure internet connection
2. Check Firebase project setup
3. Verify app is properly registered in Firebase Console

### Image Not Showing in Notifications
1. **Check image URL** - Ensure the image URL is publicly accessible
2. **Internet permission** - Verify INTERNET permission in AndroidManifest.xml
3. **Image format** - Use common formats (JPG, PNG, WebP)
4. **Image size** - Keep images under 1MB for better performance
5. **HTTPS URLs** - Use HTTPS URLs for better compatibility

### iOS Specific Issues
1. Test on physical device (not simulator)
2. Check iOS notification settings
3. Ensure proper provisioning profile for push notifications
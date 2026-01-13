# Event Reminder - Notification System Guide

Your app now supports **two types of notifications**:

## 1. 🔔 Local Notifications (Set Reminders)
Local notifications are scheduled on the device and trigger at specific times for your event reminders.

### Features:
- ✅ Schedule notifications for specific times
- ✅ Repeat options: Daily, Weekly, Monthly
- ✅ Immediate notifications for instant events
- ✅ Background monitoring of tasks
- ✅ Works offline

### How It Works:
The `NotifyHelper` class in [lib/services/notification_services.dart](lib/services/notification_services.dart) handles:
- Scheduling notifications based on task start time
- Monitoring tasks every minute
- Showing immediate notifications when task time arrives
- Managing repeat notifications

### Already Configured:
Your local notification system is already working! When you create a task/reminder in your app with a specific time, it will trigger a notification.

---

## 2. 📲 Firebase Cloud Messaging (Generic Push Notifications)
FCM allows you to send push notifications from your server/Firebase Console to all users or specific users.

### Features:
- ✅ Receive notifications from Firebase Console
- ✅ Background and foreground notification handling
- ✅ Topic-based subscriptions
- ✅ Custom data payloads
- ✅ Works with app in any state (foreground, background, terminated)

### How It Works:
The `FCMNotificationService` class in [lib/services/fcm_notification_service.dart](lib/services/fcm_notification_service.dart) handles:
- Requesting notification permissions
- Getting and managing FCM tokens
- Receiving foreground messages
- Handling background messages
- Processing notification taps

---

## 🚀 Testing Firebase Cloud Messaging

### Step 1: Get Your FCM Token
When you run the app, check your debug console. You'll see:
```
FCM Token: [your-device-token-here]
```
Copy this token - you'll need it to send test notifications.

### Step 2: Send a Test Notification via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Cloud Messaging** (under Engage section)
4. Click **"Send your first message"** or **"New campaign"**
5. Fill in the details:
   - **Notification title**: "Test Notification"
   - **Notification text**: "This is a test from Firebase!"
6. Click **"Next"**
7. Under **"Target"**:
   - Select **"User segment"** and choose your app
   - OR select **"Single device"** and paste your FCM token
8. Click **"Next"**
9. Click **"Review"** and **"Publish"**

### Step 3: Send via API (Optional)
You can also send notifications programmatically from your server:

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_DEVICE_TOKEN",
      "notification": {
        "title": "Hello from API",
        "body": "This is a test notification"
      },
      "data": {
        "route": "/home",
        "id": "123"
      }
    }
  }'
```

---

## 📱 Usage Examples in Your Code

### Subscribe to Topics (Optional)
Users can subscribe to topics to receive grouped notifications:

```dart
import 'package:event_manager/services/fcm_notification_service.dart';

// Subscribe to a topic
await FCMNotificationService.subscribeToTopic('news');
await FCMNotificationService.subscribeToTopic('promotions');

// Unsubscribe from a topic
await FCMNotificationService.unsubscribeFromTopic('news');
```

### Get Current FCM Token
```dart
String? token = await FCMNotificationService.getToken();
print('My FCM Token: $token');
// Save this token to your database to send targeted notifications
```

### Create Local Notification (Already Working)
```dart
import 'package:event_manager/services/notification_services.dart';

NotifyHelper notifyHelper = NotifyHelper();

// Schedule a notification
await notifyHelper.scheduledNotification(
  14, // hour (2 PM)
  30, // minute
  'Meeting Reminder',
  'Team standup in 30 minutes',
  'Daily'
);

// Show immediate notification
await notifyHelper.showImmediateNotification(
  'Urgent!',
  'Your event starts now!'
);
```

---

## 🔧 Configuration Files Modified

1. **[pubspec.yaml](pubspec.yaml)**
   - Added `firebase_messaging: ^15.1.6`

2. **[lib/main.dart](lib/main.dart)**
   - Initialized FCM service on app startup
   - Import: `import 'package:event_manager/services/fcm_notification_service.dart';`
   - Call: `await FCMNotificationService.initialize();`

3. **[lib/services/notification_services.dart](lib/services/notification_services.dart)**
   - Enhanced to support both Android and iOS
   - Added FCM notification channel
   - Improved notification tap handling

4. **[lib/services/fcm_notification_service.dart](lib/services/fcm_notification_service.dart)** (NEW)
   - Complete FCM implementation
   - Background message handler
   - Topic subscription support

5. **[android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)**
   - Added FCM service configuration
   - Set default notification icon and channel

---

## ⚙️ Notification Channels

Your app now has **two notification channels**:

1. **task_channel** - For local reminder notifications
   - Used by scheduled event reminders
   - High importance

2. **fcm_channel** - For Firebase push notifications
   - Used by generic push notifications from server
   - High importance

Users can manage these channels in their device settings: Settings → Apps → Event Manager → Notifications

---

## 🐛 Troubleshooting

### Notifications Not Showing?
1. Check notification permissions in device settings
2. Verify Firebase is properly configured in your project
3. Check if `google-services.json` is in `android/app/`
4. Run `flutter clean` and rebuild

### FCM Token Not Generated?
1. Ensure Firebase Core is initialized before FCM
2. Check internet connection
3. Verify Firebase project configuration

### Local Notifications Not Working?
1. Check if notification permissions are granted
2. Verify timezone initialization
3. Check if the scheduled time is in the future

---

## 📝 Next Steps

### For Production:
1. **Store FCM Tokens**: Save user FCM tokens to Firestore/your database
2. **Server Integration**: Set up a backend to send targeted notifications
3. **Analytics**: Track notification engagement
4. **Custom Actions**: Add action buttons to notifications
5. **Rich Notifications**: Add images, sounds, and custom layouts

### Example: Save Token to Firestore
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveFCMToken() async {
  String? token = await FCMNotificationService.getToken();
  User? user = FirebaseAuth.instance.currentUser;
  
  if (token != null && user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
  }
}
```

---

## ✅ Summary

✨ Your Event Reminder app now has a complete notification system:

- **Local Notifications**: Automatically trigger for scheduled reminders
- **FCM Push Notifications**: Receive generic notifications from Firebase
- **Background Support**: Works in all app states
- **iOS Ready**: Includes iOS configuration (when you add iOS support)
- **Channel Management**: Separate channels for different notification types

Happy coding! 🎉

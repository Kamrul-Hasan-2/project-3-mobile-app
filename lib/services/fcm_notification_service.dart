import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // You can display local notification here
  await FCMNotificationService.showNotificationFromFCM(message);
}

class FCMNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM
  static Future<void> initialize() async {
    // Request notification permissions (iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token for this device
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // You can send this token to your backend server to send notifications
    // Store it in Firestore or your database

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('FCM Token refreshed: $newToken');
      // Update token on server
    });

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      showNotificationFromFCM(message);
    });

    // Handle when user taps on notification to open app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Show notification using local notifications plugin
  static Future<void> showNotificationFromFCM(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_channel',
            'FCM Notifications',
            channelDescription: 'Firebase Cloud Messaging notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: 'flutter_logo',
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification data: ${message.data}');

    // Navigate to appropriate screen based on notification data
    if (message.data.containsKey('route')) {
      // You can implement navigation logic here
      // Example: Get.toNamed(message.data['route']);
      print('Route to navigate: ${message.data['route']}');
    }
  }

  // Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Get current FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}

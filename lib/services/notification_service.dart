import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    await _getFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<String?> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
    }

    _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
    }
    // Handle navigation based on notification data
  }

  void _onNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Local notification tapped: ${response.payload}');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // Check if there's an image in the notification
    String? imageUrl =
        message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl ??
        message.data['image'];

    String? bigPicturePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          largeIcon: bigPicturePath != null
              ? FilePathAndroidBitmap(bigPicturePath)
              : null,
          styleInformation: bigPicturePath != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(bigPicturePath),
                  hideExpandedLargeIcon: false,
                  contentTitle: message.notification?.title,
                  htmlFormatContentTitle: true,
                  summaryText: message.notification?.body,
                  htmlFormatSummaryText: true,
                )
              : null,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading image: $e');
      }
      return null;
    }
  }

  // Demo method to send a test notification
  Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'demo_channel',
          'Demo Channel',
          channelDescription: 'Demo notification channel',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Demo Notification',
      'This is a test notification from your Flutter app!',
      platformChannelSpecifics,
    );
  }

  // Demo method to send a test notification with image
  Future<void> sendTestNotificationWithImage() async {
    // Sample image URL for testing
    const String imageUrl = 'https://picsum.photos/400/200';

    String? bigPicturePath = await _downloadAndSaveFile(imageUrl, 'testImage');

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'demo_channel_image',
          'Demo Channel with Image',
          channelDescription: 'Demo notification channel with image support',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
          largeIcon: bigPicturePath != null
              ? FilePathAndroidBitmap(bigPicturePath)
              : null,
          styleInformation: bigPicturePath != null
              ? BigPictureStyleInformation(
                  FilePathAndroidBitmap(bigPicturePath),
                  hideExpandedLargeIcon: false,
                  contentTitle: 'Demo with Image',
                  htmlFormatContentTitle: true,
                  summaryText: 'This notification includes an image!',
                  htmlFormatSummaryText: true,
                )
              : null,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Demo with Image',
      'This notification includes an image!',
      platformChannelSpecifics,
    );
  }

  Future<String?> getToken() async {
    return await _getFCMToken();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

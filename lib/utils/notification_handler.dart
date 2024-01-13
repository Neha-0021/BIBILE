import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  String fcmToken = '';
  // ignore: unused_field
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationHandler() {
    // Set up message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages here
      // You can show in-app banners, update UI, etc.
      displayNotification(message.data);
    });

    // Set up handling when the app is in the background and is opened from a notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is in the background and is opened from a notification tap
      // You can navigate to a specific screen based on the notification content.
    });
  }

  Future<void> displayNotification(Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace 'your_channel_id' with a unique channel ID
      'your_channel_name', // Replace 'your_channel_name' with a channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID, can be any unique ID
      data['title'], // Notification title
      data['body'], // Notification body
      platformChannelSpecifics,
    );
  }

  Future<String> getFcmToken() async {
    // Request permission for notifications (if not already granted)
    await FirebaseMessaging.instance.requestPermission();

    // Get the FCM token
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      // print('FCM Token: $token');
      return token;
    } else {
      return "";
    }
  }
}
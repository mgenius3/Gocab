import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialization =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var iosInitialization =
        const DarwinInitializationSettings(); // Updated name
    var initializationSettings = InitializationSettings(
        android: androidInitialization, iOS: iosInitialization);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showRequestNotification({
    var id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'gocab',
      'channel_name',
      channelDescription: "New Message",
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails()); // Updated name

    // Customize the notification body using string interpolation:
    // String customBody = 'Destination: ${payload ?? ''}';

    await fln.show(id, title, body, platformChannelSpecifics, payload: payload);
  }
}

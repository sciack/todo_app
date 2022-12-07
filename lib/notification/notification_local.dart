import 'package:todo_app/notification/notification_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationLocal implements NotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var id = 0;

  @override
  void init() {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  @override
  void notify(String title, String text) async {
// Create the notification details
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      "todo_app_channel",
      "Todo App Channel",
      icon: "@mipmap/ic_launcher",
      visibility: NotificationVisibility.public,
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails details = NotificationDetails(android: androidDetails);
// Schedule the notification
    await flutterLocalNotificationsPlugin.show(id++, title, text, details);
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}
}

NotificationHelper getNotificationHelper() {
  return NotificationLocal();
}

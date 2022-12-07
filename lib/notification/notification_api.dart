import 'package:todo_app/notification/notification.dart'
    if (dart.library.io) 'package:todo_app/notification/notification_local.dart'
    if (dart.library.js) 'package:todo_app/notification/notification_web.dart';

abstract class NotificationHelper {
  static NotificationHelper? _instance;

  static NotificationHelper get instance {
    _instance ??= getNotificationHelper();
    return _instance!;
  }

  void notify(String title, String text);

  void init() {}
}

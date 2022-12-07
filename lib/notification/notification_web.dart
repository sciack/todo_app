import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:todo_app/notification/notification_api.dart';

class WebNotificationHelper implements NotificationHelper{
  @override
  void notify(String title, String text) {
    if( !Notification.supported) {
      return;
    }
    if (Notification.permission != 'granted') {
      Notification.requestPermission();
    }
    var notification = Notification(title, body: text);
    notification.onClick.forEach((element) {
      if (kDebugMode) {
        print(element);
      }
    });
  }

  @override
  void init() {
    if( !Notification.supported) {
      return;
    }
    if (Notification.permission != 'granted') {
      Notification.requestPermission();
    }
  }
}


NotificationHelper getNotificationHelper() {
  return WebNotificationHelper();
}
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await notificationsPlugin.initialize(initializationSettings);

    // Запрашиваем разрешение для Android 13+
    notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future showNotification({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
      id, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'offroad_channel',
          'Off-Road Напоминания',
          importance: Importance.max,
          priority: Priority.high, // Чтобы уведомление всплывало сверху
        ),
      ),
    );
  }
}
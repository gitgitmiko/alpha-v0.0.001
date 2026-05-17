import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.showDiscountNotification(
    title: message.notification?.title ?? 'Price Alert',
    body: message.notification?.body ?? '',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  final _channel = const AndroidNotificationChannel(
    'price_alerts',
    'Price Alerts',
    description: 'Discount and price drop notifications',
    importance: Importance.high,
  );

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (_) {},
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _requestPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      showDiscountNotification(
        title: message.notification?.title ?? 'Price Alert',
        body: message.notification?.body ?? '',
      );
    });
  }

  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    await FirebaseMessaging.instance.requestPermission();
  }

  Future<void> showDiscountNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> notifyPriceDrop({
    required String gameTitle,
    required double discountPercent,
  }) async {
    await showDiscountNotification(
      title: 'Price Drop!',
      body: '$gameTitle is now ${discountPercent.toStringAsFixed(0)}% OFF!',
    );
  }
}

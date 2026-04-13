// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Pedir permissões
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Configurar notificações locais para quando a app está aberta
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);

    // 3. Criar canal de notificação para Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'estudo_reminders', // id
      'Lembretes de Estudo', // title
      description: 'Canal para lembretes diários de estudo e novidades.', // description
      importance: Importance.max,
    );

    // CORREÇÃO AQUI: Acesso direto ao plugin para criar o canal
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Ouvir mensagens em primeiro plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 5. Obter o token
    String? token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'estudo_reminders', // ID do canal
            'Lembretes de Estudo',
            // A descrição é definida no canal, não aqui
            icon: android.smallIcon,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}

// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para la gestión de notificaciones.
/// Se implementa como Singleton para garantizar una única instancia en la app.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el plugin de notificaciones y configura las zonas horarias.
  Future<void> init() async {
    tz.initializeTimeZones();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Aquí puedes manejar la acción al tocar la notificación.
        print('Notificación recibida: ${response.payload}');
      },
    );
  }

  /// Define los detalles de la notificación para Android e iOS.
  NotificationDetails _notificationDetails() {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'mindkeeper_channel', // ID del canal.
      'MindKeeper Notifications', // Nombre del canal.
      channelDescription: 'Canal para recordatorios de MindKeeper',
      importance: Importance.max,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Programa una notificación individual para una fecha y hora específicas.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Programa un recordatorio completo.
  ///
  /// Parámetros:
  /// - [id]: Identificador base para la notificación.
  /// - [title]: Título de la notificación.
  /// - [body]: Cuerpo o descripción de la notificación.
  /// - [notificationCount]: Número total de notificaciones a enviar.  
  ///    Si es 0, se interpretará como "notificaciones constantes".
  /// - [interval]: Intervalo entre notificaciones.
  /// - [startTime]: Hora inicial para el envío (por defecto, ahora + 5 segundos).
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int notificationCount,
    required Duration interval,
    DateTime? startTime,
  }) async {
    final DateTime initialTime =
        startTime ?? DateTime.now().add(Duration(seconds: 5));

    if (notificationCount == 0) {
      // Caso "constante": si el intervalo es uno de los soportados.
      if (interval == Duration(minutes: 1)) {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          title,
          body,
          RepeatInterval.everyMinute,
          _notificationDetails(),
          payload: '$title|$body',
          androidScheduleMode: AndroidScheduleMode.exact,
        );
      } else if (interval == Duration(hours: 1)) {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          title,
          body,
          RepeatInterval.hourly,
          _notificationDetails(),
          payload: '$title|$body',
          androidScheduleMode: AndroidScheduleMode.exact,
        );
      } else {
        // Si el intervalo no es uno de los soportados, programa al menos la primera notificación.
        await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: initialTime,
          payload: '$title|$body',
        );
        // Se podría implementar lógica adicional para reprogramar la siguiente notificación.
      }
    } else {
      // Programa una cantidad definida de notificaciones.
      for (int i = 0; i < notificationCount; i++) {
        DateTime scheduledTime = initialTime.add(interval * i);
        await scheduleNotification(
          id: id + i, // Cada notificación debe tener un ID único.
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: '$title|$body',
        );
      }
    }
  }

  /// Cancela una notificación con el [id] dado.
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancela todas las notificaciones programadas.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

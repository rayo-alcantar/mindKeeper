//lib/services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio para la gestión de notificaciones.
/// Se implementa como Singleton para asegurar una única instancia en la app.
class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Plugin principal de notificaciones.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el plugin y configura las zonas horarias.
  Future<void> init() async {
    // Inicialización de zonas horarias
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City')); // Ajusta a tu zona horaria

    // Crear y registrar el canal de notificaciones
    await _createNotificationChannel();

    // Configuración de inicialización
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Nueva configuración para iOS sin el callback obsoleto
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mindkeeper_channel',
      'MindKeeper Notifications',
      description: 'Canal para recordatorios de MindKeeper',
      importance: Importance.max,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) async {
    if (response.payload != null) {
      print('Notificación tocada. Payload: ${response.payload}');
      // Aquí puedes implementar la navegación o acción deseada
    }
  }

  /// Retorna la configuración de notificaciones para Android e iOS.
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'mindkeeper_channel',
        'MindKeeper Notifications',
        channelDescription: 'Canal para recordatorios de MindKeeper',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        channelShowBadge: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Programa una notificación individual para un momento específico.
  ///
  /// - [id]: Identificador único de la notificación.
  /// - [title]: Título de la notificación.
  /// - [body]: Descripción o cuerpo de la notificación.
  /// - [scheduledTime]: Fecha y hora a la que se debe mostrar la notificación.
  /// - [payload]: Información adicional opcional.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'mindkeeper_channel',
            'MindKeeper Notifications',
            channelDescription: 'Canal para recordatorios de MindKeeper',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      print('Notificación programada para: $scheduledTime');
    } catch (e) {
      print('Error al programar la notificación: $e');
    }
  }

  /// Programa un "recordatorio completo".
  ///
  /// - [notificationCount]: Número total de notificaciones.
  ///   - Si es 0, se interpretará como "constante" y se usarán notificaciones periódicas.
  /// - [interval]: Intervalo entre notificaciones.
  /// - [startTime]: Hora inicial (por defecto, ahora + 5 segundos).
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required int notificationCount,
    required Duration interval,
    DateTime? startTime,
  }) async {
    final DateTime initialTime =
        startTime ?? DateTime.now().add(const Duration(seconds: 5));

    if (notificationCount == 0) {
      // Modo "constante": se usan notificaciones periódicas si el intervalo está soportado.
      if (interval == const Duration(minutes: 1)) {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          title,
          body,
          RepeatInterval.everyMinute,
          _notificationDetails(),
          payload: '$title|$body',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else if (interval == const Duration(hours: 1)) {
        await flutterLocalNotificationsPlugin.periodicallyShow(
          id,
          title,
          body,
          RepeatInterval.hourly,
          _notificationDetails(),
          payload: '$title|$body',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        // Si el intervalo no es uno de los soportados por periodicallyShow,
        // se programa la primera notificación. Luego puedes encadenar la siguiente en el callback.
        await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: initialTime,
          payload: '$title|$body',
        );
      }
    } else {
      // Se programan varias notificaciones, cada una con un ID único.
      for (int i = 0; i < notificationCount; i++) {
        final DateTime scheduledTime = initialTime.add(interval * i);
        await scheduleNotification(
          id: id + i, // Asegúrate de IDs únicos
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: '$title|$body',
        );
      }
    }
  }

  /// Cancela una notificación específica.
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancela todas las notificaciones programadas.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Verifica si los permisos de notificación están habilitados
  Future<bool> checkNotificationPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return settings ?? false;
    }
    return false;
  }

  /// Obtiene todas las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

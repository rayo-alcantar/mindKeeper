//lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    // Inicializa las zonas horarias.
    tz.initializeTimeZones();

    // Ajustes de inicialización para Android.
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Ajustes de inicialización para iOS.
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Ajustes combinados.
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inicializa el plugin con los ajustes y define el callback al tocar la notificación.
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Aquí puedes manejar la acción cuando el usuario toca la notificación.
        // Por ejemplo, navegar a una pantalla específica:
        print('Notificación recibida (payload): ${response.payload}');
      },
    );
  }

  /// Retorna la configuración de notificaciones para Android e iOS.
  NotificationDetails _notificationDetails() {
    final androidDetails = AndroidNotificationDetails(
      'mindkeeper_channel',          // ID del canal
      'MindKeeper Notifications',    // Nombre del canal
      channelDescription: 'Canal para recordatorios de MindKeeper',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
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
    // Convierte la hora local a la zona horaria configurada.
    final tz.TZDateTime tzScheduled =
        tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,                           // ID de la notificación
      title,                        // Título
      body,                         // Cuerpo
      tzScheduled,                  // Fecha y hora programadas
      _notificationDetails(),       // Configuración de notificación
      payload: payload,
      // Usa modo exact para dispararse aunque el dispositivo esté inactivo
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
}

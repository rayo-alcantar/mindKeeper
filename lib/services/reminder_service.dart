//lib/services/reminder_service.dart
import 'dart:math';
import 'package:mindkeeper/models/reminder.dart';
import 'notification_service.dart';

/// Servicio de recordatorios.
/// Aquí se maneja la lista de recordatorios y sus notificaciones.
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  ReminderService._internal();

  /// Lista simulada de recordatorios en memoria (en una app real, vendría de BD).
  final List<Reminder> _reminders = [];

  /// Retorna una copia de la lista de recordatorios.
  List<Reminder> getReminders() {
    return List.unmodifiable(_reminders);
  }

  /// Agrega un nuevo recordatorio y programa sus notificaciones.
  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    try {
      await NotificationService().scheduleReminder(
        id: reminder.id,
        title: reminder.name,
        body: reminder.description,
        notificationCount: reminder.notificationCount,
        interval: reminder.interval,
      );
    } catch (e, s) {
      print('Error al programar notificación: $e\n$s');
    }
  }

  /// Edita un recordatorio existente.
  /// Primero cancela las notificaciones previas, luego programa las nuevas.
  Future<void> editReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      // Cancela las notificaciones previas
      await _cancelReminderNotifications(_reminders[index]);
      // Actualiza el recordatorio en la lista
      _reminders[index] = updated;
      // Programa las nuevas notificaciones
      await NotificationService().scheduleReminder(
        id: updated.id,
        title: updated.name,
        body: updated.description,
        notificationCount: updated.notificationCount,
        interval: updated.interval,
      );
    }
  }

  /// Elimina un recordatorio y sus notificaciones asociadas.
  Future<void> deleteReminder(int reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = _reminders[index];
      await _cancelReminderNotifications(reminder);
      _reminders.removeAt(index);
    }
  }

  /// Cancela las notificaciones asociadas a un recordatorio.
  Future<void> _cancelReminderNotifications(Reminder reminder) async {
    if (reminder.notificationCount == 0) {
      // Modo constante, cancela la notificación base
      await NotificationService().cancelNotification(reminder.id);
    } else {
      // Modo con un número fijo de notificaciones
      for (int i = 0; i < reminder.notificationCount; i++) {
        await NotificationService().cancelNotification(reminder.id + i);
      }
    }
  }

  /// Genera un ID único para cada recordatorio.
  int generateId() {
    // En un escenario real, esto podría ser un autoincremental de BD
    return Random().nextInt(1000000);
  }
}

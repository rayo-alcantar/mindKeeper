//lib/screens/manage_reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:mindkeeper/services/notification_service.dart';
import 'package:mindkeeper/models/reminder.dart';
import 'edit_reminder_screen.dart';
import 'package:mindkeeper/services/reminder_service.dart';

class ManageRemindersScreen extends StatefulWidget {
  @override
  _ManageRemindersScreenState createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    // Se cargan los recordatorios desde la fuente de datos.
    List<Reminder> reminders = await _reminderService.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  void _editReminder(Reminder reminder) async {
    // Se navega a la pantalla de editar enviando el recordatorio seleccionado.
    final updatedReminder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderScreen(reminder: reminder),
      ),
    );

    if (updatedReminder != null) {
      setState(() {
        // Se actualiza el recordatorio en la lista.
        final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
        if (index != -1) {
          _reminders[index] = updatedReminder;
        }
      });
    }
  }

  void _deleteReminder(Reminder reminder) async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Recordatorio'),
        content: Text('¿Estás seguro de que deseas eliminar el recordatorio "${reminder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', semanticsLabel: 'Botón: Cancelar eliminación del recordatorio'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', semanticsLabel: 'Botón: Eliminar recordatorio'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Se cancela la notificación asociada y se elimina el recordatorio.
      await _notificationService.cancelNotification(reminder.id);
      await _reminderService.deleteReminder(reminder.id);
      // Recargamos la lista para actualizar la interfaz inmediatamente.
      await _loadReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Recordatorios'),
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No hay recordatorios creados.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Regresar', semanticsLabel: 'Botón: Regresar a la pantalla anterior'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(reminder.name, semanticsLabel: 'Nombre: ${reminder.name}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reminder.description, semanticsLabel: 'Descripción: ${reminder.description}'),
                        Text('Número de notificaciones: ${reminder.notificationCount}', semanticsLabel: 'Número de notificaciones: ${reminder.notificationCount}'),
                        Text('Intervalo: ${reminder.interval.inMinutes} minutos', semanticsLabel: 'Intervalo: ${reminder.interval.inMinutes} minutos'),
                      ],
                    ),
                    // Se ha eliminado el onTap de la tarjeta para evitar que se agrupe la acción.
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Botón: Editar recordatorio ${reminder.name}',
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editReminder(reminder),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Botón: Eliminar recordatorio ${reminder.name}',
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteReminder(reminder),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

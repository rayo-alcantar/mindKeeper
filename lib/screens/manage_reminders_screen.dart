//lib/screens/manage_reminders_screen.dart
import 'package:flutter/material.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';
import 'edit_reminder_screen.dart';

class ManageRemindersScreen extends StatefulWidget {
  @override
  _ManageRemindersScreenState createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    final reminders = _reminderService.getReminders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Recordatorios'),
      ),
      body: reminders.isEmpty
          ? _buildEmptyView(context)
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];

                // Envuelve el ListTile en un Semantics para indicar que es pulsable.
                return Semantics(
                  button: true,
                  label: 'Recordatorio ${reminder.name}, pulsa para editar',
                  child: ListTile(
                    title: Text(reminder.name),
                    subtitle: Text(
                      'Descripción: ${reminder.description}\n'
                      'Notificaciones: ${reminder.notificationCount == 0 ? "Constante" : reminder.notificationCount}\n'
                      'Intervalo: ${_durationToString(reminder.interval)}',
                    ),
                    isThreeLine: true,
                    trailing: Semantics(
                      label: 'Borrar recordatorio',
                      button: true,
                      child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _reminderService.deleteReminder(reminder.id);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Recordatorio eliminado.')),
                          );
                        },
                      ),
                    ),
                    onTap: () async {
                      // Navega a la pantalla de edición y espera el resultado.
                      final updated = await Navigator.push<Reminder?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReminderScreen(reminder: reminder),
                        ),
                      );
                      // Si se devolvió un recordatorio actualizado, lo editamos
                      if (updated != null) {
                        await _reminderService.editReminder(updated);
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No hay recordatorios guardados.'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Volver al menú'),
          ),
        ],
      ),
    );
  }

  // Convierte una Duration a un string amigable, ej. "0h 15m"
  String _durationToString(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}

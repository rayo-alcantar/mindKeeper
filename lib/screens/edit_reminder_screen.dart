// lib/screens/edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindkeeper/models/reminder.dart';
import 'package:mindkeeper/services/notification_service.dart';
import 'package:mindkeeper/services/reminder_service.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;

  EditReminderScreen({required this.reminder});

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  late String _name;
  late String _description;
  late int _notificationCount;
  late Duration _interval;
  late bool _isCustom;

  // Campos para el tiempo personalizado (horas y minutos)
  String _customHours = '00';
  String _customMinutes = '00';

  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();

  // Intervalos predefinidos
  final Duration _predefined15 = Duration(minutes: 15);
  final Duration _predefined1h = Duration(hours: 1);
  final Duration _predefined2h = Duration(hours: 2);

  @override
  void initState() {
    super.initState();
    // Inicializamos los valores a partir del recordatorio existente.
    _name = widget.reminder.name;
    _description = widget.reminder.description;
    _notificationCount = widget.reminder.notificationCount;
    _interval = widget.reminder.interval;

    // Se determina si el intervalo es predefinido o personalizado.
    if (_interval == _predefined15 || _interval == _predefined1h || _interval == _predefined2h) {
      _isCustom = false;
    } else {
      _isCustom = true;
      int hours = _interval.inHours;
      int minutes = _interval.inMinutes.remainder(60);
      _customHours = hours.toString().padLeft(2, '0');
      _customMinutes = minutes.toString().padLeft(2, '0');
    }
  }

  // Diálogo de ayuda que explica cada campo del formulario.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ayuda'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  '• Nombre: Ingrese el título del recordatorio. Ejemplo: "Cita médica", "Reunión con clientes".',
                ),
                Text(
                  '• Descripción: Agregue detalles o instrucciones adicionales. Ejemplo: "Revisar resultados de laboratorio", "Preparar presentación".',
                ),
                Text(
                  '• Número de notificaciones: Indique cuántas notificaciones se enviarán. Use 0 para notificaciones constantes o ingrese un número (ej. 3) para un número limitado.',
                ),
                Text('• Intervalo entre notificaciones:'),
                Text(
                  '   - Si no se personaliza, podrá elegir entre intervalos de 15 minutos, 1 hora o 2 horas.',
                ),
                Text(
                  '   - Si se activa "Personalizar intervalo", ingrese manualmente horas y minutos.',
                ),
                Text('• Botones "Cancelar" y "Guardar cambios":'),
                Text(
                  '   - Cancelar: Descarta los cambios y regresa a la pantalla anterior.',
                ),
                Text(
                  '   - Guardar cambios: Valida y actualiza el recordatorio, reprogramando las notificaciones.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Construye el widget para la selección del intervalo.
  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alterna entre intervalo predefinido y personalizado.
        SwitchListTile(
          title: Text('Personalizar intervalo'),
          value: _isCustom,
          onChanged: (value) {
            setState(() {
              _isCustom = value;
              if (!_isCustom) {
                _interval = _predefined15;
                _customHours = '00';
                _customMinutes = '00';
              }
            });
          },
        ),
        SizedBox(height: 8),
        // Muestra el control correspondiente.
        _isCustom
            ? Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _customHours,
                      decoration: InputDecoration(
                        labelText: 'Horas',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateHours,
                      onSaved: (value) => _customHours = value!.padLeft(2, '0'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(":", style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: _customMinutes,
                      decoration: InputDecoration(
                        labelText: 'Minutos',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateMinutes,
                      onSaved: (value) => _customMinutes = value!.padLeft(2, '0'),
                    ),
                  ),
                ],
              )
            : DropdownButtonFormField<Duration>(
                decoration: InputDecoration(
                  labelText: 'Intervalo entre notificaciones',
                  border: OutlineInputBorder(),
                ),
                value: (_interval == _predefined15 || _interval == _predefined1h || _interval == _predefined2h)
                    ? _interval
                    : _predefined15,
                items: [
                  DropdownMenuItem(
                    value: _predefined15,
                    child: Text('15 minutos'),
                  ),
                  DropdownMenuItem(
                    value: _predefined1h,
                    child: Text('1 hora'),
                  ),
                  DropdownMenuItem(
                    value: _predefined2h,
                    child: Text('2 horas'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _interval = value!;
                  });
                },
              ),
      ],
    );
  }

  // Validación para el campo de horas.
  String? _validateHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa las horas';
    }
    final int? hours = int.tryParse(value);
    if (hours == null || hours < 0 || hours > 23) {
      return 'Horas entre 0 y 23';
    }
    return null;
  }

  // Validación para el campo de minutos.
  String? _validateMinutes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa los minutos';
    }
    final int? minutes = int.tryParse(value);
    if (minutes == null || minutes < 0 || minutes > 59) {
      return 'Minutos entre 0 y 59';
    }
    return null;
  }

  // Función para guardar los cambios y reprogramar las notificaciones.
  Future<void> _saveEditedReminder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCustom) {
        _interval = Duration(
          hours: int.parse(_customHours),
          minutes: int.parse(_customMinutes),
        );
      }

      final updatedReminder = Reminder(
        id: widget.reminder.id,
        name: _name,
        description: _description,
        notificationCount: _notificationCount,
        interval: _interval,
        isConstant: _notificationCount == 0,
      );

      await _notificationService.cancelNotification(widget.reminder.id);
      await _notificationService.scheduleReminder(
        id: updatedReminder.id,
        title: updatedReminder.name,
        body: updatedReminder.description,
        notificationCount: updatedReminder.notificationCount,
        interval: updatedReminder.interval,
      );

      await _reminderService.editReminder(updatedReminder);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorio actualizado y notificaciones reprogramadas.')),
      );

      Navigator.pop(context, updatedReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Recordatorio'),
        actions: [
          Semantics(
            label: 'Ayuda con los controles',
            excludeSemantics: true,
            child: IconButton(
              icon: Icon(Icons.help_outline),
              tooltip: 'Ayuda',
              onPressed: _showHelpDialog,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo para el nombre del recordatorio
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Nombre del recordatorio',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              SizedBox(height: 16),
              // Campo para la descripción
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              SizedBox(height: 16),
              // Campo para número de notificaciones
              TextFormField(
                initialValue: _notificationCount.toString(),
                decoration: InputDecoration(
                  labelText: 'Número de notificaciones (0 para constante)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _notificationCount = int.tryParse(value!.trim()) ?? 1,
              ),
              SizedBox(height: 16),
              Text(
                'Intervalo entre notificaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              _buildIntervalSelector(),
              SizedBox(height: 24),
              // Botones de Cancelar y Guardar cambios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color accesible para cancelar
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      semanticsLabel: 'Botón: Cancelar',
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Color accesible para guardar
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveEditedReminder,
                    child: Text(
                      'Guardar cambios',
                      semanticsLabel: 'Botón: Guardar cambios en el recordatorio',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

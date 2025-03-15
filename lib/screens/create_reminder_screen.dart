// lib/screens/create_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/reminder_service.dart';
import '../models/reminder.dart';

class CreateReminderScreen extends StatefulWidget {
  @override
  _CreateReminderScreenState createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos del formulario
  String _name = '';
  String _description = '';
  int _notificationCount = 1;
  Duration _interval = Duration(minutes: 15);
  bool _isCustom = false; // Selección entre intervalo predefinido y personalizado

  // Campos para tiempo personalizado (horas y minutos)
  String _customHours = '00';
  String _customMinutes = '00';

  // Muestra un diálogo de ayuda que explica el funcionamiento de cada campo.
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ayuda'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('• Nombre: Título del recordatorio.'),
                Text('• Descripción: Detalles adicionales.'),
                Text('• Número de notificaciones: Cantidad a enviar (0 para notificaciones constantes).'),
                Text('• Intervalo entre notificaciones: Elige entre opciones predefinidas o personaliza el intervalo.'),
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

  // Construye el widget de entrada para el intervalo (predefinido o personalizado)
  Widget _buildIntervalInput() {
    if (_isCustom) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: _customHours,
              decoration: InputDecoration(labelText: 'Horas'),
              keyboardType: TextInputType.number,
              maxLength: 2,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa horas';
                }
                final int? hours = int.tryParse(value);
                if (hours == null || hours < 0 || hours > 23) {
                  return 'Horas entre 0 y 23';
                }
                return null;
              },
              onSaved: (value) => _customHours = value!.padLeft(2, '0'),
            ),
          ),
          SizedBox(width: 8),
          Text(":", style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              initialValue: _customMinutes,
              decoration: InputDecoration(labelText: 'Minutos'),
              keyboardType: TextInputType.number,
              maxLength: 2,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa minutos';
                }
                final int? minutes = int.tryParse(value);
                if (minutes == null || minutes < 0 || minutes > 59) {
                  return 'Minutos entre 0 y 59';
                }
                return null;
              },
              onSaved: (value) => _customMinutes = value!.padLeft(2, '0'),
            ),
          ),
        ],
      );
    } else {
      return DropdownButtonFormField<Duration>(
        decoration: InputDecoration(
          labelText: 'Intervalo entre notificaciones',
        ),
        value: _interval,
        items: [
          DropdownMenuItem(
            value: Duration(minutes: 15),
            child: Text('15 minutos'),
          ),
          DropdownMenuItem(
            value: Duration(hours: 1),
            child: Text('1 hora'),
          ),
          DropdownMenuItem(
            value: Duration(hours: 2),
            child: Text('2 horas'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _interval = value!;
          });
        },
      );
    }
  }

  // Función para guardar el recordatorio y programar las notificaciones.
  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCustom) {
        _interval = Duration(
          hours: int.parse(_customHours),
          minutes: int.parse(_customMinutes),
        );
      }

      final reminderService = ReminderService();
      final newReminder = Reminder(
        id: reminderService.generateId(),
        name: _name,
        description: _description,
        notificationCount: _notificationCount,
        interval: _interval,
        isConstant: _notificationCount == 0,
      );

      await reminderService.addReminder(newReminder);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recordatorio guardado y notificaciones programadas.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Recordatorio'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: 'Ayuda',
            onPressed: _showHelpDialog,
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
              // Campo para el nombre
              Semantics(
                label: 'Campo de nombre del recordatorio',
                textField: true,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Nombre del recordatorio'),
                  onSaved: (value) => _name = value!.trim(),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingresa un nombre' : null,
                ),
              ),
              SizedBox(height: 16),
              // Campo para la descripción
              Semantics(
                label: 'Campo de descripción',
                textField: true,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Descripción'),
                  onSaved: (value) => _description = value?.trim() ?? '',
                ),
              ),
              SizedBox(height: 16),
              // Campo para número de notificaciones
              Semantics(
                label: 'Campo para número de notificaciones',
                textField: true,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Número de notificaciones (0 para constante)',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _notificationCount = int.tryParse(value!.trim()) ?? 1,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Intervalo entre notificaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              // Selección entre intervalo predefinido y personalizado
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Predefinido'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: _isCustom,
                        onChanged: (value) {
                          setState(() {
                            _isCustom = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Personalizar'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: _isCustom,
                        onChanged: (value) {
                          setState(() {
                            _isCustom = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildIntervalInput(),
              SizedBox(height: 24),
              // Botones de Cancelar y Guardar (Cancelar a la izquierda, Guardar a la derecha)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _saveReminder,
                    child: Text('Guardar'),
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

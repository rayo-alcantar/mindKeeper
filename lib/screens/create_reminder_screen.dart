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
  bool _isCustom = false; // false: predefinido, true: personalizado

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
                  '   - Guardar: Valida y actualiza el recordatorio, programando las notificaciones.',
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

  // Construye el widget para la selección del intervalo
  Widget _buildIntervalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alterna entre intervalo predefinido y personalizado
        SwitchListTile(
          title: Text('Personalizar intervalo'),
          value: _isCustom,
          onChanged: (value) {
            setState(() {
              _isCustom = value;
              // Reinicia al valor predefinido si se desactiva la personalización
              if (!_isCustom) {
                _interval = Duration(minutes: 15);
                _customHours = '00';
                _customMinutes = '00';
              }
            });
          },
        ),
        SizedBox(height: 8),
        // Muestra el control correspondiente
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
                      onSaved: (value) =>
                          _customHours = value!.padLeft(2, '0'),
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
                      onSaved: (value) =>
                          _customMinutes = value!.padLeft(2, '0'),
                    ),
                  ),
                ],
              )
            : DropdownButtonFormField<Duration>(
                decoration: InputDecoration(
                  labelText: 'Intervalo entre notificaciones',
                  border: OutlineInputBorder(),
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
              ),
      ],
    );
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
              // Campo para el nombre
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del recordatorio',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              SizedBox(height: 16),
              // Campo para la descripción
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              SizedBox(height: 16),
              // Campo para número de notificaciones
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de notificaciones (0 para constante)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _notificationCount = int.tryParse(value!.trim()) ?? 1,
              ),
              SizedBox(height: 16),
              // Sección para el intervalo
              _buildIntervalSelector(),
              SizedBox(height: 24),
              // Botones de Cancelar y Guardar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Color accesible para cancelar
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Color accesible para guardar
                      foregroundColor: Colors.white,
                    ),
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

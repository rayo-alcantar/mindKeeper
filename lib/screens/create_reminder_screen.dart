//lib/screens/create_reminder_screen.dart
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
  bool _isCustom = false; // Si se selecciona "Personalizar"
  String _customTime = ''; // Se espera formato HH:MM

  // Valida el formato de hora (HH:MM)
  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el intervalo en formato HH:MM';
    }
    final RegExp timeRegex = RegExp(r'^([0-1]?\d|2[0-3]):([0-5]\d)$');
    if (!timeRegex.hasMatch(value.trim())) {
      return 'Formato inválido. Usa HH:MM (ej. 10:30)';
    }
    return null;
  }

  // Convierte la cadena HH:MM a Duration
  Duration _parseTimeToDuration(String value) {
    final parts = value.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  // Función para guardar el recordatorio y programar las notificaciones
  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCustom) {
        _interval = _parseTimeToDuration(_customTime);
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del recordatorio'),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de notificaciones (0 para constante)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _notificationCount = int.tryParse(value!.trim()) ?? 1,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Predefinido (15 min, 1h, etc.)'),
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
              if (_isCustom)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ingresa el intervalo en formato HH:MM',
                    hintText: 'Ej. 10:30',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d:]')),
                  ],
                  validator: _validateTime,
                  onSaved: (value) => _customTime = value!.trim(),
                )
              else
                DropdownButtonFormField<Duration>(
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
                ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveReminder,
                    child: Text('Guardar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
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

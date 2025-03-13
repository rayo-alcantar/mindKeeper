//lib/screens/edit_reminder_screen.dart
import 'package:flutter/material.dart';
import '../models/reminder.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;
  const EditReminderScreen({Key? key, required this.reminder}) : super(key: key);

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late int _notificationCount;
  late Duration _interval;
  bool _isCustom = false;
  String _customTime = '';

  @override
  void initState() {
    super.initState();
    _name = widget.reminder.name;
    _description = widget.reminder.description;
    _notificationCount = widget.reminder.notificationCount;
    _interval = widget.reminder.interval;
    _isCustom = false;
  }

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

  Duration _parseTimeToDuration(String value) {
    final parts = value.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCustom) {
        _interval = _parseTimeToDuration(_customTime);
      }

      final updatedReminder = Reminder(
        id: widget.reminder.id,
        name: _name,
        description: _description,
        notificationCount: _notificationCount,
        interval: _interval,
        isConstant: _notificationCount == 0,
      );

      // Retorna el recordatorio actualizado a la pantalla anterior
      Navigator.pop(context, updatedReminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Recordatorio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa un nombre' : null,
                onSaved: (value) => _name = value!.trim(),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _notificationCount.toString(),
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
              if (_isCustom)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ingresa el intervalo en formato HH:MM',
                    hintText: 'Ej. 10:30',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateTime,
                  onSaved: (value) => _customTime = value!.trim(),
                )
              else
                DropdownButtonFormField<Duration>(
                  decoration: InputDecoration(labelText: 'Intervalo predefinido'),
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
                    onPressed: _saveChanges,
                    child: Text('Guardar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

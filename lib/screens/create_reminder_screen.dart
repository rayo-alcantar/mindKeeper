// lib/screens/create_reminder_screen.dart
import 'package:flutter/material.dart';

class CreateReminderScreen extends StatefulWidget {
  @override
  _CreateReminderScreenState createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _notificationCount = 1;
  Duration _interval = Duration(minutes: 30);

  final List<Duration> _predefinedIntervals = [
    Duration(minutes: 30),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 6),
    Duration(hours: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Recordatorio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del recordatorio'),
                onSaved: (value) => _name = value!.trim(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) => _description = value!.trim(),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de notificaciones (0 para constante)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    _notificationCount = int.tryParse(value!) ?? 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButtonFormField<Duration>(
                  decoration: InputDecoration(
                    labelText: 'Intervalo entre notificaciones',
                  ),
                  value: _predefinedIntervals.first,
                  items: _predefinedIntervals.map((duration) {
                    String text;
                    if (duration.inMinutes < 60) {
                      text = '${duration.inMinutes} minutos';
                    } else {
                      text = '${duration.inHours} horas';
                    }
                    return DropdownMenuItem<Duration>(
                      value: duration,
                      child: Text(text),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _interval = value!;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Aquí se integrará la lógica para guardar el recordatorio y programar notificaciones.
                        Navigator.pop(context);
                      }
                    },
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

﻿import 'package:flutter/material.dart';
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

  // Para el modo personalizado se usan dos campos: horas y minutos.
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
    // Inicializamos los valores a partir del recordatorio seleccionado.
    _name = widget.reminder.name;
    _description = widget.reminder.description;
    _notificationCount = widget.reminder.notificationCount;
    _interval = widget.reminder.interval;

    // Se determina si el intervalo es predefinido o personalizado.
    if (_interval == _predefined15 || _interval == _predefined1h || _interval == _predefined2h) {
      _isCustom = false;
    } else {
      _isCustom = true;
      // Se separa el intervalo en horas y minutos.
      int hours = _interval.inHours;
      int minutes = _interval.inMinutes.remainder(60);
      _customHours = hours.toString().padLeft(2, '0');
      _customMinutes = minutes.toString().padLeft(2, '0');
    }
  }

  // Validación para el campo de horas: valor entre 0 y 23.
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

  // Validación para el campo de minutos: valor entre 0 y 59.
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

  Future<void> _saveEditedReminder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isCustom) {
        _interval = Duration(
          hours: int.parse(_customHours),
          minutes: int.parse(_customMinutes),
        );
      }

      // Se crea el objeto actualizado del recordatorio.
      final updatedReminder = Reminder(
        id: widget.reminder.id,
        name: _name,
        description: _description,
        notificationCount: _notificationCount,
        interval: _interval,
        isConstant: _notificationCount == 0,
      );

      // Se cancelan las notificaciones existentes para este recordatorio.
      await _notificationService.cancelNotification(widget.reminder.id);

      // Se reprograman las notificaciones según los nuevos datos.
      await _notificationService.scheduleReminder(
        id: updatedReminder.id,
        title: updatedReminder.name,
        body: updatedReminder.description,
        notificationCount: updatedReminder.notificationCount,
        interval: updatedReminder.interval,
      );

      // Se actualiza el recordatorio en la fuente de datos.
      await _reminderService.editReminder(updatedReminder);

      // Se muestra un mensaje de confirmación.
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
                ),
                onSaved: (value) => _description = value?.trim() ?? '',
              ),
              SizedBox(height: 16),
              // Campo para el número de notificaciones
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
              // Selección entre intervalos predefinidos y personalizados
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Predefinido (15 min, 1h, 2h)'),
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
              // Si es personalizado se muestran dos campos separados para horas y minutos.
              _isCustom
                  ? Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _customHours,
                            decoration: InputDecoration(
                              labelText: 'Horas',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateHours,
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
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateMinutes,
                            onSaved: (value) =>
                                _customMinutes = value!.padLeft(2, '0'),
                          ),
                        ),
                      ],
                    )
                  : DropdownButtonFormField<Duration>(
                      decoration: InputDecoration(
                        labelText: 'Intervalo entre notificaciones',
                      ),
                      value: (_interval == _predefined15 ||
                              _interval == _predefined1h ||
                              _interval == _predefined2h)
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
              SizedBox(height: 24),
              // Botones de guardar y cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveEditedReminder,
                    child: Text(
                      'Guardar cambios',
                      semanticsLabel: 'Botón: Guardar cambios en el recordatorio',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      semanticsLabel: 'Botón: Cancelar edición del recordatorio',
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

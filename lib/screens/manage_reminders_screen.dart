// lib/screens/manage_reminders_screen.dart
import 'package:flutter/material.dart';

class ManageRemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Recordatorios'),
      ),
      body: Center(
        child: Text(
          'Aquí se mostrarán los recordatorios guardados.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

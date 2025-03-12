// lib/screens/config_screen.dart
import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Text(
          'Opciones de configuración se mostrarán aquí.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

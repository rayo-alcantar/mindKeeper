// lib/screens/config_screen.dart
import 'package:flutter/material.dart';
import 'package:mindkeeper/services/settings_service.dart';
import 'edit_notification_sound_screen.dart';
// Importa aquí también NotificationService si deseas notificar el cambio en la configuración.
// import 'package:mindkeeper/services/notification_service.dart';

class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final SettingsService _settingsService = SettingsService();
  // String para almacenar el sonido actual.
  String _currentSound = SettingsService.defaultNotificationSound;

  @override
  void initState() {
    super.initState();
    _loadCurrentSound();
  }

  Future<void> _loadCurrentSound() async {
    final sound = await _settingsService.getNotificationSound();
    setState(() {
      _currentSound = sound;
    });
  }

  Future<void> _editNotificationSound() async {
    // Navega a la pantalla para editar el sonido.
    final selectedSound = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotificationSoundScreen(currentSound: _currentSound),
      ),
    );
    if (selectedSound != null) {
      // Guarda la selección y actualiza la pantalla.
      await _settingsService.setNotificationSound(selectedSound);
      setState(() {
        _currentSound = selectedSound;
      });
      // Aquí podrías notificar al NotificationService para que actualice el ringtone de las notificaciones.
      // Ejemplo:
      // NotificationService().updateNotificationSound(selectedSound);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(
              'Editar sonido de notificación',
              style: TextStyle(fontSize: 18),
            ),
            subtitle: Text('Sonido actual: $_currentSound', style: TextStyle(fontSize: 16)),
            trailing: Icon(Icons.chevron_right),
            onTap: _editNotificationSound,
            // Etiqueta semántica completa para accesibilidad.
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          // Aquí se podrían agregar más opciones de configuración.
        ],
      ),
    );
  }
}

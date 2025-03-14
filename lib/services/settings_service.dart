import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyNotificationSound = 'notificationSound';
  static const String defaultNotificationSound = 'default';

  /// Retorna el sonido de notificación almacenado o el valor por defecto.
  Future<String> getNotificationSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNotificationSound) ?? defaultNotificationSound;
  }

  /// Almacena el sonido de notificación seleccionado.
  Future<void> setNotificationSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotificationSound, sound);
  }
}

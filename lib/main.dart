//lib/main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/create_reminder_screen.dart';
import 'screens/manage_reminders_screen.dart';
import 'screens/config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de notificaciones
  await NotificationService().init();

  runApp(MindKeeperApp());
}

class MindKeeperApp extends StatefulWidget {
  @override
  _MindKeeperAppState createState() => _MindKeeperAppState();
}

class _MindKeeperAppState extends State<MindKeeperApp> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  /// Solicita permiso de notificaciones en Android 13+ (POST_NOTIFICATIONS).
  /// En versiones anteriores, este permiso no hará nada y la notificación funcionará igual.
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("Permiso de notificaciones concedido.");
      } else {
        print("Permiso de notificaciones denegado.");
      }
    } else {
      // Ya está concedido o no aplica (versiones < Android 13)
      print("Permiso de notificaciones ya concedido o no requerido.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindKeeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/create': (context) => CreateReminderScreen(),
        '/manage': (context) => ManageRemindersScreen(),
        '/config': (context) => ConfigScreen(),
      },
    );
  }
}

//lib/main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/create_reminder_screen.dart';
import 'screens/manage_reminders_screen.dart';
import 'screens/config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de notificaciones
  await NotificationService().init();
  
  // Solicitar permisos al inicio de la app
  await _requestPermissions();

  runApp(MindKeeperApp());
}

Future<void> _requestPermissions() async {
  // Solicitar múltiples permisos
  await Future.wait([
    Permission.notification.request(),
    Permission.scheduleExactAlarm.request(),
  ]);
}

class MindKeeperApp extends StatefulWidget {
  @override
  _MindKeeperAppState createState() => _MindKeeperAppState();
}

class _MindKeeperAppState extends State<MindKeeperApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _requestNotificationPermission();
    // Verificar permisos de alarmas exactas (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      print("Se requiere permiso de alarmas exactas");
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("Permiso de notificaciones concedido.");
      } else {
        print("Permiso de notificaciones denegado.");
        // Mostrar diálogo para explicar por qué se necesitan los permisos
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permisos necesarios'),
          content: Text('Las notificaciones son necesarias para recordarte tus tareas. Por favor, actívalas en la configuración.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Abrir configuración'),
            ),
          ],
        ),
      );
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

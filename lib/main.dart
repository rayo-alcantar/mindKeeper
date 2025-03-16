import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/create_reminder_screen.dart';
import 'screens/manage_reminders_screen.dart';
import 'screens/config_screen.dart';
import 'screens/edit_reminder_screen.dart';
import 'models/reminder.dart'; // Asegúrate de importar el modelo Reminder

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de notificaciones
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  
  // Verificar y solicitar permisos de notificación
  await notificationService.checkNotificationPermissions();

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
    _initializeNotifications();
    _requestPermissions();
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

  Future<void> _requestPermissions() async {
    // Solicitar permisos de notificación
    final notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    // Solicitar permisos de almacenamiento para Android < 13
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
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
      // Rutas fijas para otras pantallas
      routes: {
        '/': (context) => HomeScreen(),
        '/create': (context) => CreateReminderScreen(),
        '/manage': (context) => ManageRemindersScreen(),
        '/config': (context) => ConfigScreen(),
      },
      // Definición de la ruta '/edit' para recibir un objeto Reminder a través de los argumentos
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final reminder = settings.arguments as Reminder;
          return MaterialPageRoute(
            builder: (context) => EditReminderScreen(reminder: reminder),
          );
        }
        return null;
      },
    );
  }
}

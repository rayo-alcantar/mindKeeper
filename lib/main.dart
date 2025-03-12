// lib/main.dart
import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/create_reminder_screen.dart';
import 'screens/manage_reminders_screen.dart';
import 'screens/config_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(MindKeeperApp());
}

class MindKeeperApp extends StatelessWidget {
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

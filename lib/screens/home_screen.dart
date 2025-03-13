//lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función para abrir una URL externa
  Future<void> _openUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  // Función para salir de la aplicación
  void _exitApp(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MindKeeper'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
            child: Text('Crear recordatorio'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/manage');
            },
            child: Text('Gestionar recordatorios'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
            child: Text('Configuración'),
          ),
          ElevatedButton(
            onPressed: () {
              _openUrl(context, 'https://www.paypal.me/tuusuario');
            },
            child: Text('Donar al desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              _openUrl(context, 'https://www.tusitioweb.com');
            },
            child: Text('Mirar la web del desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              _exitApp(context);
            },
            child: Text('Salir'),
          ),

          // Se ha removido el botón de prueba de notificación en 30s,
          // tal como solicitaste.
        ],
      ),
    );
  }
}

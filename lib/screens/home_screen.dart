//lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función para abrir una URL externa usando las APIs actuales de url_launcher.
  Future<void> _openUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      // Se abre la URL en una aplicación externa.
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  // Función para salir de la aplicación.
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
              _openUrl(context, 'https://paypal.me/rayoalcantar?country.x=MX&locale.x=es_XC');
            },
            child: Text('Donar al desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              _openUrl(context, 'https://rayoscompany.com/');
            },
            child: Text('Mirar la web del desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              _exitApp(context);
            },
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }
}

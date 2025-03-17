// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función para abrir una URL externa usando las APIs actuales de url_launcher.
  Future<void> _openUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se asigna un fondo con color personalizado
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('MindKeeper'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Botón para Crear recordatorio
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
            child: Text('Crear recordatorio'),
          ),
          SizedBox(height: 16),
          // Botón para Gestionar recordatorios
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/manage');
            },
            child: Text('Gestionar recordatorios'),
          ),
          SizedBox(height: 16),
          // Botón para Configuración
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
            child: Text('Configuración'),
          ),
          SizedBox(height: 16),
          // Botón para Donar al desarrollador
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              _openUrl(context, 'https://paypal.me/rayoalcantar?country.x=MX&locale.x=es_XC');
            },
            child: Text('Donar al desarrollador'),
          ),
          SizedBox(height: 16),
          // Botón para Mirar la web del desarrollador
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            onPressed: () {
              _openUrl(context, 'https://rayoscompany.com/');
            },
            child: Text('Mirar la web del desarrollador'),
          ),
        ],
      ),
    );
  }
}

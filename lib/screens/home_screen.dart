import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  // Función que recibe el BuildContext y la URL a abrir.
  Future<void> _openUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Usa el contexto recibido para mostrar un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  // Función para salir de la aplicación
  void _exitApp(BuildContext context) {
    // Se recomienda usar SystemNavigator.pop() en aplicaciones móviles
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
              // Llama a _openUrl pasando el contexto actual y la URL de PayPal
              _openUrl(context, 'https://www.paypal.me/tuusuario');
            },
            child: Text('Donar al desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              // Llama a _openUrl pasando el contexto actual y la URL de tu sitio web
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
        ],
      ),
    );
  }
}

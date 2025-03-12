import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir la web y Paypal

class HomeScreen extends StatelessWidget {
  void _exitApp(BuildContext context) {
    // Se puede usar el paquete 'exit_app' o SystemNavigator.pop() para cerrar la app
    // Importante: en plataformas móviles se debe tener cuidado al cerrar la aplicación de forma abrupta.
    Navigator.of(context).pop();
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se usa ListView para facilitar la navegación y accesibilidad
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
              // Abre el enlace a Paypal para donar
              _openUrl('https://www.paypal.me/tuusuario');
            },
            child: Text('Donar al desarrollador'),
          ),
          ElevatedButton(
            onPressed: () {
              // Abre la web del desarrollador
              _openUrl('https://www.tusitioweb.com');
            },
            child: Text('Mirar la web del desarrollador'),
          ),
          ElevatedButton(
            onPressed: () => _exitApp(context),
            child: Text('Salir'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EditNotificationSoundScreen extends StatefulWidget {
  final String currentSound;

  const EditNotificationSoundScreen({required this.currentSound});

  @override
  _EditNotificationSoundScreenState createState() => _EditNotificationSoundScreenState();
}

class _EditNotificationSoundScreenState extends State<EditNotificationSoundScreen> {
  late String _selectedSound;

  // Lista predefinida de sonidos disponibles.
  final List<Map<String, String>> availableSounds = [
    {'name': 'Default', 'value': 'default'},
    {'name': 'Sonido 1', 'value': 'sound1'},
    {'name': 'Sonido 2', 'value': 'sound2'},
    {'name': 'Sonido 3', 'value': 'sound3'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
  }

  void _saveSelection() {
    // Retorna el valor seleccionado a la pantalla anterior.
    Navigator.pop(context, _selectedSound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar sonido de notificación'),
      ),
      body: ListView.builder(
        itemCount: availableSounds.length,
        itemBuilder: (context, index) {
          final sound = availableSounds[index];
          return RadioListTile<String>(
            title: Text(sound['name']!, style: TextStyle(fontSize: 16)),
            secondary: Icon(Icons.music_note),
            value: sound['value']!,
            groupValue: _selectedSound,
            onChanged: (value) {
              setState(() {
                _selectedSound = value!;
              });
            },
            // Etiqueta semántica para accesibilidad.
            subtitle: Text('Selecciona el sonido ${sound['name']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelection,
        tooltip: 'Guardar selección',
        child: Icon(Icons.save),
      ),
    );
  }
}

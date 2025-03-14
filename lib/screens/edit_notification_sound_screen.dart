import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class EditNotificationSoundScreen extends StatefulWidget {
  final String currentSound;

  const EditNotificationSoundScreen({required this.currentSound});

  @override
  _EditNotificationSoundScreenState createState() => _EditNotificationSoundScreenState();
}

class _EditNotificationSoundScreenState extends State<EditNotificationSoundScreen> {
  late String _selectedSound;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
    _checkPermissionAndOpenPicker();
  }

  /// Verifica el permiso para acceder a archivos de audio y, de estar concedido,
  /// abre el selector de archivos filtrando audio.
  Future<void> _checkPermissionAndOpenPicker() async {
    // Solicita el permiso para acceder a archivos de audio (Android 13+)
    var status = await Permission.audio.status;
    if (!status.isGranted) {
      status = await Permission.audio.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permiso de acceso a archivos de audio denegado')),
        );
        return;
      }
    }
    // Abre el selector de archivos para audio.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedSound = result.files.single.path!;
      });
    }
  }

  /// Retorna el ringtone seleccionado a la pantalla anterior.
  void _saveSelection() {
    Navigator.pop(context, _selectedSound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar sonido de notificación'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text('Sonido seleccionado:'),
              subtitle: Text(
                _selectedSound,
                style: TextStyle(fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPermissionAndOpenPicker,
              child: Text('Cambiar sonido'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelection,
        tooltip: 'Guardar selección',
        child: Icon(Icons.save),
      ),
    );
  }
}

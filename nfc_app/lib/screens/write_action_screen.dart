import 'dart:io'; // Para detectar el sistema operativo (Después)
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteActionScreen extends StatefulWidget {
  @override
  _WriteActionScreenState createState() => _WriteActionScreenState();
}

class _WriteActionScreenState extends State<WriteActionScreen> {
  String? selectedAction;
  final Map<String, String> actions = {
    "Activar Wi-Fi": "intent://android.settings.WIFI_SETTINGS#Intent;scheme=android-app;end;",
    "Activar Bluetooth": "intent://android.settings.BLUETOOTH_SETTINGS#Intent;scheme=android-app;end;",
    "Abrir Configuración": "intent://android.settings.SETTINGS#Intent;scheme=android-app;end;",
    "Ejecutar Atajo en iOS": "shortcuts://run-shortcut?name=MiAtajo"
  };

  void _writeNfc() async {
    if (selectedAction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una acción.")),
      );
      return;
    }

    String actionUri = actions[selectedAction]!;

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("NFC no disponible en este dispositivo.")),
      );
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Este chip NFC no permite escritura.")),
          );
          NfcManager.instance.stopSession();
          return;
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(actionUri)), // Guarda la acción en NFC
        ]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Acción guardada en la tarjeta NFC.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al escribir en el NFC.")),
          );
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Escribir Acción en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedAction,
              hint: Text("Selecciona una acción"),
              isExpanded: true,
              items: actions.keys.map((String action) {
                return DropdownMenuItem<String>(
                  value: action,
                  child: Text(action),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedAction = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _writeNfc,
              child: Text("Escribir en NFC"),
            ),
          ],
        ),
      ),
    );
  }
}
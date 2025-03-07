import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteTextScreen extends StatefulWidget {
  @override
  _WriteTextScreenState createState() => _WriteTextScreenState();
}

class _WriteTextScreenState extends State<WriteTextScreen> {
  TextEditingController textController = TextEditingController();

  void _writeNfc() async {
    String message = textController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa un mensaje de texto.")),
      );
      return;
    }

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

        NdefMessage ndefMessage = NdefMessage([
          NdefRecord.createText(message), // Guarda el mensaje en formato NDEF
        ]);

        try {
          await ndef.write(ndefMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Mensaje guardado exitosamente en la tarjeta NFC.")),
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
      appBar: AppBar(title: Text("Escribir Mensaje en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Ingresa el mensaje"),
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

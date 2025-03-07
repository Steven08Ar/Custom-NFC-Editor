import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteUrlScreen extends StatefulWidget {
  @override
  _WriteUrlScreenState createState() => _WriteUrlScreenState();
}

class _WriteUrlScreenState extends State<WriteUrlScreen> {
  TextEditingController urlController = TextEditingController();

  void _writeNfc() async {
    String url = urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa una URL válida.")),
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

        NdefMessage message = NdefMessage([
          NdefRecord.createUri(Uri.parse(url)),
        ]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("URL escrita exitosamente en el NFC.")),
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
      appBar: AppBar(title: Text("Escribir URL en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: "Ingresa la URL"),
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
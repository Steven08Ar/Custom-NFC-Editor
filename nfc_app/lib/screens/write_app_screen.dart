import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteAppScreen extends StatefulWidget {
  @override
  _WriteAppScreenState createState() => _WriteAppScreenState();
}

class _WriteAppScreenState extends State<WriteAppScreen> {
  TextEditingController linkController = TextEditingController();

  void _writeNfc() async {
    String appLink = linkController.text.trim();
    if (appLink.isEmpty || (!appLink.startsWith("http") && !appLink.contains("://"))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa un enlace válido.")),
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
          NdefRecord.createUri(Uri.parse(appLink)), // Guarda el enlace en la NFC
        ]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Enlace guardado en la tarjeta NFC.")),
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
      appBar: AppBar(title: Text("Abrir App con NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: linkController,
              decoration: InputDecoration(
                labelText: "Enlace de la aplicación",
                hintText: "Ejemplo: whatsapp://send?text=Hola!",
              ),
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
import 'dart:io'; // Para detectar el sistema operativo
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WritePhoneScreen extends StatefulWidget {
  @override
  _WritePhoneScreenState createState() => _WritePhoneScreenState();
}

class _WritePhoneScreenState extends State<WritePhoneScreen> {
  TextEditingController phoneController = TextEditingController();

  void _writeNfc() async {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa un número de teléfono válido.")),
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

        // 🚨 Diferente formato según el sistema operativo
        NdefRecord record;
        if (Platform.isIOS) {
          record = NdefRecord.createText("Teléfono: $phoneNumber"); // Guardar como texto en iOS
        } else {
          record = NdefRecord.createUri(Uri.parse("tel:$phoneNumber")); // Guardar como enlace en Android
        }

        NdefMessage message = NdefMessage([record]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Número de teléfono guardado exitosamente en la tarjeta NFC.")),
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
      appBar: AppBar(title: Text("Escribir Teléfono en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Ingresa el número de teléfono"),
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

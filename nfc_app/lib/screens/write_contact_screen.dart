import 'dart:io'; // Para detectar el sistema operativo
import 'dart:typed_data'; // Para usar Uint8List
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteContactScreen extends StatefulWidget {
  @override
  _WriteContactScreenState createState() => _WriteContactScreenState();
}

class _WriteContactScreenState extends State<WriteContactScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void _writeNfc() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, completa todos los campos.")),
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

    // 📌 Formato vCard para el contacto
    String vCardData = "BEGIN:VCARD\n"
        "VERSION:3.0\n"
        "FN:$name\n"
        "TEL:$phone\n"
        "EMAIL:$email\n"
        "END:VCARD";

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
          record = NdefRecord.createText(vCardData); // Guardar vCard como texto en iOS
        } else {
          record = NdefRecord.createMime("text/vcard", Uint8List.fromList(vCardData.codeUnits)); // 🔹 CORREGIDO
        }

        NdefMessage message = NdefMessage([record]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Contacto guardado exitosamente en la tarjeta NFC.")),
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
      appBar: AppBar(title: Text("Escribir Contacto en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Teléfono"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Correo Electrónico"),
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

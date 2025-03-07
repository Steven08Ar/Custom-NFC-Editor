import 'dart:io'; // Para detectar el sistema operativo
import 'dart:typed_data'; // Para manejar Uint8List
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WriteWifiScreen extends StatefulWidget {
  @override
  _WriteWifiScreenState createState() => _WriteWifiScreenState();
}

class _WriteWifiScreenState extends State<WriteWifiScreen> {
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void _writeNfc() async {
    String ssid = ssidController.text.trim();
    String password = passwordController.text.trim();

    if (ssid.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ingresa SSID y contraseña.")),
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

    // 📌 Formato Wi-Fi según Android e iOS
    String wifiDataAndroid = "WIFI:T:WPA;S:$ssid;P:$password;;";
    String wifiDataIOS = "Red Wi-Fi: $ssid\nContraseña: $password";

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

        NdefRecord record;
        if (Platform.isIOS) {
          // 🔹 iOS: Guardamos como texto plano
          record = NdefRecord.createText(wifiDataIOS);
        } else {
          // 🔥 Android: Guardamos en formato especial para Wi-Fi
          record = NdefRecord.createMime(
            "application/vnd.wfa.wsc",
            Uint8List.fromList(wifiDataAndroid.codeUnits),
          );
        }

        NdefMessage message = NdefMessage([record]);

        try {
          await ndef.write(message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Red Wi-Fi guardada en la tarjeta NFC.")),
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
      appBar: AppBar(title: Text("Escribir Wi-Fi en NFC")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: ssidController,
              decoration: InputDecoration(labelText: "Nombre de la Red (SSID)"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Contraseña"),
              obscureText: true,
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
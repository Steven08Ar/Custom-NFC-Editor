import 'dart:io'; // Para detectar el sistema operativo
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ClearNfcScreen extends StatefulWidget {
  @override
  _ClearNfcScreenState createState() => _ClearNfcScreenState();
}

class _ClearNfcScreenState extends State<ClearNfcScreen> {
  void _clearNfc() async {
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
            SnackBar(content: Text("Este chip NFC no permite ser modificado.")),
          );
          NfcManager.instance.stopSession();
          return;
        }

        try {
          // 🚨 Diferente acción según el sistema operativo
          if (Platform.isAndroid) {
            // 🔥 En Android podemos borrar la etiqueta completamente
            await ndef.write(NdefMessage([]));
          } else {
            // 🔹 En iOS solo sobrescribimos con un mensaje vacío
            await ndef.write(NdefMessage([NdefRecord.createText("")]));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Datos NFC eliminados correctamente.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al borrar la etiqueta NFC.")),
          );
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Borrar Datos NFC")),
      body: Center(
        child: ElevatedButton(
          onPressed: _clearNfc,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text("Borrar NFC"),
        ),
      ),
    );
  }
}

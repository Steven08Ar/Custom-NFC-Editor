import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class LockNfcScreen extends StatefulWidget {
  @override
  _LockNfcScreenState createState() => _LockNfcScreenState();
}

class _LockNfcScreenState extends State<LockNfcScreen> {
  void _lockNfc() async {
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
            SnackBar(content: Text("Este chip NFC ya está bloqueado o no permite escritura.")),
          );
          NfcManager.instance.stopSession();
          return;
        }

        try {
          // 🚨 BLOQUEA la etiqueta NFC de forma PERMANENTE
          await ndef.writeLock();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Etiqueta NFC bloqueada permanentemente.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al bloquear la etiqueta NFC.")),
          );
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bloquear NFC (Protección)")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showConfirmationDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text("Bloquear NFC"),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("⚠️ Advertencia"),
          content: Text("¿Estás seguro de que quieres bloquear esta etiqueta NFC? Esta acción es permanente y no se podrá deshacer."),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Bloquear"),
              onPressed: () {
                Navigator.of(context).pop();
                _lockNfc();
              },
            ),
          ],
        );
      },
    );
  }
}
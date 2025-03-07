import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';

class NFCAuthenticator {
  static Future<void> authenticateAndUnlock(String encryptionKey) async {
    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            print("Este dispositivo NFC no soporta NDEF.");
            return;
          }

          // Crear payload de autenticación
          String authPayload = jsonEncode({
            "auth": encryptionKey
          });

          // Escribir credenciales en la cerradura
          NdefMessage message = NdefMessage([
            NdefRecord.createText(authPayload),
          ]);

          await ndef.write(message);
          print("Cerradura desbloqueada exitosamente.");
        },
      );
    } catch (e) {
      print("Error al autenticar: $e");
    }
  }
}
import 'package:nfc_manager/nfc_manager.dart';
import 'database_helper.dart';

class NFCReader {
  static Future<void> startNFCReading(Function(String) onLockDetected) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      print("NFC no disponible");
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            print("La cerradura no usa NDEF.");
            return;
          }

          String uuid = tag.data["mifare"]["identifier"].toString();
          print("Cerradura detectada: $uuid");

          // Verificar en la base de datos
          var lockData = await DatabaseHelper.instance.getLockByUUID(uuid);
          if (lockData != null) {
            String encryptionKey = lockData["encryptionKey"];
            onLockDetected(encryptionKey);
          } else {
            print("Cerradura no registrada.");
          }
        } catch (e) {
          print("Error al leer NFC: $e");
        }
      },
    );
  }
}
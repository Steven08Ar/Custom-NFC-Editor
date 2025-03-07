import 'package:flutter/material.dart';
import 'package:nfc_app/screens/modify_nfc_screen.dart';
import 'package:nfc_app/services/nfc_reader.dart';
import 'package:nfc_app/services/nfc_authenticator.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menú Principal"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              "Modificar tarjetas NFC",
              Icons.nfc,
              () {
                // Navega a la pantalla para modificar tarjetas NFC
              },
            ),
            _buildMenuButton(
              context,
              "Identificar Tarjetas de Débito/Crédito",
              Icons.credit_card,
              () {
                // Navega a la pantalla de identificación de tarjetas
              },
            ),
            _buildMenuButton(
              context,
              "Convertir Celular en Datáfono (Futuro)",
              Icons.phone_android,
              null, // Deshabilitado por ahora
            ),
            _buildMenuButton(
              context,
              "Convertir Celular en Tarjeta NFC",
              Icons.lock_open, // Icono de desbloqueo
              () async {
                await NFCReader.startNFCReading((encryptionKey) async {
                  await NFCAuthenticator.authenticateAndUnlock(encryptionKey);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cerradura desbloqueada")),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(title, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: onPressed != null ? Colors.blue : Colors.grey,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'write_url_screen.dart';
import 'write_phone_screen.dart';
import 'write_contact_screen.dart';
import 'write_text_screen.dart';
import 'clear_nfc_screen.dart';
import 'write_wifi_screen.dart';
import 'lock_nfc_screen.dart';
import 'write_app_screen.dart';

class ModifyNfcScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modificar Tarjeta NFC"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildMenuButton(
            context,
            "Escribir URL",
            Icons.link,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteUrlScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Guardar número de teléfono",
            Icons.phone,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WritePhoneScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Registrar un contacto (vCard)",
            Icons.contact_mail,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteContactScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Guardar un mensaje de texto",
            Icons.message,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteTextScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Borrar datos NFC",
            Icons.delete,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClearNfcScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Configurar red Wi-Fi",
            Icons.wifi,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteWifiScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Bloquear NFC (Protección Escritura)",
            Icons.lock,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LockNfcScreen()),
              );
            },
          ),
          _buildMenuButton(
            context,
            "Abrir una aplicación",
            Icons.apps,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WriteAppScreen()),
              );
            },
          ),
          _buildMenuButton(context, "Ejecutar acciones automáticas", Icons.flash_on, () {
            // Implementar funciones domóticas con NFC
          }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(title, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
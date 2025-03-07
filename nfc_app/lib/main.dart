import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NFC App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Aquí llamamos a la pantalla del menú principal
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});

  @override
  _NFCReaderScreenState createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  String _nfcData = "Acerque una tarjeta NFC";

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  void _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _nfcData = "NFC no disponible en este dispositivo";
      });
    }
  }

  void _startNFCScan() async {
    setState(() {
      _nfcData = "Escaneando...";
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      setState(() {
        _nfcData = "Datos de la tarjeta: ${tag.data}";
      });

      // Termina la sesión NFC
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lector NFC")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_nfcData, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNFCScan,
              child: const Text("Leer NFC"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({Key? key}) : super(key: key);

  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final String _url = "https://www.gem.net.br";
  final double _qrSize = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code GEM'),
        backgroundColor: Color(0xFF699A92),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título
              Text(
                'QR Code para GEM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF699A92),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Escaneie o código abaixo para acessar o site',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Container do QR Code
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // QR Code
                    QrImageView(
                      data: _url,
                      version: QrVersions.auto,
                      size: _qrSize,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF699A92),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              ),

              const SizedBox(height: 30),
/*
              Expanded(
                child: QrImageView(
                  data: _url,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),

 */

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
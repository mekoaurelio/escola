
import 'package:flutter/material.dart';
import 'extractor_screen.dart';


class MainPdf extends StatelessWidget {
  const MainPdf({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RREO Anexo 8 Extractor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExtractorScreen(),
    );
  }
}
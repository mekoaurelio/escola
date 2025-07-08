
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../services/utils.dart';

void uploadPdf(String fileName) async {
  // Cria o input
  final uploadInput = html.FileUploadInputElement()..accept = '.pdf';
  uploadInput.click();

  uploadInput.onChange.listen((event) async {
    final file = uploadInput.files!.first;
    final reader = html.FileReader();

    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;

    final data = reader.result as Uint8List;

    final uri = Uri.parse('https://importacao-contracheques.onrender.com/imports');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'pdfFile', // nome do campo
          data,
          filename: fileName,
          //contentType: http.MediaType('application', 'pdf'),
          contentType: MediaType.parse('application/pdf'),
        ),
      );
    print('ANTES');

    try{
    final response = await request.send();
    Utils.snak('Atencão', response.statusCode.toString(), false, Colors.red);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print('Upload concluído: $responseBody');
    } else {
      print('Erro ao fazer upload: ${response.statusCode}');
    }
    } catch (e) {
      print(e);
    }
  });
}


import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import 'ler_pdf.dart';

class ExtractorScreen extends StatefulWidget {
  const ExtractorScreen({super.key});

  @override
  State<ExtractorScreen> createState() => _ExtractorScreenState();
}

class _ExtractorScreenState extends State<ExtractorScreen> {
  bool _isLoading = false;
  String? _resultText;
  String? _errorText;
  String? _fileName;
  Map<String, dynamic>? _stats;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrator RREO - Anexo 8'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    const Text(
                      'Selecione o arquivo PDF do RREO',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndProcess,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Selecionar PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    if (_fileName != null) ...[
                      const SizedBox(height: 10),
                      Text('Arquivo: $_fileName', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 10),
                      Text('Processando... ${(_progress * 100).toStringAsFixed(0)}%'),
                    ],
                    if (_errorText != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.red.shade100,
                        child: Text(_errorText!, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (_stats != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 ESTATÍSTICAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      _buildStatRow('Páginas extraídas', '${_stats!['extractedPages']}'),
                      _buildStatRow('Caracteres', '${_stats!['anexo8Length']}'),
                      if (_stats!['tokens'] != null) ...[
                        const Divider(),
                        const Text('💰 CUSTOS', style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildStatRow('Tokens input', '${_stats!['tokens']['prompt']}'),
                        _buildStatRow('Tokens output', '${_stats!['tokens']['completion']}'),
                        _buildStatRow('Total tokens', '${_stats!['tokens']['total']}'),
                        _buildStatRow('Custo (USD)', '\$${_stats!['tokens']['costUSD'].toStringAsFixed(5)}'),
                        _buildStatRow('Custo (BRL)', 'R\$ ${_stats!['tokens']['costBRL'].toStringAsFixed(4)}'),
                      ],
                      if (_stats!['processingTimeMs'] != null) ...[
                        const Divider(),
                        _buildStatRow('Tempo processamento', '${(_stats!['processingTimeMs'] / 1000).toStringAsFixed(2)}s'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // JSON Result
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _resultText ?? '',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _pickAndProcess() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
      _resultText = null;
      _stats = null;
      _progress = 0.1;
    });

    try {
      // Selecionar PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        setState(() {
          _isLoading = false;
          _errorText = 'Nenhum arquivo selecionado';
        });
        return;
      }

      setState(() {
        _fileName = result.files.single.name;
        _progress = 0.3;
      });

      // Extrair e analisar
      Uint8List pdfBytes = result.files.single.bytes!;

      final extraction = await RreoAnexo8Extractor.extractAndAnalyze(pdfBytes);

      setState(() {
        _progress = 0.9;
      });

      if (!extraction.success) {
        setState(() {
          _errorText = extraction.error ?? 'Erro desconhecido';
          _stats = extraction.toJson();
          _isLoading = false;
        });
        return;
      }

      // Extrair JSON da resposta
      String? jsonStr;
      if (extraction.aiResponse != null) {
        // Tentar extrair JSON da resposta
        String content = extraction.aiResponse!.content;
        RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
        var match = jsonRegex.firstMatch(content);
        if (match != null) {
          jsonStr = match.group(0);
        } else {
          jsonStr = content;
        }
      }

      setState(() {
        _resultText = jsonStr ?? extraction.anexo8Text;
        _stats = extraction.toJson();
        _progress = 1.0;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorText = 'Erro: $e';
        _isLoading = false;
      });
    }
  }
}
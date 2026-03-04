import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;


// Importe sua classe OpenAIResponse corretamente
import '../services/open_ai_response.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _displayText = "Aguardando envio de PDF...";
  bool _isLoading = false;
  static const String apiKey = 'AIzaSyDRldUHAkRkmSQIgVSZepmabxrWo23IZE8';
  Map<String, dynamic>? _parsedData;

  /*
  void debugApiModels() async {
    const apiKey = 'AIzaSyDRldUHAkRkmSQIgVSZepmabxrWo23IZE8'; // Coloque sua chave aqui

    print("Consultando modelos disponíveis...");

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("=== MODELOS DISPONÍVEIS PARA SUA CHAVE ===");
        for (var model in data['models']) {
          // Isso vai imprimir algo como: "models/gemini-1.5-flash"
          print(model['name']);
          print("   - Métodos suportados: ${model['supportedGenerationMethods']}");
        }
        print("============================================");
      } else {
        print("ERRO DE PERMISSÃO: ${response.statusCode}");
        print("Corpo do erro: ${response.body}");
      }
    } catch (e) {
      print("Erro de conexão: $e");
    }
  }
  Future<void> checkAvailableModels() async {
    try {
      // Inicializa sem modelo específico apenas para listar
      // Nota: A listagem de modelos não requer instanciar o GenerativeModel com um modelo específico
      // Mas a biblioteca pede um Model para inicializar. Vamos tentar listar direto via API REST se o pacote não ajudar,
      // mas o pacote tem um método estático em algumas versões.

      // A melhor forma de testar se a chave funciona é tentar um modelo antigo:
      final model = GenerativeModel(model: 'gemini-1.0-pro', apiKey: apiKey);
      print("Teste com 1.0-pro: ${await model.countTokens([Content.text('oi')])}");

    } catch (e) {
      print("Erro ao testar chave: $e");
    }
  }



  void _handleSend() async {
    setState(() {
      _isLoading = true;
      _displayText = "Lendo arquivo...";
    });

    try {
      // 1. Pega os bytes do PDF diretamente (sem conversão para string base64)
      final pdfBytes = await pickPdfBytes();

      if (pdfBytes == null) {
        setState(() {
          _isLoading = false;
          _displayText = "Nenhum arquivo selecionado.";
        });
        return;
      }

      setState(() => _displayText = "Enviando para o Gemini...");

      // 2. Envia para a API
      final result = await fetchGeminiResponse(pdfBytes);

      setState(() {
        _isLoading = false;
        if (result != null) {
          _displayText = result.content;
        } else {
          _displayText = "Ocorreu um erro ao processar o arquivo.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _displayText = "Erro: $e";
      });
    }
  }



   */

  // Alterado para retornar Uint8List (bytes) diretamente
  Future<Uint8List?> pickPdfBytes() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Essencial para Web e para ter acesso aos bytes
    );

    if (result != null) {
      return result.files.single.bytes;
    }
    return null;
  }

  void _handleSend() async {
    setState(() {
      _isLoading = true;
      _displayText = "Lendo arquivo...";
      _parsedData = null; // Limpa dados anteriores
    });

    try {
      final pdfBytes = await pickPdfBytes();

      if (pdfBytes == null) {
        setState(() {
          _isLoading = false;
          _displayText = "Nenhum arquivo selecionado.";
        });
        return;
      }

      setState(() => _displayText = "Enviando para o Gemini...");

      final result = await fetchGeminiResponse(pdfBytes);

      if (result != null) {
        // 1. Limpeza do JSON (Remove ```json e quebras de linha extras)
        String rawJson = result.content.replaceAll(RegExp(r'^```json|^```|```$'), '').trim();

        // 2. Decodifica para Map do Dart
        Map<String, dynamic> dataMap = jsonDecode(rawJson);

        // 3. Salva no Banco de Dados (Ex: Firestore, SQLite, API)
        await _saveToDatabase(dataMap);

        setState(() {
          _isLoading = false;
          _parsedData = dataMap; // Atualiza a UI com os dados reais
          _displayText = "Dados processados com sucesso!";
        });
      } else {
        throw Exception("O retorno da IA foi vazio.");
      }

    } catch (e) {
      print("Erro: $e");
      setState(() {
        _isLoading = false;
        _displayText = "Erro ao processar: $e";
        _parsedData = null; // Garante que não mostre dados quebrados
      });
    }
  }

  // Simulação de salvamento no banco
  Future<void> _saveToDatabase(Map<String, dynamic> data) async {
    // AQUI VOCÊ CONECTA SEU BACKEND
    // Exemplo com Firestore:
    // await FirebaseFirestore.instance.collection('relatorios_rreo').add({
    //   ...data,
    //   'data_importacao': FieldValue.serverTimestamp(),
    // });

    print("Salvando no banco de dados: $data");
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay
  }

  Future<OpenAIResponse?> fetchGeminiResponse(Uint8List pdfBytes) async {
    try {
      // CORREÇÃO 1: Nome do modelo corrigido
      final model = GenerativeModel(
        model: 'models/gemini-2.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.1,
        ),
      );

      const prompt = """
Você é um especialista em RREO. Extraia APENAS os dados do Anexo 8 do PDF fornecido.

INSTRUÇÕES:
1. IGNORE cabeçalhos, rodapés e textos descritivos
2. EXTRAIA apenas os valores numéricos com suas descrições
3. FORMATO: JSON estruturado por seções

SEÇÕES PARA EXTRAIR:
- receita_impostos: itens 1.x (IPTU, ITBI, ISS, IRRF)
- transferencias: itens 2.x (FPM, ICMS, IPVA, IPI, ITR)
- totais: itens 3, 4, 5
- fundeb_receitas: itens 6.x
- fundeb_despesas: itens 10.x
- mde_impostos: itens 20.x
- mde_total: itens 21.x
- indicadores: itens 15, 16, 17, 18, 19
- restos_pagar: itens 30.x
- disponibilidade: itens 34-37

RETORNE APENAS O JSON, sem explicações adicionais.
""";

      // 3. Monta o conteúdo multimodal (Texto + PDF Bytes)
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ])
      ];

      // 4. Chamada da API
      final response = await model.generateContent(content);

      if (response.text != null) {
        String cleanedText = response.text!;

        // Limpeza opcional: Remove marcadores de código markdown se o Gemini os incluir
        // Ex: ```json { ... } ```
        if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText.replaceAll(RegExp(r'^```json\s*|^```\s*|```$'), '');
        }

        return OpenAIResponse(
            content: cleanedText.trim(),
            model:  'models/gemini-2.5-flash'
        );
      } else {
        throw Exception("O modelo não retornou conteúdo.");
      }

    } catch (e) {
      debugPrint("Erro no Gemini: $e");
      if (e.toString().contains('401')) {
        throw Exception("Chave de API inválida.");
      } else if (e.toString().contains('429')) {
        throw Exception("Limite de cota excedido ou modelo sobrecarregado.");
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extrator RREO Inteligente"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_parsedData != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // Ação manual de salvar se quiser
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Dados já foram salvos!")));
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _handleSend,
        label: Text(_isLoading ? "Processando..." : "Analisar Novo PDF"),
        icon: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
            : const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(_displayText),
          ],
        ),
      );
    }

    // Se temos dados parseados, mostramos a UI Rica
    if (_parsedData != null) {
      return ListView(
        children: [
          _buildSectionCard("Receita de Impostos", _parsedData!['receita_impostos']),
          _buildSectionCard("Transferências", _parsedData!['transferencias']),
          _buildSectionCard("FUNDEB - Receitas", _parsedData!['fundeb_receitas']),
          _buildSectionCard("FUNDEB - Despesas", _parsedData!['fundeb_despesas']),
          _buildSectionCard("Indicadores", _parsedData!['indicadores']),
          _buildSectionCard("Restos a Pagar", _parsedData!['restos_pagar']),
          // Adicione outras seções conforme seu JSON
        ],
      );
    }

    // Estado inicial ou de erro
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            _displayText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os cartões expansíveis
  Widget _buildSectionCard(String title, dynamic data) {
    if (data == null || (data is List && data.isEmpty)) {
      return const SizedBox.shrink(); // Não mostra seções vazias
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: const Icon(Icons.table_chart, color: Colors.blue),
        children: [
          if (data is List)
            _buildTableFromList(data)
          else if (data is Map)
            _buildListFromMap(data)
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(data.toString()),
            ),
        ],
      ),
    );
  }

  // Constrói uma tabela para Listas de Objetos (ex: Receitas)
  Widget _buildTableFromList(List<dynamic> items) {
    if (items.isEmpty) return const Text("Sem dados");

    // Pega as chaves do primeiro item para fazer o cabeçalho
    var firstItem = items.first as Map<String, dynamic>;
    var columns = firstItem.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(
            label: Text(col.toUpperCase().replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold))
        )).toList(),
        rows: items.map((item) {
          return DataRow(
            cells: columns.map((col) {
              return DataCell(Text(item[col]?.toString() ?? '-'));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // Constrói lista para Mapas simples (ex: Totais)
  Widget _buildListFromMap(Map<dynamic, dynamic> data) {
    return Column(
      children: data.entries.map((e) {
        return ListTile(
          title: Text(e.key.toString().toUpperCase().replaceAll('_', ' ')),
          trailing: Text(
            e.value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        );
      }).toList(),
    );
  }
}
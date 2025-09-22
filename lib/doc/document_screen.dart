/*
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:psycostatattoo/data/api_my_sql.dart'; // Verifique se este caminho está correto
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdfx/pdfx.dart'; // Apenas esta importação é necessária para o viewer
import 'dart:html' as html;
import '../const/const.dart';
import '../services/utils.dart';

const String documentApiUrl = 'https://www.xmktech.net/docs/gerenciar_documentos.php';

class DocumentScreen extends StatefulWidget {
  final String sala;

  const DocumentScreen({Key? key, this.sala = 'geral'}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late Future<List<dynamic>> _documentsFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  void _refreshDocuments() {
    setState(() {
      _documentsFuture = ApiMySql.get('documentos', null, null);
    });
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploading = true);

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      var request = http.MultipartRequest('POST', Uri.parse(documentApiUrl));
      request.fields['sala'] = widget.sala;
      request.fields['descricao'] = 'Documento enviado via App';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          Utils.snak('Parabéns', responseData['message'], false, Colors.green);
          _refreshDocuments();
        } else {
          Utils.snak('Atenção', 'Erro do servidor: ${responseData['message']}', false, Colors.red);
        }
      } catch (e) {
        Utils.snak('Atenção', 'Erro de conexão durante o upload: $e' , false, Colors.red);
      } finally {
        setState(() => _isUploading = false);
      }
    } else {
      print("Nenhum arquivo selecionado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      body: FutureBuilder<List<dynamic>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum documento encontrado.'));
          }

          final documents = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return _DocumentThumbnail(document: documents[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        label: _isUploading ? const Text('Enviando...') : const Text('Novo Documento'),
        icon: _isUploading
            ? Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Icon(Icons.upload_file),
      ),
    );
  }
}

/// Widget para a miniatura do documento
class _DocumentThumbnail extends StatelessWidget {
  final Map<String, dynamic> document;

  const _DocumentThumbnail({Key? key, required this.document}) : super(key: key);

  void _downloadDocument() {
    // Pega a URL completa diretamente do campo 'caminho' do banco
    final String documentUrl = document['caminho'];
    final String originalName = document['nome_original'] ?? 'documento.pdf';

    if (kIsWeb) {
      // Cria o link de download com a URL correta
      html.AnchorElement(href: documentUrl)
        ..setAttribute("download", originalName)
        ..click();
    } else {
      // Em mobile, abre a URL externa
      launchUrl(Uri.parse(documentUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _showPdfViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          // Passa o ID para a API segura, como fizemos antes
          documentId: int.parse(document['id']),
          documentName: document['nome_original'] ?? 'Documento',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: corFundoOadrao,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => _showPdfViewer(context),
                  child: Container(
                    color: Colors.red.shade50,
                    child: Tooltip(
                      message: 'Clique para visualizar',
                      child: Icon(Icons.picture_as_pdf, size: 60, color: Colors.red.shade700),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document['nome_original'] ?? 'Sem nome', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(document['data_formatada'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (String result) {
                if (result == 'view') {
                  _showPdfViewer(context);
                } else if (result == 'download') {
                  _downloadDocument();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'view', child: ListTile(leading: Icon(Icons.visibility), title: Text('Visualizar'))),
                const PopupMenuItem<String>(value: 'download', child: ListTile(leading: Icon(Icons.download), title: Text('Baixar'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// TELA DO VISUALIZADOR DE PDF - AGORA MUITO MAIS SIMPLES
// ==========================================================
class PdfViewerScreen extends StatefulWidget {
  final int documentId; // Recebe o ID em vez da URL
  final String documentName;

  const PdfViewerScreen({
    Key? key,
    required this.documentId,
    required this.documentName,
  }) : super(key: key);


  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String _errorMessage = '';
  String getDocumentApiUrl = 'https://www.xmktech.net/docs/obter_documento.php';


  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    // Configuração do worker para web, necessária para a sua versão do pdfx
    if (kIsWeb) {
     // PdfView.setCustomWorkerPath('https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.4.120/pdf.worker.min.js');
    }

    try {
      print( getDocumentApiUrl);
      // 1. Faz uma requisição POST para a API, enviando o ID do documento
      final response = await http.post(
        Uri.parse(getDocumentApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': widget.documentId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // 2. Decodifica a string Base64 de volta para bytes (Uint8List)
          final Uint8List pdfBytes = base64Decode(responseData['data']);

          // 3. Inicializa o controller com os bytes
          setState(() {
            _pdfController = PdfControllerPinch(
              document: PdfDocument.openData(pdfBytes),
            );
            _isLoading = false;
          });
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Erro de servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Erro ao carregar PDF: ${e.toString()}";
        });
      }
    }
  }

  @override
  void dispose() {
    // É importante fazer o dispose do controller
    _pdfController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      appBar: AppBar(
        title: Text(widget.documentName),
        actions: [
          // Só mostra os botões se o PDF estiver carregado
          if (!_isLoading && _errorMessage.isEmpty) ...[
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Falha ao Carregar o Documento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _loadDocument();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // O widget PdfViewPinch continua sendo o correto.
    // Ele gerencia os gestos de zoom automaticamente.
    return PdfViewPinch(
      controller: _pdfController!,
      // Os builders para uma melhor UX continuam válidos
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, error) => Center(child: Text('Erro ao renderizar página: ${error.toString()}')),
      ),
    );
  }
}

 */

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdfx/pdfx.dart';
import 'dart:html' as html;
import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

const String documentApiUrl = 'https://www.xmktech.net/docs/gerenciar_documentos.php';

class DocumentScreen extends StatefulWidget {
  final String sala;

  const DocumentScreen({Key? key, this.sala = 'geral'}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  late Future<List<dynamic>> _documentsFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  void _refreshDocuments() {
    setState(() {
      _documentsFuture = ApiMySql.get('documentos', null, null);
    });
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploading = true);

      final fileBytes = result.files.single.bytes!;
      final fileName = result.files.single.name;

      var request = http.MultipartRequest('POST', Uri.parse(documentApiUrl));
      request.fields['sala'] = widget.sala;
      request.fields['descricao'] = 'Documento enviado via App';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      try {
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = json.decode(response.body);

        if (response.statusCode == 201) {
          Utils.snak('Parabéns', responseData['message'], false, Colors.green);
          _refreshDocuments();
        } else {
          Utils.snak('Parabéns', ' ${responseData['message']}', false, Colors.green);
        }
      } catch (e) {
        Utils.snak('Atenção', 'Erro de conexão durante o upload: $e', false, Colors.red);
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }


  Future<void> _pickAndUploadFileScreen() async {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho elegante
            _buildHeader(),
            const SizedBox(height: 24),
            // Lista de documentos
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _documentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum documento encontrado.'));
                  }

                  final documents = snapshot.data!;
                  return ListView.separated(
                    itemCount: documents.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _DocumentListItem(document: documents[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        //onPressed: _isUploading ? null : _pickAndUploadFile,
        backgroundColor: Colors.blue,
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.upload, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.library_books, size: 40, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Texto(tit: 'Biblioteca de Documentos',tam: 18,negrito: true,bottom: 4,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Texto(tit: 'Acesse todos os documentos compartilhados',cor: Colors.grey.shade700,bottom: 4,),
                    TextButton(
                      onPressed: () {
                       // Get.to(() => recoverPasswordBuilder(), arguments: {}); // Call the builder function
                      },
                      child: Text(
                        'Novo',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  final Map<String, dynamic> document;

  const _DocumentListItem({Key? key, required this.document}) : super(key: key);

  void _downloadDocument() {
    final String documentUrl = document['caminho'];
    final String originalName = document['nome_original'] ?? 'documento.pdf';

    if (kIsWeb) {
      html.AnchorElement(href: documentUrl)
        ..setAttribute("download", originalName)
        ..click();
    } else {
      launchUrl(Uri.parse(documentUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _showPdfViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          documentId: int.parse(document['id']),
          documentName: document['nome_original'] ?? 'Documento',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.library_books_sharp, color: Colors.blue),
      title: Text(
        document['nome_original'] ?? 'Sem nome',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        document['detalhe'] ?? 'Meko',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (String result) {
          if (result == 'view') {
            _showPdfViewer(context);
          } else if (result == 'download') {
            _downloadDocument();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'view',
            child: ListTile(
              leading: Icon(Icons.visibility),
              title: Text('Visualizar'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.download),
              title: Text('Baixar'),
            ),
          ),
        ],
      ),
      onTap: () => _showPdfViewer(context),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final int documentId;
  final String documentName;

  const PdfViewerScreen({
    Key? key,
    required this.documentId,
    required this.documentName,
  }) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String _errorMessage = '';
  String getDocumentApiUrl = 'https://www.xmktech.net/docs/obter_documento.php';

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final response = await http.post(
        Uri.parse(getDocumentApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': widget.documentId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final Uint8List pdfBytes = base64Decode(responseData['data']);
          setState(() {
            _pdfController = PdfControllerPinch(
              document: PdfDocument.openData(pdfBytes),
            );
            _isLoading = false;
          });
        } else {
          throw Exception(responseData['message']);
        }
      } else {
        throw Exception('Erro de servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Erro ao carregar PDF: ${e.toString()}";
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      appBar: AppBar(
        title: Text(widget.documentName),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Falha ao Carregar o Documento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _loadDocument();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfViewPinch(
      controller: _pdfController!,
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, error) => Center(
            child: Text('Erro ao renderizar página: ${error.toString()}')),
      ),
    );
  }
}

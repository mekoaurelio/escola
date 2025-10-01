import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdfx/pdfx.dart';
import 'dart:html' as html;
import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../widgets/texto.dart';
import 'doc_detalhe.dart';

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
                      onPressed: () async{
                       final result=await Get.to(() => DocDetalhe(), arguments: {});
                       if(result){
                         _refreshDocuments();
                       }
                      },
                      child: Text('Novo',
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
  String getDocumentApiUrl = 'https://www.xmktech.net/docs/ler_documento.php';

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

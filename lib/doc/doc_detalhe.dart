import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/elegant_button.dart';
const String documentApiUrl = 'https://www.xmktech.net/docs/gerenciar_documentos.php';

class DocDetalhe extends StatefulWidget {
  const DocDetalhe({super.key});

  @override
  State<DocDetalhe> createState() => _DocDetalheState();
}

class _DocDetalheState extends State<DocDetalhe> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  String arquivo='Nenhum Arquivo Escolhido';
  FilePickerResult? _result;
  bool _isUploading=true;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 640,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(arquivo, style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              CancelButton(
                  text: 'ESCOLHER ARQUIVO',
                  onPressed: () => _pickFile()
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Titulo'),
              ),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CancelButton(
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  ConfirmButton(
                    text: 'SALVAR',
                      onPressed: () => saveAndAupload()
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _result=result;
        arquivo = result.files.single.name;
      });

    }
  }
  Future<void> saveAndAupload() async {
    if (_result == null) {
      Utils.snak('Atenção', 'Escolha um arquivo ', false, Colors.red);
     return;
    }
    if(_titulo.text=='' || _descricao.text==''){
      Utils.snak('Atenção', 'Escolha um Título e uma Descrição ', false, Colors.red);
      return;
    }
    final fileBytes = _result!.files.single.bytes!;
    final fileName = _result!.files.single.name;

    var request = http.MultipartRequest('POST', Uri.parse(documentApiUrl));
    request.fields['sala'] = '1';
    request.fields['descricao'] = 'Documento enviado via App';
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // SALVA OS DADOS NO BANCO DE DADOS
        final path=Utils.removerAcentosUnicode('http://www./xmktech.net/web/docs/uploads/$fileName');
        final title=_titulo.text;
        final descri=_descricao.text;

        print("insert into documentos (caminho,nome_original,detalhe) values('$path','$title','$descri')");
        ApiMySql.executaSql("insert into documentos (caminho,nome_original,detalhe) values('$path','$title','$descri')");
        Get.back(result: true);
      }
    } catch (e) {
      Utils.snak('Atenção', 'Erro de conexão durante o upload: $e', false, Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }
}

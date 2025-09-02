import 'package:GEM/services/table_name_service.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';

import '../data/api_my_sql.dart';
import '../data/database_structure_builder.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class ExcelReaderPage extends StatefulWidget {
  const ExcelReaderPage({super.key});

  @override
  State<ExcelReaderPage> createState() => _ExcelReaderPageState();
}

class _ExcelReaderPageState extends State<ExcelReaderPage> {
  // Lista para armazenar os dados lidos para exibição na tela.
  List<Map<String, dynamic>> _dadosExibicao = [];

  // --- NOVAS VARIÁVEIS DE ESTADO PARA O PROGRESSO ---
  bool _isLoading = false;
  double _progress = 0.0;
  String _statusMessage = "";
  List<List<dynamic>> batchArgs = [];
  var _currentAno;
  var _currentBimestre;
  var _currentmuni;
  var _nomeMunicipio;
  FilePickerResult? pickedFile;
  final GlobalFilterController _filterController = Get.find<GlobalFilterController>();

  @override
  void initState() {
    super.initState();
    _filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    _filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    _filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    atualizaTela();
  }
  void atualizaTela(){
    setState(() {
      _currentmuni=_filterController.municipio.value;
      _currentAno=_filterController.ano.value;
      _currentBimestre=_filterController.bimestre.value;
      _nomeMunicipio=Utils.getNomeMunicipio(_currentmuni);
    });
  }

  /// ==========================================================
  /// Cria a estrutura de todas as tabelas                     =
  /// ==========================================================
  void _criaEsturaDasTabelas()async {
    setState(() {
      _isLoading=true;
      _statusMessage = 'Criando tabelas';
    });
    final builder = DatabaseStructureBuilder(
      municipio: _currentmuni,
      ano: _currentAno,
      bimestre: _currentBimestre,
    );

    // 3. Executa a construção
    final BuildResult result = await builder.build();
    setState(() {
      _statusMessage = 'Tabelas Criadas';
      _isLoading=false;
    });
    Utils.snak('Parabéns!', 'Estrutura Criada com Sucesso', false, Colors.green);
  }
  /// ==========================================================
  /// Executa importação                                       =
  /// ==========================================================
  Future<void> executaImportacao() async {
    bool temFolha=await ApiMySql.temRegistros(TBFolha);
    bool temVatagens=await ApiMySql.temRegistros(TBVantagens);
    if(temVatagens){
      await ApiMySql.executaSql('delete from $TBVantagens');
    }
    if(temFolha){
      await ApiMySql.executaSql('delete from $TBFolha');
    }
     pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile == null) {

      Utils.snak('Atenção', 'Escoha uma planilha para importar os dads', false, Colors.red);
      return;
    }
    await lerPlanilha('PROFESSOR',pickedFile!);
    _progress=0;
    print('vai executar vantagens');
    await lerPlanilha('VANTAGENS',pickedFile!);
    print('executou mensagens');
  }

  /// ==========================================================
  /// Importa os dados                                         =
  /// ==========================================================

  Future<String> lerPlanilha(var tipo,FilePickerResult pickedFile) async {
    ///Primeiro verifica se já tem dados para a tabela de professor e vantagens
    // Inicia o estado de carregamento
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _statusMessage = "Iniciando leitura do arquivo...";
      _dadosExibicao.clear(); // Limpa resultados anteriores
    });

    try {
      var bytes = pickedFile.files.single.bytes!;
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.keys.isEmpty) {
        throw Exception("Nenhuma planilha encontrada no arquivo.");
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;
      final totalRows = sheet.maxRows - 1; // Desconsiderando o cabeçalho

      if (totalRows <= 0) {
        throw Exception("A planilha está vazia.");
      }

      final headers = sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();
      final List<Map<String, dynamic>> dadosProcessados = [];

      // Itera sobre cada linha da planilha, começando da segunda (índice 1).
      var sqlVantagens='"';
      var tipoExp='Professor';
      if(tipo!='PROFESSOR'){
        tipoExp='Vantagens';
      }
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;

        // **ATUALIZAÇÃO DE PROGRESSO**
        // Atualiza a UI a cada 20 linhas para não sobrecarregar
        if (i % 20 == 0 || i == sheet.rows.length - 1) {
          setState(() {
            _progress = i / totalRows;
            _statusMessage = "Processando $tipoExp linha $i de $totalRows...";
          });
          // Pequeno delay para permitir que a UI se atualize
          await Future.delayed(Duration.zero);
        }

        final matricula = row[0]?.value;
        final nome = row[1]?.value;

        final Map<String, dynamic> dadosFuncionario = {
          'Matrícula': matricula,
          'Nome': nome,
          'Local de Trabalho': row[2]?.value,
          'Data Admissão':row[3]!=null?Utils.dtToMysql(row[3]?.value.toString()):'', // Idealmente converter com Utils.dtToMysql
          'Cargo': row[4]?.value,
          'Nível/Faixa': row[7]?.value,
          'Horas Normais (CLT)': row[9]?.value,
          'Horas': row[6]?.value,
          'Vantagens': [] // Lista para armazenar as vantagens.
        };
        final unidade=dadosFuncionario['Cargo'];
        final local=dadosFuncionario['Local de Trabalho'];
        final admissao=dadosFuncionario['Data Admissão'];
        final nivel=dadosFuncionario['Nível/Faixa'];
        final salario=dadosFuncionario['Horas Normais (CLT)'];
        final horas=dadosFuncionario['Horas'];

        if(tipo=='PROFESSOR'){
/*
          print("INSERT INTO $TBFolha (matricula, nome,unidade,local_lotacao,admissao,nivel,vencimento,horas) VALUES "
              "( '$matricula', '$nome', '$unidade','$local','$admissao', '$nivel', $salario,'$horas');");

 */

          await ApiMySql.executaSql(
              "INSERT INTO $TBFolha (matricula, nome,unidade,local_lotacao,admissao,nivel,vencimento,horas) VALUES "
                  "( '$matricula', '$nome', '$unidade','$local','$admissao', '$nivel', $salario,'$horas');");

        }else { ///VATGAENS
          List<Map<String, String>> vantagens = [];
          for (int colIndex = 10; colIndex <= 26; colIndex++) {
            if (colIndex < row.length && colIndex < headers.length) {
              final advantageValue = row[colIndex]?.value;
              if (advantageValue != null && advantageValue
                  .toString()
                  .trim()
                  .isNotEmpty) {
                final advantageName = headers[colIndex];
                batchArgs.add([matricula, advantageName, advantageValue]);
                vantagens.add({
                  'Nome': advantageName,
                  'Valor': advantageValue.toString(),
                });
              }
            }
          }

          dadosFuncionario['Vantagens'] = vantagens;
          dadosProcessados.add(dadosFuncionario);
          for (int y = 0; y<=vantagens.length; y++) {
            try{
              sqlVantagens = " INSERT INTO $TBVantagens (folha_id,codigo, descricao, valor) VALUES (";
              sqlVantagens += "$matricula,'0', '${vantagens[y]['Nome']}', ${vantagens[y]['Valor']});\n";
              var result=await ApiMySql.executaSql(sqlVantagens);
              print(sqlVantagens);
            } catch (e) {
              print(e); // Log do erro no console
            }
          }
        }
      }

      setState(() {
        _dadosExibicao = dadosProcessados;
        _statusMessage = "Importação concluída com sucesso! $totalRows registros lidos.";
      });

    } catch (e) {
      setState(() {
        _statusMessage = "Ocorreu um erro: ${e.toString()}";
      });
      print(e); // Log do erro no console
    } finally {
      // Garante que o estado de carregamento seja desativado
      setState(() {
        _isLoading = false;
      });
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Texto( tit:"Atualizando dados do bimestre $_currentBimestre do ano $_currentAno de $_nomeMunicipio",
        cor: Colors.white,tam: 16,),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if(! _isLoading){
                    _criaEsturaDasTabelas();
                  }
                },
                icon: const Icon(Icons.create_new_folder_rounded,color: Colors.blue,),
                label: const Text("Criar estrutura das tabelas"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(width: 30),
              ElevatedButton.icon(
                onPressed: () {
                  if(! _isLoading){
                    executaImportacao();
                  }
                },
                icon: const Icon(Icons.upload_file),
                label:  Texto(tit:"Selecionar e Ler Planilha",left: 10,),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
            ),

            const SizedBox(height: 20),

            // --- WIDGET DA BARRA DE PROGRESSO ---
            Visibility(
              visible: _isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_statusMessage, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _dadosExibicao.isEmpty && !_isLoading
                  ? const Center(child: Text("Nenhum dado carregado. Selecione uma planilha."))
                  : ListView.builder(
                itemCount: _dadosExibicao.length,
                itemBuilder: (context, index) {
                  final funcionario = _dadosExibicao[index];
                  final vantagens = funcionario['Vantagens'] as List<Map<String, String>>;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${funcionario['Nome']} (Mat: ${funcionario['Matrícula']})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (vantagens.isNotEmpty)
                            ...vantagens.map(
                                  (vantagem) => Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                child: Text(
                                  "${vantagem['Nome']}: ${vantagem['Valor']}",
                                ),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, top: 4.0),
                              child: Text(
                                "Nenhuma vantagem encontrada.",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart'; // Importa o pacote excel
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../services/table_name_service.dart';
import '../services/utils.dart';     // Para o Utils

class ImportContratosScreen extends StatefulWidget {
  const ImportContratosScreen({Key? key}) : super(key: key);

  @override
  State<ImportContratosScreen> createState() => _ImportContratosScreenState();
}

class _ImportContratosScreenState extends State<ImportContratosScreen> {
  String? _sqlScript;
  bool _isLoading = false;
  String? _fileName;
  int _processedRows = 0;
  int _skippedRows = 0;

  // Função para obter o valor de uma célula como String, tratando tipos e nulos.
  String _getCellValue(Data? cell,String posi) {

    if (cell == null) return '';
    print('posicão $posi ${cell!.value}');
    // A biblioteca excel pode ler números como double (ex: 19.0) ou int.
    /*
    if (cell.value is double) {
      print('É UM DOUBLE '+cell.value );
      // Se for um double sem parte decimal, converte para int.
      if ((cell.value as double) % 1 == 0) {
        return (cell.value as double).toInt().toString();
      }
      return (cell.value as double).toString();
    }

     */

    if(cell.value.toString().toString().contains('R/\$')){
      print('VALOR');
      return Utils.saldoToSave(cell.value.toString());
    }
    return cell.value?.toString().trim() ?? '';
  }

  // Função para limpar e converter valores monetários de String para double
  double _parseCurrency(String value) {
    if (value.isEmpty) return 0.0;
    final cleanValue = value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }

  // Função para formatar a data (dd/MM/yyyy) para o formato SQL (yyyy-MM-dd)
  String _formatDateForSql(String dateStr) {
    if (dateStr.isEmpty || dateStr == '#N/A') return 'NULL';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dateStr);
      return "'${DateFormat('yyyy-MM-dd').format(date)}'";
    } catch (e) {
      return 'NULL';
    }
  }

  /// Processa a planilha Excel e gera o script SQL
  String _generateSqlFromExcel(Excel excel) {
    final List<String> insertsFolha = [];
    final List<String> insertsVantagens = [];
    _processedRows = 0;
    _skippedRows = 0;

    final sheet = excel.tables[excel.tables.keys.first]; // Pega a primeira aba

    if (sheet == null) {
      return '-- ERRO: Nenhuma aba encontrada na planilha.';
    }

    // Pega a linha do cabeçalho para obter os nomes das vantagens
    final headerRow = sheet.rows[0];

    // Começa a ler da segunda linha (índice 1) para pular o cabeçalho
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // Se a primeira célula (matrícula) estiver vazia, pulamos a linha
      final matriculaStr = _getCellValue(row.isNotEmpty ? row[0] : null,'');
      if (matriculaStr.isEmpty) {
        _skippedRows++;
        continue;
      }
      print('largura '+row.length.toString());

      _getCellValue(row.length > 1 ? row[1] : null,'1');
      _getCellValue(row.length > 2 ? row[2] : null,'2');
      _getCellValue(row.length > 3 ? row[3] : null,'3');
      _getCellValue(row.length > 4 ? row[4] : null,'4');
      _getCellValue(row.length > 5 ? row[5] : null,'5');
      _getCellValue(row.length > 6 ? row[6] : null,'6');
      _getCellValue(row.length > 7 ? row[7] : null,'7');
      _getCellValue(row.length > 8 ? row[8] : null,'8');
      _getCellValue(row.length > 9 ? row[9] : null,'9');

      _getCellValue(row.length > 10 ? row[10] :null,'10');
      _getCellValue(row.length > 11 ? row[11] : null,'11');
      _getCellValue(row.length > 12 ? row[12] : null,'12');


      // ==========================================================
      // PARTE 1: Processar os dados principais do funcionário
      // ==========================================================

      final matricula = matriculaStr;
      final nome = _getCellValue(row.length > 1 ? row[1] : null,'').replaceAll("'", "''");
      final dataAdmissao = _formatDateForSql(_getCellValue(row.length > 2 ? row[2] : null,''));
      final admissao=Utils.dtToMysql(dataAdmissao);
      final horas = _getCellValue(row.length > 5 ? row[5] : null,'');
      final cargo = _getCellValue(row.length > 3 ? row[3] : null,'')+'-$horas';
      final local_lotacao = _getCellValue(row.length > 4 ? row[4] : null,'');
      final unidade = _getCellValue(row.length > 5 ? row[5] : null,'')+'-$horas';
      final nivelFaixa = _getCellValue(row.length > 6 ? row[6] : null,'');
      final vencimento = _parseCurrency(_getCellValue(row.length > 8 ? row[8] : null,''));
      final venc=Utils.vrStringToDouble(vencimento.toString());



     // print("INSERT INTO cia_2501 (matricula, nome, admissao, unidade,nivel,vencimento, total_geral) VALUES "
       //   "('$matricula', '$nome', $dataAdmissao, '$unidade', '$nivelFaixa', $vencimento);");

      insertsFolha.add(
          "INSERT INTO cia_2501 (matricula, nome, admissao, unidade,nivel,vencimento,local_lotacao) VALUES "
              "('$matricula', '$nome', $admissao, '$cargo', '$nivelFaixa', $venc,'$local_lotacao');"
      );

      // ==========================================================
      // PARTE 2: Processar as vantagens (colunas J até AB)
      // ==========================================================
      // A coluna J é o índice 9. A coluna W (Venc. Cargo Comissão) é o índice 22.
      for (int colIndex = 9; colIndex < 22; colIndex++) {
        final valorVantagemStr = _getCellValue(row.length > colIndex ? row[colIndex] : null,'$colIndex');

        if (valorVantagemStr.isNotEmpty) {
          final double valorVantagem = _parseCurrency(valorVantagemStr);

          // O valor precisa ser maior que zero para ser inserido
          if (valorVantagem > 0) {
             final String descricaoVantagem = _getCellValue(headerRow.length > colIndex ? headerRow[colIndex] : null,'').replaceAll("'", "''",);

            print("INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
                "('$matricula', '$descricaoVantagem', $valorVantagem);");

            insertsVantagens.add(
                "INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
                    "('$matricula', '$descricaoVantagem', $valorVantagem);"
            );

          }
        }
      }

      _processedRows++;
    }

    // ==========================================================
    // PARTE 3: Juntar tudo em um único script SQL
    // ==========================================================
    if (insertsFolha.isEmpty && insertsVantagens.isEmpty) {
      return '-- Nenhum dado válido encontrado para gerar o script.';
    }

    final StringBuffer sqlScript = StringBuffer();

    if (insertsFolha.isNotEmpty) {
      sqlScript.writeln('-- Inserções para a tabela de Folha ($TBFolha)');
      sqlScript.writeln("DELETE FROM $TBFolha;");
      sqlScript.writeln(insertsFolha.join('\n'));
      sqlScript.writeln('\n');
    }

    if (insertsVantagens.isNotEmpty) {
      sqlScript.writeln('-- Inserções para a tabela de Vantagens ($TBVantagens)');
      sqlScript.writeln("DELETE FROM $TBVantagens;");
      sqlScript.writeln(insertsVantagens.join('\n'));
    }

    return sqlScript.toString();
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoading = true;
      _sqlScript = null;
      _fileName = null;
      _processedRows = 0;
      _skippedRows = 0;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // MUDANÇA: aceita .xlsx
      );

      if (result != null && result.files.single.bytes != null) {
        _fileName = result.files.single.name;
        final bytes = result.files.single.bytes!;

        // MUDANÇA: Usa o pacote 'excel' para decodificar os bytes
        var excel = Excel.decodeBytes(bytes);

        setState(() {
          _sqlScript = _generateSqlFromExcel(excel);
        });
      }
    } catch (e) {
      setState(() {
        _sqlScript = '-- Ocorreu um erro ao processar a planilha Excel: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Folha (XLSX)'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar Planilha (.xlsx)'),
                onPressed: _isLoading ? null : _pickAndProcessFile,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_sqlScript != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Script gerado para: $_fileName'),
                      const SizedBox(height: 4),
                      Text(
                        '$_processedRows registros processados, $_skippedRows linhas ignoradas.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _sqlScript!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copiar Script SQL',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _sqlScript!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Script copiado para a área de transferência!')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Center(child: Text('Selecione uma planilha (.xlsx) para gerar o script SQL.'))
            ],
          ),
        ),
      ),
    );
  }
}

/*

import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExcelReaderPage extends StatefulWidget {
  const ExcelReaderPage({super.key});

  @override
  State<ExcelReaderPage> createState() => _ExcelReaderPageState();
}

class _ExcelReaderPageState extends State<ExcelReaderPage> {
  List<Map<String, dynamic>> rows = [];

  Future<void> _pickAndReadExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      _readExcelFile(bytes);
    }
  }

  /// Use FilePicker to pick files in Flutter Web

  void lerPlanilha()async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    /// file might be picked

    if (pickedFile != null) {
      var bytes = pickedFile.files.single.bytes;
      var excel = Excel.decodeBytes(bytes!);
      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print(excel.tables[table]!.maxColumns);
        print(excel.tables[table]!.maxRows);


        for (var i = 1; i < excel.tables[table]!.rows.length; i++) {
          final row = excel.tables[table]!.rows[i];
        //  for (var j = 0; j < 11; j++) {
            for (var j = 0; j < row.length; j++) {
            final value = row.length > j ? row[j]?.value : null;
            if(j==0 && value==null){
              break;
            }
            //OK
            if(j==0){
              print('matricula = $value');
            }
            //OK
            if(j==1){
              print('nome = $value');
            }//OK
            if(j==2){
              print('admissão = $value');
            }
            //OK
            if(j==3){
              print('cargo = $value');
            }
            if(j==5){
              print('horas = $value');
            }
            if(j==6){
              print('niivel = $value');
            }
            if(j==8){
              print('salario = $value');
            }
            if(value!=null) {
              print('dado $value posição $j');
            }
          }
        //  data.add(rowData);

        }
      }
    }
  }
  void _readExcelFile(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      print("Nenhuma planilha encontrada.");
      return;
    }

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null) return;

    final headers = sheet.rows.first.map((cell) => cell?.value.toString()).toList();
    final List<Map<String, dynamic>> data = [];

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final Map<String, dynamic> rowData = {};
      for (var j = 0; j < headers.length; j++) {
        final key = headers[j] ?? 'col$j';
        final value = row.length > j ? row[j]?.value : null;
        rowData[key] = value;
      }
      data.add(rowData);
    }

    setState(() {
      rows = data;
    });

    // Exibe no console
    for (var row in rows) {
      print(row);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leitor de Excel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: lerPlanilha,
              child: const Text("Selecionar Planilha Excel"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: rows.isEmpty
                  ? const Text("Nenhum dado carregado.")
                  : ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return Card(
                    child: ListTile(
                      title: Text(row.toString()),
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

 */


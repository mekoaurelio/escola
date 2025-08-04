/*
import 'dart:convert'; // Necessário para decodificar os bytes
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart'; // Importa o novo pacote
import 'package:flutter/services.dart';

import '../const/nome_tabelas.dart'; // Para a variável TBFolha
import '../services/table_name_service.dart';
import '../services/utils.dart'; // Para o Utils

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

  // Função para limpar e converter valores monetários de String para double
  double _parseCurrency(String value) {
    if (value.isEmpty) return 0.0;
    // Remove "R$ ", troca o ponto de milhar e a vírgula decimal
    final cleanValue = value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Processa os dados do CSV e gera o script SQL
  /*
  String _generateSqlFromCsv(List<List<dynamic>> rows) {
    final List<String> inserts = [];
    _processedRows = 0;
    _skippedRows = 0;

    // Itera sobre cada linha, pulando o cabeçalho (primeira linha, índice 0)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      // Verifica se a linha tem o número mínimo de colunas e se a matrícula não está vazia
      if (row.length < 24 || row[0].toString().trim().isEmpty) {
        _skippedRows++;
        continue;
      }

      // Extrai os dados das colunas com base nos índices
      final matricula = row[0].toString().trim();
      final nome = row[1].toString().trim().replaceAll("'", "''"); // Escapa aspas simples
      final dataAdmissao = Utils.dtToMysql(row[2].toString().trim());
      final cargo = row[3].toString().trim().replaceAll("'", "''");
      final nivel = row[4].toString().trim();
      final horas = row[5].toString().trim();
      final nivelFaixa = row[6].toString().trim();
      final grupo = row[7].toString().trim();

      final totalVantagens = _parseCurrency(row[22].toString());
      final provBase = _parseCurrency(row[23].toString());
      final totalGeral = _parseCurrency(row[24].toString());

      // Monta o comando INSERT
      // Adapte os campos da sua tabela TBFolha aqui
      inserts.add(
          "INSERT INTO $TBFolha (matricula, nome, admissao, cargo, nivel, horas, nivel_faixa, grupo, vencimento_base, total_vantagens, total_geral) VALUES "
              "('$matricula', '$nome', $dataAdmissao, '$cargo', '$nivel', '$horas', '$nivelFaixa', '$grupo', $provBase, $totalVantagens, $totalGeral);"
      );
      _processedRows++;
    }

    if (inserts.isNotEmpty) {
      // Cria o script final com DELETE + todos os INSERTs
      return "DELETE FROM $TBFolha;\n\n${inserts.join('\n')}";
    }

    return '-- Nenhum dado válido encontrado para gerar o script.';
  }

   */

  // dentro da classe _ImportContratosScreenState

  /// Processa os dados do CSV e gera o script SQL para duas tabelas
  String _generateSqlFromCsv(List<List<dynamic>> rows) {
    // Listas para armazenar os comandos SQL para cada tabela
    final List<String> insertsFolha = [];
    final List<String> insertsVantagens = [];

    _processedRows = 0;
    _skippedRows = 0;

    // Pega a linha do cabeçalho (índice 0) para obter os nomes das vantagens
    final headerRow = rows[0];

    // Itera sobre cada linha de dados, pulando o cabeçalho
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.length < 24 || row[0].toString().trim().isEmpty) {
        _skippedRows++;
        continue;
      }

      // ==========================================================
      // PARTE 1: Processar os dados principais do funcionário
      // ==========================================================
      final matricula = row[0].toString().trim();
      final nome = row[1].toString().trim().replaceAll("'", "''");
      final dataAdmissao = Utils.dtToMysql(row[2].toString().trim());
      final cargo = row[3].toString().trim().replaceAll("'", "''");
      final nivel = row[4].toString().trim();
      final horas = row[5].toString().trim();
      final nivelFaixa = row[6].toString().trim();
      final grupo = row[7].toString().trim();
      final provBase = _parseCurrency(row[23].toString());
      final totalGeral = _parseCurrency(row[24].toString());

      // Monta o INSERT para a tabela TBFolha (ajuste os campos conforme sua tabela)
      print( "INSERT INTO $TBFolha (matricula, nome, admissao, cargo, nivel, horas, nivel_faixa, grupo, vencimento_base, total_geral) VALUES "
          "('$matricula', '$nome', $dataAdmissao, '$cargo', '$nivel', '$horas', '$nivelFaixa', '$grupo', $provBase, $totalGeral);");
      /*
      insertsFolha.add(
          "INSERT INTO $TBFolha (matricula, nome, admissao, cargo, nivel, horas, nivel_faixa, grupo, vencimento_base, total_geral) VALUES "
              "('$matricula', '$nome', $dataAdmissao, '$cargo', '$nivel', '$horas', '$nivelFaixa', '$grupo', $provBase, $totalGeral);"
      );

       */

      // ==========================================================
      // PARTE 2: Processar as vantagens (colunas J até AB)
      // ==========================================================
      // A coluna J é o índice 9. A coluna AB é o índice 27.
      // Vamos iterar da coluna 9 até a 21, que são as vantagens antes dos totais.
      for (int colIndex = 9; colIndex < 22; colIndex++) {
        // Pega o valor da célula da vantagem
        final String valorVantagemStr = row.length > colIndex ? row[colIndex].toString().trim() : '';

        // Se a célula não estiver vazia, processa a vantagem
        if (valorVantagemStr.isNotEmpty) {
          // Converte o valor para double
          final double valorVantagem = _parseCurrency(valorVantagemStr);

          // Pega o nome da vantagem da linha de cabeçalho
          final String descricaoVantagem = headerRow.length > colIndex ? headerRow[colIndex].toString().trim().replaceAll("'", "''") : 'Vantagem Desconhecida';

          // Monta o INSERT para a tabela TBVantagens
          print( "INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
              "('$matricula', '$descricaoVantagem', $valorVantagem);");
          /*
          insertsVantagens.add(
              "INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
                  "('$matricula', '$descricaoVantagem', $valorVantagem);"
          );

           */
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

    // Cria o script final com DELETEs e todos os INSERTs
    final StringBuffer sqlScript = StringBuffer();

    if (insertsFolha.isNotEmpty) {
      sqlScript.writeln('-- Inserções para a tabela de Folha');
      sqlScript.writeln("DELETE FROM $TBFolha;");
      sqlScript.writeln(insertsFolha.join('\n'));
      sqlScript.writeln('\n'); // Adiciona uma linha em branco para separar
    }

    if (insertsVantagens.isNotEmpty) {
      sqlScript.writeln('-- Inserções para a tabela de Vantagens');
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
        allowedExtensions: ['xlsx'], // MUDANÇA: aceita apenas .csv
      );

      if (result != null && result.files.single.bytes != null) {
        _fileName = result.files.single.name;
        final bytes = result.files.single.bytes!;

        // MUDANÇA: Decodifica os bytes como uma string UTF-8 e processa como CSV
        final content = utf8.decode(bytes);
        final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(content);

        setState(() {
          _sqlScript = _generateSqlFromCsv(rowsAsListOfValues);
        });
      }
    } catch (e) {
      setState(() {
        _sqlScript = '-- Ocorreu um erro ao processar o arquivo CSV: $e';
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
        title: const Text('Importar Folha de Pagamento (CSV)'),
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
                label: const Text('Selecionar Planilha (.csv)'),
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
                      // Mostra um resumo do processamento
                      Text('Script gerado para: $_fileName'),
                      const SizedBox(height: 4),
                      Text(
                        '$_processedRows registros processados, $_skippedRows linhas ignoradas.',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      // ... (resto da UI para mostrar o script e copiar)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
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
                const Center(child: Text('Selecione uma planilha (.csv) para gerar o script SQL.'))
            ],
          ),
        ),
      ),
    );
  }
}

 */

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
  String _getCellValue(Data? cell) {
    if (cell == null) return '';
    // A biblioteca excel pode ler números como double (ex: 19.0) ou int.
    if (cell.value is double) {
      // Se for um double sem parte decimal, converte para int.
      if ((cell.value as double) % 1 == 0) {
        return (cell.value as double).toInt().toString();
      }
      return (cell.value as double).toString();
    }
    // Lida com datas que podem ser lidas como um tipo específico
  //  if (cell.cellType == CellType.date) {
      try {
        // Tenta formatar a data lida pelo pacote
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(cell.value.toString()));
      } catch(e) {
        return cell.value.toString();
      }
  //  }
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
      final matriculaStr = _getCellValue(row.isNotEmpty ? row[0] : null);
      if (matriculaStr.isEmpty) {
        _skippedRows++;
        continue;
      }

      // ==========================================================
      // PARTE 1: Processar os dados principais do funcionário
      // ==========================================================
      final matricula = matriculaStr;
      final nome = _getCellValue(row.length > 1 ? row[1] : null).replaceAll("'", "''");
      final dataAdmissao = _formatDateForSql(_getCellValue(row.length > 2 ? row[2] : null));
      final cargo = _getCellValue(row.length > 3 ? row[3] : null).replaceAll("'", "''");
      final nivel = _getCellValue(row.length > 4 ? row[4] : null);
      final horas = _getCellValue(row.length > 5 ? row[5] : null);
      final nivelFaixa = _getCellValue(row.length > 6 ? row[6] : null);
      final grupo = _getCellValue(row.length > 7 ? row[7] : null);
      final provBase = _parseCurrency(_getCellValue(row.length > 23 ? row[23] : null));
      final totalGeral = _parseCurrency(_getCellValue(row.length > 24 ? row[24] : null));

      print( "INSERT INTO $TBFolha (matricula, nome, admissao, cargo, nivel, horas, nivel_faixa, grupo, vencimento_base, total_geral) VALUES "
          "('$matricula', '$nome', $dataAdmissao, '$cargo', '$nivel', '$horas', '$nivelFaixa', '$grupo', $provBase, $totalGeral);");
      /*
      insertsFolha.add(
          "INSERT INTO $TBFolha (matricula, nome, admissao, cargo, nivel, horas, nivel_faixa, grupo, vencimento_base, total_geral) VALUES "
              "('$matricula', '$nome', $dataAdmissao, '$cargo', '$nivel', '$horas', '$nivelFaixa', '$grupo', $provBase, $totalGeral);"
      );

       */

      // ==========================================================
      // PARTE 2: Processar as vantagens (colunas J até AB)
      // ==========================================================
      // A coluna J é o índice 9. A coluna W (Venc. Cargo Comissão) é o índice 22.
      for (int colIndex = 9; colIndex < 22; colIndex++) {
        final valorVantagemStr = _getCellValue(row.length > colIndex ? row[colIndex] : null);

        if (valorVantagemStr.isNotEmpty) {
          final double valorVantagem = _parseCurrency(valorVantagemStr);
          // O valor precisa ser maior que zero para ser inserido
          if (valorVantagem > 0) {
            final String descricaoVantagem = _getCellValue(headerRow.length > colIndex ? headerRow[colIndex] : null).replaceAll("'", "''");

            print("INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
                "('$matricula', '$descricaoVantagem', $valorVantagem);");
            /*
            insertsVantagens.add(
                "INSERT INTO $TBVantagens (matricula, descricao, valor) VALUES "
                    "('$matricula', '$descricaoVantagem', $valorVantagem);"
            );

             */
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
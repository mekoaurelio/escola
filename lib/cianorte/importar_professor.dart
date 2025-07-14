import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../const/nome_tabelas.dart'; // Para formatar datas

class ImportContratosScreen extends StatefulWidget {
  const ImportContratosScreen({Key? key}) : super(key: key);

  @override
  State<ImportContratosScreen> createState() => _ImportContratosScreenState();
}

class _ImportContratosScreenState extends State<ImportContratosScreen> {
  String? _sqlScript;
  bool _isLoading = false;
  String? _fileName;

  // Função para obter o valor de uma célula como String, tratando nulos.
  String _getCellValue(Data? cell) {
    // A biblioteca excel pode ler números como double (ex: 19.0), então tratamos isso.
    if (cell?.value is double) {
      return (cell!.value as double).toInt().toString();
    }
    return cell?.value?.toString().trim() ?? '';
  }

  // Função para converter data no formato 'dd/MM/yyyy' para 'yyyy-MM-dd' (formato do MySQL)
  String _formatDateForSql(String dateStr) {
    if (dateStr.isEmpty) return 'NULL';
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dateStr);
      return "'${DateFormat('yyyy-MM-dd').format(date)}'"; // Retorna com aspas para SQL
    } catch (e) {
      return 'NULL'; // Retorna NULL se a data for inválida
    }
  }

  /// Processa a planilha Excel e gera o script SQL
  String _generateSqlFromExcel(Excel excel) {
    final List<String> inserts = [];
    final sheet = excel.tables[excel.tables.keys.first]; // Pega a primeira aba

    if (sheet == null) {
      return '-- ERRO: Nenhuma aba encontrada na planilha.';
    }

    // Começa a ler da linha 6 (índice 5)
    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // Se a primeira célula (código do funcionário) estiver vazia, pulamos a linha
      final codigoFuncionarioStr = _getCellValue(row.isNotEmpty ? row[0] : null);
      if (codigoFuncionarioStr.isEmpty) {
        continue;
      }

      // Extrai os dados das colunas
      // Os índices correspondem às colunas (A=0, B=1, C=2, etc.)
      final funcionarioCodigo = int.tryParse(codigoFuncionarioStr) ?? 0;
      final contratoId = int.tryParse(_getCellValue(row.length > 1 ? row[1] : null)) ?? 0;
      final nome = _getCellValue(row.length > 2 ? row[2] : null).replaceAll("'", "''"); // Escapa aspas simples
      final situacao = _getCellValue(row.length > 5 ? row[5] : null);
      final dataAdmissao = _formatDateForSql(_getCellValue(row.length > 6 ? row[6] : null));
      final dataDemissao = _formatDateForSql(_getCellValue(row.length > 7 ? row[7] : null));
      final localTrabalho = _getCellValue(row.length > 8 ? row[8] : null).replaceAll("'", "''");
      final regime = _getCellValue(row.length > 9 ? row[9] : null).replaceAll("'", "''");
      final cargo = _getCellValue(row.length > 10 ? row[10] : null).replaceAll("'", "''");
      final centroCusto = _getCellValue(row.length > 12 ? row[12] : null).replaceAll("'", "''");
      final dataTerminoContrato = _formatDateForSql(_getCellValue(row.length > 15 ? row[15] : null));

      inserts.add(
          "INSERT INTO $TBFolha (matricula,nome, cpf, unidade,          lotacao, cargo, nivel, admissao,status ) VALUES "
              "($funcionarioCodigo,       '$nome','', '$centroCusto','$regime','$cargo',' ', $dataAdmissao, '$situacao');"
      );
    }

    // Adiciona um comando para deletar os dados antigos antes de inserir os novos
    if (inserts.isNotEmpty) {
      return "DELETE FROM funcionarios_contratos;\n\n${inserts.join('\n')}";
    }

    return '-- Nenhum dado válido encontrado para gerar o script.';
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _isLoading = true;
      _sqlScript = null;
      _fileName = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.bytes != null) {
        _fileName = result.files.single.name;
        final bytes = result.files.single.bytes!;

        var excel = Excel.decodeBytes(bytes);

        setState(() {
          _sqlScript = _generateSqlFromExcel(excel);
        });
      }
    } catch (e) {
      setState(() {
        _sqlScript = '-- Ocorreu um erro ao processar a planilha: $e';
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
        title: const Text('Importar Contratos de Funcionários'),
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
                label: const Text('Selecionar Planilha de Contratos (.xlsx)'),
                onPressed: _isLoading ? null : _pickAndProcessFile,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_sqlScript != null)
                Expanded(
                  child: Column(
                    children: [
                      Text('Script gerado para: $_fileName'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            //border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
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
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar Script SQL',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _sqlScript!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Script copiado para a área de transferência!')),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                const Center(child: Text('Selecione uma planilha para gerar o script SQL.'))
            ],
          ),
        ),
      ),
    );
  }
}
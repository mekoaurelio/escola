
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

import '../const/nome_tabelas.dart';

class ImportarVantagens extends StatefulWidget {
  const ImportarVantagens({Key? key}) : super(key: key);

  @override
  State<ImportarVantagens> createState() => _ImportarVantagensState();
}

class _ImportarVantagensState extends State<ImportarVantagens> {
  String? _sqlScript;
  bool _isLoading = false;
  String? _fileName;

  // Função para obter o valor de uma célula como String, tratando nulos.
  String _getCellValue(Data? cell) {
    return cell?.value?.toString().trim() ?? '';
  }

  /// Processa a planilha Excel e gera o script SQL
  String _generateSqlFromExcel(Excel excel) {
    final List<String> inserts = [];
    final sheet = excel.tables[excel.tables.keys.first]; // Pega a primeira aba

    if (sheet == null) {
      return '-- ERRO: Nenhuma aba encontrada na planilha.';
    }

    String? currentFuncionario;
    String? currentMatricula;
    String competencia = '07/2025'; // Pode ser extraído da planilha se necessário

    final RegExp funcionarioRegex = RegExp(r'(\d+-\d+)\s(.*?)\s-');

    // Começa a ler da linha 5 (índice 4)
    for (int i = 4; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // A primeira célula (coluna A) contém a informação principal da linha
      final String firstCellData = _getCellValue(row.isNotEmpty ? row[0] : null);

      // 1. Detecta um novo funcionário
      if (firstCellData.startsWith('Funcionário:')) {
        final match = funcionarioRegex.firstMatch(firstCellData);
        if (match != null) {
          currentMatricula = match.group(1)?.trim();
          currentFuncionario = match.group(2)?.trim();
        }
        print('DADOS DO FUNCIONARIO  matricula=>$currentMatricula nome $currentFuncionario');
        continue;
      }

      // 2. Se não estamos em um bloco de funcionário, ignora
      if (currentFuncionario == null || currentMatricula == null) {
        continue;
      }

      // 3. Detecta o fim do bloco do funcionário
      if (firstCellData.startsWith('Total Funcionário:')) {
        currentFuncionario = null;
        currentMatricula = null;
        inserts.add('-- Fim do funcionário --\n');
        continue;
      }

      // 4. Ignora linhas de cabeçalho ou irrelevantes
      if (firstCellData.isEmpty || firstCellData.startsWith('Verba') || firstCellData.startsWith('Situação')) {
        continue;
      }

      final proventoDesc = _getCellValue(row.length > 1 ? row[2] : null);
      final proventoRef = _getCellValue(row.length > 2 ? row[1] : null);
      final proventoValor = _getCellValue(row.length > 3 ? row[0] : null);

      if (proventoDesc.isNotEmpty) {
        // Separa o código da descrição
        final descParts = proventoDesc.split(',,-');
        final proventoCodigo = descParts[0].trim();
        String proventoDescricaoLimpa = descParts.length > 1 ? descParts[1].trim() : proventoDesc;
        proventoDescricaoLimpa=proventoDescricaoLimpa.substring(2,proventoDescricaoLimpa.length);
        int pos=currentMatricula.indexOf('-');
        if(pos>0) {
          currentMatricula = currentMatricula.substring(0, pos);
        }


        print("INSERT INTO $TBVantagens (folha_id, codigo, descricao, valor,percentual) VALUES "
            "($currentMatricula, '1', '$proventoDescricaoLimpa',$proventoValor,0 );"
        );
        /*
        inserts.add(
            "INSERT INTO folha_pagamento_detalhes (folha_id, codigo, descricao, valor) VALUES "
                "('$currentMatricula', '$currentFuncionario', '$competencia', 'Provento', ${int.tryParse(proventoCodigo) ?? 0}, '$proventoDescricaoLimpa', '$proventoRef', ${double.tryParse(proventoValor.replaceAll('.','').replaceAll(',','.')) ?? 0.0});"
        );

         */
      }

      // DESCONTOS (Colunas AH, AI, AO)
      // Ajuste os índices se as colunas forem diferentes.
      final descontoDesc = _getCellValue(row.length > 33 ? row[33] : null);
      final descontoRef = _getCellValue(row.length > 34 ? row[34] : null);
      final descontoValor = _getCellValue(row.length > 40 ? row[40] : null);
/*
      if (descontoDesc.isNotEmpty) {
        final descParts = descontoDesc.split(',,-');
        final descontoCodigo = descParts[0].trim();
        final descontoDescricaoLimpa = descParts.length > 1 ? descParts[1].trim() : descontoDesc;

        inserts.add(
            "INSERT INTO folha_pagamento_detalhes (matricula, nome_funcionario, competencia, tipo_lancamento, verba_id, verba_descricao, referencia, valor) VALUES "
                "('$currentMatricula', '$currentFuncionario', '$competencia', 'Desconto', ${int.tryParse(descontoCodigo) ?? 0}, '$descontoDescricaoLimpa', '$descontoRef', ${double.tryParse(descontoValor.replaceAll('.','').replaceAll(',','.')) ?? 0.0});"
        );
      }

 */
    }

    return inserts.join('\n');
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

        // Decodifica a planilha a partir dos bytes
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
        title: const Text('Importar Folha de Pagamento (XLSX)'),
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
                    children: [
                      Text('Script gerado para: $_fileName'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                           // border: Border.all(color: Colors.grey.shade400),
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



/*
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

class ImportarVantagens extends StatefulWidget {
  const ImportarVantagens({Key? key}) : super(key: key);

  @override
  State<ImportarVantagens> createState() => _ImportarVantagensState();
}

class _ImportarVantagensState extends State<ImportarVantagens> {
  String? _sqlScript;
  bool _isLoading = false;
  String? _fileName;

  // Função para obter o valor de uma célula como String, tratando nulos.
  String _getCellValue(Data? cell) {
    if (cell?.value is double) {
      return (cell!.value as double).toInt().toString();
    }
    return cell?.value?.toString().trim() ?? '';
  }

  // Escapa aspas simples para SQL
  String _escapeSql(String value) {
    return value.replaceAll("'", "''");
  }

  /// Processa a planilha de professores e gera o script SQL
  String _generateSqlFromExcel(Excel excel) {
    final List<String> updates = [];
    final sheet = excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      return '-- ERRO: Nenhuma aba encontrada na planilha.';
    }

    print("=== INICIANDO DEBUG DAS LINHAS DO EXCEL ===");
    print("Total de linhas na planilha: ${sheet.rows.length}");

    for (int i = 5; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];

      // ==========================================================
      // CÓDIGO DE DEBUG - IMPRIME A LINHA E SEUS ÍNDICES
      // ==========================================================
      print("\n--- Processando Linha ${i + 1} ---");
      for (int j = 0; j < row.length; j++) {
        final cellValue = _getCellValue(row[j]);
        if (cellValue.isNotEmpty) {
          print("Índice[$j]: '$cellValue'");
        }
      }
      // ==========================================================

      final codigoFuncionario = _getCellValue(row.isNotEmpty ? row[0] : null);
      if (codigoFuncionario.isEmpty) {
        continue;
      }

      // ... O resto da sua lógica de extração ...
      // (Vamos mantê-la por enquanto, mas o debug acima nos dirá os índices corretos)
      final matricula = codigoFuncionario;
      final nome = _escapeSql(_getCellValue(row.length > 2 ? row[2] : null));
      final nivelSalario = _escapeSql(_getCellValue(row.length > 10 ? row[10] : null));

      if (matricula.isNotEmpty && nivelSalario.isNotEmpty) {
        updates.add(
            "UPDATE funcionarios SET nivel_cargo = '$nivelSalario' WHERE matricula = '$matricula'; -- Nome: $nome"
        );
      }
    }

    print("=== FIM DO DEBUG ===");

    if (updates.isEmpty) {
      return '-- Nenhum dado de funcionário válido encontrado para gerar o script.';
    }

    return "-- Script gerado para atualizar o nível/cargo dos funcionários.\n"
        "-- Total de registros: ${updates.length}\n\n"
        "${updates.join('\n')}";
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
        title: const Text('Importar Nível/Cargo de Funcionários'),
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
                label: const Text('Selecionar Planilha de Cargos (.xlsx)'),
                onPressed: _isLoading ? null : _pickAndProcessFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_sqlScript != null)
                Expanded(
                  child: Column(
                    children: [
                      Text('Script SQL gerado a partir de: $_fileName', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            //border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _sqlScript!,
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(Icons.copy_all_rounded),
                        iconSize: 32,
                        tooltip: 'Copiar Script SQL',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _sqlScript!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Script copiado para a área de transferência!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Selecione uma planilha para gerar o script de atualização.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

 */
import 'dart:typed_data'; // Necessário para Uint8List
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Clipboard
import 'package:file_picker/file_picker.dart'; // Para selecionar arquivos
import 'package:excel/excel.dart';

import '../data/api_my_sql.dart'; // Para ler arquivos .xlsx

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerador de SQL',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _sqlScript;
  bool _isLoading = false;
  String? _fileName;

  /// Retorna o valor de uma célula como String, tratando nulos.
  String _getCellStringValue(Data? cell) {
    return cell?.value?.toString().trim() ?? '';
  }

  /// Converte o formato de moeda para um número.
  double _parseCurrency(String value) {
    final cleaned = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Escapa aspas simples para evitar erros de sintaxe SQL.
  String _escapeSql(String s) {
    return s.replaceAll("'", "''");
  }

  /// A lógica principal que converte as linhas do Excel em um script SQL.
/*
      delete from cn_Lancamentos;
delete from cn_servidores;
delete from cn_Cargos;
delete from cn_Eventos;
delete from cn_FontesRecursos;
delete from cn_Planos;
delete from cn_ProjetosAtividades;
delete from cn_Unidades;

  */


  double _parseValor(dynamic cellValue) {
    print('INICIANDO--->$cellValue');
    if (cellValue == null) return 0.0;
    print('PASSOU');

    // Se for um DateTime (erro de interpretação)
    if (cellValue is DateTime) {
      print('Ë UMA DATA');
      // Convertemos para string e tentamos parsear como número
      final dateStr = cellValue.toString();
      print('XXXXXXXXX-> $dateStr');
      try {
        // Tenta extrair o valor numérico da string da data
        final parts = dateStr.split('T')[0].split('-');
        final day = int.tryParse(parts[2]) ?? 0;
        final month = int.tryParse(parts[1]) ?? 0;
        final year = int.tryParse(parts[0]) ?? 0;

        // Se for uma data "pequena" (provavelmente erro de conversão)
        if (year < 1905) {
          // Retorna o dia como valor (aproximação)
          return day.toDouble();
        }
        return 0.0;
      } catch (e) {
        return 0.0;
      }
    }

    // Se for numérico
    if (cellValue is num) {
      print('É UM NUMERO');
      return cellValue.toDouble();
    }

    // Se for string
    if (cellValue is String) {
      print('Ë UMA STRING');
      // Remove pontos de milhar e substitui vírgula decimal por ponto
      final cleaned = cellValue
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    return 0.0;
  }


  String _generateSqlFromExcelRows(List<List<Data?>> dataRows) {
    final Set<String> processedCargos = {};
    final Set<String> processedUnidades = {};
    final Set<String> processedMatriculas = {};
    final Set<String> processedEventos = {};
    final Set<String> processedProjetos = {};
    final Set<String> processedFontes = {};
    final Set<String> processedPlanos = {};

    final List<String> lookupInserts = [];
    final List<String> lancamentoInserts = [];

    for (final row in dataRows) {
      if (row.length < 22) continue;

      final tipoEventoAbreviado = _getCellStringValue(row[0]);
      final tipoServidor = _getCellStringValue(row[1]);
      final codigoEvento = _getCellStringValue(row[2]);
      final descricaoEvento = _getCellStringValue(row[3]);
      final recisao = _getCellStringValue(row[4]);
      final codigoLotacao = _getCellStringValue(row[5]);
      final lotacao = _getCellStringValue(row[6]);
      final matricula = _getCellStringValue(row[7]);
      final nomeServidor = _getCellStringValue(row[8]);
      final cargo = _getCellStringValue(row[9]);
      final despesaCodigo = _getCellStringValue(row[10]);
      final despesaDescricao = _getCellStringValue(row[11]);
      final fonteRecurso = _getCellStringValue(row[12]);
      final codigoProjetoAtividade = _getCellStringValue(row[13]);
      final projetoAtividade = _getCellStringValue(row[14]);
      final descricaoProjetoAtividade = _getCellStringValue(row[15]);
      final eventoDescricaoCompleta = _getCellStringValue(row[17]);
      final codigoExtra = _getCellStringValue(row[18]);
      final descricaoExtra = _getCellStringValue(row[19]);
      final deduzirEmpenho = _getCellStringValue(row[20]);

      final valor = _parseValor(row[21]?.value);


      if (cargo.isNotEmpty && !processedCargos.contains(cargo)) {
        ApiMySql.executaSql("INSERT INTO cn_Cargos (nome) VALUES ('${_escapeSql(cargo)}');");
        lookupInserts.add("INSERT INTO cn_Cargos (nome) VALUES ('${_escapeSql(cargo)}');");
        processedCargos.add(cargo);
      }

      if (codigoLotacao.isNotEmpty && !processedUnidades.contains(codigoLotacao)) {
        String tipoUnidade = 'Administrativo';
        if (lotacao.toLowerCase().contains('escola')) tipoUnidade = 'Escola';
        if (lotacao.toLowerCase().contains('cmei')) tipoUnidade = 'CMEI';
        if (lotacao.toLowerCase().contains('transporte')) tipoUnidade = 'Transporte';
        bool isEdInfantil = tipoUnidade == 'CMEI';

        ApiMySql.executaSql("INSERT INTO cn_Unidades (codigo_lotacao, nome, tipo, educacao_infantil) VALUES ('${_escapeSql(codigoLotacao)}', '${_escapeSql(lotacao)}', '$tipoUnidade', ${isEdInfantil ? 'TRUE' : 'FALSE'});");
        lookupInserts.add("INSERT INTO cn_Unidades (codigo_lotacao, nome, tipo, educacao_infantil) VALUES ('${_escapeSql(codigoLotacao)}', '${_escapeSql(lotacao)}', '$tipoUnidade', ${isEdInfantil ? 'TRUE' : 'FALSE'});");
        processedUnidades.add(codigoLotacao);
      }

      ApiMySql.executaSql("INSERT INTO cn_servidores (matricula, nome, tipo, classe, cargo_id, unidade_id, local_lotacao) VALUES ('${_escapeSql(matricula)}', '${_escapeSql(nomeServidor)}', '${_escapeSql(tipoServidor)}', '${_escapeSql(tipoServidor)}', (SELECT id FROM cn_Cargos WHERE nome = '${_escapeSql(cargo)}'), (SELECT id FROM cn_Unidades WHERE codigo_lotacao = '${_escapeSql(codigoLotacao)}'), '${_escapeSql(lotacao)}');");
      if (matricula.isNotEmpty && !processedMatriculas.contains(matricula)) {
        lookupInserts.add("INSERT INTO cn_servidores (matricula, nome, tipo, classe, cargo_id, unidade_id, local_lotacao) VALUES ('${_escapeSql(matricula)}', '${_escapeSql(nomeServidor)}', '${_escapeSql(tipoServidor)}', '${_escapeSql(tipoServidor)}', (SELECT id FROM cn_Cargos WHERE nome = '${_escapeSql(cargo)}'), (SELECT id FROM cn_Unidades WHERE codigo_lotacao = '${_escapeSql(codigoLotacao)}'), '${_escapeSql(lotacao)}');");
        processedMatriculas.add(matricula);
      }

      if (codigoEvento.isNotEmpty && !processedEventos.contains(codigoEvento)) {
        String tipoEventoCompleto = 'Informação';
        if (tipoEventoAbreviado == 'P') tipoEventoCompleto = 'Provento';
        if (tipoEventoAbreviado == 'D') tipoEventoCompleto = 'Desconto';

        ApiMySql.executaSql("INSERT INTO cn_Eventos (codigo, descricao, tipo, despesa_codigo, despesa_descricao, deduzir_empenho) VALUES ('${_escapeSql(codigoEvento)}', '${_escapeSql(descricaoEvento)}', '$tipoEventoCompleto', '${_escapeSql(despesaCodigo)}', '${_escapeSql(despesaDescricao)}', '${_escapeSql(deduzirEmpenho)}');");
        lookupInserts.add("INSERT INTO cn_Eventos (codigo, descricao, tipo, despesa_codigo, despesa_descricao, deduzir_empenho) VALUES ('${_escapeSql(codigoEvento)}', '${_escapeSql(descricaoEvento)}', '$tipoEventoCompleto', '${_escapeSql(despesaCodigo)}', '${_escapeSql(despesaDescricao)}', '${_escapeSql(deduzirEmpenho)}');");
        processedEventos.add(codigoEvento);
      }

      if (codigoProjetoAtividade.isNotEmpty && !processedProjetos.contains(codigoProjetoAtividade)) {
        ApiMySql.executaSql("INSERT INTO cn_ProjetosAtividades (codigo, numero, descricao) VALUES ('${_escapeSql(codigoProjetoAtividade)}', '${_escapeSql(projetoAtividade)}', '${_escapeSql(descricaoProjetoAtividade)}');");
        lookupInserts.add("INSERT INTO cn_ProjetosAtividades (codigo, numero, descricao) VALUES ('${_escapeSql(codigoProjetoAtividade)}', '${_escapeSql(projetoAtividade)}', '${_escapeSql(descricaoProjetoAtividade)}');");
        processedProjetos.add(codigoProjetoAtividade);
      }

      if (fonteRecurso.isNotEmpty && !processedFontes.contains(fonteRecurso)) {
        ApiMySql.executaSql("INSERT INTO cn_FontesRecursos (codigo) VALUES ('${_escapeSql(fonteRecurso)}');");
        lookupInserts.add("INSERT INTO cn_FontesRecursos (codigo) VALUES ('${_escapeSql(fonteRecurso)}');");
        processedFontes.add(fonteRecurso);
      }

      String? planoCodigo;
      if (eventoDescricaoCompleta.contains('| Plano:')) {
        try {
          final planoPart = eventoDescricaoCompleta.split('| Plano:')[1].trim();
          final planoInfo = planoPart.split('-');
          planoCodigo = planoInfo.last;
          final planoDescricao = planoInfo.sublist(0, planoInfo.length - 1).join('-');

          if (planoCodigo.isNotEmpty && !processedPlanos.contains(planoCodigo)) {
            ApiMySql.executaSql("INSERT INTO cn_Planos (codigo, descricao) VALUES ('${_escapeSql(planoCodigo)}', '${_escapeSql(planoDescricao)}');");
            lookupInserts.add("INSERT INTO cn_Planos (codigo, descricao) VALUES ('${_escapeSql(planoCodigo)}', '${_escapeSql(planoDescricao)}');");
            processedPlanos.add(planoCodigo);
          }
        } catch (e) {}
      }

      final String planoIdSubquery = planoCodigo != null ? "(SELECT id FROM cn_Planos WHERE codigo = '${_escapeSql(planoCodigo)}')" : "NULL";

      ApiMySql.executaSql("INSERT INTO cn_Lancamentos (servidor_id, evento_id, projeto_atividade_id, fonte_recurso_id, plano_id, competencia, valor, codigo_extra, descricao_extra, recisao) VALUES ((SELECT id FROM cn_servidores WHERE matricula = '${_escapeSql(matricula)}'), (SELECT id FROM cn_Eventos WHERE codigo = '${_escapeSql(codigoEvento)}'), (SELECT id FROM cn_ProjetosAtividades WHERE codigo = '${_escapeSql(codigoProjetoAtividade)}'), (SELECT id FROM cn_FontesRecursos WHERE codigo = '${_escapeSql(fonteRecurso)}'), $planoIdSubquery, CURDATE(), $valor, '${_escapeSql(codigoExtra)}', '${_escapeSql(descricaoExtra)}', '${_escapeSql(recisao)}');");

      lancamentoInserts.add("INSERT INTO cn_Lancamentos (servidor_id, evento_id, projeto_atividade_id, fonte_recurso_id, plano_id, competencia, valor, codigo_extra, descricao_extra, recisao) VALUES ((SELECT id FROM cn_servidores WHERE matricula = '${_escapeSql(matricula)}'), (SELECT id FROM cn_Eventos WHERE codigo = '${_escapeSql(codigoEvento)}'), (SELECT id FROM cn_ProjetosAtividades WHERE codigo = '${_escapeSql(codigoProjetoAtividade)}'), (SELECT id FROM cn_FontesRecursos WHERE codigo = '${_escapeSql(fonteRecurso)}'), $planoIdSubquery, CURDATE(), $valor, '${_escapeSql(codigoExtra)}', '${_escapeSql(descricaoExtra)}', '${_escapeSql(recisao)}');");
    }

    final finalScript = StringBuffer();
    finalScript.writeln('-- Script gerado em: ${DateTime.now()}');
    finalScript.writeln('-- Total de ${dataRows.length} linhas de dados processadas do arquivo $_fileName.\n');
    finalScript.writeln('-- =========================================================');
    finalScript.writeln('-- 1. INSERÇÕES NAS TABELAS DE SUPORTE (DADOS ÚNICOS)');
    finalScript.writeln('-- =========================================================\n');
    finalScript.writeAll(lookupInserts, '\n');
    finalScript.writeln('\n\n-- =========================================================');
    finalScript.writeln('-- 2. INSERÇÕES NA TABELA DE LANÇAMENTOS');
    finalScript.writeln('-- =========================================================\n');
    finalScript.writeAll(lancamentoInserts, '\n');

    return finalScript.toString();
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
        allowedExtensions: ['xlsx'], // <<< MUDANÇA AQUI
      );

      if (result != null && result.files.single.bytes != null) {
        final Uint8List fileBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // <<< LÓGICA DE LEITURA DO EXCEL >>>
        var excel = Excel.decodeBytes(fileBytes);

        // Assume que os dados estão na primeira aba da planilha.
        var sheetName = excel.tables.keys.first;
        var sheet = excel.tables[sheetName];

        if (sheet == null) {
          throw Exception('Nenhuma aba encontrada na planilha.');
        }

        // Pula a primeira linha (cabeçalho) e pega as linhas de dados.
        final dataRows = sheet.rows.skip(1).toList();

        if (dataRows.isEmpty) {
          throw Exception('A planilha não contém linhas de dados.');
        }

        setState(() {
          _fileName = fileName;
          _sqlScript = _generateSqlFromExcelRows(dataRows);
        });
      }
    } catch (e) {
      setState(() {
        _sqlScript = '-- Ocorreu um erro ao processar a planilha: \n-- $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_sqlScript != null && _sqlScript!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _sqlScript!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Script SQL copiado para a área de transferência!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerador de SQL a partir de Planilha (.xlsx)'),
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
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Script gerado para: $_fileName',
                                  style: Theme.of(context).textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copiar Script',
                                onPressed: _copyToClipboard,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          /*
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.2),
                          ),
                          
                           */
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _sqlScript!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Text(
                    'Selecione um arquivo .xlsx para começar.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
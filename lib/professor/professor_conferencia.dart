import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';

import 'dart:typed_data';
import 'dart:html' as html; // Para web
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// Dependências adicionadas para Excel
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // Para File
import 'package:universal_html/html.dart' as html; // Para web

class ProfessorConferencia extends StatefulWidget {
  const ProfessorConferencia({super.key});

  @override
  State<ProfessorConferencia> createState() => _ProfessorConferenciaState();
}

class _ProfessorConferenciaState extends State<ProfessorConferencia> {
  final TextEditingController controller = TextEditingController();
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  List<dynamic> listaCompleta = [];
  List<dynamic> lista = [];
  List<dynamic> getHoraNivel = [];

  int currentPage = 1;
  int pageSize = 15;
  int hoverIndex = -1;

  bool isLoading = true;

  // debounce para pesquisa
  DateTime? _lastSearch;

  String textExport='Exportar Planilha';

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _loadData());
    filterController.ano.listen((_) => _loadData());
    filterController.bimestre.listen((_) => _loadData());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final horaNivel = await ApiMySql.getHoraNivel(TBSimulaCab, TBSimulaForm)
          .timeout(const Duration(seconds: 30));
      if (horaNivel.isEmpty || horaNivel.contains('Erro')) {
        Utils.snak('Atenção', 'Não foi possível carregar os níveis', false, Colors.red);
        setState(() => isLoading = false);
        return;
      }
      final professores = await ApiMySql.getProfessor()
          .timeout(const Duration(seconds: 30));

      setState(() {
        getHoraNivel = horaNivel;
        listaCompleta = professores;
        lista = professores;
        // Removido: pageSize = professores.length;
        // É melhor manter um pageSize fixo ou configurável para a paginação na UI
        // Se você quiser mostrar todos por padrão, defina-o maior ou igual a lista.length
        isLoading = false;
      });
    } catch (e) {
      Utils.snak('Erro', 'Falha ao carregar dados: $e', false, Colors.red);
      setState(() => isLoading = false);
    }
  }

  /// === Cálculos ===
  List<double> calcularProgressao(double valorInicial, double percentual, int iteracoes) {
    final resultados = <double>[valorInicial];
    var valorAtual = valorInicial;

    for (int i = 0; i < iteracoes; i++) {
      valorAtual *= (1 + (percentual / 100));
      resultados.add(valorAtual);
    }
    return resultados;
  }

  double salarioProposto(String nivel, String hora) {
    try {
      final hr = hora.replaceAll('hs', '');
      final _nivel = nivel.substring(0, 1);
      final _classe = int.tryParse(nivel.substring(1)) ?? 0;

      final encontrado = getHoraNivel.firstWhere(
            (e) => e['horas'] == hr && e['nivel'] == _nivel,
        orElse: () => {},
      );

      if (encontrado.isEmpty) return 0;

      final valor = double.tryParse(encontrado['valor'].toString()) ?? 0;
      final resultados = calcularProgressao(valor, 2, 30);

      return (_classe > 0 && _classe <= resultados.length)
          ? resultados[_classe - 1]
          : 0;
    } catch (_) {
      return 0;
    }
  }

  /// === UI Helpers ===
  List<dynamic> get currentItems {
    final start = (currentPage - 1) * pageSize;
    final end = start + pageSize;
    return lista.sublist(start, end > lista.length ? lista.length : end);
  }

  Widget cabecalho() {
    const headers = [
      ['Matrícula', 90],
      ['Professor', 250],
      ['Horas', 70],
      ['Nível', 70],
      ['Vencimento', 100],
      ['APTS', 100],
      ['Vantagens', 100],
      ['Total', 100],
      ['Proposta', 100],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.blue,
      child: Row(
        children: [
          const SizedBox(width: 15),
          for (var h in headers)
            Line(
              tex: h[0] as String,
              tam: h[1] as double,
              alin: Alignment.center,
              cor: Colors.grey.shade300,
              negrito: true,
              fontSize: 16,
            ),
        ],
      ),
    );
  }

  Widget buildRow(dynamic item, int index) {
    final vencimento = double.tryParse(item['vencimento'].toString()) ?? 0;
    final horas = item['horas'];
    final nivel = item['nivel'];
    final vrP = salarioProposto(nivel, horas);
    final proposta = Utils.formatVr.format(vrP);

    final sumVantagem = double.tryParse(item['soma_vantagens'].toString()) ?? 0;
    final descriVantagem = item['vantagens_detalhadas'];
    final total = vencimento + sumVantagem;

    Color cor = Colors.black;
    bool negrito = false;
    String tooltip = '';

    if (vencimento < vrP) {
      cor = Colors.red;
      negrito = true;
      tooltip = 'Valor Proposto menor que Vencimento';
    } else if (vrP == 0) {
      cor = Colors.blue;
      negrito = true;
      tooltip = 'Nível inválido';
    } else {
      tooltip = descriVantagem ?? '';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => hoverIndex = index),
      onExit: (_) => setState(() => hoverIndex = -1),
      child: Tooltip(
        message: tooltip,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        child: Container(
          color: hoverIndex == index ? Colors.blue.shade50 : Colors.transparent,
          child: Row(
            children: [
              const SizedBox(width: 15),
              Line(tex: item['matricula'], tam: 90, alin: Alignment.centerLeft, cor: cor, negrito: negrito, fontSize: 18),
              Line(tex: item['nome'], tam: 250, alin: Alignment.centerLeft, cor: cor, negrito: true),
              Line(tex: '$horas', tam: 70, alin: Alignment.center, cor: cor, negrito: negrito),
              Line(tex: "$nivel", tam: 70, alin: Alignment.center, cor: cor, negrito: negrito),
              Line(tex: Utils.formatVr.format(vencimento), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: !negrito),
              Line(tex: 'ATPS', tam: 100, alin: Alignment.centerRight, cor: cor),
              Line(tex: Utils.formatVr.format(sumVantagem), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: negrito),
              Line(tex: Utils.formatVr.format(total), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: negrito),
              Line(tex: proposta, tam: 100, alin: Alignment.centerRight, cor: cor, negrito: true),
              IconButton(
                onPressed: () => edite('Alterando', 'nivel', nivel, item['matricula']),
                icon: const Icon(Icons.edit, size: 15, color: Colors.black54),
              ),
              IconButton(
                onPressed: () => delete(item['matricula'], item['nome']),
                icon: const Icon(Icons.delete, size: 15, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== FUNÇÃO PARA GERAR DADOS EXCEL ====
  List<List<dynamic>> generateExcelData() {
    List<List<dynamic>> excelData = [];

    // Adiciona o cabeçalho
    excelData.add([
      'Matrícula',
      'Professor',
      'Horas',
      'Nível',
      'Vencimento',
      'APTS',
      'Vantagens',
      'Total',
      'Proposta',
    ]);

    // Adiciona os dados de cada professor da lista completa
    for (var item in lista) {
      final vencimento = double.tryParse(item['vencimento'].toString()) ?? 0;
      final horas = item['horas'];
      final nivel = item['nivel'];
      final vrP = salarioProposto(nivel, horas);
      final sumVantagem = double.tryParse(item['soma_vantagens'].toString()) ?? 0;
      final total = vencimento + sumVantagem;

      excelData.add([
        item['matricula'],
        item['nome'],
        horas,
        nivel,
        vencimento, // Armazena como double para o Excel, que formatará.
        'ATPS',
        sumVantagem, // Armazena como double.
        total, // Armazena como double.
        vrP, // Armazena como double.
      ]);
    }
    return excelData;
  }

  // ==== FUNÇÃO PARA EXPORTAR PARA EXCEL ====
  Future<void> exportToExcel() async {
    setState(() => textExport='Exportando...');
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Professores']; // Cria uma aba com o nome 'Professores'

      // Adiciona os dados gerados à planilha
      for (var rowData in generateExcelData()) {
        List<CellValue> rowCells = rowData.map((item) {
          if (item is String) {
            return TextCellValue(item);
          } else if (item is num) { // int ou double
            return DoubleCellValue(item.toDouble());
          }
          return TextCellValue(item?.toString() ?? '');
        }).toList();

        sheet.appendRow(rowCells);
      }

      for (int i = 0; i < sheet.maxColumns; i++) {
        sheet.setColumnAutoFit(i);
      }

      final List<int>? excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception("Falha ao codificar o arquivo Excel.");
      }

      final String filename = "professores_${DateTime.now().toIso8601String().substring(0, 10)}.xlsx";

      if (kIsWeb) {
        // Lógica para Flutter Web
        final blob = html.Blob([Uint8List.fromList(excelBytes)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        Utils.snak('Download', 'O download do arquivo foi iniciado.', true, Colors.green);
        setState(() => textExport='Exportar Planilha');
      } else {
        // Lógica para plataformas nativas (Android, iOS, Desktop)
        // Pedir permissão (principalmente Android)
        if (Platform.isAndroid) {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            Utils.snak('Permissão Negada', 'A permissão de armazenamento é necessária para salvar o arquivo.', false, Colors.red);
            return;
          }
        }

        Directory? directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getExternalStorageDirectory(); // Pode ser getApplicationDocumentsDirectory()
        } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          throw Exception("Não foi possível obter o diretório de armazenamento.");
        }

        final path = "${directory.path}/$filename";
        final File file = File(path);
        await file.writeAsBytes(excelBytes);
        Utils.snak('Sucesso', 'Arquivo salvo em: $path', true, Colors.green);
      }
    } catch (e) {
      Utils.snak('Erro na Exportação', 'Falha ao exportar para Excel: $e', false, Colors.red);
      print('Erro de exportação: $e');
    }
  }


  Future<void> exportToPdf(List<dynamic> lista, Function salarioProposto) async {
    if (lista.isEmpty) {
      Utils.snak('Atenção', 'Não há registros para gerar PDF.', false, Colors.red);
      return;
    }

    final pdf = pw.Document();

    final headers = [
      'Matrícula',
      'Professor',
      'Horas',
      'Nível',
      'Vencimento',
      'APTS',
      'Vantagens',
      'Total',
      'Proposta',
    ];

    // Constrói as linhas da tabela
    List<List<String>> rows = [];
    for (var item in lista) {
      final vencimento = double.tryParse(item['vencimento'].toString()) ?? 0;
      final horas = item['horas'];
      final nivel = item['nivel'];
      final vrP = salarioProposto(nivel, horas);
      final sumVantagem = double.tryParse(item['soma_vantagens'].toString()) ?? 0;
      final total = vencimento + sumVantagem;

      rows.add([
        item['matricula'].toString(),
        item['nome'].toString(),
        horas.toString(),
        nivel.toString(),
        vencimento.toStringAsFixed(2),
        'ATPS',
        sumVantagem.toStringAsFixed(2),
        total.toStringAsFixed(2),
        vrP.toStringAsFixed(2),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'Relatório de Professores',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
          ),
        ],
      ),
    );

    final pdfBytes = await pdf.save();

    final filename = 'professores_${DateTime.now().toIso8601String().substring(0, 10)}.pdf';

    if (kIsWeb) {
      // Abrir PDF em nova aba no Flutter Web
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
      Utils.snak('PDF Gerado', 'O PDF foi aberto em uma nova aba.', true, Colors.green);
    } else {
      // Para Mobile/Desktop
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: filename,
      );
      Utils.snak('PDF Gerado', 'Pré-visualização do PDF aberta.', true, Colors.green);
    }
  }



  @override
  Widget build(BuildContext context) {
    final totalPages = lista.isEmpty ? 0 : (lista.length / pageSize).ceil();
    const double maxTableWidth = 1500;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      body: lista.isEmpty
          ? Utils.vazio('Nenhum Registro')
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTableWidth),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFiel(
                        controller: controller,
                        label: '',
                        prefixIcon: Icons.search_outlined,
                        obrigatorio: false,
                        onChanged: onChange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: exportToExcel,
                      icon: const Icon(Icons.download, color: Colors.white),
                      label:  Text(textExport, style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    /*
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => exportToPdf(lista, salarioProposto),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text('Exportar PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Cor para PDF
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                     */

                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 20), // Espaço entre a pesquisa/botão e a tabela
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        cabecalho(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentItems.length,
                            itemBuilder: (context, index) => buildRow(currentItems[index], index),
                          ),
                        ),
                        PaginationFooter(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          totalItems: lista.length,
                          onPageChanged: (newPage) => setState(() => currentPage = newPage),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> delete(var matricula, var nome) async {
    final confirmar = await Utils.showDlg(
      'Atenção',
      'Confirma a exclusão de \n$nome?',
      context,
      'Sim',
      'Não',
    );
    if (confirmar) {
      await ApiMySql.executaSql("Update $TBFolha set status='D' WHERE matricula=$matricula");
      _loadData();
    }
  }

  Future<void> edite(var title, var campo, vrInicial, var matricula) async {
    await Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: title,
      labelCampo: campo,
      valorInicial: vrInicial,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
      aoSalvar: (novoValor) async {
        await ApiMySql.executaSql("Update $TBFolha set nivel='$novoValor' WHERE matricula=$matricula");
        _loadData();
      },
    );
  }

  void onChange(String text) {
    final now = DateTime.now();
    if (_lastSearch != null && now.difference(_lastSearch!).inMilliseconds < 300) return;
    _lastSearch = now;

    setState(() {
      if (text.isEmpty) {
        lista = listaCompleta;
      } else {
        final query = text.toLowerCase();
        lista = listaCompleta.where((professor) {
          return professor['nome'].toString().toLowerCase().contains(query) ||
              professor['matricula'].toString().toLowerCase().contains(query) ||
              professor['nivel'].toString().toLowerCase().contains(query) ||
              professor['unidade'].toString().toLowerCase().contains(query);
        }).toList();
      }
      currentPage = 1;
    });
  }
}

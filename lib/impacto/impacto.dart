import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class Impacto extends StatefulWidget {
  const Impacto({super.key});

  @override
  State<Impacto> createState() => _ImpactoScreenState();

}
class _ImpactoScreenState extends State<Impacto> {
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '');
  bool _isloading=true;
  double totalFolha=0;
  double totalVantagens=0;
  double percVantagem=0;
  double custoTotalLiquidoCalc=0;
  double encargosPrev14PercentCalc=0;
  double decimoTerceiroProporcionalCalc=0;
  double feriasProporcionalCalc=0;
  double totalFolhaMensalCalc=0;
  double totalFolhaAnualCalc=0;

  //DADOS DO EXERCICIO
  double receitasDeImpostos=0;
  double receitaDeTransferencia=0;
  double receitaTotalFundeb=0;
  double perdaGanho=0;
  double totF=0;

  @override
  void initState() {
    super.initState();
    // Registra os listeners. Eles reagirão a mudanças SE a tela estiver visível.
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      var getTotal=await ApiMySql.executaSql('SELECT sum(vencimento) as totFolha from $TBFolha').timeout(const Duration(seconds: 30));
      var getVan=await ApiMySql.executaSql('SELECT sum(valor) as totVan from $TBVantagens').timeout(const Duration(seconds: 30));;
      var getImpostos=await ApiMySql.executaSql('select sum(vr12) as totImp from $TBImpostos').timeout(const Duration(seconds: 30));
      var getDecenio=await ApiMySql.executaSql('select sum(vr12) as totImp from $TBDecenio').timeout(const Duration(seconds: 30));
      var getDecenio2=await ApiMySql.executaSql('select sum(vr1) as totImp from $TBDecenio').timeout(const Duration(seconds: 30));
      var getTotais=await ApiMySql.get(TBTotais,null,null).timeout(const Duration(seconds: 30));

      setState(() {
        totalFolha=double.parse(getTotal[0]['totFolha']) ;
        totalVantagens=double.parse(getVan[0]['totVan']) ;
        percVantagem =(totalVantagens/totalFolha ) * 100;
        custoTotalLiquidoCalc = totalFolha + totalVantagens;
        encargosPrev14PercentCalc = custoTotalLiquidoCalc * 0.14;
        feriasProporcionalCalc = encargosPrev14PercentCalc/3;
        decimoTerceiroProporcionalCalc = (encargosPrev14PercentCalc+feriasProporcionalCalc) / 12;
        totalFolhaMensalCalc = custoTotalLiquidoCalc + decimoTerceiroProporcionalCalc + feriasProporcionalCalc;
        totalFolhaAnualCalc = totalFolhaMensalCalc * 12;
        //DADOS DO EXERCICIO
        receitasDeImpostos=double.parse(getImpostos[0]['totImp']);
        receitaDeTransferencia=double.parse(getDecenio[0]['totImp']);
        receitaTotalFundeb=double.parse(getTotais[0]['total_receitas_fundeb']);
        totF=(totalFolhaAnualCalc/receitaTotalFundeb)*100;
        double tot=double.parse(getDecenio2[0]['totImp']);
        perdaGanho=receitaTotalFundeb-((tot/100)*20);
        _isloading=false;
      });

    } catch (e) {
      setState(() => _isloading = false);
      print('Erro ao carregar dados: $e');
      Utils.snak('Atenção', 'Erro ao carregar dados. Tente novamente', false, Colors.red);
    }
  }

  Widget _buildTabela(String title) {
    return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child:Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue, // Cor de fundo azul claro da imagem
              ),
              child: Center(
                child:Texto(tit: title,tam: 18,negrito: true,cor: Colors.grey.shade300,),
              ),
            ),
            Table(
              // Define as larguras relativas das colunas
              columnWidths: const {
                0: FlexColumnWidth(4.5), // Vantagens
                1: FlexColumnWidth(1.5), // Atual
              },
              // Define a borda para todas as células da tabela
              border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
              children: [
              _buildDataRow('1. Valor da folha de vencimentos básicos - Mensal - R/\$', _currencyFormat.format(totalFolha)),
              _buildDataRow('2. Valor das vantagens pecuniárias - Mensal - R/\$',  _currencyFormat.format(totalVantagens),cor: Colors.red,icon: Icons.help, tooTip: d2),
              _buildDataRow('3. Percentual das vantagens pecuniárias sobre a folha de vencimento', '${percVantagem.toStringAsFixed(2)}%',icon: Icons.help, tooTip: d3  ),
              _buildDataRow('4. Custo total da folha de pagamento líquida mensal', _currencyFormat.format(custoTotalLiquidoCalc),tam: 18,icon: Icons.help, tooTip: d4 ),
              _buildDataRow('5. Encargos previdenciários', '14%',icon: Icons.help, tooTip: d5 ),
              _buildDataRow('6. Encargos previdenciários (14%)', _currencyFormat.format(encargosPrev14PercentCalc),icon: Icons.help, tooTip: d6 ),
              _buildDataRow('7. Valor do décimo terceiro 1/12', _currencyFormat.format(decimoTerceiroProporcionalCalc),icon: Icons.help, tooTip: d7),
              _buildDataRow('8. Valor 1/3 férias (proporcional)', _currencyFormat.format(feriasProporcionalCalc),icon: Icons.help, tooTip: d8 ),
              _buildDataRow('9. Total folha mensal', _currencyFormat.format(totalFolhaMensalCalc),icon: Icons.help, tooTip: d9 ),
              _buildDataRow('10. Total folha bruta anual', _currencyFormat.format(totalFolhaAnualCalc),tam: 22,icon: Icons.help, tooTip: d10),

            ],
            )
          ],
        )
    );
  }

  Widget _buildDadosDoExercicio(String title) {
    return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child:Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue, // Cor de fundo azul claro da imagem
              ),
              child: Center(
                child:Texto(tit: title,tam: 18,negrito: true,cor: Colors.grey.shade300,),
              ),
            ),
            Table(
              // Define as larguras relativas das colunas
              columnWidths: const {
                0: FlexColumnWidth(4.5), // Vantagens
                1: FlexColumnWidth(1.5), // Atual
              },
              // Define a borda para todas as células da tabela
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              children: [
                _buildDataRow('1. Receita de Impostos', _currencyFormat.format(receitasDeImpostos)),
                _buildDataRow('2. Receitas de Transferências',  _currencyFormat.format(receitaDeTransferencia),tooTip: d2),
                _buildDataRow('   Total Receita - (1 + 2)', _currencyFormat.format(receitasDeImpostos+receitaDeTransferencia), tooTip: d3  ),
                _buildDataRow('3. Custo total da folha de pagamento líquida mensal', _currencyFormat.format(totalFolhaAnualCalc),tam: 18,icon: Icons.help, tooTip: d4 ),
                _buildDataRow('4. Receitas Recebidas do FUNDEB - (FNDE)', _currencyFormat.format(receitaTotalFundeb),tam: 18,icon: Icons.help, tooTip: d4 ),
                _buildDataRow('5. Pag dos Profincionais do Magistério (70%)', '${_currencyFormat.format(totF)}%' ,icon: Icons.help, tooTip: d6 ),
                _buildDataRow('PERDA/GANHO', _currencyFormat.format(perdaGanho)),
                _buildDataRow('6. Mínimo 70% - Folha dos profissionais do magistério (5/4)', '${_currencyFormat.format((receitaTotalFundeb/100)*totF)}%',icon: Icons.help, tooTip: d10),
                _buildDataRow('. TOTAL - Consolidação de recursos para MDE - (4 + 6 + 7) ', _currencyFormat.format(receitasDeImpostos+receitaDeTransferencia+receitaTotalFundeb),icon: Icons.help, tooTip: d7,tam: 18),
              ],
            )
          ],
        )
    );
  }

  TableRow _buildDataRow(String label, String valor,{Color cor=Colors.black, double tam=15,IconData? icon,String? tooTip}) {
    const cellStyle = TextStyle(fontSize: 15, color: Colors.black87,);
    return TableRow(
      children: [
        _buildTableCell(label, style: cellStyle,icon: icon,tooTip: tooTip),
        _buildTableCell(valor, style: cellStyle, alignment: MainAxisAlignment.end,cor: cor,tam: tam),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {
        required TextStyle style, MainAxisAlignment alignment = MainAxisAlignment.start,
        Color cor=Colors.black54,double tam=15,IconData? icon,String? tooTip
      }
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Texto(tit:text,icone: icon ,tooltip: tooTip ,mainAxisAlignment: alignment,
      cor: cor,tam: tam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Largura máxima para todo o conteúdo
            child: Column(

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label:  Text('PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        generateImpactoPdf(
                          totalFolha: totalFolha,
                          totalVantagens: totalVantagens,
                          percVantagem: percVantagem,
                          custoTotalLiquidoCalc: custoTotalLiquidoCalc,
                          encargosPrev14PercentCalc: encargosPrev14PercentCalc,
                          feriasProporcionalCalc: feriasProporcionalCalc,
                          decimoTerceiroProporcionalCalc: decimoTerceiroProporcionalCalc,
                          totalFolhaMensalCalc: totalFolhaMensalCalc,
                          totalFolhaAnualCalc: totalFolhaAnualCalc,
                          receitasDeImpostos: receitasDeImpostos,
                          receitaDeTransferencia: receitaDeTransferencia,
                          receitaTotalFundeb: receitaTotalFundeb,
                          perdaGanho: perdaGanho,
                          totF: totF,
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label:  Text('Excel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        generateExcel(
                          totalFolha: totalFolha,
                          totalVantagens: totalVantagens,
                          percVantagem: percVantagem,
                          custoTotalLiquidoCalc: custoTotalLiquidoCalc,
                          encargosPrev14PercentCalc: encargosPrev14PercentCalc,
                          feriasProporcionalCalc: feriasProporcionalCalc,
                          decimoTerceiroProporcionalCalc: decimoTerceiroProporcionalCalc,
                          totalFolhaMensalCalc: totalFolhaMensalCalc,
                          totalFolhaAnualCalc: totalFolhaAnualCalc,
                          receitasDeImpostos: receitasDeImpostos,
                          receitaDeTransferencia: receitaDeTransferencia,
                          receitaTotalFundeb: receitaTotalFundeb,
                          totF: totF,
                          perdaGanho: perdaGanho,
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                  ],
                ),

                _buildTabela('Dados Da Folha De Pagamento'),
                _buildDadosDoExercicio('Dados Do Execício'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateImpactoPdf({
    required double totalFolha,
    required double totalVantagens,
    required double percVantagem,
    required double custoTotalLiquidoCalc,
    required double encargosPrev14PercentCalc,
    required double feriasProporcionalCalc,
    required double decimoTerceiroProporcionalCalc,
    required double totalFolhaMensalCalc,
    required double totalFolhaAnualCalc,
    required double receitasDeImpostos,
    required double receitaDeTransferencia,
    required double receitaTotalFundeb,
    required double perdaGanho,
    required double totF,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Helper para linha de tabela
    pw.TableRow buildRow(String label, String valor,
        {bool bold = false, PdfColor color = PdfColors.black}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              valor,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Relatório de Impacto Financeiro",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // --- TABELA FOLHA ---
          pw.Text("Dados da Folha de Pagamento", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              buildRow("1. Valor da folha de vencimentos básicos - Mensal", currencyFormat.format(totalFolha)),
              buildRow("2. Valor das vantagens pecuniárias - Mensal", currencyFormat.format(totalVantagens), color: PdfColors.red),
              buildRow("3. Percentual das vantagens sobre a folha", "${percVantagem.toStringAsFixed(2)}%"),
              buildRow("4. Custo total da folha líquida mensal", currencyFormat.format(custoTotalLiquidoCalc), bold: true),
              buildRow("5. Encargos previdenciários (14%)", currencyFormat.format(encargosPrev14PercentCalc)),
              buildRow("6. Décimo terceiro proporcional", currencyFormat.format(decimoTerceiroProporcionalCalc)),
              buildRow("7. Férias proporcionais (1/3)", currencyFormat.format(feriasProporcionalCalc)),
              buildRow("8. Total folha mensal", currencyFormat.format(totalFolhaMensalCalc), bold: true),
              buildRow("9. Total folha bruta anual", currencyFormat.format(totalFolhaAnualCalc), bold: true),
            ],
          ),

          pw.SizedBox(height: 20),

          // --- TABELA EXERCÍCIO ---
          pw.Text("Dados do Exercício", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              buildRow("1. Receita de Impostos", currencyFormat.format(receitasDeImpostos)),
              buildRow("2. Receitas de Transferências", currencyFormat.format(receitaDeTransferencia)),
              buildRow("   Total Receita (1 + 2)", currencyFormat.format(receitasDeImpostos + receitaDeTransferencia)),
              buildRow("3. Custo total da folha anual", currencyFormat.format(totalFolhaAnualCalc)),
              buildRow("4. Receitas FUNDEB", currencyFormat.format(receitaTotalFundeb), bold: true),
              buildRow("5. Profissionais do Magistério (70%)", "${totF.toStringAsFixed(2)}%"),
              buildRow("6. Perda/Ganho", currencyFormat.format(perdaGanho)),
            ],
          ),
        ],

        // Rodapé para todas as páginas
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "© ${DateTime.now().year} GEM Analytics — Relatório Confidencial",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                "Página ${context.pageNumber} de ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),


      ),
    );

    final pdfBytes = await pdf.save();
    final filename = "impacto_${DateTime.now().toIso8601String().substring(0, 10)}.pdf";

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    }
  }


  Future<void> generateExcel({
    required double totalFolha,
    required double totalVantagens,
    required double percVantagem,
    required double custoTotalLiquidoCalc,
    required double encargosPrev14PercentCalc,
    required double feriasProporcionalCalc,
    required double decimoTerceiroProporcionalCalc,
    required double totalFolhaMensalCalc,
    required double totalFolhaAnualCalc,
    required double receitasDeImpostos,
    required double receitaDeTransferencia,
    required double receitaTotalFundeb,
    required double totF,
    required double perdaGanho,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Relatório'];

    // Estilo negrito
    final boldStyle = CellStyle(
      bold: true,
      fontSize: 14,
    );

    // Helper para adicionar linhas (aceita String e double)
    void addRow(String label, [double? value]) {
      sheet.appendRow([
        TextCellValue(label),
        if (value != null) DoubleCellValue(value),
      ]);
    }

    // Cabeçalho 1
    sheet.appendRow([TextCellValue('Dados da Folha de Pagamento')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = boldStyle;
    sheet.appendRow([]);

    addRow('1. Valor da folha de vencimentos básicos - Mensal', totalFolha);
    addRow('2. Valor das vantagens pecuniárias - Mensal', totalVantagens);
    addRow('3. Percentual das vantagens sobre a folha de vencimento', percVantagem);
    addRow('4. Custo total da folha de pagamento líquida mensal', custoTotalLiquidoCalc);
    addRow('5. Encargos previdenciários (14%)', encargosPrev14PercentCalc);
    addRow('6. Valor do décimo terceiro proporcional', decimoTerceiroProporcionalCalc);
    addRow('7. Valor 1/3 férias (proporcional)', feriasProporcionalCalc);
    addRow('8. Total folha mensal', totalFolhaMensalCalc);
    addRow('9. Total folha bruta anual', totalFolhaAnualCalc);

    // Linha em branco extra
    sheet.appendRow([]);
    sheet.appendRow([]);

    // Cabeçalho 2
    final headerRowIndex = sheet.maxRows;
    sheet.appendRow([TextCellValue('Dados do Exercício')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRowIndex)).cellStyle = boldStyle;
    sheet.appendRow([]);

    addRow('1. Receita de Impostos', receitasDeImpostos);
    addRow('2. Receita de Transferências', receitaDeTransferencia);
    addRow('3. Receita Total FUNDEB', receitaTotalFundeb);
    addRow('4. Percentual gastos com profissionais do magistério', totF);
    addRow('5. Perda/Ganho', perdaGanho);

    // Converte para bytes
    final List<int>? bytes = excel.encode();

    if (bytes != null) {
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "relatorio_folha.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }




}
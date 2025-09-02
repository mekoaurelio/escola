import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class Impacto extends StatelessWidget {
  const Impacto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projeção de Recursos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImpactoScreen(),
    );
  }
}

class ImpactoScreen extends StatefulWidget {
  const ImpactoScreen({super.key});

  @override
  State<ImpactoScreen> createState() => _ImpactoScreenState();
}
class _ImpactoScreenState extends State<ImpactoScreen> {
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
    var getTotal=await ApiMySql.executaSql('SELECT sum(vencimento) as totFolha from $TBFolha').timeout(const Duration(seconds: 30));
    var getVan=await ApiMySql.executaSql('SELECT sum(valor) as totVan from $TBVantagens').timeout(const Duration(seconds: 30));

    try {
      setState(() {
        totalFolha=double.parse(getTotal[0]['totFolha']) ;
        totalVantagens=double.parse(getVan[0]['totVan']) ;
        percVantagem =(totalVantagens/totalFolha ) * 100;
        custoTotalLiquidoCalc = totalFolha + totalVantagens;
        encargosPrev14PercentCalc = custoTotalLiquidoCalc * 0.14;
        decimoTerceiroProporcionalCalc = encargosPrev14PercentCalc / 12;
        feriasProporcionalCalc = (1/3)*encargosPrev14PercentCalc;
        totalFolhaMensalCalc = custoTotalLiquidoCalc + decimoTerceiroProporcionalCalc + feriasProporcionalCalc;
        totalFolhaAnualCalc = totalFolhaMensalCalc * 12;
        _isloading=false;
      });

    } catch (e) {
      setState(() => _isloading = false);
      print('Erro ao carregar dados: $e');
      Utils.snak('Atenção', 'Erro ao carregar dados: $e', false, Colors.red);
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
                _buildDataRow('1. Receita de Impostos', _currencyFormat.format(totalFolha)),
                _buildDataRow('2. Receitas de Transferências',  _currencyFormat.format(totalVantagens),cor: Colors.red,icon: Icons.help, tooTip: d2),
                _buildDataRow('   Total Receita - (1 + 2)', '${percVantagem.toStringAsFixed(2)}%',icon: Icons.help, tooTip: d3  ),
                _buildDataRow('3. Custo total da folha de pagamento líquida mensal', _currencyFormat.format(custoTotalLiquidoCalc),tam: 18,icon: Icons.help, tooTip: d4 ),
                _buildDataRow('4. Receitas Recebidas do FUNDEB - (FNDE)',' ',icon: Icons.help, tooTip: d5 ),
                _buildDataRow('5. Pag dos Profincionais do Magistério (70%)', _currencyFormat.format(encargosPrev14PercentCalc),icon: Icons.help, tooTip: d6 ),
                _buildDataRow('. GANHO/PERDA ', _currencyFormat.format(decimoTerceiroProporcionalCalc),icon: Icons.help, tooTip: d7),
                _buildDataRow('6. Conta 25% (1.104) - (25% - 1)', _currencyFormat.format(feriasProporcionalCalc),icon: Icons.help, tooTip: d8 ),
                _buildDataRow('7. Conta 5% (1.103) - (5% - 2)', _currencyFormat.format(totalFolhaMensalCalc),icon: Icons.help, tooTip: d9 ),
                _buildDataRow('8. Mínimo 70% - Folha dos profissionais do magistério (5/4)', _currencyFormat.format(totalFolhaAnualCalc),tam: 22,icon: Icons.help, tooTip: d10),
                _buildDataRow('. TOTAL - Consolidação de recursos para MDE - (4 + 6 + 7) ', _currencyFormat.format(decimoTerceiroProporcionalCalc),icon: Icons.help, tooTip: d7),


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
                _buildTabela('Dados Da Folha De Pagamento'),
                _buildDadosDoExercicio('Dados Do Execício'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
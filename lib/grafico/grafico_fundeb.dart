import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart';
import '../widgets/texto.dart'; // OTIMIZADO: Usando o pacote intl para formatação.

/// Classe de modelo para os dados do FUNDEB.
/// Movida para fora da classe do widget para melhor organização.
class FundebData {
  final String year;
  final double value;
  final double? growth;
  final bool isEstimated;

  FundebData({
    required this.year,
    required this.value,
    this.growth,
    this.isEstimated = false,

  });
}

/// OTIMIZADO: Função de formatação de moeda centralizada e reutilizável.
/// Usa o pacote 'intl' para uma formatação correta e localizada.
String formatCurrency(double value) {
  final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  return format.format(value);
}

class FundebChart extends StatefulWidget {
  final String tipo;
  final String title;

  const FundebChart({
    Key? key,
    required this.tipo,
    required this.title,
  }) : super(key: key);

  @override
  State<FundebChart> createState() => _FundebChartState();
}

class _FundebChartState extends State<FundebChart> with AnoBimestreListenerMixin{
  List<FundebData> fundebData =[];
  bool _isLoading=true;
  var maxYValue;
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    var TB='';
    Utils.snak('Grafico', 'grafico fundeb', false, Colors.green);
    /*
    Utils.snak('MUDANDO', 'grafico fundeb', false, Colors.green);
    setState(() {
      TBExercicio='a_exercicio$ano$bimestre';
      TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
      fundebData.clear();
      if(widget.title.contains('Evolução')){
        TB=TBExercicio;
      }else{
        TB=TBReceitaFundebSimulador;
      }
      start(TB)  ;
    });

     */
  }

  // Função auxiliar para encurtar os valores no eixo Y (ex: 20M, 10M)
  String formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  start()async{
    String TB='';
    if(widget.tipo=='receita'){
      TB=TBReceitaFundebSimulador;
    }else{
      TB=TBExercicio;
    }
    Utils.snak('GRAFICO FUNDEB', 'TABELA : $TB', false, Colors.green);
    final f = await ApiMySql.get(TB, null,'ordem');
    print(f);
    fundebData = [
      FundebData(year: getDescri(f[1]['descricao']), value: double.parse(f[1]['valor']), growth: null),
      FundebData(year: getDescri(f[2]['descricao']), value: double.parse(f[2]['valor']), growth: 26.37),
      FundebData(year: getDescri(f[3]['descricao']), value: double.parse(f[3]['valor']), growth: 21.64),
      FundebData(year: getDescri(f[4]['descricao']), value: double.parse(f[4]['valor']), growth: 10.71),
      FundebData(year: getDescri(f[5]['descricao']), value: double.parse(f[5]['valor']), growth: 29.59),
      FundebData(year: getDescri(f[6]['descricao']), value: double.parse(f[6]['valor']), growth: 3.72, isEstimated: true),
    ];
    setState(() => _isLoading = false);
  }
  
  getDescri(String descri){
    return descri.substring(descri.length-4,descri.length);
  }

  @override
  void initState() {
    super.initState();
    /*
    var TB='';
    TBExercicio='a_exercicio$ano$bimestre';
    TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
    if(widget.title.contains('Evolução')){
      TB=TBExercicio;
    }else{
      TB=TBExercicio;
    }
    */

    start();


  }

  @override
  Widget build(BuildContext context) {
    // Encontrar o valor máximo para definir a altura do eixo Y.
    if(!_isLoading)
      maxYValue = fundebData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        :
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Card(
              child: Texto(tit: widget.title,cor:Colors.black54,tam: 22,),
            ),
          ),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                // Adiciona um espaçamento de 20% no topo do gráfico.
                maxY: maxYValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = fundebData[groupIndex];
                      final yearText = '${data.year}${data.isEstimated ? ' (Est.)' : ''}';
                      final valueText = formatCurrency(data.value);
                      final growthText = data.growth != null
                          ? '\nCrescimento: ${data.growth?.toStringAsFixed(2)}%'
                          : '';

                      return BarTooltipItem(
                        '$yearText: $valueText$growthText',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < fundebData.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(
                              fundebData[index].year.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // CORRIGIDO: Usa a função de utilidade centralizada.
                      getTitlesWidget: (value, meta) =>
                          Text(formatShortCurrency(value), style: const TextStyle(fontSize: 10)),
                      reservedSize: 60,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(fundebData.length, (index) {
                  final data = fundebData[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.value,
                        // Cor diferente para valores estimados.
                        color: data.isEstimated ? Colors.orange.shade400 : Colors.blue.shade400,
                        width: 30,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  );
                }),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Detalhes Anuais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(),
          // OTIMIZADO: O `Column` é mais apropriado aqui do que o spread operator em uma lista.
          Column(
            children: fundebData.map((data) => FundebDataRow(data: data)).toList(),
          ),
        ],
      ),
    );
  }

}

class FundebDataRow extends StatelessWidget {
  final FundebData data;

  const FundebDataRow({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///MOSTRA OS ANOS
          Expanded(
            flex: 3,
            child: Text(
              '${data.year}${data.isEstimated ? ' (Estimativa)' : ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ///VALORES
          Expanded(
            flex: 4,
            child: Text(
              // CORRIGIDO: Usa a função de utilidade centralizada.
              formatCurrency(data.value),
              style: const TextStyle(fontFamily: 'monospace'), // Monospace ajuda a alinhar números
              textAlign: TextAlign.right,
            ),
          ),
         ///MOSTRA OS PERCENTUAIS, QUANDO HOUVER
          if (data.growth != null)
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    data.growth! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: data.growth! >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${data.growth!.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: data.growth! >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(flex: 2, child: SizedBox()), // Espaço para alinhar as linhas
        ],
      ),
    );
  }
}
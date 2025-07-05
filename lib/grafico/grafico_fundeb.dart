import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class FundebChart extends StatefulWidget {
  final String tipo;

  const FundebChart({
    Key? key,
    required this.tipo,
  }) : super(key: key);

  @override
  State<FundebChart> createState() => _FundebChartState();
}

class _FundebChartState extends State<FundebChart> with AnoBimestreListenerMixin {
  List<FundebData> fundebData = [];
  bool _isLoading = true;
  var maxYValue;
  final anoBimestreController = Get.find<AnoBimestreController>();
  bool temDados=true;

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    Utils.snak('Grafico', 'grafico fundeb', false, Colors.green);
  }

  String formatShortCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Future<void> start() async {
    String TB = widget.tipo == 'receita' ? TBReceitaFundebSimulador : TBExercicio;
    try {
      var f = await ApiMySql.get(TB, null, 'ordem');
      print(f.length);
      if(f.length>0) {
        setState(() {
          fundebData = [
            FundebData(year: getDescri(f[1]['descricao']),
                value: double.parse(f[1]['valor']),
                growth: null),
            FundebData(year: getDescri(f[2]['descricao']),
                value: double.parse(f[2]['valor']),
                growth: 26.37),
            FundebData(year: getDescri(f[3]['descricao']),
                value: double.parse(f[3]['valor']),
                growth: 21.64),
            FundebData(year: getDescri(f[4]['descricao']),
                value: double.parse(f[4]['valor']),
                growth: 10.71),
            FundebData(year: getDescri(f[5]['descricao']),
                value: double.parse(f[5]['valor']),
                growth: 29.59),
            FundebData(year: getDescri(f[6]['descricao']),
                value: double.parse(f[6]['valor']),
                growth: 3.72,
                isEstimated: true),
          ];
          _isLoading = false;
        });
      }else{
        setState(() {
          temDados=false;
          _isLoading=false;
        });
      }


    } catch (e) {
      setState(() {
        temDados=false;
        _isLoading = false;
        return;
       // Utils.snak('Erro', 'Falha ao carregar dados', false, Colors.red);
      });
    }
  }

  String getDescri(String descri) {
    return descri.substring(descri.length - 4, descri.length);
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && temDados) {
      maxYValue = fundebData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())

        :!temDados?Utils.vazio('Nenhum Dado Encontrado',height: 100,width: 100):

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gráfico principal
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxYValue * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 10,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = fundebData[groupIndex];
                          return BarTooltipItem(
                            '${data.year}: ${Utils.formatCurrency(data.value)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < fundebData.length) {
                              return Text(
                                fundebData[index].year,
                                style: TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 20,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _calculateInterval(maxYValue),
                          getTitlesWidget: (value, meta) => Text(
                            formatShortCurrency(value),
                            style: TextStyle(fontSize: 8),
                          ),
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(fundebData.length, (index) {
                      final data = fundebData[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.value,
                            color: data.isEstimated
                                ? Colors.orange.shade400
                                : Colors.blue.shade400,
                            width: 60,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      );
                    }),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),

              // Legenda compacta
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.blue.shade400, 'Valores Reais'),
                    SizedBox(width: 12),
                    _buildLegendItem(Colors.orange.shade400, 'Estimativas'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 100000) return 20000;
    if (maxValue <= 1000000) return 200000;
    if (maxValue <= 10000000) return 2000000;
    return 20000000;
  }
}

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


import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart';

class FundebChartSelector extends StatefulWidget {
  const FundebChartSelector({Key? key}) : super(key: key);

  @override
  State<FundebChartSelector> createState() => _FundebChartSelectorState();
}

class _FundebChartSelectorState extends State<FundebChartSelector> with AnoBimestreListenerMixin {
  String chartType = 'linha';
  final realFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  var receitaFundeb = [];
  var exercicioFundeb = [];
  bool _isLoading = true;
  final anos = ['2020', '2021', '2022', '2023', '2024', '2025'];
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    setState(() {
      TBReceitaFundebSimulador = 'a_receita_fundeb_simulador$ano$bimestre';
      TBExercicio = 'a_exercicio$ano$bimestre';
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final f = await ApiMySql.get(TBReceitaFundebSimulador, null, 'ordem');
      final e = await ApiMySql.get(TBExercicio, null, 'ordem');

      setState(() {
        receitaFundeb = [
          double.parse(f[1]['valor']),
          double.parse(f[2]['valor']),
          double.parse(f[3]['valor']),
          double.parse(f[4]['valor']),
          double.parse(f[5]['valor']),
          double.parse(f[6]['valor'])
        ];

        exercicioFundeb = [
          double.parse(e[1]['valor']),
          double.parse(e[2]['valor']),
          double.parse(e[3]['valor']),
          double.parse(e[4]['valor']),
          double.parse(e[5]['valor']),
          double.parse(e[6]['valor'])
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('ERRO $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5, // Ocupa metade da tela
      width:  MediaQuery.of(context).size.width * 0.5,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : receitaFundeb.isEmpty?Utils.vazio('Nenhum Dado Encontrado',height: 100,width: 100):

        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: chartType,
                    items: const [
                      DropdownMenuItem(
                        value: 'linha',
                        child: Text('Linha', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'barra',
                        child: Text('Barra', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => chartType = value);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildChart(),
              ),
            ),
            _buildCompactLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case 'barra':
        return _buildCompactBarChart();
      case 'pizza':
        return _buildCompactPieChart();
      case 'linha':
      default:
        return _buildCompactLineChart();
    }
  }

  Widget _buildCompactLineChart() {
    final receitaSpots = List.generate(
      receitaFundeb.length,
          (i) => FlSpot(i.toDouble(), receitaFundeb[i] / 1e6),
    );
    final exercicioSpots = List.generate(
      exercicioFundeb.length,
          (i) => FlSpot(i.toDouble(), exercicioFundeb[i] / 1e6),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                int i = value.toInt();
                if (i >= 0 && i < anos.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      anos[i],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(),
              getTitlesWidget: (value, _) => Text(
                '${value.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 8),
              ),
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final label = spot.barIndex == 0 ? 'Receita' : 'Exercício';
                final value = spot.y * 1e6;
                return LineTooltipItem(
                  '$label: ${realFormat.format(value)}',
                  TextStyle(fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: receitaSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: exercicioSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildCompactBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(anos.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: receitaFundeb[i] / 1e6,
                color: Colors.orange,
                width: 12,
                borderRadius: BorderRadius.zero,
              ),
              BarChartRodData(
                toY: exercicioFundeb[i] / 1e6,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.zero,
              ),
            ],
            barsSpace: 4,
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int i = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    i >= 0 && i < anos.length ? anos[i] : '',
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(),
              getTitlesWidget: (value, _) => Text(
                '${value.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 8),
              ),
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Receita' : 'Exercício';
              final value = rod.toY * 1e6;
              return BarTooltipItem(
                '$label: ${realFormat.format(value)}',
                TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildCompactPieChart() {
    final receita = receitaFundeb.last;
    final exercicio = exercicioFundeb.last;
    final diferenca = receita - exercicio;

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            value: exercicio,
            title: '${(exercicio / receita * 100).toStringAsFixed(1)}%',
            color: Colors.blue,
            radius: 40,
            titleStyle: TextStyle(fontSize: 10, color: Colors.white),
          ),
          PieChartSectionData(
            value: diferenca,
            title: '${(diferenca / receita * 100).toStringAsFixed(1)}%',
            color: Colors.orange,
            radius: 40,
            titleStyle: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            chartType == 'barra' ? Colors.orange : Colors.green,
            'Receita',
          ),
          SizedBox(width: 12),
          _buildLegendItem(Colors.blue, 'Exercício'),
        ],
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

  double _calculateInterval() {
    final maxValue = [
      ...receitaFundeb,
      ...exercicioFundeb
    ].reduce((a, b) => a > b ? a : b) / 1e6;

    if (maxValue < 10) return 2;
    if (maxValue < 50) return 10;
    if (maxValue < 100) return 20;
    return 50;
  }
}
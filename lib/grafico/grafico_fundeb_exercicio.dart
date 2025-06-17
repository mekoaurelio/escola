import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';


import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class FundebChartSelector extends StatefulWidget {
  const FundebChartSelector({super.key});

  @override
  State<FundebChartSelector> createState() => _FundebChartSelectorState();
}

class _FundebChartSelectorState extends State<FundebChartSelector> {
  String chartType = 'linha';
  final realFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
  var receitaFundeb=[];
  var exercicioFundeb=[];
  bool _isLoading=true;

  final anos = ['2020', '2021', '2022', '2023', '2024', '2025'];


  start()async {
    try {
      final f = await ApiMySql.get(TBReceitaFundebSimulador, null, 'ordem');
      final e = await ApiMySql.get(TBExercicio, null, 'ordem');

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
      setState(() => _isLoading = false);
      
    }catch (e) {
    }
  }

  @override
  void initState() {
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title:  Texto(tit:'Receita FUNDEB x Exercício'),backgroundColor: Colors.white,),
      body:_isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: chartType,
            items: const [
              DropdownMenuItem(value: 'linha', child: Text('Gráfico de Linha')),
              DropdownMenuItem(value: 'barra', child: Text('Gráfico de Barra')),
            //  DropdownMenuItem(value: 'pizza', child: Text('Gráfico de Pizza (2025)')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => chartType = value);
            },
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildChart(),
            ),
          )

        ],
      )
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case 'barra':
        return _buildBarChart();
      case 'pizza':
        return _buildPieChart();
      case 'linha':
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    final receitaSpots = List.generate(
      receitaFundeb.length,
          (i) => FlSpot(i.toDouble(), receitaFundeb[i] / 1e6),
    );
    final exercicioSpots = List.generate(
      exercicioFundeb.length,
          (i) => FlSpot(i.toDouble(), exercicioFundeb[i] / 1e6),
    );

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  ///mostras os anos na parte de baixo do gráfico
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      int i = value.toInt();
                      if (i >= 0 && i < anos.length) {
                        return Texto(tit:anos[i],left: 10,negrito: true,);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                ///mostra os valores ao lado esquerdo  do gráfico
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) =>
                    Texto(tit:'${value.toStringAsFixed(1)}',tam: 9,),
                  ),
                ),

                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),

              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                 // tooltipBgColor: Colors.black87,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final label = spot.barIndex == 0 ? 'Receita' : 'Exercício';
                      final value = spot.y * 1e6; // voltando à escala original
                      return LineTooltipItem(

                        '$label: ${realFormat.format(value)}',

                        const TextStyle(color: Colors.white),
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
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: exercicioSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Colors.green, 'Receita FUNDEB'),
            const SizedBox(width: 16),
            _buildLegend(Colors.blue, 'Exercício'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: List.generate(anos.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: receitaFundeb[i] / 1e6,
                      color: Colors.orange,
                      width: 50,//largura das linhas
                      borderRadius: BorderRadius.only(),
                    ),
                    BarChartRodData(
                      toY: exercicioFundeb[i] / 1e6,
                      color: Colors.blue,
                      width: 50,
                      borderRadius: BorderRadius.only(),
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
                      return Text(i >= 0 && i < anos.length ? anos[i] : '');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) =>
                        Texto(tit:'${value.toStringAsFixed(1)}M',tam: 9,),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                 // tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Receita' : 'Exercício';
                    final value = rod.toY * 1e6; // desfaz a divisão por 1 milhão
                    return BarTooltipItem(
                      '$label: ${realFormat.format(value)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ///legendas
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Colors.orange, 'Receita FUNDEB'),
            const SizedBox(width: 16),
            _buildLegend(Colors.blue, 'Folha FUNDEB (Exercício)'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPieChart() {
    final receita = receitaFundeb.last;
    final exercicio = exercicioFundeb.last;
    final diferenca = receita - exercicio;

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: exercicio,
                  title: 'Folha',
                  color: Colors.blue,
                  radius: 60,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
                PieChartSectionData(
                  value: diferenca,
                  title: 'Outros',
                  color: Colors.orange,
                  radius: 60,
                  titleStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legenda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Colors.blue, 'Folha (Exercício)'),
            const SizedBox(width: 16),
            _buildLegend(Colors.orange, 'Demais gastos (Receita - Folha)'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

}

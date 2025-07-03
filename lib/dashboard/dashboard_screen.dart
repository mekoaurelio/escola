import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../auxiliares/cargo_lista.dart';
import '../grafico/grafico_fundeb.dart';
import '../grafico/grafico_fundeb_exercicio.dart';
import '../grafico/receita_municipio.dart';
import '../widgets/texto.dart';
import 'tabela_receitas.dart';

class DashboardScreen extends StatelessWidget {
  final List<double> valores = [43768980.67, 8590000.00, 11406750.00];
  final List<String> labels = ["Valor 1", "Valor 2", "Valor 3"];
  final NumberFormat currencyFormat = NumberFormat("#,##0.00", "pt_BR");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                //CargoLista
                _buildChartCard(
                  title: 'Consolidação de Recursos',
                  chart: TabelaReceitas(),
                ),
                SizedBox(height: 20),

                _buildChartCard(
                  title: 'Receitas do Município',
                  chart: GraficoReceitaMunicipio(),
                ),
                SizedBox(height: 20),
                _buildChartCard(
                    title: 'Receita FUNDEB X Exercício',
                    chart: FundebChartSelector()
                ),
                SizedBox(height: 20),
                _buildChartCard(
                  title: 'Receita FUNDEB Anualmente',
                  chart: FundebChart(tipo:'receita',),
                ),
                SizedBox(height: 20),
                _buildChartCard(
                  title: 'Evolução da Folha Anualmente',
                  chart: FundebChart(tipo:'Exercicio'),
                ),
                SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          )
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Texto(tit: title,tam: 20,negrito: true,cor:  Colors.blue.shade800,bottom: 8,),
              SizedBox(
                height: 200,
                child: chart,
              ),
            ],
          ),
        ),
      );

  }

  Widget _buildPieChart(BuildContext context) {
    final double total = valores.reduce((a, b) => a + b);

    return Container(
        height: MediaQuery.of(context).size.height * 0.5, // Ocupa metade da tela
        width:  MediaQuery.of(context).size.width * 0.5,
        child:  PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections: List.generate(valores.length, (i) {
              final percentage = (valores[i] / total * 100).round();
              return PieChartSectionData(
                color: _getColor(i),
                value: valores[i],
                title: '$percentage%',
                radius: 20,
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
          ),
        )
    );

  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    labels[value.toInt()],
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(valores),
              getTitlesWidget: (value, meta) {
                return Text(
                  currencyFormat.format(value),
                  style: TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          valores.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: valores[index],
                color: _getColor(index),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  labels[value.toInt()],
                  style: TextStyle(fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(valores),
              getTitlesWidget: (value, meta) {
                return Text(
                  currencyFormat.format(value),
                  style: TextStyle(fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: valores.length.toDouble() - 1,
        minY: 0,
        maxY: valores.reduce((a, b) => a > b ? a : b) * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(valores.length, (i) => FlSpot(i.toDouble(), valores[i])),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(labels.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColor(index),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '${labels[index]}: ${currencyFormat.format(valores[index])}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  Color _getColor(int index) {
    const colors = [Colors.blue, Colors.green, Colors.orange];
    return colors[index % colors.length];
  }

  double _calculateInterval(List<double> values) {
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 100000) return 20000;
    if (max <= 1000000) return 200000;
    if (max <= 10000000) return 2000000;
    return 20000000;
  }
}
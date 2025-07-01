import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class GraficoReceitaMunicipio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5, // 50% da largura
      height: MediaQuery.of(context).size.height * 0.5, // 50% da altura
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: _CompactChartContent(),
      ),
    );
  }
}

class _CompactChartContent extends StatefulWidget {
  @override
  _CompactChartContentState createState() => _CompactChartContentState();
}

class _CompactChartContentState extends State<_CompactChartContent> {
  List<double> valores = [];
  List<String> labels = ["FUNDEB", "Recursos Própio 5%", "Recursos Própio 25%"];
  bool isLoading = true;
  String errorMessage = '';
  ChartType selectedChartType = ChartType.pie;
  final NumberFormat currencyFormat = NumberFormat("#,##0.00", "pt_BR");

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      final data = await ApiMySql.get(TBTotais, null, null);

      double receita = double.parse(data[0]['receita']) + double.parse(data[0]['fundeb_10_5']);

      setState(() {
        valores = [
          receita,
          double.parse(data[0]['decendio_5']),
          double.parse(data[0]['imposto_25'])
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar dados';
        valores = [43768980.67, 8590000.00, 11406750.00]; // Valores de fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage.isNotEmpty
        ? Utils.vazio('Nenhum Dado Encontrado',width: 100,height: 100)
        : Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.pie_chart, size: 20),
                color: selectedChartType == ChartType.pie
                    ? Colors.blue
                    : Colors.grey,
                onPressed: () => setState(() => selectedChartType = ChartType.pie),
              ),
              IconButton(
                icon: Icon(Icons.bar_chart, size: 20),
                color: selectedChartType == ChartType.bar
                    ? Colors.blue
                    : Colors.grey,
                onPressed: () => setState(() => selectedChartType = ChartType.bar),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: selectedChartType == ChartType.pie
                ? _buildCompactPieChart()
                : _buildCompactBarChart(),
          ),
        ),
        _buildCompactLegend(),
      ],
    );
  }

  Widget _buildCompactPieChart() {
    final double total = valores.reduce((a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 30,
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
    );
  }

  Widget _buildCompactBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: valores.reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(
            enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                Utils.formatCurrency(rod.toY),
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
              getTitlesWidget: (value, meta) => Texto(tit: labels[value.toInt()],tam: 10,negrito: true,cor: Colors.red,),
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(valores),
              getTitlesWidget: (value, meta) => Texto(tit: _compactCurrencyFormat(value),tam: 12,),
              reservedSize: 30,
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
                width: 60,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }

  Widget _buildCompactLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: List.generate(labels.length, (index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: _getColor(index),
              ),
              SizedBox(width: 4),
              Text(
                '${labels[index]}: ${_compactCurrencyFormat(valores[index])}',
                style: TextStyle(fontSize: 10),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [Colors.blue, Colors.green, Colors.orange];
    return colors[index % colors.length];
  }

  String _compactCurrencyFormat(double value) {
    if (value >= 1000000) {
      return '${currencyFormat.format(value / 1000000)}M';
    } else if (value >= 1000) {
      return '${currencyFormat.format(value / 1000)}K';
    }
    return currencyFormat.format(value);
  }

  double _calculateInterval(List<double> values) {
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 100000) return 20000;
    if (max <= 1000000) return 200000;
    if (max <= 10000000) return 2000000;
    return 20000000;
  }
}

enum ChartType { pie, bar }
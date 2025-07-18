import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../const/const.dart';
import '../indicadores/aceleracao_do_crescimento.dart';
import '../indicadores/dados_do_municipio.dart';
import '../indicadores/indicadores_educacionais.dart';
import '../indicadores/receitas_educacionais.dart';
import '../indicadores/situacao_toledo.dart';
import '../simulador/simula.dart';
import '../widgets/texto.dart';

class DashboardScreen extends StatelessWidget {
  final List<double> valores = [43768980.67, 8590000.00, 11406750.00];
  final List<String> labels = ["Valor 1", "Valor 2", "Valor 3"];
  final NumberFormat currencyFormat = NumberFormat("#,##0.00", "pt_BR");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child:Tooltip(
                  message: 'Clique em um card para abrir a análise detalhada.',
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Wrap(
                    spacing: 24, // Espaço horizontal entre os cards
                    runSpacing: 24, // Espaço vertical entre as linhas de cards
                    alignment: WrapAlignment.center,
                    children: [
                      // Card 2
                      _buildMetricCard(
                        context: context,
                        title: "Simulador Magistério",
                        fontSize: 20,
                        icon: Icons.trending_up,
                        color: Colors.orange.shade700,
                        previewChart: IgnorePointer(
                            child: Simula()
                        ),
                        fullScreenWidget:  Simula(),
                      ),

                      _buildMetricCard(
                        context: context,
                        title: "ICMS Educação Toledo",
                        fontSize: 20,
                        icon: Icons.generating_tokens_outlined,
                        color: Colors.blue.shade700,
                        previewChart: IgnorePointer(
                            child: IndicadoresEducacionais()
                        ),
                        fullScreenWidget:  IndicadoresEducacionais(),
                      ),
                      _buildMetricCard(
                        context: context,
                        title: "Demonstrativos das Receitas da Educação",
                        fontSize: 18,
                        icon: Icons.monetization_on_outlined,
                        color: Colors.purple.shade700,
                        previewChart: IgnorePointer(
                            child: DadosDoMunicipio()
                        ),
                        fullScreenWidget:  DadosDoMunicipio(),
                      ),
                      _buildMetricCard(
                        context: context,
                        title: "Programa de Aceleração do Crescimento",
                        fontSize: 18,
                        icon: Icons.group_add_outlined,
                        color: Colors.green.shade700,
                        previewChart: IgnorePointer(
                            child: AceleracaoDoCrescimento()
                        ),
                        fullScreenWidget:  AceleracaoDoCrescimento(),
                      ),
                      _buildMetricCard(
                        context: context,
                        title: "Impacto da Educação",
                        fontSize: 18,
                        icon: Icons.school,
                        color: Colors.yellow.shade900,
                        previewChart: IgnorePointer(
                            child: SituacaoToledo()
                        ),
                        fullScreenWidget:  SituacaoToledo(),
                      ),

                      _buildMetricCard(
                          context: context,
                          title: "Receitas Educacionais de 2025",
                          fontSize: 18,
                          icon: Icons.auto_graph_outlined,
                          color: Colors.blue.shade800,
                          previewChart: IgnorePointer(
                              child: ReceitasEducacionais2025()
                          ),
                          fullScreenWidget:  ReceitasEducacionais2025()
                      ),

                    ],
                  ),
                )

            )
        ),
      ),
    );
  }
}

Widget _buildMetricCard({
  required String title,
  required IconData icon,
  required Color color,
  required Widget previewChart,
  required Widget fullScreenWidget,
  required BuildContext context,
  required double fontSize,
}) {
  return SizedBox(
      width: 550,
      height: 320,
      child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FullScreenChartPage(
                    title: title,
                    child: fullScreenWidget,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ///Ícone
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 28, color: color),
                        ),
                        const SizedBox(width: 10),
                        ///Título
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Padding ligeiramente reduzido
                        child: IgnorePointer(
                          // ==========================================================
                          // AQUI ESTÁ A CORREÇÃO FINAL E ROBUSTA
                          // ==========================================================
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return FittedBox(
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter, // Alinha pelo topo
                                child: Container(
                                  width: constraints.maxWidth * 2.5, // Fator de zoom virtual
                                  height: constraints.maxHeight * 2.5, // Fator de zoom virtual
                                  color: Colors.transparent,
                                  child: previewChart,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ),
          )
      )
  );
}

class FullScreenChartPage extends StatelessWidget {
  final String title;
  final Widget child;

  const FullScreenChartPage({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Texto(tit:title,cor: Colors.white,tam: 18,negrito: true,),
          backgroundColor: appBarColor,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child, // O widget interativo original
          ),
        )
    );
  }
}
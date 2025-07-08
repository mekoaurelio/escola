import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../auxiliares/cargo_lista.dart';
import '../grafico/grafico_fundeb.dart';
import '../grafico/grafico_fundeb_exercicio.dart';
import '../grafico/receita_municipio.dart';
import '../simulador/simula.dart';
import '../widgets/texto.dart';
import 'tabela_receitas.dart';

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
                color: Colors.black.withValues(),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Wrap(
                    spacing: 24, // Espaço horizontal entre os cards
                    runSpacing: 24, // Espaço vertical entre as linhas de cards
                    alignment: WrapAlignment.center,
                    children: [
                      // Card 2
                      _buildChartCard(
                        context: context,
                        title: 'Simulador Magistério',
                        previewChart: IgnorePointer(
                            child: Simula()
                        ),
                        fullScreenWidget:  Simula(),
                      ),
                      _buildChartCard(
                        context: context,
                        title: 'Consolidação de Recursos',
                        // A pré-visualização pode ser um widget diferente ou mais simples
                        previewChart: IgnorePointer(child: TabelaReceitas()),
                        // O widget completo que será aberto
                        fullScreenWidget:  TabelaReceitas(),
                      ),

                      // Card 3
                      _buildChartCard(
                        context: context,
                        title: 'Receitas do Município',
                        previewChart: IgnorePointer(child: GraficoReceitaMunicipio()),
                        fullScreenWidget:  GraficoReceitaMunicipio(),
                      ),

                      // Card 4
                      _buildChartCard(
                          context: context,
                          title: 'Receita FUNDEB X Exercício',
                          previewChart: IgnorePointer(child: FundebChartSelector()),
                          fullScreenWidget: FundebChartSelector()),

                      _buildChartCard(
                          context: context,
                          title: 'Receita FUNDEB Anualmente',
                          previewChart: IgnorePointer(child: FundebChart(tipo:'receita',)),
                          fullScreenWidget: FundebChart(tipo:'receita',)),
                      _buildChartCard(
                          context: context,
                          title: 'Evolução da Folha Anualmente',
                          previewChart: IgnorePointer(child: FundebChart(tipo:'Exercicio',)),
                          fullScreenWidget: FundebChart(tipo:'Exercicio',)),
                    ],
                  ),
                )

          )
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required String title,
    required Widget previewChart,
    required Widget fullScreenWidget,
  }) {
    return SizedBox(
      width: 550,
      height: 320,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
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
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Texto(
                      tit: title,
                      tam: 18,
                      negrito: true,
                      cor: Colors.blue.shade800,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Padding ligeiramente reduzido
                      child: IgnorePointer(
                        // ==========================================================
                        // AQUI ESTÁ A CORREÇÃO FINAL E ROBUSTA
                        // ==========================================================
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // O LayoutBuilder nos dá as dimensões finitas (constraints)
                            // da área disponível para a pré-visualização.

                            return FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter, // Alinha pelo topo
                              child: Container(
                                // Usamos as dimensões do LayoutBuilder para criar um
                                // "canvas" virtual para o previewChart se desenhar.
                                // A proporção (width/height) é importante.
                                // Aqui, estamos assumindo uma proporção de desktop.
                                width: constraints.maxWidth * 2.5, // Fator de zoom virtual
                                height: constraints.maxHeight * 2.5, // Fator de zoom virtual
                                decoration: BoxDecoration(
                                  // Um fundo branco para garantir que não haja transparência
                                  // vinda do widget Simula.
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
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

              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.open_in_full_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        title: Text(title),
        backgroundColor: Colors.white,
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
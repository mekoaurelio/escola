import 'package:flutter/material.dart';

class IndicadoresEducacionais extends StatelessWidget {
  const IndicadoresEducacionais({super.key});

  @override
  Widget build(BuildContext context) {
    final headerColor = const Color(0xFF1F3C88); // Azul marinho
    final metaColor = Colors.yellow.shade600; // Lilás sofisticado
    final textoSecundario = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna esquerda - Indicadores existentes
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _indicadorBox(
                    titulo: "Indicador de Ensino",
                    peso: 0.5,
                    linhas: [
                      _linhaIndicador("IDEB 2021", "6,2", Icons.auto_graph_outlined),
                      _linhaIndicador("IDEB 2023", "6,8", Icons.auto_graph_outlined),
                    ],
                    meta: "6,6",
                    atingimento: "1,0",
                    corMeta: Colors.green.shade900,
                    descricao: "Atingimento da Meta do IDEB",
                    headerColor: headerColor,
                    valorColor: Colors.green.shade300,
                    metaColor: metaColor,
                    textoSecundario: textoSecundario,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  _indicadorBox(
                    titulo: "Indicador de Alfabetização",
                    peso: 0.3,
                    linhas: [
                      _linhaIndicador("SAEB 2021", "6,5", Icons.note_alt_outlined),
                      _linhaIndicador("SAEB 2023", "6,9", Icons.note_alt_outlined),
                    ],
                    meta: "6,7",
                    atingimento: "1,02",
                    corMeta: Colors.green.shade900,
                    icon: Icons.check_circle_outline,
                    descricao: "Atingimento da Meta do SAEB",
                    headerColor: headerColor,
                    valorColor: Colors.green.shade300,
                    metaColor: metaColor,
                    textoSecundario: textoSecundario,
                  ),
                  const SizedBox(height: 16),
                  _indicadorBox(
                    titulo: "Indicadores de Educação Integral",
                    peso: 0.1,
                    linhas: [
                      _linhaIndicador("Integral Censo 2022", "730", Icons.integration_instructions_outlined),
                      _linhaIndicador("Integral Censo 2023", "1.040", Icons.integration_instructions_outlined),
                      _linhaIndicador("Total Matrículas 2022", "14.444", Icons.summarize_outlined),
                      _linhaIndicador("Total Matrículas 2023", "14.701", Icons.summarize_outlined),
                      _linhaIndicador("Percentual 2021", "5%", Icons.percent),
                      _linhaIndicador("Percentual 2022", "7%", Icons.percent),
                    ],
                    meta: "14,1%",
                    atingimento: "0,5",
                    corMeta: Colors.red,
                    icon: Icons.dangerous_outlined,
                    descricao: "Atingimento da Meta da Educação Integral",
                    headerColor: headerColor,
                    valorColor: Colors.red.shade200,
                    metaColor: metaColor,
                    textoSecundario: textoSecundario,
                  ),
                  const SizedBox(height: 16),
                  _indicadorBox(
                    titulo: "Indicador Socioeconômico",
                    peso: 0.1,
                    linhas: [
                      _linhaIndicador("INSE 2021", "5,4", Icons.grading),
                    ],
                    meta: "5,2",
                    atingimento: "1,0",
                    icon: Icons.check_circle_outline,
                    corMeta: Colors.green.shade900,
                    descricao: "Atingimento da Meta do INSE",
                    headerColor: headerColor,
                    valorColor: Colors.green.shade300,
                    metaColor: metaColor,
                    textoSecundario: textoSecundario,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Coluna direita - Cálculo do IQEP
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildIqepCalculationCard(),
                  const SizedBox(height: 16),
                  _buildResourceProjectionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIqepCalculationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
        children: [
        const Icon(Icons.calculate, color: Color(0xFF1F3C88)),
          const SizedBox(width: 8),
          Text(
            "CÁLCULO DO IQEP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          ],
        ),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),

        _buildCalculationStep(
          title: "INDICADORES * MATRÍCULAS",
          description: "(IDEB *0,5 + ALFAB. *0,3 + INTEGRAL *0,1 + FATOR SOCIAL *0,1)",
          value: "14.201,17",
        ),

        _buildCalculationStep(
          title: "",
          description: "SOMA (INDICADORES * MATRÍCULAS) DE TODOS OS MUNICIPIOS DO ESTADO",
          value: "1.053.736,28",
          isOperation: true,
        ),

        _buildCalculationStep(
          title: "RESULTADO",
          description: "Índice de Qualidade da Educação do Paraná (IQEP) DESTE MUNICÍPIO",
          value: "0,01347696406159",
          isResult: true,
        ),
        ],
      ),
    ),
    );
  }

  Widget _buildResourceProjectionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                Text(
                  "PROJEÇÃO DE RECURSOS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),

            _buildCalculationStep(
              title: "MULTIPLICA",
              description: "PREVISÃO RECURSO PARA DISTRIBUIÇÃO",
              value: "1.271.621.000,00",
              isOperation: true,
            ),

            _buildCalculationStep(
              title: "RESULTADO",
              description: "PREVISÃO DE VALOR PARA ESTE MUNICÍPIO",
              value: "R\$ 17.137.590,52",
              isResult: true,
            ),

            const SizedBox(height: 8),
            _buildCalculationStep(
              title: "PER CAPITA",
              description: "Valor por aluno",
              value: "R\$ 1.165,74",
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStep({
    required String title,
    required String description,
    required String value,
    bool isOperation = false,
    bool isResult = false,
    bool isSecondary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(title!='')
          Text(
            title,
            style: TextStyle(
              fontSize: isOperation ? 14 : 16,
              fontWeight: isOperation ? FontWeight.normal : FontWeight.bold,
              color: isOperation ? Colors.grey.shade600 :
              isResult ? const Color(0xFF1F3C88) :
              isSecondary ? Colors.green.shade800 : Colors.grey.shade800,
              fontStyle: isOperation ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isResult ?  Colors.blue.shade300 :
              isSecondary ? Colors.green.shade500 : Colors.green.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isResult ? 18 : 16,
                fontWeight: FontWeight.bold,
                //color: isResult ? const Color(0xFF1F3C88) :
                color: isResult ? Colors.white70 :
                isSecondary ? Colors.green.shade800 : Colors.grey.shade100,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos existentes mantidos da implementação anterior
  Widget _indicadorBox({
    required String titulo,
    required double peso,
    required List<Widget> linhas,
    required String meta,
    required String atingimento,
    required String descricao,
    required Color headerColor,
    required Color valorColor,
    required Color metaColor,
    required Color textoSecundario,
    required Color corMeta,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: headerColor),
                const SizedBox(width: 10),
                Text(
                  "$titulo (Peso $peso)",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...linhas,
                const SizedBox(height: 12),
                Row(
                  children: [
                    _blocoTexto("META", meta, metaColor, icone: Icons.flag),
                    const SizedBox(width: 12),
                    _blocoTexto(descricao, atingimento, valorColor,
                        vertical: true, icone: icon, IconColor: corMeta),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _linhaIndicador(String label, String valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            width: 85,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF5DA9E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
      valor,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
            )
          )
        ],
      ),
    );
  }

  Widget _blocoTexto(String titulo, String valor, Color cor,
      {bool vertical = false, IconData? icone, Color? IconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icone != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                icone,
                size: 28,
                color: IconColor ?? Colors.white.withOpacity(0.9),
              ),
            ),
          vertical
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
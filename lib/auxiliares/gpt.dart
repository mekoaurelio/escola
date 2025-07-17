/*
import 'package:flutter/material.dart';

import '../widgets/texto.dart';

class IndicatorsDashboard extends StatelessWidget {
  const IndicatorsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final background = Color(0xFFF4F4F7);
    final headerColor = Color(0xFF1F3C88); // Azul marinho
    final metaColor = Colors.yellow.shade600; // Lilás sofisticado
    final textoSecundario = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: 700,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _indicadorBox(
                titulo: "Indicador de Ensino",
                peso: 0.5,
                linhas: [
                  _linhaIndicador("IDEB 2021", "6,2",Icons.auto_graph_outlined),
                  _linhaIndicador("IDEB 2023", "6,8",Icons.auto_graph_outlined),
                ],
                meta: "6,6",
                atingimento: "1,0",
                corMeta:Colors.green.shade900,
                descricao: "Atingimento da Meta do IDEB",
                headerColor: headerColor,
                valorColor: Colors.green.shade300,
                metaColor: metaColor,
                textoSecundario: textoSecundario,
                icon: Icons.check_circle_outline
              ),
              const SizedBox(height: 16),
              _indicadorBox(
                titulo: "Indicador de Alfabetização",
                peso: 0.3,
                linhas: [
                  _linhaIndicador("SAEB 2021", "6,5",Icons.note_alt_outlined),
                  _linhaIndicador("SAEB 2023", "6,9",Icons.note_alt_outlined),
                ],
                meta: "6,7",
                atingimento: "1,02",
                corMeta:Colors.green.shade900,
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
                  _linhaIndicador("Integral Censo 2022", "730",Icons.integration_instructions_outlined),
                  _linhaIndicador("Integral Censo 2023", "1.040",Icons.integration_instructions_outlined),
                  _linhaIndicador("Total Matrículas 2022", "14.444",Icons.summarize_outlined),
                  _linhaIndicador("Total Matrículas 2023", "14.701",Icons.summarize_outlined),
                  _linhaIndicador("Percentual 2021", "5%",Icons.percent),
                  _linhaIndicador("Percentual 2022", "7%",Icons.percent),
                ],
                meta: "14,1%",
                atingimento: "0,5",
                corMeta:Colors.red,
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
                  _linhaIndicador("INSE 2021", "5,4",Icons.grading),
                ],
                meta: "5,2",
                atingimento: "1,0",
                icon: Icons.check_circle_outline,
                corMeta:Colors.green.shade900,
                descricao: "Atingimento da Meta do INSE",
                headerColor: headerColor,
                valorColor: Colors.green.shade300,
                metaColor: metaColor,
                textoSecundario: textoSecundario,
              ),
            ],
          ),
        ),
      )
    );
  }

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
          Row(
            children: [
              SizedBox(width: 20,),
              Icon(Icons.bar_chart,color: Colors.blue.shade600,),
              Texto(tit: "$titulo (Peso $peso)",cor:Colors.black54 ,tam: 22,fontWeight:FontWeight.w600,left: 10,
              top: 10,),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey.shade400),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...linhas,
                const SizedBox(height: 12),
                Row(
                  children: [
                    _blocoTexto("META", meta, metaColor,icone: Icons.flag),
                    const SizedBox(width: 12),
                    _blocoTexto(atingimento, descricao, valorColor, vertical: true,icone: icon,
                    IconColor: corMeta),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _linhaIndicador(String label, String valor,IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         // Expanded(child:
         // Image.asset('assets/images/ideb_icone.jpg', height: 40),
         // ),
          Expanded(child: Texto(
              tit:label,tam: 15,cor: Colors.black54,fontWeight:FontWeight.w600,prefixIcon: icon,)
          ),
          const SizedBox(width: 10),
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF5DA9E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              valor,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _blocoTexto(String titulo, String valor, Color cor, {bool vertical = false, IconData? icone,Color? IconColor,}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone (se fornecido)
          if (icone != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                icone,
                size: 32, // Tamanho proporcional
                color: IconColor ?? Colors.white.withOpacity(0.9),
              ),
            ),

          // Conteúdo de texto (título e valor)
          vertical
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20,
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
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Adicionado para uma fonte mais elegante
import 'package:psycostatattoo/widgets/texto.dart'; // Mantive seu import

class IndicatorsDashboard extends StatelessWidget {
  const IndicatorsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fundo cinza claro
      appBar: AppBar(
        title: Text("Dashboard de Indicadores Educacionais", style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600), // Largura máxima para desktop
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === COLUNA DA ESQUERDA (Seu código, com leves ajustes de estilo) ===
                Expanded(
                  flex: 3, // Ocupa 3/5 do espaço
                  child: _buildIndicadoresColumn(),
                ),

                const SizedBox(width: 24), // Espaçador entre as colunas

                // === COLUNA DA DIREITA (Nova, baseada na imagem) ===
                Expanded(
                  flex: 2, // Ocupa 2/5 do espaço
                  child: _buildResultadosColumn(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Coluna de Indicadores (seu código organizado)
  Widget _buildIndicadoresColumn() {
    return Column(
      children: [
        _indicadorBox(
          titulo: "Indicador de Ensino",
          peso: 0.5,
          linhas: [
            _linhaIndicador("IDEB 2021", "6,2", Icons.trending_up),
            _linhaIndicador("IDEB 2023", "6,8", Icons.trending_up),
          ],
          meta: "6,6",
          atingimento: "1,0",
          descricaoAtingimento: "Atingimento da Meta do IDEB",
          atingimentoIcon: Icons.check_circle_outline,
          atingimentoIconColor: Colors.green.shade700,
        ),
        const SizedBox(height: 24),
        _indicadorBox(
          titulo: "Indicador de Alfabetização",
          peso: 0.3,
          linhas: [
            _linhaIndicador("SAEB 2021", "6,5", Icons.spellcheck),
            _linhaIndicador("SAEB 2023", "6,9", Icons.spellcheck),
          ],
          meta: "6,7",
          atingimento: "1,02",
          descricaoAtingimento: "Atingimento da Meta do SAEB",
          atingimentoIcon: Icons.check_circle_outline,
          atingimentoIconColor: Colors.green.shade700,
        ),
        const SizedBox(height: 24),
        _indicadorBox(
          titulo: "Educação Integral",
          peso: 0.1,
          linhas: [
            _linhaIndicador("Integral Censo 2022", "730", Icons.groups),
            _linhaIndicador("Integral Censo 2023", "1.040", Icons.groups),
            _linhaIndicador("Total Matrículas 2022", "14.444", Icons.person),
            _linhaIndicador("Total Matrículas 2023", "14.701", Icons.person),
            _linhaIndicador("Percentual 2021", "5%", Icons.percent),
            _linhaIndicador("Percentual 2022", "7%", Icons.percent),
          ],
          meta: "14,1%",
          atingimento: "0,5",
          descricaoAtingimento: "Atingimento da Meta da Ed. Integral",
          atingimentoIcon: Icons.warning_amber_rounded,
          atingimentoIconColor: Colors.orange.shade800,
        ),
        const SizedBox(height: 24),
        _indicadorBox(
          titulo: "Indicador Socioeconômico",
          peso: 0.1,
          linhas: [
            _linhaIndicador("INSE 2021", "5,4", Icons.real_estate_agent),
          ],
          meta: "5,2",
          atingimento: "1,0",
          descricaoAtingimento: "Atingimento da Meta do INSE",
          atingimentoIcon: Icons.check_circle_outline,
          atingimentoIconColor: Colors.green.shade700,
        ),
      ],
    );
  }

  /// Coluna de Resultados (nova)
  Widget _buildResultadosColumn() {
    return Column(
      children: [
        _buildResultBox(
          title: "INDICADORES * MATRÍCULAS\nDESTE MUNICÍPIO",
          subtitle: "(IDEB *0,5 + ALFAB. *0,3 + INTEGRAL *0,1 + FATOR SOCIAL *0,1)",
          value: "14.201,17",
          color: const Color(0xFFE6F4EA), // Verde claro
          borderColor: const Color(0xFFB7E4C7),
          valueColor: Colors.black87,
        ),
        _buildConnector("(DIVIDE)"),
        _buildResultBox(
          title: "SOMA (INDICADORES * MATRÍCULAS) DE TODOS OS MUNICIPIOS DO ESTADO",
          value: "1.053.736,28",
          color: const Color(0xFFE3F2FD), // Azul claro
          borderColor: const Color(0xFF90CAF9),
          valueColor: Colors.black87,
        ),
        _buildConnector("(RESULTADO)"),
        _buildResultBox(
          title: "Índice de Qualidade da Educação do Paraná (IQEP) DESTE MUNICÍPIO",
          value: "0,01347696406159",
          color: const Color(0xFFE6F4EA),
          borderColor: const Color(0xFFB7E4C7),
          valueColor: Colors.black87,
        ),
        _buildConnector("(MULTIPLICA)"),
        _buildResultBox(
          title: "PREVISÃO RECURSO PARA DISTRIBUIÇÃO",
          value: "1.271.621.000,00",
          color: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
          valueColor: Colors.black87,
        ),
        _buildConnector("(RESULTADO)"),
        _buildResultBox(
          title: "PREVISÃO DE VALOR PARA\nESTE MUNICÍPIO",
          value: "R\$ 17.137.590,52",
          color: const Color(0xFF388E3C), // Verde escuro
          borderColor: const Color(0xFF2E7D32),
          valueColor: Colors.white,
          titleColor: Colors.white,
        ),
        const SizedBox(height: 16),
        _buildResultBox(
          title: "PER CAPITA",
          value: "R\$ 1.165,74",
          color: const Color(0xFF4CAF50), // Verde médio
          borderColor: const Color(0xFF388E3C),
          valueColor: Colors.white,
          titleColor: Colors.white,
        ),
      ],
    );
  }

  // Seus widgets helper com estilo aprimorado
  Widget _indicadorBox({
    required String titulo,
    required double peso,
    required List<Widget> linhas,
    required String meta,
    required String atingimento,
    required String descricaoAtingimento,
    required IconData atingimentoIcon,
    required Color atingimentoIconColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text("$titulo (Peso $peso)", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(children: linhas)),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _blocoMeta(meta),
                      const SizedBox(height: 16),
                      _blocoAtingimento(descricaoAtingimento, atingimento, atingimentoIcon, atingimentoIconColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaIndicador(String label, String valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _blocoMeta(String valor) {
    return Column(
      children: [
        const Text("META", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
          child: Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _blocoAtingimento(String descricao, String valor, IconData icon, Color iconColor) {
    return Column(
      children: [
        Text(descricao, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // Helpers para a coluna da direita
  Widget _buildResultBox({
    required String title,
    String? subtitle,
    required String value,
    required Color color,
    required Color borderColor,
    required Color valueColor,
    Color titleColor = Colors.black87,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor), textAlign: TextAlign.center),
          if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 10, color: titleColor.withOpacity(0.8)), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildConnector(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
    );
  }
}
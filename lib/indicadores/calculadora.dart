/*
import 'package:flutter/material.dart';

// Definindo as cores principais para fácil reutilização e consistência
const Color kDarkHeaderColor = Color(0xFF343A40);
const Color kBlueHeaderColor = Color(0xFF007BFF);
const Color kGreenPillColor = Color(0xFF3CD856); //#3CD856
const Color kLightBluePillColor = Color(0xFF67C8FF);//#67C8FF
const Color kLightGreenPillColor = Color(0xFFE0F2F1);
const Color kDarkGreenTextColor = Color(0xFF00695C);


class IcmsDashboardPage extends StatelessWidget {
  const IcmsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useSingleColumn = constraints.maxWidth < 900;
            return useSingleColumn
                ? Column(
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 24),
                _buildRightColumn(),
              ],
            )
                : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLeftColumn()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRightColumn()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        IndicatorCard(
          title: 'INDICADOR DE ENSINO (Peso 0.5)',
          children: [
            const DataRowWithPill(label: 'IDEB 2021', value: '6,8'),
            const DataRowWithPill(label: 'IDEB 2023', value: '7,5'),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                    imagePath: 'assets/images/meta.png', // Passe o caminho do seu arquivo
                      value: '6,9',
                      label: 'Meta',
                      backgroundColor: Color(0xFFF0F9FC),
                    ),

                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta_ok.png',
                      value: '1,1',
                      label: 'Atingimento da Meta\ndo IDEB',
                      //#F0FFF3
                      backgroundColor: Color(0xFFF0FFF3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        IndicatorCard(
          title: 'INDICADOR DE ALFABETIZAÇÃO (Peso 0,3)',
          children: [
            const DataRowWithPill(label: 'SAEB 2021', value: '6,9'),
            const DataRowWithPill(label: 'SAEB 2023', value: '7,5'),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta.png',
                      value: '7',
                      label: 'Meta',
                      //iconColor: kBlueHeaderColor,
                      backgroundColor: Color(0xFFE3F2FD),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta_ok.png',
                      value: '1,08',
                      label: 'Atingimento da Meta\ndo SAEB',
                    //  iconColor: kGreenPillColor,
                      backgroundColor: Color(0xFFE8F5E9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        IndicatorCard(
          title: 'INDICADORES DE EDUCAÇÃO INTEGRAL (Peso 0.1)',
          children: [
            const DataRowWithPill(label: 'INTEGRAL CENSO 2022', value: '1.011'),
            const DataRowWithPill(label: 'INTEGRAL CENSO 2023', value: '1.259'),
            const DataRowWithPill(label: 'TOTAL DE MATRÍCULAS 2022', value: '4.647'),
            const DataRowWithPill(label: 'TOTAL DE MATRÍCULAS 2023', value: '5.119'),
            const DataRowWithPill(label: '% PERCENTUAL 2021', value: '22%'),
            const DataRowWithPill(label: '% PERCENTUAL 2022', value: '25%'),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta.png',
                      value: '28%',
                      label: 'Meta',
                     // iconColor: kBlueHeaderColor,
                      backgroundColor: Color(0xFFE3F2FD),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta_nao_ok.png',
                      value: '0,9',
                      label: 'Atingimento da\nEducação Integral',
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        IndicatorCard(
          title: 'INDICADOR SOCIOECONÔMICO (Peso 0.1)',
          children: [
            const DataRowWithPill(label: 'INSE 2021', value: '5.4', pillColor: Color(0xFFE9ECEF), valueColor: Colors.black87,),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta.png',
                      value: '5,2',
                      label: 'Meta',
                     // iconColor: kBlueHeaderColor,
                      backgroundColor: Color(0xFFE3F2FD),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      imagePath: 'assets/images/meta_ok.png',
                      value: '1,0',
                      label: 'Atingimento da Meta\ndo INSE',
                      //iconColor: kGreenPillColor,
                      backgroundColor: Color(0xFFE8F5E9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: const [
        CalculationCard(
          title: 'CÁLCULO DO IQEP',
          icon: Icons.calculate_outlined,
          children: [
            CalculationItem(
              title: 'INDICADORES * MATRÍCULAS',
              subtitle: '(IDEB *0,5 + ALFAB. *0,3 +INTEGRAL *0,1 + FATOR SOCIAL *0,1)',
              value: ' 5.390,81',

              pillColor: kGreenPillColor,
            ),
            CalculationItem(
              title: 'SOMA (INDICADORES * MATRÍCULAS) DE TODOS OS MUNICÍPIO DO ESTADO',
              value: '1.053.736,28',
              pillColor: kGreenPillColor,
            ),
            CalculationItem(
              title: 'RESULTADO',
              subtitle: 'Índice de Qualidade da Educação do Paraná (IQEP) - Deste município',
              value: '0,00511542317863',
              pillColor: kLightBluePillColor,
            ),
          ],
        ),
        SizedBox(height: 24),
        CalculationCard(
          title: 'PROJEÇÃO DE RECURSOS',
          icon: Icons.show_chart,
          children: [
            CalculationItem(
              title: 'MULTIPLICA',
              subtitle: 'PREVISÃO RECURSO PARA DISTRIBUIÇÃO',
              value: 'R\$ 1.271.621.000,00',
              pillColor: kGreenPillColor,
            ),
            CalculationItem(
              title: 'RESULTADO',
              subtitle: 'PREVISÃO DE VALOR PARA ESTE MUNICÍPIO',
              value: 'R\$ 6.504.879,54',
              pillColor: kLightBluePillColor,
            ),
            CalculationItem(
              title: 'PER CAPITA',
              subtitle: 'VALOR POR ALUNO',
              value: 'R\$ 1.270,73',
              //#16D03B #16D03B #F0FFF3
              pillColor: Color(0xFFF0FFF3),
              valueColor: Color(0xFF16D03B),
            ),
          ],
        ),
      ],
    );
  }
}

/// WIDGETS DE COMPONENTES REUTILIZÁVEIS

class IndicatorCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const IndicatorCard({Key? key, required this.title, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: kDarkHeaderColor,
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class CalculationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const CalculationCard({Key? key, required this.title, required this.icon, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: kBlueHeaderColor,
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children.map((child) => Padding(padding: const EdgeInsets.only(bottom: 16), child: child)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DataRowWithPill extends StatelessWidget {
  final String label;
  final String value;
  final Color pillColor;
  final Color valueColor;

  const DataRowWithPill({Key? key, required this.label, required this.value, this.pillColor = kLightBluePillColor, this.valueColor = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class SummaryChip extends StatelessWidget {
  // ALTERADO: de IconData para String
  final String imagePath;

  final String value;
  final String label;

  // REMOVIDO: a cor agora vem do próprio asset
  // final Color iconColor;

  final Color backgroundColor;

  // Construtor atualizado
  const SummaryChip({
    Key? key,
    required this.imagePath, // Antigo 'icon'
    required this.value,
    required this.label,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ALTERADO: de Icon para Image.asset
          Image.asset(
            imagePath,
            width: 28,  // Definimos a largura e altura para manter o tamanho
            height: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.2)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CalculationItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final Color pillColor;
  final Color valueColor;

  const CalculationItem({Key? key, required this.title, this.subtitle, required this.value, required this.pillColor, this.valueColor = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kDarkHeaderColor)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

 */

import 'package:flutter/material.dart';

// Definindo as cores principais para fácil reutilização e consistência
const Color kDarkHeaderColor = Color(0xFF343A40); // Cor dos títulos das cards da esquerda
const Color kBlueHeaderColor = Color(0xFF007BFF); // Cor dos títulos das cards da direita
const Color kLightGreenValuePill = Color(0xFFD4EDDA); // Cor para pills de valor verde claro (IQEP, Previsão Recurso)
const Color kLightBlueValuePill = Color(0xFFCCE5FF); // Cor para pills de valor azul claro (Matrículas, INSE)
const Color kLightYellowValuePill = Color(0xFFFFF3CD); // Cor para pills de valor amarelo claro (Metas)
const Color kGreenAccent = Color(0xFF198754); // Verde para textos importantes (ex: PER CAPITA)
const Color kRedAccent = Color(0xFFDC3545); // Vermelho para atingimento não ok
const Color kLightGrayPill = Color(0xFFE9ECEF); // Cinza claro para valores de base

class IcmsDashboardPage extends StatelessWidget {
  const IcmsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useSingleColumn = constraints.maxWidth < 900;
            return useSingleColumn
                ? Column(
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 24),
                _buildRightColumn(),
              ],
            )
                : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLeftColumn()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRightColumn()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        // INDICADOR DE ENSINO (Peso 0,5)
        IndicatorCard(
          title: 'INDICADOR DE ENSINO (Peso 0,5)',
          children: [
            const DataRowWithPill(
                label: 'IDEPR 2023 (Valores por Município da rede)',
                value: '6,8',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'IDEPR 2024 (Valores por Município da rede)',
                value: '6,4',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.flag, // Representando 'Meta'
                      value: '6,9',
                      label: 'META',
                      backgroundColor: kLightYellowValuePill,
                      valueColor: Colors.black87,
                      labelColor: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.check_circle_outline, // Representando 'Atingimento'
                      value: '0,93',
                      label: 'Atingimento da Meta do IDEPR',
                      backgroundColor: kLightGreenValuePill,
                      valueColor: kGreenAccent,
                      labelColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // INDICADOR DE ALFABETIZAÇÃO (Peso 0,3)
        IndicatorCard(
          title: 'INDICADOR DE ALFABETIZAÇÃO (Peso 0,3)',
          children: [
            const DataRowWithPill(
                label: 'NOTA SAEP - 2º ANO\n2023',
                value: '5,64',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'NOTA SAEP - 5º ANO\n2023',
                value: '6,64',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'NOTA SAEP - 2º ANO\n2024',
                value: '5,65',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'NOTA SAEP - 5º ANO\n2024',
                value: '6,71',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.flag,
                      value: '6,4',
                      label: 'META',
                      backgroundColor: kLightYellowValuePill,
                      valueColor: Colors.black87,
                      labelColor: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.check_circle_outline,
                      value: '0,97',
                      label: 'Atingimento da Meta do SAEP',
                      backgroundColor: kLightGreenValuePill,
                      valueColor: kGreenAccent,
                      labelColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // INDICADORES DE EDUCAÇÃO INTEGRAL (Peso 0.1)
        IndicatorCard(
          title: 'Indicadores de Educação Integral (Peso 0.1)',
          children: [
            const DataRowWithPill(
                label: 'Matrículas Integral\nCenso 2023',
                value: '1.886',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'Matrículas Integral\nCenso 2024',
                value: '2.097',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'Total Matrículas\nCenso 2023',
                value: '8.102',
                pillColor: kLightBlueValuePill,
                valueColor: Colors.black87),
            const DataRowWithPill(
                label: 'Total Matrículas\nCenso 2024',
                value: '8.263',
                pillColor: kLightBlueValuePill,
                valueColor: Colors.black87),
            const DataRowWithPill(
                label: 'Percentual 2023',
                value: '23,0%',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            const DataRowWithPill(
                label: 'Percentual 2024',
                value: '25,4%',
                pillColor: kLightGreenValuePill,
                valueColor: kGreenAccent),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.flag,
                      value: '28,8%',
                      label: 'META',
                      backgroundColor: kLightYellowValuePill,
                      valueColor: Colors.black87,
                      labelColor: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.cancel_outlined, // Ícone para atingimento não ok
                      value: '0,88',
                      label: 'Atingimento da Meta da Educação Integral',
                      backgroundColor: Colors.red, // Um vermelho claro para indicar não atingido
                      valueColor: Colors.white, // Cor do texto vermelho forte
                      labelColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 24),

        // INDICADOR SOCIOECONÔMICO (Peso 0.1)
        IndicatorCard(
          title: 'Indicador Socioeconômico (Peso 0.1)',
          children: [
            const DataRowWithPill(
                label: 'INSE 2021',
                value: '5,4',
                pillColor: kLightGrayPill,
                valueColor: Colors.black87),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: const [
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.flag,
                      value: '5,2',
                      label: 'META',
                      backgroundColor: kLightYellowValuePill,
                      valueColor: Colors.black87,
                      labelColor: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.check_circle_outline,
                      value: '1,00',
                      label: 'Atingimento da Meta\nINSE',
                      backgroundColor: kLightGreenValuePill,
                      valueColor: kGreenAccent,
                      labelColor: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: const [
        // Card de cálculo do IQEP (parte superior da direita)
        CalculationCard(
          title: 'Índice de Qualidade da Educação do\nParaná (IQEP) DESTE MUNICÍPIO',
          // Icone não presente na imagem, mantendo para consistência do componente
          icon: Icons.star_border,
          children: [
            CalculationItem(
              title: 'INDICADORES * MATRÍCULAS',
              subtitle:
              '(IDEB *0,5 + ALFAB. *0,3 + INTEGRAL *0,1 + FATOR SOCIAL *0,1)',
              value: '7800,27',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
            CalculationItem(
              title: 'Índice de Qualidade da Educação do\nParaná (IQEP) DESTE MUNICÍPIO',
              value: '0,00765531725672',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
            CalculationItem(
              title: 'SOMA (INDICADORES * MATRÍCULAS) DE\nTODOS OS MUNICÍPIO DO ESTADO',
              value: '1018934,91',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
            CalculationItem(
              title: 'RESULTADO',
              value: '0,00765531725672',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
          ],
        ),
        SizedBox(height: 24),
        // Card de projeção de recursos (parte inferior da direita)
        CalculationCard(
          title: 'PREVISÃO RECURSO PARA\nDISTRIBUIÇÃO',
          // Icone não presente na imagem, mantendo para consistência do componente
          icon: Icons.monetization_on_outlined,
          children: [
            CalculationItem(
              title: 'PREVISÃO RECURSO PARA\nDISTRIBUIÇÃO',
              value: 'R\$ 1.462.977.175,00',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
            CalculationItem(
              title: 'PREVISÃO DE VALOR PARA\nESTE MUNICÍPIO',
              value: 'R\$ 11.199.554,41',
              pillColor: kLightGreenValuePill,
              valueColor: kGreenAccent,
              titleColor: Colors.black87,
            ),
            CalculationItem(
              title: 'PER CAPITA',
              value: 'R\$ 1.355,39',
              pillColor: kLightGreenValuePill, // Ou outra cor, se preferir
              valueColor: kGreenAccent, // Texto verde mais escuro para destaque
              titleColor: Colors.black87,
            ),
          ],
        ),
      ],
    );
  }
}

/// WIDGETS DE COMPONENTES REUTILIZÁVEIS

class IndicatorCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const IndicatorCard({Key? key, required this.title, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: kDarkHeaderColor,
            child: Text(title,
                textAlign: TextAlign.center, // Centraliza o texto do título
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class CalculationCard extends StatelessWidget {
  final String title;
  final IconData icon; // Mantido, mas pode ser removido se não for usado visualmente
  final List<Widget> children;

  const CalculationCard(
      {Key? key, required this.title, required this.icon, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: kBlueHeaderColor,
            child: Text(title,
                textAlign: TextAlign.center, // Centraliza o texto do título
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children
                  .map((child) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: child))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DataRowWithPill extends StatelessWidget {
  final String label;
  final String value;
  final Color pillColor;
  final Color valueColor;

  const DataRowWithPill(
      {Key? key,
        required this.label,
        required this.value,
        this.pillColor = kLightBlueValuePill,
        this.valueColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha o topo se o label for multilinhas
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class SummaryChip extends StatelessWidget {
  // Alterado para IconData pois na imagem são ícones simples
  final IconData icon;
  final String value;
  final String label;
  final Color backgroundColor;
  final Color valueColor;
  final Color labelColor;

  const SummaryChip({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.backgroundColor,
    this.valueColor = Colors.black87,
    this.labelColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: valueColor, // Usa a cor do valor para o ícone
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: valueColor)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: labelColor, fontSize: 11, height: 1.2)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CalculationItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final Color pillColor;
  final Color valueColor;
  final Color titleColor; // Cor para o título do item

  const CalculationItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.pillColor,
    this.valueColor = Colors.white,
    this.titleColor = Colors.black54, // Padrão cinza escuro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: titleColor)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
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
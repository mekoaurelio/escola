import 'package:flutter/material.dart';

class EducationalReceiptsPage extends StatelessWidget {
  const EducationalReceiptsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo cinza claro para a página inteira
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- CARD 1: TOTAL DE RECEITAS ---
              const TotalReceiptsCard(
                year: 2025,
                totalAmount: 'R\$ 83.553.718,93',
              ),
              const SizedBox(height: 24),

              // --- CARD 2: FONTES DE FINANCIAMENTO BÁSICA ---
              TitledTableCard(
                title: 'FONTES DE FINANCIAMENTO DA EDUCAÇÃO BÁSICA',
                imagePath: 'assets/images/dollar_up.png',
                data: const [
                  {'label': 'FUNDEB', 'value': 'R\$ 8.967.707,50'},
                  {'label': '103 - 5% de Transferência', 'value': 'R\$ 539.055,08', 'isSubItem': true},
                  {'label': '104 - 25% de Transferência', 'value': 'R\$ 3.933.095,94', 'isSubItem': true},
                  {'label': 'TOTAL', 'value': 'R\$ 83.553.718,93', 'isTotal': true},
                ],
              ),
              const SizedBox(height: 24),

              // --- CARD 3: FONTES ADICIONAIS ---
              TitledTableCard(
                title: 'FONTES ADICIONAIS PARA FINANCIAMENTO DA EDUCAÇÃO',
                imagePath: 'assets/images/dollar_up.png',
                data: const [
                  {'label': 'SALÁRIO-EDUCAÇÃO', 'value': 'R\$ 23.090.209,66'},
                  {'label': 'PNAE', 'value': 'R\$ 8.967.707,50'},
                  {'label': 'PNATE', 'value': 'R\$ 539.055,08'},
                  {'label': 'PETE', 'value': 'R\$ 3.933.095,94'},
                  {'label': 'PDDE', 'value': 'R\$ 1.900.000,00'},
                  {'label': 'PROGRAMA ESCOLA EM TEMPO INTEGRAL (1.385 alunos pactuados)', 'value': 'R\$ 3.928.317,05'},
                  {'label': 'NOVO PAC', 'value': 'R\$ 5.945.400,98'},
                  {'label': 'PACTO NACIONAL DE RETOMADA', 'value': 'R\$ 13.373.932,72'},
                  {'label': 'TRANSFERÊNCIA DE CONVÊNIOS', 'value': 'R\$ 7.123.000,00'},
                  {'label': 'OUTRAS RECEITAS', 'value': 'R\$ 14.753.000,00'},
                  {'label': 'TOTAL', 'value': 'R\$ 83.553.718,93', 'isTotal': true},
                ],
              ),
              const SizedBox(height: 24),

              // --- CARD 4: ATENDIMENTO DA REDE PÚBLICA ---
              TitledTableCard(
                title: 'ATENDIMENTO DA REDE PÚBLICA MUNICIPAL',
                imagePath: 'assets/images/dollar_up.png',
                data: const [
                  {'label': 'CRECHE PÚBLICA INTEGRAL', 'value': '2.350'},
                  {'label': 'CRECHE PÚBLICA PARCIAL', 'value': '0'},
                  {'label': 'CRECHE CONVENIADA INTEGRAL', 'value': '5.653'},
                  {'label': 'PRÉ-ESCOLA PÚBLICA INTEGRAL', 'value': '714'},
                  {'label': 'PRÉ-ESCOLA PÚBLICA PARCIAL', 'value': '7.811'},
                  {'label': 'PRÉ-ESCOLA CONVENIADA INTEGRAL', 'value': '422'},
                  {'label': 'PRÉ-ESCOLA CONVENIADA PARCIAL', 'value': '494'},
                  {'label': 'ENSINO FUNDAMENTAL PÚBLICO INICIAL', 'value': '25.397'},
                  {'label': 'ENSINO FUNDAMENTAL PÚBLICO INTEGRAL', 'value': '1.260'},
                  {'label': 'EJA PRESENCIAL', 'value': '486'},
                  {'label': 'EDUCAÇÃO ESPECIAL', 'value': '2.673'},
                  {'label': 'EDUCAÇÃO ESPECIAL - AEE', 'value': '1.136'},
                  {'label': 'TOTAL', 'value': '48.396', 'isTotal': true},
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA OS CARDS COM TABELAS
class TitledTableCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Map<String, dynamic>> data;

  const TitledTableCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Cabeçalho escuro do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF343A40), // Cor cinza escuro
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 28,  // Definimos a largura e altura para manter o tamanho
                  height: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Corpo do card com as linhas de dados
          Column(
            children: data.map((item) {
              return TableDataRow(
                label: item['label']!,
                value: item['value']!,
                isTotal: item['isTotal'] ?? false,
                isSubItem: item['isSubItem'] ?? false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA CADA LINHA DA TABELA
class TableDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isSubItem;

  const TableDataRow({
    Key? key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isSubItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo de texto padrão
    TextStyle labelStyle = TextStyle(
      fontSize: 13,
      color: const Color(0xFF565656),
    );
    TextStyle valueStyle = TextStyle(
      fontSize: 13,
      color: const Color(0xFF333333),
      fontWeight: FontWeight.w500,
    );

    // Se for a linha de total, aplica negrito e muda a cor do texto
    if (isTotal) {
      labelStyle = labelStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFFFFFFF));
      valueStyle = valueStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFFFFFFF));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        isSubItem ? 32 : 16, // Adiciona indentação se for um sub-item
        12,
        16,
        12,
      ),
      decoration: BoxDecoration(//#  0xFF67C8FF COR/AUXILIAR 02
        color: isTotal ? const Color(0xFF67C8FF) : Colors.white, // Fundo azul claro para total
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3, // Dá mais espaço para o rótulo
            child: Text(label, style: labelStyle),
          ),
          Expanded(
            flex: 2, // Dá espaço para o valor
            child: Text(value, style: valueStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// WIDGET ESPECÍFICO PARA O PRIMEIRO CARD (TOTAL DE RECEITAS)
class TotalReceiptsCard extends StatelessWidget {
  final int year;
  final String totalAmount;

  const TotalReceiptsCard({
    Key? key,
    required this.year,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Cabeçalho azul do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'RECEITAS EDUCACIONAIS - $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Corpo branco do card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text(
                  'TOTAL DE RECEITAS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalAmount,
                  style: const TextStyle(
                    color: Color(0xFF28a745), // Cor verde
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
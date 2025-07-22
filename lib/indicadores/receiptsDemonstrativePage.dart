import 'package:flutter/material.dart';

// Define os tipos de ícones que uma linha pode ter
enum RowIconType { none, dollar, emptyCircle }

class ReceiptsDemonstrativePage extends StatelessWidget {
  const ReceiptsDemonstrativePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- CARD 1: INFORMAÇÕES DO MUNICÍPIO ---
            InfoCard(
              title: 'INFORMAÇÕES DO MUNICÍPIO',
              icon: Icons.description,
              headerColor: const Color(0xFFEDCB06), // Amarelo
              children: const [
                DataRowItem(
                  label: 'POPULAÇÃO ESTIMADA 2022 (IBGE)',
                  value: '150.024',
                ),
                DataRowItem(
                  label: 'DADOS DO EXERCÍCIO DE 2025',
                  value: '2º BIMESTRE',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- CARD 2: RECEITAS MUNICIPAIS ---
            InfoCard(
              title: 'RECEITAS MUNICIPAIS',
              icon: Icons.attach_money,//#3CD856
              headerColor: const Color(0xFF3CD856), // Verde
              children: const [
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receita de Impostos',
                  value: 'R\$ 83.029.413,57',
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receitas de Transferências',
                  value: 'R\$ 171.356.979,58',
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'TOTAL RECEITA',
                  value: 'R\$ 254.386.393,15',
                  isHighlighted: true,
                ),
                DataRowItem(
                  iconType: RowIconType.emptyCircle,
                  label: 'Transferências FNDE',
                  value: 'R\$ 5.585.913,04',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- CARD 3: FUNDEB E REMUNERAÇÃO ---
            InfoCard(
              title: 'FUNDEB E REMUNERAÇÃO',
              icon: Icons.account_balance,//#0077FF
              headerColor: const Color(0xFF0077FF), // Azul
              children: const [
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '10. Receitas Destinadas ao FUNDEB',
                  value: 'R\$ 83.029.413,57',
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '10. Receitas Recebidas do FUNDEB',
                  value: 'R\$ 171.356.979,58',
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '13. Pagamento dos professores do Magistério (70%)',
                  value: 'R\$ 34.549.863,34',
                  isAlert: true,
                ),
                DataRowItem(
                  iconType: RowIconType.emptyCircle,
                  label: 'Ganho/Perda',
                  value: 'R\$ 171.356.979,58',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- CARD 4: INVESTIMENTO EM EDUCAÇÃO ---
            InfoCard(
              title: 'INVESTIMENTO EM EDUCAÇÃO',
              icon: Icons.school,//#FF7228
              headerColor: const Color(0xFFFF7228), // Laranja
              children: const [
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 25% (1.104)', value: 'R\$ 83.029.413,57'),
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 5% (1.103)', value: 'R\$ 171.356.979,58'),
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 1000 (Livre)', value: 'R\$ 34.549.863,34'),
                DataRowItem(iconType: RowIconType.emptyCircle, label: '19.1. Mínimo 70%', value: 'R\$ 171.356.979,58'),
                DataRowItem(label: '38. PERCENTUAL DE APLICAÇÃO MDE', value: '80,54%', isHighlighted: true),
                DataRowItem(label: 'TOTAL DE INVESTIMENTO EM EDUCAÇÃO', value: 'R\$ 66.318.427,81', value2: '20,26%', isHighlighted: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA OS CARDS PRINCIPAIS
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final List<Widget> children;

  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cabeçalho colorido
          Container(
            color: headerColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
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
          // Corpo branco com as linhas de dados
          ...children,
        ],
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA CADA LINHA DE DADOS
class DataRowItem extends StatelessWidget {
  final String label;
  final String? value;
  final String? value2; // Para a linha com 3 colunas
  final RowIconType iconType;
  final bool isHighlighted;
  final bool isAlert;

  const DataRowItem({
    Key? key,
    required this.label,
    this.value,
    this.value2,
    this.iconType = RowIconType.none,
    this.isHighlighted = false,
    this.isAlert = false,
  }) : super(key: key);

  Widget _buildIcon() {
    Widget iconWidget;
    switch (iconType) {
      case RowIconType.dollar:
        iconWidget = Container(
          width: 18,
          height: 18,
          child: Image.asset('assets/images/dolar.png',color: isAlert ? Colors.red : Colors.grey.shade800,)
        );
        break;
      case RowIconType.emptyCircle:
        iconWidget = Icon(Icons.radio_button_unchecked, size: 18, color: Colors.grey[400]);
        break;
      case RowIconType.none:
      default:
        iconWidget = const SizedBox(width: 18); // Mantém o alinhamento
    }
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: iconWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color labelColor = isAlert ? Colors.red : Colors.grey.shade700;
    Color valueColor = isAlert ? Colors.red : Colors.grey.shade800;
    FontWeight labelWeight = FontWeight.normal;
    FontWeight valueWeight = FontWeight.w500;

    if (isHighlighted) {//67C8FF
      backgroundColor = const Color(0xFF67C8FF);
      labelColor = Colors.white;
      //#67C8FF
      valueColor = Colors.white;
      labelWeight = FontWeight.bold;
      valueWeight = FontWeight.bold;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      child: Row(
        children: [
          _buildIcon(),
          ///descrição
          Expanded(
            flex: 5, // Mais espaço para o label
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: labelColor,
                fontWeight: labelWeight,
              ),
            ),
          ),

          ///VALOR
          if (value2 != null) // Lógica para a linha de 3 colunas
            Expanded(
              flex: 2,
              child: Text(value2!,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: valueColor, fontWeight: valueWeight),
              ),
            ),
          if (value != null)
            Expanded(
              flex: 3,
              child: Text(value!,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
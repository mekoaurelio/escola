import 'package:flutter/material.dart';

import '../widgets/texto.dart';

class ReceitasEducacionais2025 extends StatelessWidget {
  const ReceitasEducacionais2025({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width *0.44,
                child:Column(
                  children: [
                    _buildRevenueSummaryCard(),
                    const SizedBox(height: 16),
                    _buildFonteFinanciamentoCard(),
                    const SizedBox(height: 10),
                    _buildRevenueSourcesCard(),
                    const SizedBox(height: 16),
                    _buildNivelDeEnsinoCard(),
                  ],
                ),
              )
          )
      ),
    );
  }

  Widget _buildRevenueSummaryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFF1F3C88)),
                SizedBox(width: 8),
                Text(
                  "RECEITAS EDUCACIONAIS - 2025",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "TOTAL DE RECEITAS",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "R\$ 83.553.718,93",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSourcesCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF1F3C88)),
                SizedBox(width: 8),
                Text(
                  "Fontes Adicionais para Financiamento da Educação",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              children: [
                _buildTableRow(
                    "Fonte",
                    "Receita (R\$)",
                    isHeader: true
                ),
                _buildTableRow("Salário-Educação", "23.090.209,66",),
                _buildTableRow("PNAE", "8.967.707,50"),
                _buildTableRow("PNATE", "539.055,08"),
                _buildTableRow("PETE", "3.933.095,94"),
                _buildTableRow("PDDE", "1.900.000,00"),
                _buildTableRow(
                    "Programa Escola em Tempo Integral",
                    "3.928.317,05",
                    note: "1.385 alunos pactuados"
                ),
                _buildTableRow("Novo PAC", "5.945.400,98"),
                _buildTableRow(
                    "Pacto Nacional de Retomada",
                    "13.373.932,72"
                ),
                _buildTableRow("Transferência de Convênios", "7.123.000,00"),
                _buildTableRow(
                    "Outras receitas",
                    "14.753.000,00"
                ),
                _buildTableRow(
                    "TOTAL",
                    "83.553.718,93",
                    isTotal: true
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelDeEnsinoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF1F3C88)),
                SizedBox(width: 8),
                Text(
                  "Atendimento da Rede Pública Municipal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              children: [
                _buildTableRow("Nível de Ensino", "Nº de Alunos", isHeader: true),
                _buildTableRow("Creche Pública Integral", "2.350"),
                _buildTableRow("Creche Pública Parcial", "0"),
                _buildTableRow("Creche Conveniada Integral", "5.653"),
                _buildTableRow("Pré-Escola Pública Integral", "714"),
                _buildTableRow("Pré-Escola Pública Parcial", "7.811"),
                _buildTableRow("Pré-Escola Conveniada Integral", "422"),
                _buildTableRow("Pré-Escola Conveniada Parcial", "494",),
                _buildTableRow("Ensino Fundamental Público Inicial", "25.397"),
                _buildTableRow("Ensino Fundamental Público Integral", "1.260"),
                _buildTableRow("EJA Presencial", "486"),
                _buildTableRow("Educação Especial", "2.673"),
                _buildTableRow("Educação Especial - AEE", "1.136"),
                _buildTableRow("TOTAL", "48.396",
                    isTotal: true
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFonteFinanciamentoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF1F3C88)),
                SizedBox(width: 8),
                Text(
                  "Fontes de Financiamento da Educação Básica",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3C88),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              children: [
                _buildTableRow("Fonte",'Receita (R\$)', isHeader: true),
                _buildTableRow("FUNDEB", "8.967.707,50"),
                _buildTableRow("103 - 5% de Transferência", "539.055,08"),
                _buildTableRow("104 - 25% de Transferência", "3.933.095,94"),
                _buildTableRow("TOTAL", "83.553.718,93",
                    isTotal: true
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String source, String value, {
    bool isHeader = false,
    bool isTotal = false,
    String? note,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: isTotal ? Colors.blue.shade300 : Colors.transparent,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Texto(tit: source,tam:isHeader ? 14 : 13 ,fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
                cor: isHeader ? const Color(0xFF1F3C88) : Colors.black87,left: 5,
              ),
              ///Se tiver uma nota
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  note,
                  style:  TextStyle(
                    fontSize: isHeader ? 14 : 13,
                    color: isHeader ? const Color(0xFF1F3C88) : Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ]
            ],
          ),
        ),
        ///Valores
        Align(
          alignment: Alignment.centerRight,
          child:Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Texto(tit: "$value",alin:TextAlign.end ,tam:isTotal ? 16 : 14 ,
              fontWeight:isTotal ? FontWeight.bold : isHeader || isTotal ? FontWeight.bold : FontWeight.normal ,
              cor: isTotal ? Colors.blue : isHeader ? const Color(0xFF1F3C88) : Colors.black87,
            ),
          ),
        )

      ],
    );
  }
}
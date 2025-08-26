import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dadosFinanceiros.dart';


class FinancialDetailsTable extends StatelessWidget {
  final DadosFinanceiros dados;

  const FinancialDetailsTable({Key? key, required this.dados}) : super(key: key);

  // Helper para formatar os valores monetários
  String _formatCurrency(double value) {
    // Usando NumberFormat para um controle preciso, sem o símbolo de R$
    final formatter = NumberFormat("#,##0.00", "pt_BR");
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    // ---- Cálculo dos Totais e Variações ----
    final totalAtual = dados.vencimentoAtual + dados.adicionalAtual + dados.vantagensAtual + dados.encargosAtual;
    final totalProposta = dados.vencimentoProposta + dados.adicionalProposta + dados.vantagensProposta + dados.encargosProposta;
    final totalVariacao = totalProposta - totalAtual;

    final variacaoVencimento = dados.vencimentoProposta - dados.vencimentoAtual;
    final variacaoAdicional = dados.adicionalProposta - dados.adicionalAtual;
    final variacaoVantagens = dados.vantagensProposta - dados.vantagensAtual;
    final variacaoEncargos = dados.encargosProposta - dados.encargosAtual;

    // ---- Estilos para reutilização ----
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54);
    const cellStyle = TextStyle(fontSize: 15, color: Colors.black87);
    const totalLabelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF));
    const totalValueStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF007BFF));

    return Table(
      // Define as larguras relativas das colunas
      columnWidths: const {
        0: FlexColumnWidth(2.5), // Vantagens
        1: FlexColumnWidth(1.5), // Atual
        2: FlexColumnWidth(1.5), // Proposta
        3: FlexColumnWidth(1.5), // Variação
      },
      // Define a borda para todas as células da tabela
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      children: [
        // ---- Linha do Cabeçalho ----
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            _buildTableCell('Vantagens', style: headerStyle, isHeader: true),
            _buildTableCell('Atual', style: headerStyle, isHeader: true),
            _buildTableCell('Proposta', style: headerStyle, isHeader: true),
            _buildTableCell('Variação', style: headerStyle, isHeader: true),
          ],
        ),

        // ---- Linhas de Dados ----
        _buildDataRow('Vencimento Básico', dados.vencimentoAtual, dados.vencimentoProposta, variacaoVencimento),
        _buildDataRow('Adicional Tempo Serviço', dados.adicionalAtual, dados.adicionalProposta, variacaoAdicional),
        _buildDataRow('Vantagens Pecuniárias', dados.vantagensAtual, dados.vantagensProposta, variacaoVantagens),
        _buildDataRow('Encargos Sociais (14%)', dados.encargosAtual, dados.encargosProposta, variacaoEncargos),

        // ---- Linha de Total ----
        TableRow(
          children: [
            _buildTableCell('TOTAL REMUNERAÇÃO', style: totalLabelStyle, alignment: TextAlign.left),
            _buildTableCell(_formatCurrency(totalAtual), style: totalValueStyle),
            _buildTableCell(_formatCurrency(totalProposta), style: totalValueStyle),
            _buildTableCell(_formatCurrency(totalVariacao), style: totalValueStyle),
          ],
        ),
      ],
    );
  }

  /// Helper para criar uma linha de dados completa.
  TableRow _buildDataRow(String label, double atual, double proposta, double variacao) {
    const cellStyle = TextStyle(fontSize: 15, color: Colors.black87);
    return TableRow(
      children: [
        _buildTableCell(label, style: cellStyle, alignment: TextAlign.left),
        _buildTableCell(_formatCurrency(atual), style: cellStyle),
        _buildTableCell(_formatCurrency(proposta), style: cellStyle),
        _buildTableCell(_formatCurrency(variacao), style: cellStyle),
      ],
    );
  }

  /// Helper para criar uma célula da tabela, facilitando a customização.
  Widget _buildTableCell(String text, {required TextStyle style, TextAlign alignment = TextAlign.right, bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Text(
        text,
        style: style,
        textAlign: isHeader ? TextAlign.left : alignment,
      ),
    );
  }
}
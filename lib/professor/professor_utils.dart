import 'package:flutter/material.dart';

class ProfessorUtils {

  static const Color _primaryColor = Color(0xFF1976D2);
  static const Color _secondaryColor = Color(0xFF42A5F5);
  static const Color _accentColor = Color(0xFFFF9800);
  static const Color _backgroundColor = Color(0xFFFAFAFA);
  static const Color _textColor = Color(0xFF212121);
  static const Color _borderColor = Color(0xFFE0E0E0);
  /*
  static Widget buildSummaryCards(BuildContext context, int cargaHoraria,double _percEntreColunas) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Primeira linha de itens
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(context,
                        'Carga Horária',
                        '$cargaHoraria horas',
                        Icons.access_time,
                        onTap: () => _editWorkingHours(),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(context,
                        'Progressão',
                        '${_percEntreColunas.toStringAsFixed(2)}%',
                        Icons.trending_up,
                        onTap: () => _editProgression(context,),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            // Segunda linha de itens
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Dispersão Horizontal',
                        '$_dispersaoHorizontal%',
                        Icons.compare_arrows,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Dispersão Total',
                        '$_dispersaoTotal%',
                        Icons.bar_chart,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: _primaryColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _editProgression(BuildContext context) {
    Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: 'Editar Progressão',
      labelCampo: 'Percentual',
      valorInicial: _editProgression.toString(),
      aoSalvar: (novoValor) {
        setState(() {
          _percEntreColunas = double.tryParse(novoValor)!;
          _calculateTableAndDispersions();
        });
      },
    );
  }

  void _calculateTableAndDispersions() {
    List<List<double>> tempTable = [];
    double primeiroValorTabela = 0; // Primeira coluna da primeira linha (NB, classe 1)
    double ultimaColunaPrimeiraLinha = 0; // Última coluna da primeira linha (NB, última classe)
    double ultimaColunaUltimaLinha = 0; // Última coluna da última linha (NE, última classe)

    for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++) {
      List<double> rowValues = [];
      double vrAnteriorDaLinha = 0;

      // Define o valor inicial da linha com base no nível
      if (nivelIndex == 0) vrAnteriorDaLinha = valorBase; //3
      if (nivelIndex == 1) vrAnteriorDaLinha = penA; //tava 0
      if (nivelIndex == 2) vrAnteriorDaLinha = penB; //1
      if (nivelIndex == 3) vrAnteriorDaLinha = penC; //2
      if (nivelIndex == 4) vrAnteriorDaLinha = penD; //3
      if (nivelIndex == 5) vrAnteriorDaLinha = penE; //3

      for (int coluna = 1; coluna <= cargaHoraria; coluna++) {
        double valorAtual;
        if (coluna == 1) {
          valorAtual = vrAnteriorDaLinha;
          // Captura o primeiro valor da tabela (NB, Classe 1)
          if (nivelIndex == 0) {
            primeiroValorTabela = valorAtual;
          }
        } else {
          double percCalc = _percEntreColunas;
          valorAtual =
              ((vrAnteriorDaLinha * percCalc) / 100) + vrAnteriorDaLinha;
        }

        rowValues.add(valorAtual);
        vrAnteriorDaLinha = valorAtual;

        // Captura a última coluna da primeira linha (NB)
        if (nivelIndex == 0 && coluna == cargaHoraria) {
          ultimaColunaPrimeiraLinha = valorAtual;
        }

        // Captura a última coluna da última linha (NE)
        if (nivelIndex == 4 && coluna == cargaHoraria) {
          ultimaColunaUltimaLinha = valorAtual;
        }
      }
      tempTable.add(rowValues);
    }

    // Cálculo das dispersões conforme especificado
    double calcDispersaoHorizontal = 0;
    double calcDispersaoTotal = 0;

    if (primeiroValorTabela != 0) {
      // Dispersão Horizontal: (última coluna da primeira linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
      calcDispersaoHorizontal =
          ((ultimaColunaPrimeiraLinha - primeiroValorTabela) /
              primeiroValorTabela) * 100;

      // Dispersão Total: (última coluna da última linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
      // print('primeiroValorTabela : $primeiroValorTabela ultimaColunaUltimaLinha : $ultimaColunaUltimaLinha');
      calcDispersaoTotal = ((ultimaColunaUltimaLinha - primeiroValorTabela) /
          primeiroValorTabela) * 100;
    }

    setState(() {
      _calculatedTableValues = tempTable;
      _dispersaoHorizontal = calcDispersaoHorizontal.toStringAsFixed(2);
      _dispersaoTotal = calcDispersaoTotal.toStringAsFixed(2);
    });
  }

   */

  static double totalDeVencimentos(String nivel, int coluna, var professores) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    double total = 0.0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        total += double.tryParse(professor['vencimento'].toString()) ?? 0.0;
      }
    }

    return total;
  }

  // Método auxiliar para calcular o total por nível
  static double calculateTotalForLevel(String nivel,var professores,int cargaHoraria) {
    double total = 0.0;
    for (int coluna = 0; coluna < cargaHoraria; coluna++) {
      total += ProfessorUtils.totalDeVencimentos(nivel, coluna + 1,professores);
      //ProfessorUtils.totalDeVencimentos(niveis[nivelIndex], coluna + 1,professores)),
    }
    return total;
  }
}
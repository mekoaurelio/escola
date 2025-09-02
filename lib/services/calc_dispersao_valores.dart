/*
class TableCalculationResult {
  final List<List<double>> calculatedTableValues;
  final String dispersaoHorizontal;
  final String dispersaoTotal;

  TableCalculationResult({
    required this.calculatedTableValues,
    required this.dispersaoHorizontal,
    required this.dispersaoTotal,
  });
}

TableCalculationResult calculateTableAndDispersions({
  required List<String> niveis,
  required double valorBase,
  required double penA,
  required double penB,
  required double penC,
  required double penD,
  required double penE,
  required int cargaHoraria,
  required double percEntreColunas,
}) {
  List<List<double>> tempTable = [];
  double primeiroValorTabela = 0;
  double ultimaColunaPrimeiraLinha = 0;
  double ultimaColunaUltimaLinha = 0;

  for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++) {
    List<double> rowValues = [];
    double vrAnteriorDaLinha = 0;

    // Define o valor inicial da linha com base no nível
    switch (nivelIndex) {
      case 0: vrAnteriorDaLinha = penB; break;
      case 1: vrAnteriorDaLinha = penC; break;
      case 2: vrAnteriorDaLinha = penD; break;
      case 3: vrAnteriorDaLinha = penE; break;
      case 4: vrAnteriorDaLinha = penE; break;
      default: vrAnteriorDaLinha = 0;
    }

    for (int coluna = 1; coluna <= cargaHoraria; coluna++) {
      double valorAtual;
      if (coluna == 1) {
        valorAtual = vrAnteriorDaLinha;
        if (nivelIndex == 0) {
          primeiroValorTabela = valorAtual;
        }
      } else {
        valorAtual = ((vrAnteriorDaLinha * percEntreColunas) / 100) + vrAnteriorDaLinha;
      }

      rowValues.add(valorAtual);
      vrAnteriorDaLinha = valorAtual;

      if (nivelIndex == 0 && coluna == cargaHoraria) {
        ultimaColunaPrimeiraLinha = valorAtual;
      }

      if (nivelIndex == 4 && coluna == cargaHoraria) {
        ultimaColunaUltimaLinha = valorAtual;
      }
    }
    tempTable.add(rowValues);
  }

  double calcDispersaoHorizontal = 0;
  double calcDispersaoTotal = 0;

  if (primeiroValorTabela != 0) {
    calcDispersaoHorizontal = ((ultimaColunaPrimeiraLinha - primeiroValorTabela) / primeiroValorTabela) * 100;
    calcDispersaoTotal = ((ultimaColunaUltimaLinha - primeiroValorTabela) / primeiroValorTabela) * 100;
  }

  return TableCalculationResult(
    calculatedTableValues: tempTable,
    dispersaoHorizontal: calcDispersaoHorizontal.toStringAsFixed(2),
    dispersaoTotal: calcDispersaoTotal.toStringAsFixed(2),
  );
}

 */

import 'package:intl/intl.dart';

class TableCalculationResult {
  final List<List<double>> calculatedTableValues;
  final String dispersaoHorizontal;
  final String dispersaoTotal;

  TableCalculationResult({
    required this.calculatedTableValues,
    required this.dispersaoHorizontal,
    required this.dispersaoTotal,
  });
}

/// Calcula uma tabela de progressão salarial e as dispersões horizontal e total.
///
/// A função constrói uma tabela onde cada linha representa um nível e cada coluna
/// representa uma progressão (baseada na carga horária).
///
/// Parâmetros:
///   - `niveis`: Uma lista de strings com os nomes dos níveis (ex: ['Nível A', 'Nível B']).
///   - `valoresIniciaisNiveis`: Uma lista de strings contendo o valor base para CADA nível correspondente.
///     Deve ter o mesmo tamanho da lista `niveis`. Ex: ['5000.00', '5500.00'].
///   - `cargaHoraria`: O número de colunas a serem geradas em cada linha da tabela.
///   - `percEntreColunas`: O percentual de acréscimo de uma coluna para a próxima.
///
/// Retorna um objeto [TableCalculationResult] com a tabela calculada e as dispersões.
///
/// Exemplo de uso:
/// ```dart
/// final resultado = calculateTableAndDispersions(
///   niveis: ['Nível B', 'Nível C', 'Nível D', 'Nível E'],
///   valoresIniciaisNiveis: ['3500.50', '3850.55', '4235.60', '4659.16'],
///   cargaHoraria: 15,
///   percEntreColunas: 2.5,
/// );
/// ```
TableCalculationResult calculateTableAndDispersions({
  required List<String> niveis,
  required List<String> valoresIniciaisNiveis,
  required int cargaHoraria,
  required double percEntreColunas,
}) {
  // --- 1. Validação de Entradas ---
  //print(niveis);
  //print(valoresIniciaisNiveis);
  //print(cargaHoraria);
  //print(percEntreColunas);
  if (niveis.length != valoresIniciaisNiveis.length) {
    throw ArgumentError(
        'A lista de níveis (${niveis.length}) e de valores iniciais (${valoresIniciaisNiveis.length}) devem ter o mesmo tamanho.');
  }

  // Se não houver dados de entrada, retorna um resultado vazio.
  if (niveis.isEmpty) {
    return TableCalculationResult(
      calculatedTableValues: [],
      dispersaoHorizontal: '0.00',
      dispersaoTotal: '0.00',
    );
  }

  final List<List<double>> tempTable = [];

  // --- 2. Construção da Tabela (Lógica Principal) ---
  for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++) {
    final List<double> rowValues = [];

    // Pega o valor inicial para esta linha da lista de entrada.
    // Usa tryParse para segurança, retornando 0.0 se a string for inválida.
    final double valorInicialDaLinha = double.tryParse(valoresIniciaisNiveis[nivelIndex]) ?? 0.0;

    for (int colunaIndex = 0; colunaIndex < cargaHoraria; colunaIndex++) {
      double valorAtual;
      if (colunaIndex == 0) {
        // A primeira coluna da linha sempre recebe o valor inicial.
        valorAtual = valorInicialDaLinha;
      } else {
        // As colunas seguintes são calculadas com base no valor anterior na mesma linha.
        final double valorAnterior = rowValues.last;
        valorAtual = valorAnterior + (valorAnterior * percEntreColunas / 100);
      }
      rowValues.add(valorAtual);
    }
    tempTable.add(rowValues);
  }

  // --- 3. Cálculo das Dispersões ---
  double calcDispersaoHorizontal = 0.0;
  double calcDispersaoTotal = 0.0;

  // Garante que a tabela não esteja vazia para evitar erros.
  if (tempTable.isNotEmpty && tempTable.first.isNotEmpty) {
    final double primeiroValorTabela = tempTable.first.first; // Valor da célula [0][0]
    final double ultimaColunaPrimeiraLinha = tempTable.first.last; // Último valor da primeira linha
    final double ultimaColunaUltimaLinha = tempTable.last.last;   // Último valor da última linha

    if (primeiroValorTabela != 0) {
      calcDispersaoHorizontal = ((ultimaColunaPrimeiraLinha - primeiroValorTabela) / primeiroValorTabela) * 100;
      calcDispersaoTotal = ((ultimaColunaUltimaLinha - primeiroValorTabela) / primeiroValorTabela) * 100;
    }
  }

  // Formatador para garantir que a saída seja sempre com duas casas decimais e vírgula.
  final formatter = NumberFormat("0.00", "pt_BR");

  return TableCalculationResult(
    calculatedTableValues: tempTable,
    dispersaoHorizontal: formatter.format(calcDispersaoHorizontal),
    dispersaoTotal: formatter.format(calcDispersaoTotal),
  );
}
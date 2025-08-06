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
      //case 5: vrAnteriorDaLinha = penE; break;
      /*
      case 0: vrAnteriorDaLinha = valorBase; break;
      case 1: vrAnteriorDaLinha = penA; break;
      case 2: vrAnteriorDaLinha = penB; break;
      case 3: vrAnteriorDaLinha = penC; break;
      case 4: vrAnteriorDaLinha = penD; break;
      case 5: vrAnteriorDaLinha = penE; break;
       */
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
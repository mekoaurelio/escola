import '../services/utils.dart';

class AchaSalarioPeloNivelMatrix {
  final int cargaHoraria;
  final List<String> niveis;
  //final List<String> niveisP;
  final List<List<double>> calculatedTableValues;

  AchaSalarioPeloNivelMatrix({
    required this.cargaHoraria,
    required this.niveis,
   // required this.niveisP,
    required this.calculatedTableValues,
  });

  /// Retorna a matriz bruta (nível × classes)
  List<List<double>> getMatrizValores() {
    return calculatedTableValues;
  }

  /// Retorna a matriz formatada em string (opcional)
  List<List<String>> getMatrizFormatada() {
    return calculatedTableValues
        .map((linha) => linha
        .map((valor) => Utils.formatVr.format(valor))
        .toList())
        .toList();
  }

  /// Se quiser gerar um mapa {nivel: [valores]}
  Map<String, List<double>> getMapaPorNivel() {
    final mapa = <String, List<double>>{};
    for (int i = 0; i < niveis.length; i++) {
      mapa[niveis[i]] = calculatedTableValues[i];
    }
    return mapa;
  }
}

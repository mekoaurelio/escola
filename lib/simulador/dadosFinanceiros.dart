// Crie uma classe para representar os dados da tabela
class DadosFinanceiros {
  final double vencimentoAtual;
  final double vencimentoProposta;

  final double adicionalAtual;
  final double adicionalProposta;

  final double vantagensAtual;
  final double vantagensProposta;

  final double encargosAtual;
  final double encargosProposta;

  final double dispersaoHorizontal;
  final double dispersaoTotal;

  DadosFinanceiros({
    required this.vencimentoAtual,
    required this.vencimentoProposta,
    required this.adicionalAtual,
    required this.adicionalProposta,
    required this.vantagensAtual,
    required this.vantagensProposta,
    required this.encargosAtual,
    required this.encargosProposta,
    required this.dispersaoHorizontal,
    required this.dispersaoTotal,
  });
}
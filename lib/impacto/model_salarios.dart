class ModelSalario {
  final String nome;
  final double vencimento;
  final String horas;
  final String nivel;
  final String vantagens_detalhadas;
  final double soma_vantagens;
  final double soma_apts;
  final double total_vencimentos_geral;

  ModelSalario({
    required this.nome,
    required this.vencimento,
    required this.horas,
    required this.nivel,
    required this.vantagens_detalhadas,
    required this.soma_vantagens,
    required this.soma_apts,
    required this.total_vencimentos_geral,
  });

  factory ModelSalario.fromJson(Map<String, dynamic> json) {
    return ModelSalario(
      nome: json['nome'],
      vencimento: json['vencimento'],
      horas: json['horas'],
      nivel: json['nivel'],
      vantagens_detalhadas: json['vantagens_detalhadas'],
      soma_vantagens: json['soma_vantagens'],
      soma_apts: (json['soma_apts'] as num).toDouble(),
      total_vencimentos_geral: (json['total_vencimentos_geral'] as num).toDouble(),
    );
  }
}
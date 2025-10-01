class ModelSimulaForm {
  final int id;
  final int idForm;
  final String nivel;
  final String label;
  final String tipo;
  final double valor;
  final double valorProgressao;
  final double perc;

  ModelSimulaForm({
    required this.id,
    required this.idForm,
    required this.nivel,
    required this.label,
    required this.tipo,
    required this.valor,
    required this.valorProgressao,
    required this.perc,
  });

  factory ModelSimulaForm.fromJson(Map<String, dynamic> json) {
    return ModelSimulaForm(
      id: json['id'],
      idForm: json['id_form'],
      nivel: json['nivel'],
      label: json['label'],
      tipo: json['tipo'],
      valor: (json['valor'] as num).toDouble(),
      valorProgressao: (json['valor_progressao'] as num).toDouble(),
      perc: (json['perc'] as num).toDouble(),
    );
  }
}
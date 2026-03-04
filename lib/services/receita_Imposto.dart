class ReceitaImposto {
  final String descricao;
  final double valor1;
  final double valor2;
  final double valor3;
  final double valor4;

  ReceitaImposto({
    required this.descricao,
    required this.valor1,
    required this.valor2,
    required this.valor3,
    required this.valor4,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor1': valor1,
      'valor2': valor2,
      'valor3': valor3,
      'valor4': valor4,
    };
  }
}

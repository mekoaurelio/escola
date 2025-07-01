class Professor {
  final String matricula;
  final String nome;
  final String? cpf;
  final String tipo;
  final String? classe;
  final String cargo;
  final String unidade;
  final bool educacaoInfantil;

  Professor({
    required this.matricula,
    required this.nome,
    this.cpf,
    required this.tipo,
    this.classe,
    required this.cargo,
    required this.unidade,
    required this.educacaoInfantil,
  });

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      matricula: map['matricula'],
      nome: map['nome'],
      cpf: map['cpf'],
      tipo: map['tipo'],
      classe: map['classe'],
      cargo: map['cargo'],
      unidade: map['unidade'],
      educacaoInfantil: map['educacao_infantil'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'matricula': matricula,
      'nome': nome,
      'cpf': cpf,
      'tipo': tipo,
      'classe': classe,
      'cargo': cargo,
      'unidade': unidade,
      'educacao_infantil': educacaoInfantil,
    };
  }
}
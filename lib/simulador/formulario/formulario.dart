// lib/models/formulario_model.dart

// Enum para definir os diferentes tipos de itens que o formulário pode ter.
enum TipoItem { cabecalho, progressao, encargos }

class Formulario {
  int id;
  String titulo;
  String horas;
  List<ItemFormulario> itens;

  Formulario({
    required this.id,
    required this.titulo,
    required this.horas,
    required this.itens,
  });
}

class ItemFormulario {
  int id;
  String label;
  String nivel;
  String titulo;
  double? percentual; // Nulo para itens como o "Piso Inicial"
  double valor;
  double valor_progressao;
  TipoItem tipo;
  int posicao;

  ItemFormulario({
    required this.id,
    required this.label,
    required this.nivel,
    required this.titulo,
    this.percentual,
    required this.valor,
    required this.valor_progressao,
    required this.tipo,
    required this.posicao,
  });
}
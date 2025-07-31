import 'package:flutter/material.dart';

class CidadeSelector extends StatelessWidget {
  final String cidadeSelecionada;
  final void Function(String) onChanged;

  const CidadeSelector({
    Key? key,
    required this.cidadeSelecionada,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: cidadeSelecionada,
      isExpanded: true,
      onChanged: (String? novaCidade) {
        if (novaCidade != null) {
          onChanged(novaCidade);
        }
      },
      items: ['Dois Vizinhos', 'Cianorte']
          .map((cidade) => DropdownMenuItem(
        value: cidade,
        child: Text(cidade),
      ))
          .toList(),
    );
  }
}

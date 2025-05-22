
import 'package:flutter/material.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';
import 'utils.dart';

/// Tela que mostra duas seções: Fundeb e Infantil
/*
class ProgressaoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> fundeb;
  final List<Map<String, dynamic>> infantil;

  const ProgressaoScreen({
    Key? key,
    required this.fundeb,
    required this.infantil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Section(
                  title: 'SIMULADOR PCRM – PROFESSORES',
                  items: fundeb,
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'SIMULADOR PCRM – EDUCADOR INFANTIL (40h)',
                  items: infantil,
                ),
              ],
            ),
          ) ,
        )
    );

  }
}

 */

class ProgressaoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> fundeb;
  final List<Map<String, dynamic>> infantil;

  const ProgressaoScreen({
    Key? key,
    required this.fundeb,
    required this.infantil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SingleChildScrollView(
          // Reduz o padding top para diminuir o espaço acima
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),  // Alterado de EdgeInsets.all(16)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                title: 'SIMULADOR PCRM – PROFESSORES',
                items: fundeb,
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'SIMULADOR PCRM – EDUCADOR INFANTIL (40h)',
                items: infantil,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget genérico para exibir uma seção com título e lista de itens
class _Section extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _Section({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula iterativamente os valores compostos:
    double? lastValue;
    final cards = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final data = items[i];
      final rawValor = double.tryParse(data['valor'].toString()) ?? 0;
      final perc      = double.tryParse(data['percentual'].toString()) ?? 0;

      // Primeiro item: usa rawValor. Depois, valor anterior * (1 + perc/100)
      final computed = (i == 0)
          ? rawValor
          : (lastValue! * (1 + perc / 100));

      lastValue = computed;

      cards.add(_ItemCard(
        data: data,
        displayValue: computed,
        isFirst: i == 0,
      ));
    }

    return   Column(
      children: [
        Texto(tit: title, cor: Colors.black, bottom: 8),
        // centraliza e limita largura a 60%
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: Column(
              children: cards,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card simples para mostrar os campos de cada Map
class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final double displayValue;
  final bool isFirst;

  const _ItemCard({
    Key? key,
    required this.data,
    required this.displayValue,
    this.isFirst = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formata o valor em real
    final valorStr = Utils.toReal(displayValue);
    return Padding(
        padding: const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
        child: Row(
          children: [
            // Descrição
            Line(
              tex: data['descricao'] ?? '',
              tam: 200,
              cor: isFirst ? Colors.black : Colors.black54,
              top: 5,
              bottom: 5,
              alin: Alignment.centerLeft,
              negrito: isFirst,
              fontSize: isFirst ? 18 : 14,
            ),

            // Percentual
            Line(
              tex: '${data['percentual']}%',
              tam: 80,
              cor: Colors.black54,
              top: 5,
              bottom: 5,
              alin: Alignment.centerRight,
            ),

            // Valor calculado
            Line(
              tex: valorStr,
              tam: 120,
              cor: isFirst ? Colors.red : Colors.black87,
              top: 5,
              bottom: 5,
              alin: Alignment.centerRight,
              negrito: isFirst,
              fontSize: isFirst ? 18 : 15,
            ),
          ],
        ),
      );
   // );
  }
}

import 'package:flutter/material.dart';

import 'line.dart';

class VantagensList extends StatelessWidget {
  final String vantagensDetalhadas;

  const VantagensList({super.key, required this.vantagensDetalhadas});

  @override
  Widget build(BuildContext context) {
    if (vantagensDetalhadas.isEmpty) {
      return const Text('Nenhuma vantagem encontrada.');
    }

    // Divide a string pelo separador ' | '
    final vantagens = vantagensDetalhadas.split(' | ');

    return ListView.builder(
      shrinkWrap: true, // permite usar dentro de outro ListView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vantagens.length,
      itemBuilder: (context, index) {
        final item = vantagens[index].trim();
        final dado= item.split(':');
        var vr=dado[3].replaceAll('-', '');
        vr=vr.replaceAll('R/\$', '');
        bool negrito=dado[0]=='21003' || dado[0]=='21019';
        return Row(
          children: [
            Line(tex: dado[0], tam: 50, alin: Alignment.centerLeft,cor: Colors.black,negrito: negrito),///matícula
            Line(tex: dado[1], tam: 250, alin: Alignment.centerLeft,cor: Colors.black,negrito: negrito),///descricao
            Line(tex: dado[2]=='0.00'?'':'${dado[2]}%', tam: 100, alin: Alignment.centerLeft,cor: Colors.black,negrito: negrito),//percentual
            Line(tex: '$vr', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: negrito),///Valor
          ],
        ) ;

        //  Texto(tit: dado[0]+' '+dado[1],cor: Colors.blue,left: 30,negrito: true,);
      },
    );
  }
}

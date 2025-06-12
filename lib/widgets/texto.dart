import 'package:flutter/material.dart';

class Texto extends StatelessWidget {
  final String tit;
  final double tam;
  final Color cor;
  final bool negrito;
  final TextAlign? alin;
  final int linhas;
  final double top, bottom, left, right;

  final bool exibirIcone;
  final IconData icone;
  final VoidCallback? aoClicarIcone;

  Texto({
    required this.tit,
    this.tam = 15,
    this.cor = Colors.black54,
    this.negrito = false,
    this.alin,
    this.linhas = 1,
    this.top = 0,
    this.bottom = 0,
    this.left = 0,
    this.right = 0,
    this.exibirIcone = false,
    this.icone = Icons.edit,
    this.aoClicarIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              tit,
              textAlign: alin,
              maxLines: linhas,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: tam,
                color: cor,
                fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: 5,),
          if (exibirIcone)
            IconButton(
              icon: Icon(icone, size: tam + 2),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: aoClicarIcone,
              tooltip: 'Editar',
            ),
        ],
      ),
    );
  }
}

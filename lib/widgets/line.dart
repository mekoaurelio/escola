import 'package:flutter/material.dart';
import 'texto.dart';

class Line extends StatelessWidget {
  final String tex;
  final double tam;
  final Color cor;
  final bool negrito;
  final Alignment alin;
  final double top;
  final double bottom;
  final double fontSize;
  final IconData icone;
  final bool exibirIcone;

  const Line({
    Key? key,
    required this.tex,
    this.tam = 15,
    this.cor = Colors.black87,
    this.negrito = false,
    this.alin = Alignment.center,
    this.top = 0,
    this.bottom = 0,
    this.fontSize = 12,
    this.icone = Icons.edit,
    this.exibirIcone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tam,
      alignment: alin,
      child: Texto(
        tit: tex,
        cor: cor,
        tam: fontSize,
        top: top,
        bottom: bottom,
        negrito: negrito,
        exibirIcone: exibirIcone,
        icone: icone,
      ),
    );
  }
}

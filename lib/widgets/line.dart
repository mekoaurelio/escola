import 'package:flutter/material.dart';

import 'texto.dart';

class Line extends StatefulWidget {
  var tex;
  double? tam=15;
  Color? cor;
  bool? negrito=false;
  dynamic alin=TextAlign.center;
  double? top=0;
  double? bottom=0;
  double? fontSize=0;
  
  Line({
    this.tex,
    this.tam,
    this.cor,
    this.negrito,
    this.alin,
    this.bottom,
    this.top,
    this.fontSize
  });

  @override
  _LineState createState() => _LineState();
}

class _LineState extends State<Line> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      width: widget.tam,
      alignment: widget.alin ?? Alignment.center,
      //color: Colors.yellow,
      child: Texto(
        tit: widget.tex,
        cor: widget.cor ?? Colors.black87,
        tam: widget.fontSize ?? 12,
        top: widget.top ?? 0,
        bottom: widget.bottom ?? 0,
        negrito: widget.negrito ?? false,
      ),
    );
  }
}

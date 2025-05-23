import 'package:flutter/material.dart';

class Texto extends StatefulWidget {
  var tit;
  double? tam=15;
  Color? cor;
  bool? negrito=false;
  dynamic alin;
  int? linhas=1;
  double? top=0, bottom=0, left=0, right=0;

  Texto({
    this.tit,
    this.tam,
    this.cor=Colors.black54,
    this.negrito,
    this.alin,
    this.linhas=1,
    this.top=0,this.bottom=0,this.left=0,this.right=0
  });

  @override
  _TextoState createState() => _TextoState();
}

class _TextoState extends State<Texto> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: widget.top!,bottom: widget.bottom!,left:widget.left!,right:widget.right!),
        child:Text(widget.tit,
          textAlign: widget.alin,
          maxLines: widget.linhas,
          style: TextStyle(
            fontWeight: widget.negrito==null?FontWeight.normal:widget.negrito!?FontWeight.bold:FontWeight.normal,
            color: widget.cor,
            fontSize: widget.tam,
          ),
        )
    );
  }
}
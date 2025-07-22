import 'package:GEM/auxiliares/usuario_detalhe.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/base_lista.dart';
import '../widgets/line.dart';
import '../widgets/painel.dart';

class UsuariosLista extends ListaBase {
  final String table;
  final String title;

  const UsuariosLista({
    Key? key,
    required this.table,
    required this.title,
  }) : super(key: key);


  @override
  ListaBaseState createStateBase() => _ListaBaseState();
}

class _ListaBaseState extends ListaBaseState<UsuariosLista> {
  String? _lastLoadedTable;

  @override
  void initState() {
    super.initState();
    _loadTableIfNeeded();
    carregarDados(widget.table);
  }

  @override
  void didUpdateWidget(covariant UsuariosLista oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadTableIfNeeded();
  }

  void _loadTableIfNeeded() {
    if (_lastLoadedTable != widget.table) {
      _lastLoadedTable = widget.table;
      carregarDados(widget.table);
    }
  }

  @override
  String getTituloPesquisa() => 'Pesquise por nome, documento ou e-mail...';

  @override
  String getAppBarTitle() => 'Alunos';

  Future<void> selecao(rec) async {
    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.44,
        height: MediaQuery.of(context).size.height *0.44,
        child: UsuarioDetalhe(data:lista[hoverIndex],table: widget.table,),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
      setState(() {
        carregarDados(widget.table);
      });
  }

  Future<void> onAdd() async {
    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.40,
        height: MediaQuery.of(context).size.height *0.40,
        child: UsuarioDetalhe(data: null,table: widget.table,),
         onClose: () => Navigator.of(context).pop(),
      ),
    );
    if(result!=null) {
      setState(() => lista = result);
    }
  }

  @override
  Widget cabecalho() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children:  [
        Line(tex: '', tam: 48, cor: Colors.black54, top: 5, bottom: 5),
        Line(tex: 'Usuário', tam: 300, alin: Alignment.centerLeft),
      ],
    );
  }

  @override
  buildGridChildren(int index,screenSizeConfig) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Make space for the delete icon
          children: [
            Expanded(  // Allow the content to expand and fill the available space
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Line(tex: '', tam: 5),
                  Line(tex: row['id_user'], tam: 300, alin: Alignment.centerLeft,), //
                ],
              ),
            ),
            IconButton(
              onPressed: () => delData(index,widget.table),
              icon: Icon(Icons.delete, size: screenSizeConfig.getIconSize(), color: Colors.black38,),
            ),
          ],
        ),
      ],
    );
  }

  void onChange(String text) {
    setState(() {
      lista = listaOriginal.where((professor) {
        final nome = professor['id_user'].toString().toLowerCase();
        return nome.contains(text.toLowerCase());
      }).toList();
    });
  }
}
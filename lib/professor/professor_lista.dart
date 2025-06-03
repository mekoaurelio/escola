import 'package:flutter/material.dart';

import '../data/api_my_sql.dart';
import '../services/base_lista.dart';
import '../widgets/line.dart';
import '../widgets/painel.dart';
import 'professor_detalhe.dart';


class ProfessorLista extends ListaBase {
  final String table;

  const ProfessorLista({
    Key? key,
    required this.table,
  }) : super(key: key);


  @override
  ListaBaseState createStateBase() => _ListaBaseState();
}

class _ListaBaseState extends ListaBaseState<ProfessorLista> {
  String? _lastLoadedTable;

  @override
  void initState() {
    super.initState();
    _loadTableIfNeeded();
    carregarDados(widget.table);
  }

  @override
  void didUpdateWidget(covariant ProfessorLista oldWidget) {
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
    ///CARREGA TODAS AS TABELAS AUXILIARES
    var cargos=await ApiMySql.get('cargo',null,null);
    var area_atuacao=await ApiMySql.get('area_atuacao',null,null);
    var local_servico=await ApiMySql.get('local_servico',null,null);
    var nivel=await ApiMySql.get('nivel',null,null);
    var formacao=await ApiMySql.get('formacao',null,null);
    var regimeContracao=await ApiMySql.get('regime_contratacao',null,null);
    var funcao=await ApiMySql.get('funcao',null,null);
    var fonte_receita=await ApiMySql.get('fonte_receita',null,null);
    var classe=await ApiMySql.get('classe',null,null);

    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.50,
        height: MediaQuery.of(context).size.height *0.90,
        child: ProfessorDetalhe(professor: lista[hoverIndex],
          cargos: cargos,areaAtuacao: area_atuacao,localServico: local_servico,nivel:nivel,formacao: formacao,
          regime: regimeContracao,fonteReceita: fonte_receita,
        classe: classe, funcao: funcao,),

        onClose: () => Navigator.of(context).pop(),
      ),
    );
      setState(() {
        carregarDados(widget.table);
      });
  }

  Future<void> onAdd() async {
    ///CARREGA TODAS AS TABELAS AUXILIARES
    var cargos=await ApiMySql.get('cargo',null,null);
    var area_atuacao=await ApiMySql.get('area_atuacao',null,null);
    var local_servico=await ApiMySql.get('local_servico',null,null);
    var nivel=await ApiMySql.get('nivel',null,null);
    var formacao=await ApiMySql.get('formacao',null,null);
    var regimeContracao=await ApiMySql.get('regime_contratacao',null,null);
    var funcao=await ApiMySql.get('funcao',null,null);
    var fonte_receita=await ApiMySql.get('fonte_receita',null,null);
    var classe=await ApiMySql.get('classe',null,null);

    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.50,
        height: MediaQuery.of(context).size.height *0.90,
        /// COMO ESTÁ ADD UM NOVO PROFESSOR A TEBELA professor VAI COMO NULL
        child: ProfessorDetalhe(professor: null,
          cargos: cargos,areaAtuacao: area_atuacao,localServico:local_servico,nivel:nivel,formacao: formacao,
        regime: regimeContracao,funcao:funcao,fonteReceita: fonte_receita,classe: classe,),

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
        Line(tex: 'Descrição do cargo', tam: 300, alin: Alignment.centerLeft),
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
                  image(),
                  Line(tex: '', tam: 5),
                  Line(tex: row['nome'], tam: 300, alin: Alignment.centerLeft,), //
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
        final nome = professor['nome'].toString().toLowerCase();
        return nome.contains(text.toLowerCase());
      }).toList();
    });
  }
}
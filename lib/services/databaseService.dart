import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';

import '../data/api_my_sql.dart';
import '../simulador/formulario/formulario.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';

import 'utils.dart';

class DatabaseService {
  // Simula uma tabela de formulários no banco de dados
  final List<Formulario> _formulariosSalvos = [];
  int _nextItemId = 1;
  final GlobalFilterController _filterController = Get.find<GlobalFilterController>();

  // Carrega todos os formulários salvos.
  Future<List<Formulario>> carregarTodosOsFormularios() async {
    _formulariosSalvos.clear();
    var _forms=await ApiMySql.get(TBSimulaCab, null, null).timeout(const Duration(seconds: 30));
    for(int i = 0 ; i<_forms.length ; i++) {
      final novoFormulario = Formulario(
        id: int.parse(_forms[i]['id']),
        horas: _forms[i]['horas'],
        titulo: _forms[i]['descricao'],
        itens: [], // Começa sem itens
      );
      _formulariosSalvos.add(novoFormulario);

    }
    return List.from(_formulariosSalvos);
  }

  // Cria um novo formulário com um título e o salva.
  Future<Formulario> criarNovoFormulario(String titulo, String horas) async {
      var tb = await montaNomeTabela('simula_cab');
      final temTabela = await ApiMySql.tabelaExiste(tb);
      if (!temTabela) {
        var tbCriada = await ApiMySql.CriaTabelaSimulaCab(tb);
      }
      print('insert into $tb (descricao,horas,classes,progressao,) values ("$titulo","$horas"),15,1.0');
      var itens = await ApiMySql.executaSql('insert into $tb (descricao,horas) values ("$titulo","$horas")');
      var result = await ApiMySql.executaSql('select * from $tb where descricao="$titulo"').timeout(const Duration(seconds: 30));
      print('KKKKKKKKK');
      print(result);

      print('----------');
      final novoFormulario = Formulario(
        id: int.parse(result[0]['id']),
        horas: result[0]['horas'],
        titulo: titulo,
        itens: [], // Começa sem itens
      );
      _formulariosSalvos.add(novoFormulario);
      return novoFormulario;


  }

  Future<String> montaNomeTabela(var tb) async {
    var _muni=_filterController.municipio.value;
    var _ano=_filterController.ano.value;
    var _bimestre=_filterController.bimestre.value;
    return '${_muni}$tb$_ano$_bimestre';
  }

  Future<void> salvarFormulario(Formulario formulario) async {
    final index = _formulariosSalvos.indexWhere((f) => f.id == formulario.id);
    var tb=await montaNomeTabela('simula_form');
    print(tb);
    if (index != -1) {
      /// ==========================================================
      /// Altera o formulário                                      =
      /// ==========================================================

     // print('ALTERANDO');
     // await gravaNoBanco(formulario, 'A',tb,formulario.id);
      _formulariosSalvos[index] = formulario;
    } else {
      /// ==========================================================
      /// Novo formulário                                          =
      /// ==========================================================
      final temTabela=await ApiMySql.tabelaExiste(tb);
      if(!temTabela){
        await ApiMySql.CriaTabelaSimulaForm(tb);
      }
    }
  }

  /// ==========================================================
  /// delete formulário                                        =
  /// ==========================================================
  Future<void> deletarFormulario(int id,BuildContext context) async {
    final bool confirmar = await Utils.showDlg(
      'Atenção', 'Confirma a exclusão ?', context, 'Sim', 'Não',);
    if (confirmar) {
      await ApiMySql.executaSql("DELETE FROM $TBSimulaCab WHERE id=$id",);
      _formulariosSalvos.removeWhere((f) => f.id == id);
      print("Formulário ID $id deletado.");
    }
  }

  // Gera um ID único para um novo item.
  int getProximoItemId() {
    return _nextItemId++;
  }
}
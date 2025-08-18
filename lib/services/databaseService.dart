import 'package:GEM/services/table_name_service.dart';

import '../data/api_my_sql.dart';
import '../simulador/formulario/formulario.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';

class DatabaseService {
  // Simula uma tabela de formulários no banco de dados
  final List<Formulario> _formulariosSalvos = [];
  int _nextFormId = 1;
  int _nextItemId = 1;
  final GlobalFilterController _filterController = Get.find<GlobalFilterController>();

  // Carrega todos os formulários salvos.
  Future<List<Formulario>> carregarTodosOsFormularios() async {
    _formulariosSalvos.clear();
    var _forms=await ApiMySql.get(TBSimulaCab, null, null);
    for(int i = 0 ; i<_forms.length ; i++) {
      final novoFormulario = Formulario(
        id: int.parse(_forms[i]['id']),
        titulo: _forms[i]['descricao'],
        itens: [], // Começa sem itens
      );
      _formulariosSalvos.add(novoFormulario);

    }
    return List.from(_formulariosSalvos);
  }

  // Cria um novo formulário com um título e o salva.
  Future<Formulario> criarNovoFormulario(String titulo) async {
    var tb=await montaNomeTabela('simula_cab');
    final temTabela=await ApiMySql.tabelaExiste(tb);
    if(!temTabela){
      var tbCriada=await ApiMySql.CriaTabelaSimulaCab(tb);
    }
    var itens=await ApiMySql.executaSql('insert into $tb (descricao) values ("$titulo")');
    var result=await ApiMySql.executaSql('select * from $tb where descricao="$titulo"');
    final novoFormulario = Formulario(
      id: int.parse(result[0]['id']),
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
     // print('INSERT');
      //await ApiMySql.InsertItens(formulario);
      //await gravaNoBanco(formulario, 'I',tb,formulario.id);
    }
  }
/*
  Future<void> gravaNoBanco(Formulario formulario,var type,var tb,var id_form) async {

    for(int i = 0 ; i<formulario.itens.length ; i++) {
      var label=formulario.itens[i].label;
      var perc=formulario.itens[i].percentual;
      if(perc==null){
        perc=0;
      }
      var tipo=formulario.itens[i].tipo;
      var valor=formulario.itens[i].valor;
      //id_form
      if(type=='I'){
        print('insert INTO $tb (label,tipo,valor,perc,id_form) Values ("$label","$tipo",$valor,$perc,$id_form)');
        await ApiMySql.executaSql('insert INTO $tb (label,tipo,valor,perc,id_form) Values ("$label","$tipo",$valor,$perc,$id_form)');
      }else{
        print('update $tb set label="$label",tipo="$label",valor=$valor,perc=$perc');
        await ApiMySql.executaSql('update $tb set label="$label",tipo="$label",valor=$valor,perc=$perc');
      }
    }


  }

 */

  /// ==========================================================
  /// delete formulário                                        =
  /// ==========================================================
  Future<void> deletarFormulario(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _formulariosSalvos.removeWhere((f) => f.id == id);
    print("Formulário ID $id deletado.");
  }

  // Gera um ID único para um novo item.
  int getProximoItemId() {
    return _nextItemId++;
  }
}
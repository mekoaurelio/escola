import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../services/utils.dart';
import '../widgets/formFieldData.dart';

class ProfessorDetalhe extends StatelessWidget {
  final Map<String, dynamic>? professor;
  final List<Map<String, dynamic>> cargos; // vinda de API ou injeção
  final List<Map<String, dynamic>> areaAtuacao;
  final List<Map<String, dynamic>> localServico;
  final List<Map<String, dynamic>> nivel;
  final List<Map<String, dynamic>> formacao;
  final List<Map<String, dynamic>> regime;
  final List<Map<String, dynamic>> funcao;
  final List<Map<String, dynamic>> fonteReceita;
  final List<Map<String, dynamic>> classe;


  ProfessorDetalhe({
    Key? key,
    required this.professor,
    required this.cargos,
    required this.areaAtuacao,
    required this.localServico,
    required this.nivel,
    required this.formacao,
    required this.regime,
    required this.funcao,
    required this.fonteReceita,
    required this.classe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///VERICIA SE EXISTE DADOS DAS TABELAS AUXILIARES
    final initialCargoId = professor?['cargo_id']?.toString() ?? '1';
    final initialArea = professor?['area_atuacao_id']?.toString() ?? '1';
    final initialLocal = professor?['local_servico_id']?.toString() ?? '1';
    final initialNivel = professor?['nivel_id']?.toString() ?? '1';
    final initialFormacao = professor?['formacao_id']?.toString() ?? '1';
    final initialRegime = professor?['regime_contratacao_id']?.toString() ?? '1';
    final initialfuncao = professor?['funcao_id']?.toString() ?? '1';
    final initialClasse = professor?['classe_id']?.toString() ?? '1';
    final initialReceita = professor?['fonte_receita_id']?.toString() ?? '1';

    final initial = {
      for (var f in _allFields)

        ///AQUI CARREGA TODOS OS CAMPOS QUE NÃO SÃO DAS TABELAS AUXILIARES
        //f.controllerName: professor?[f.controllerName]?.toString() ?? '',

      f.controllerName: Utils.formatInitialValue(
        f.controllerName, professor?[f.controllerName]?.toString() ?? '',f.tipo
      ),

      ///SE EXISTIR DADO, MOSTRA ESSE DADO, CASO CONTRARIO O CONTROLLER APARECE EM BRANCO
      'cargo_id': initialCargoId, // Se não for válido, usa vazio
      'area_atuacao_id': initialArea ,
      'local_servico_id':  initialLocal ,
      'nivel_id':  initialNivel ,
      'formacao_id':  initialFormacao ,
      'regime_contratacao_id':  initialRegime ,
      'funcao_id':  initialfuncao ,
      'classe_id':  initialClasse ,
      'fonte_receita_id':  initialReceita ,
    };

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Text('Professor'),
          bottom: TabBar(tabs: [
            Tab(text: 'Dados Básicos'),
            Tab(text: 'Profissional'),
            Tab(text: 'Remuneração'),
            Tab(text: 'Cálculos'),
          ]),
        ),
        body: TabBarView(children: [
          _buildTab(_basicFields, initial,0),
          _buildTab(_profFields, initial,1),
          _buildTab(_remFields, initial,2),
          _buildTab(_calcFields, initial,3),
        ]),
      ),
    );
  }

  Widget _buildTab(List<FormFieldData> fields, Map<String, String> initial,int tabIndex) {
    return GenericFormScreen(
      subTitle: '',
      onBack: () => Get.back(),
      onSave: (vals) async {
        if (professor?['id'] == null) {
          ///DADOS BÁSICOS
          if(tabIndex==0){
            ///Formata a data
            vals['data_admissao']=Utils.dtToMysql(vals['data_admissao']);
            var idProf=await ApiMySql.insertDynamic(vals,'professor');
            Utils.setIdProfessor(idProf);
          }else{
            var idProf=Utils.getIdProfessor();
            if(idProf=='' || idProf==null) {
              Utils.snak('attention'.tr, 'Volte a ABA Dados Báisos e preencha o nome do professor', false, Colors.red);
              return;
            }
            await ApiMySql.updateDynamic('professor',vals,idValue: idProf);
          }
        } else {
          await ApiMySql.updateDynamic('professor', vals, idValue: professor?['id']);
          Utils.snak('Parabéns', 'Dados salvos com sucesso!', false, Colors.green);
        }
       // Get.back(result: true);
      },
      fieldsData: fields,
      initialValues: initial,
    );
  }
  ///DADOS BÁSICOS
  List<FormFieldData> get _basicFields => [
    TextFormFieldData(controllerName: 'matricula', label: 'Matrícula',tipo: 'String'),
    TextFormFieldData(controllerName: 'nome', label: 'Nome',tipo: 'String'),
    TextFormFieldData(controllerName: 'data_admissao', label: 'Data de Admissão',obrigatorio: false,inputFormatters: [Utils.maskDt],tipo: 'data'),
  ];
  ///PROFISSIONAL
  List<FormFieldData> get _profFields => [
    ///FORMAÇÃO
    DropdownFormFieldData(
      controllerName: 'formacao_id',
      label: 'Formação',
      hint: 'Selecione...',
      items: formacao,
      idField: 'id',
      displayField: 'descricao',
      tipo: 'string',
    ),
    ///REGIME DE CONTRATA"CÃO
    DropdownFormFieldData(
      controllerName: 'regime_contratacao_id',
      label: 'Regime de Contratação',
      hint: 'Selecione...',
      items: regime,
      idField: 'id',
      displayField: 'descricao',
      tipo: 'string',
    ),
    ///CARGO
    DropdownFormFieldData(
      controllerName: 'cargo_id',
      label: 'Cargo',
      hint: 'Selecione...',
      items: cargos,
      idField: 'id',
      displayField: 'nome',
      tipo: 'string',
    ),
    ///FONTE DE RECEITA
    DropdownFormFieldData(
      controllerName: 'fonte_receita_id',
      label: 'Fonte de Receita',
      hint: 'Selecione...',
      items: fonteReceita,
      idField: 'id',
      displayField: 'descricao',
      tipo: 'string',
    ),
    ///CLSSE
    DropdownFormFieldData(
      controllerName: 'classe_id',
      label: 'Classe',
      hint: 'Selecione...',
      items: classe,
      idField: 'id',
      displayField: 'descricao',
      tipo: 'string',
    ),
    ///AREA DE ATUACÃO
    DropdownFormFieldData(
      controllerName: 'area_atuacao_id',
      label: 'Áreaçãoa de atuação',
      hint: 'Selecione...',
      items: areaAtuacao,
      idField: 'id',
      displayField: 'descricao',
      tipo: 'string',
    ),
    ///LOCAL DE SERVIÇO
    DropdownFormFieldData(
        controllerName: 'local_servico_id',
        label: 'Local de serviço',
        hint: 'Selecione...',
        items: localServico,
        idField: 'id',
        displayField: 'nome',
      tipo: 'string',
    ),

    TextFormFieldData(controllerName: 'tempo_servico_anos', label: 'Tempo Serviço (anos)',tipo: 'string'),
    TextFormFieldData(controllerName: 'referencia', label: 'Referência',tipo: 'string'),
  ];
  ///REMUNERAÇÃO
  List<FormFieldData> get _remFields => [
    TextFormFieldData(controllerName: 'vencimento_basico_atual', label: 'Vencimento Básico Atual',
        inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],tipo: 'dinheiro'),
    TextFormFieldData(controllerName: 'vencimento_basico_proposta', label: 'Vencumento Proposto',
        inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],tipo: 'dinheiro'),
    TextFormFieldData(controllerName: 'jornada_suplementar', label: 'Jornada Suplementar',tipo:'string'),
    TextFormFieldData(controllerName: 'percentual_ats', label: 'Percentual ATS',tipo: 'String'),
    TextFormFieldData(controllerName: 'gratificacao_direcao', label: 'Gratificação Direção',tipo: 'String'),
    TextFormFieldData(controllerName: 'gratificacao_orientacao', label: 'Gratificação Orientação',tipo: 'String'),
    TextFormFieldData(controllerName: 'gratificacao_coordenacao', label: 'Gratificação Coordenação',tipo: 'String'),
    TextFormFieldData(controllerName: 'adicional_ats', label: 'Adicional ATS',tipo: 'String' ),
    TextFormFieldData(controllerName: 'salario_familia', label: 'Salário Família',tipo: 'dinheiro'),
  ];
  ///CÁLCULOS
  List<FormFieldData> get _calcFields => [
    TextFormFieldData(controllerName: 'remuneracao_total', label: 'Remuneração Total',
        inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],tipo: 'dinheiro'
    ),
    TextFormFieldData(controllerName: 'encargos_sociais', label: 'Encargos Sociais',
        inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],tipo: 'dinheiro'),
    TextFormFieldData(controllerName: 'remuneracao_total_com_encargos', label: 'Total + Encargos',
        inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],tipo: 'dinheiro'),
    TextFormFieldData(controllerName: 'complementacao_piso', label: 'Complementação Piso',tipo: 'string'),
    TextFormFieldData(controllerName: 'adicional_especial_5', label: 'Adicional Esp. 5%',tipo: 'string'),
    TextFormFieldData(controllerName: 'adicional_especial_10', label: 'Adicional Esp. 10%',tipo: 'string'),
    TextFormFieldData(controllerName: 'adicional_especial_25', label: 'Adicional Esp. 25%',tipo: 'string'),
    TextFormFieldData(controllerName: 'abono_permanencia', label: 'Abono Permanência',tipo: 'string'),
    TextFormFieldData(controllerName: 'diferenca_enquadramento', label: 'Diferença Enquadramento',tipo: 'string'),
    TextFormFieldData(controllerName: 'diferenca_salarial_piso', label: 'Diferença Piso Salarial',tipo: 'string'),
  ];

  // juntar todas só se precisar do initial:
  List<FormFieldData> get _allFields => [
    ..._basicFields,
    ..._profFields,
    ..._remFields,
    ..._calcFields,
  ];
}

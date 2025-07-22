import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../login/direito_de_acesso.dart';
import '../services/generic_form_screen.dart';
import '../widgets/formFieldData.dart';
import '../widgets/painel.dart';

class UsuarioDetalhe extends StatelessWidget {
  var data;
  final String table;
  final List<Map<String, dynamic>>? dropdownItems; // se precisar

   UsuarioDetalhe({
    Key? key,
    this.data,
    required this.table,
    this.dropdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fields = <FormFieldData>[
      TextFormFieldData(controllerName: 'id_user', label: 'Usuário', hintText: 'Informe o nome do usuário',tipo:'String'),
      if(data==null)
      TextFormFieldData(controllerName: 'senha', label: 'Senha', hintText: 'Crie uma senha para esse usuário',tipo:'String'),
      if (dropdownItems != null)
        DropdownFormFieldData(
          controllerName: 'categoria_id',
          label: 'Categoria',
          hint: 'Selecione...',
          items: dropdownItems!,
          idField: 'id',
          displayField: 'descricao', tipo:'String'
        ),
    ];
    final initialValues = {
      for (var f in fields)
        f.controllerName: data?[f.controllerName]?.toString() ?? '',
    };

    return Scaffold(
      backgroundColor: corFundoOadrao,
      body: GenericFormScreen(
        subTitle: data == null ? 'Novo' : 'Editando',
        onBack: () => Get.back(),
        onSave: (formValues) async {
          if (data == null || data!['id'] == null) {
            var idUser=await ApiMySql.insertDynamic(formValues, table);
            print('insert into login_direitos (home,id_user) Values ("true",$idUser)');
            await ApiMySql.executaSql('insert into login_direitos (home,id_user) Values (TRUE,$idUser)');
          //  direito(context,idUser,formValues['id_user'],'INSERT');
          } else {
            await ApiMySql.updateDynamic(table,formValues,idValue: data!['id']);
            await direito(context,data!['id'],data['id_user'],'UPDATE');
          }
          // Atualiza a lista e volta
          final listaAtualizada = await ApiMySql.get(table, null,null);
          Get.back(result: listaAtualizada);
        },
        fieldsData: fields,
        initialValues: initialValues,
        hasImagePicker: false,
        idUser: data!=null?data!['id']:null,///Código
        nmUser: data!=null?data!['id_user']:null,///Nome
      ),
    );
  }

  direito(BuildContext context,var idUser,var nmUser,var tipo)async{
    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.40,
        height: double.infinity,
        child: DireitoDeAcesso(
          acessosIniciais: {
            "Simulador": true,
            "Projeção dos Recursos do FUNDEB": true,
          },
          idUser: idUser,
          nmUser: nmUser,
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }


}

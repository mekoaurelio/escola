
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
  final List<Map<String, dynamic>>? dropdownItems;

  UsuarioDetalhe({
    Key? key,
    this.data,
    required this.table,
    this.dropdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Garantir que fields nunca seja vazio
    final fields = <FormFieldData>[
      TextFormFieldData(
        controllerName: 'id_user',
        label: 'Usuário',
        hintText: 'Informe o nome do usuário',
        tipo: 'String',
        obrigatorio: true, // Adicionar validação
      ),
      if (data == null) // Só mostrar senha quando for novo usuário
        TextFormFieldData(
          controllerName: 'senha',
          label: 'Senha',
          hintText: 'Crie uma senha para esse usuário',
          tipo: 'String',
          obrigatorio: true,
        ),
      if (dropdownItems != null && dropdownItems!.isNotEmpty)
        DropdownFormFieldData(
          controllerName: 'categoria_id',
          label: 'Categoria',
          hint: 'Selecione...',
          items: dropdownItems!,
          idField: 'id',
          displayField: 'descricao',
          tipo: 'String',
          obrigatorio: true,
        ),
    ];

    // Garantir que initialValues seja um Map válido
    final initialValues = <String, String>{};
    if (data != null) {
      for (var field in fields) {
        initialValues[field.controllerName] = data[field.controllerName]?.toString() ?? '';
      }
    }

    return Scaffold(
      backgroundColor: corFundoOadrao,
      body: GenericFormScreen(
        subTitle: data == null ? 'Novo' : 'Editando',
        onBack: () {
          // Garantir que o pop seja chamado com segurança
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          Get.back();
        },
        onSave: (formValues) async {
          try {
            if (data == null || data!['id'] == null) {
              var idUser = await ApiMySql.insertDynamic(formValues, table);
              if (idUser != null) {
                await ApiMySql.executaSql('insert into login_direitos (home,id_user) Values (TRUE,$idUser)');
              }
            } else {
              await ApiMySql.updateDynamic(table, formValues, idValue: data!['id']);
              await direito(context, data!['id'], data['id_user'], 'UPDATE');
            }
            // Atualiza a lista e volta
            final listaAtualizada = await ApiMySql.get(table, null, null);
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(listaAtualizada);
            }
            Get.back(result: listaAtualizada);
          } catch (e) {
            print('Erro ao salvar: $e');
            // Mostrar mensagem de erro ao usuário
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar: $e')),
            );
          }
        },
        fieldsData: fields.isEmpty ? _getDefaultFields() : fields, // Garantir que não seja vazio
        initialValues: initialValues,
        hasImagePicker: false,
        idUser: data != null ? data!['id'] : null,
        nmUser: data != null ? data!['id_user'] : null,
      ),
    );
  }

  // Método para fornecer campos padrão caso fields esteja vazio
  List<FormFieldData> _getDefaultFields() {
    return [
      TextFormFieldData(
        controllerName: 'id_user',
        label: 'Usuário',
        hintText: 'Informe o nome do usuário',
        tipo: 'String',
        obrigatorio: true,
      ),
      TextFormFieldData(
        controllerName: 'senha',
        label: 'Senha',
        hintText: 'Crie uma senha para esse usuário',
        tipo: 'String',
        obrigatorio: true,
      ),
    ];
  }

  direito(BuildContext context, var idUser, var nmUser, var tipo) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width * 0.40,
        height: double.infinity,
        child: DireitoDeAcesso(
          acessosIniciais: {
            "Simulador": true,
            "Projeção dos Recursos do FUNDEB": true,
          },
          idUser: idUser,
          nmUser: nmUser,
        ),
        //onClose: () => Navigator.of(context).pop(),

        onClose: () {
          // Garantir que o pop seja chamado com segurança
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          Get.back();
        },

      ),
    );
  }
}



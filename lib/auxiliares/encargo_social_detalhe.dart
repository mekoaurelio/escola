import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../services/utils.dart';
import '../widgets/formFieldData.dart';

class EncargoSocialDetalhe extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String table;
  final List<Map<String, dynamic>>? dropdownItems; // se precisar

  const EncargoSocialDetalhe({
    Key? key,
    this.data,
    required this.table,
    this.dropdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define aqui os campos do seu formulário
    final fields = <FormFieldData>[
      TextFormFieldData(controllerName: 'nome', label: 'Nome', hintText: 'Informe o nome',tipo:'String'),
      TextFormFieldData(controllerName: 'descricao', label: 'Descrição', hintText: 'Informe a descrição',tipo:'String'),
      if (dropdownItems != null)
        DropdownFormFieldData(
          controllerName: 'categoria_id',
          label: 'Categoria',
          hint: 'Selecione...',
          items: dropdownItems!,
          idField: 'id',
          displayField: 'descricao',
            tipo:'String'
        ),
    ];

    // Mapeia valores iniciais
    final initialValues = {
      for (var f in fields)
        f.controllerName: data?[f.controllerName]?.toString() ?? '',
    };

    return Scaffold(
      body: GenericFormScreen(
        subTitle: data == null ? 'new'.tr : 'edit'.tr,
        onBack: () => Get.back(),
        onSave: (formValues) async {
          if (data == null || data!['id'] == null) {
            await ApiMySql.insertDynamic(formValues, table);
          } else {
            await ApiMySql.updateDynamic(table,formValues,idValue: data!['id']);
          }
          // Atualiza a lista e volta
          final listaAtualizada = await ApiMySql.get(table, null,null);
          Get.back(result: listaAtualizada);
        },
        fieldsData: fields,
        initialValues: initialValues,
        hasImagePicker: false,
      ),
    );
  }
}

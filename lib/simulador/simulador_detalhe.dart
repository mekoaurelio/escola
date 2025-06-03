import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../widgets/formFieldData.dart';
import '../widgets/percentageInputFormatter.dart';

class SimuladorDetalhe extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String table;
  final List<Map<String, dynamic>>? dropdownItems; // se precisar

  const SimuladorDetalhe({
    Key? key,
    this.data,
    required this.table,
    this.dropdownItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define aqui os campos do seu formulário
    final fields = <FormFieldData>[
      TextFormFieldData(controllerName: 'descricao', label: 'Descrição',tipo:'String'),
      TextFormFieldData(controllerName: 'percentual', label: 'Percentual',inputFormatters: [CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')],tipo:'String',
      obrigatorio: false),

      //TextFormFieldData(controllerName: 'percentual', label: 'Percentual',inputFormatters: [PercentShiftFormatter()],tipo:'String',
        //  obrigatorio: false),

      TextFormFieldData(controllerName: 'valor', label: 'Valor',inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],
          tipo:'String',obrigatorio: false),
    ];

    // Mapeia valores iniciais
    final initialValues = {
      for (var f in fields)
        f.controllerName: data?[f.controllerName]?.toString() ?? '',
    };

    return Scaffold(
      body: GenericFormScreen(
        subTitle: data == null ? 'Novo Cargo' : 'Editar Cargo',
        onBack: () => Get.back(),
        onSave: (formValues) async {
          if (data == null || data!['id'] == null) {
            if(formValues['percentual']=='')
              formValues['percentual']='0';
            if(formValues['valor']=='')
              formValues['valor']='0';
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

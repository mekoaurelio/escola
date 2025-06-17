import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../services/utils.dart';
import '../widgets/formFieldData.dart';

class SimuladorAlt extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String tb;
  final String tipo;

  const SimuladorAlt({
    Key? key,
    this.data,
    required this.tb,
    required this.tipo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final fields = <FormFieldData>[
      tipo=='valor'?
      TextFormFieldData(controllerName: 'valor', label: 'Valor',
          inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt'),],
          tipo:'string'):

      TextFormFieldData(controllerName: 'percentual', label: 'Percentual',
          inputFormatters: [CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')],
          tipo:'string'),

    ];

    // Mapeia valores iniciais
    final initialValues = {
      for (var f in fields)
        f.controllerName: Utils.formatInitialValue(
            f.controllerName, data?[f.controllerName]?.toString() ?? '',f.tipo
        ),
    };

    return Scaffold(
      body: GenericFormScreen(
        subTitle: data==null?'Novo Dado': data!['descricao'],
        onBack: () => Get.back(),
        onSave: (formValues) async {
          if (data == null || data!['id'] == null) {
            print('NOVO');
             await ApiMySql.insertDynamic(formValues, tb);
          } else {
            print('EDITANDO');
            await ApiMySql.updateDynamic(tb,formValues,idValue: data!['id']);
            Get.back();
            //Utils.snak('congra'.tr, 'success'.tr, false, Colors.green);
          }
        },
        fieldsData: fields,
        initialValues: initialValues,
        hasImagePicker: false,
      ),
    );
  }
}



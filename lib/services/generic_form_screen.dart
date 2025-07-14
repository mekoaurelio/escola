import 'package:flutter/material.dart';
import 'package:psycostatattoo/widgets/custom_butom.dart';
import 'package:get/get.dart';

import '../login/direito_de_acesso.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/formFieldData.dart';
import '../widgets/texto.dart';

class GenericFormScreen extends StatefulWidget {
  final String title;
  final String subTitle;
  final String? imageName;
  final VoidCallback? onBack;
  final Future<void> Function(Map<String, String>) onSave;
  final List<FormFieldData> fieldsData; // <— aceita FormFieldData
  final Map<String, String>? initialValues;
  final bool hasImagePicker;

  const GenericFormScreen({
    Key? key,
    this.title = 'E-Learning',
    required this.subTitle,
    this.imageName,
    this.onBack,
    required this.onSave,
    required this.fieldsData, // <— aqui
    this.initialValues,
    this.hasImagePicker = true,
  }) : super(key: key);

  @override
  State<GenericFormScreen> createState() => GenericFormScreenState();
}

class GenericFormScreenState extends State<GenericFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (var field in widget.fieldsData)
        field.controllerName: TextEditingController(
          text: widget.initialValues?[field.controllerName] ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = _controllers.map((k, v) => MapEntry(k, v.text));
    await widget.onSave(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///Titulo da tela
          Center(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.44,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Texto(tit: widget.subTitle, cor: Colors.white,left: 10,),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.35,
            padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // imagePicker se necessário...
                    for (var field in widget.fieldsData) ...[
                      const SizedBox(height: 12),
                      if (field is TextFormFieldData)
                        CustomTextFiel(
                          controller: _controllers[field.controllerName],
                          label: field.label,
                          hintText: field.hintText,
                          prefixIcon: field.prefixIcon,
                          inputFormatters: field.inputFormatters,
                          obrigatorio: field.obrigatorio,

                          /*
                    keyboardType: field.tipo == 'dinheiro'
                        ? TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,

                     */
                        )
                      else if (field is DropdownFormFieldData)
                        DropdownButtonFormField<dynamic>(
                          value: widget.initialValues?[field.controllerName],

                          decoration: InputDecoration(
                            labelText: field.label,
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          items:
                              field.items
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item[field.idField],
                                      child: Text(
                                        item[field.displayField].toString(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) =>
                                  _controllers[field.controllerName]!.text =
                                      v.toString(),
                          validator: (v) => v == null ? 'Obrigatório' : null,
                        )
                      else
                        SizedBox.shrink(),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppButton(
                          onPressed: widget.onBack!,
                          text: 'Voltar',
                        ),
                        AppButton(
                          onPressed: _save,
                          text: 'Salvar',
                          backgroundColor: Colors.blue.shade300,
                        ),
                      ],
                    ),
                    TextButton(
                      child: const Text('Direitos de acesso'),
                      onPressed: () {
                        Get.to(() => DireitoDeAcesso(
                          acessosIniciais: {
                            "Simulador": false,
                            "Projeção dos Recursos do FUNDEB": false,
                          },
                        )
                            , arguments: {}); // Call the builder function
                      },

                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:psycostatattoo/data/api_my_sql.dart';
import 'package:psycostatattoo/widgets/custom_butom.dart';
import 'package:get/get.dart';

import '../login/direito_de_acesso.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/formFieldData.dart';
import '../widgets/painel.dart';
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
  final String? idUser;
  final String? nmUser;

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
    this.idUser,
    this.nmUser,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Título fixo no topo
          Container(
            height: 40,
            width: double.infinity, // ocupar 100% da largura
            color: Colors.blue.shade600,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            child: Texto(tit: widget.subTitle, cor: Colors.white),
          ),

          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

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
                              items: field.items.map(
                                    (item) => DropdownMenuItem(
                                  value: item[field.idField],
                                  child: Text(item[field.displayField].toString()),
                                ),
                              ).toList(),
                              onChanged: (v) =>
                              _controllers[field.controllerName]!.text = v.toString(),
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

                        if(widget.idUser!=null)
                        TextButton(
                          child: const Text('Direitos de acesso'),
                          onPressed: () async{
                            var id=widget.idUser;
                            var acessos=await ApiMySql.executaSql('select * from login_direitos where id_user=$id');
                            direito(acessos);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  direito(var acessos)async{
    bool a01=acessos[0]['simulador']=='1';
    bool a02=acessos[0]['projecao_dos_recursos_do_fundeb']=='1';
    bool a03=acessos[0]['professores']=='1';
    bool a04=acessos[0]['projecao_de_recursos']=='1';
    bool a05=acessos[0]['simulador_magisterio']=='1';
    bool a06=acessos[0]['professor_educador']=='1';
    bool a07=acessos[0]['educador_infantil']=='1';

    bool a08=acessos[0]['folha_de_pagamento']=='1';
    bool a09=acessos[0]['impacto']=='1';
    bool a10=acessos[0]['documentacao']=='1';
    bool a11=acessos[0]['encargos_sociais']=='1';


    var result=await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.40,
        height: double.infinity,
        child: DireitoDeAcesso(
          acessosIniciais: {
            "Simulador": a01,
            "Projeção dos Recursos do FUNDEB": a02,
            "Professores": a03,
            "Projeção de Recursos": a04,
            "Simulador Magistério": a05,
            "Professor Educador": a06,
            "Educador Infantil": a07,

            "Folha de Pagamento": a08,
            "Impacto": a09,
            "Documentação": a10,
            "Encargos Sociais": a11,
          },
          idUser: widget.idUser,
          nmUser: widget.nmUser,
          tipo: 'UPDATE',
        ),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }


}

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../services/utils.dart';

class CodDescri extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String table;

  const CodDescri({Key? key,
    this.data,
    required this.table,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: MyFormScreen(data: data,table: table,), // Pass the data
      ),
    );
  }
}

class MyFormScreen extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String table;

  MyFormScreen(
      {
    Key? key, this.data,
        required this.table,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> initialValues = {
      'descricao': data?['descricao']?.toString() ?? '',
    };

    final List<CustomTextFieldData> myFieldsData = [
      CustomTextFieldData(controllerName: 'descricao', label: 'Descrição', hintText: 'Descrição',prefixIcon: Icons.numbers),
     ];

    backToList()async{
      List data = await ApiMySql.get(table,null);
      Get.back(result: data);
    }

    Future<void> saveData(Map<String, String> datax) async {
      if (data?['id']==null) {
       // var idUser=await ApiMySql.insertCodDescri(datax);
        await ApiMySql.insertCodDescri(datax,table);
        backToList();
      } else {
        await ApiMySql.updateCodDescri(datax,data?['id'],table);
        Utils.snak('congra'.tr, 'success'.tr, false, Colors.green);
      }
    }

    return GenericFormScreen(
      subTitle: 'teste',
      imageName: 'assets/images/logo.png', // Replace with your image path
      fieldsData: myFieldsData,
      onBack: () => backToList(),
      onSave: saveData,
      initialValues: initialValues,
      hasImagePicker: false,
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/generic_form_screen.dart';
import '../services/utils.dart';
import '../widgets/formFieldData.dart';

class CodDescri extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String table;
  final List<Map<String, dynamic>>? dropdownItems; // se precisar

  const CodDescri({
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
      //appBar: AppBar(
       // title: Text(data == null ? 'Novo Cargo' : 'Editar Cargo'),
      //),
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
          final listaAtualizada = await ApiMySql.get(table, null);
          Get.back(result: listaAtualizada);
        },
        fieldsData: fields,
        initialValues: initialValues,
        hasImagePicker: false,
      ),
    );
  }
}

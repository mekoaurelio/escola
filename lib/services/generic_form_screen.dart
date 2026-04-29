import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../login/direito_de_acesso.dart';
import '../widgets/custom_butom.dart';
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
  final List<FormFieldData> fieldsData;
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
    required this.fieldsData,
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
  Map<String, TextEditingController>? _controllers;
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isDisposed) return;

    _controllers = {};
    for (var field in widget.fieldsData) {
      _controllers![field.controllerName] = TextEditingController(
        text: widget.initialValues?[field.controllerName] ?? '',
      );
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controllers != null) {
      for (var c in _controllers!.values) {
        if (c != null) c.dispose();
      }
      _controllers = null;
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_isInitialized || _controllers == null) {
      _showError('Formulário não inicializado');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final data = <String, String>{};
    _controllers!.forEach((k, v) {
      if (v != null) data[k] = v.text;
    });

    await widget.onSave(data);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading enquanto inicializa
    if (!_isInitialized || _controllers == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Título fixo no topo
          Container(
            height: 40,
            width: double.infinity,
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
                            _buildTextField(field)
                          else if (field is DropdownFormFieldData)
                            _buildDropdownField(field)
                          else
                            SizedBox.shrink(),
                        ],

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              onPressed: _handleBack,
                              text: 'Voltar',
                            ),
                            AppButton(
                              onPressed: _save,
                              text: 'Salvar',
                              backgroundColor: Colors.blue.shade300,
                            ),
                          ],
                        ),

                        if (widget.idUser != null)
                          TextButton(
                            child: const Text('Direitos de acesso'),
                            onPressed: () async {
                              if (!mounted) return;
                              var id = widget.idUser;
                              try {
                                var acessos = await ApiMySql.executaSql('select * from login_direitos where id_user=$id');
                                if (mounted) _showDireitosDialog(acessos);
                              } catch (e) {
                                print('Erro ao carregar direitos: $e');
                              }
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

  Widget _buildTextField(TextFormFieldData field) {
    final controller = _controllers?[field.controllerName];
    if (controller == null) return SizedBox.shrink();

    return CustomTextFiel(
      controller: controller,
      label: field.label,
      hintText: field.hintText,
      prefixIcon: field.prefixIcon,
      inputFormatters: field.inputFormatters,
      obrigatorio: field.obrigatorio,
    );
  }

  Widget _buildDropdownField(DropdownFormFieldData field) {
    final controller = _controllers?[field.controllerName];
    if (controller == null) return SizedBox.shrink();

    return DropdownButtonFormField<dynamic>(
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
      onChanged: (v) {
        if (controller != null) {
          controller.text = v?.toString() ?? '';
        }
      },
      validator: (v) {
        if (field.obrigatorio && v == null) {
          return 'Obrigatório';
        }
        return null;
      },
    );
  }

  void _showDireitosDialog(var acessos) async {
    if (!mounted) return;
    if (acessos == null || acessos.isEmpty) return;

    bool a01 = acessos[0]['simulador'] == '1';
    bool a02 = acessos[0]['projecao_dos_recursos_do_fundeb'] == '1';
    bool a03 = acessos[0]['professores'] == '1';
    bool a04 = acessos[0]['projecao_de_recursos'] == '1';
    bool a05 = acessos[0]['simulador_magisterio'] == '1';
    bool a06 = acessos[0]['professor_educador'] == '1';
    bool a07 = acessos[0]['educador_infantil'] == '1';
    bool a08 = acessos[0]['folha_de_pagamento'] == '1';
    bool a09 = acessos[0]['impacto'] == '1';
    bool a10 = acessos[0]['documentacao'] == '1';
    bool a11 = acessos[0]['encargos_sociais'] == '1';
    bool a12 = acessos[0]['notificacao'] == '1';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width * 0.40,
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
            "Notificação": a12,
          },
          idUser: widget.idUser,
          nmUser: widget.nmUser,
          tipo: 'UPDATE',
        ),
        onClose: () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

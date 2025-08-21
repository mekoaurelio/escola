// lib/screens/formulario_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/api_my_sql.dart';
import '../../services/databaseService.dart';
import '../../services/table_name_service.dart';
import '../../services/utils.dart';
import 'formulario.dart';


class FormularioBuilderScreen extends StatefulWidget {
  final Formulario formulario;

  const FormularioBuilderScreen({super.key, required this.formulario});

  @override
  State<FormularioBuilderScreen> createState() => _FormularioBuilderScreenState();
}

class _FormularioBuilderScreenState extends State<FormularioBuilderScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Formulario _formulario;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _percentFormat = NumberFormat.decimalPercentPattern(locale: 'pt_BR', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _formulario = widget.formulario;
  }

  Future<void> _salvarDados() async {
    await _dbService.salvarFormulario(_formulario);
    Utils.snak('Parabéns', 'Formulário salvo com sucesso!', false, Colors.green);
  }

  void _gerenciarItem([ItemFormulario? item]) {
    final formKey = GlobalKey<FormState>();
    bool isEditing = item != null;
    final valorFormatter = NumberFormat("#,##0.00", "pt_BR");
    final percentFormatter = NumberFormat("##0.00", "pt_BR");

    // Inicializa os dados para o diálogo
    final labelController = TextEditingController(text: isEditing ? item.label : '');

    final percentController = TextEditingController(
        text: isEditing && item.percentual != null ? percentFormatter.format(item.valor) : '');
    final valorController = TextEditingController(
        text: isEditing && item.valor != 0 ? valorFormatter.format(item.valor) : '');

   // final percentController = TextEditingController(text: isEditing ? item.percentual?.toString() ?? '' : '');
   // final valorController = TextEditingController(text: isEditing ? item.valor.toString() : '');
    TipoItem tipoSelecionado = isEditing ? item.tipo : TipoItem.progressao;

    showDialog(
      context: context,
      builder: (context) {
        // Usa um StatefulWidget para o diálogo para gerenciar o estado do Dropdown
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Item' : 'Adicionar Novo Item'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: labelController,
                        decoration: const InputDecoration(labelText: 'Label do Item'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                      ),
                      DropdownButton<TipoItem>(
                        value: tipoSelecionado,
                        isExpanded: true,
                        items: TipoItem.values.map((TipoItem tipo) {
                          return DropdownMenuItem<TipoItem>(
                            value: tipo,
                            child: Text(tipo.toString().split('.').last.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (novoTipo) {
                          if (novoTipo != null) {
                            setDialogState(() {
                              tipoSelecionado = novoTipo;
                            });
                          }
                        },
                      ),
                      if (tipoSelecionado != TipoItem.cabecalho)
                        TextFormField(
                          controller: valorController,
                         // controller: percentController,
                          decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ValorInputFormatter(),
                            //PercentInputFormatter(),
                          ],
                        ),
                      if (tipoSelecionado == TipoItem.cabecalho)
                        TextFormField(
                          controller: valorController,
                          decoration: const InputDecoration(labelText: 'Valor  (R\$)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ValorInputFormatter(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                ///Salvar
                ElevatedButton(
                  onPressed: () async{
                    if (formKey.currentState!.validate()) {
                      final label = labelController.text;
                      final percent = percentController.text==' '?'0.0':percentController.text.replaceAll(',', '.');
                      final valor = valorController.text==''?'0.0':Utils.saldoToSave(valorController.text);
                      print('valor $valor ');

                      var idForm=_formulario.id;
                      if(isEditing){
                        var idI=item.id;
                        await ApiMySql.executaSql('update $TBSimulaForm set label="$label",tipo="$tipoSelecionado",valor=$valor where id=$idI');
                      }else{
                        await ApiMySql.executaSql('insert INTO $TBSimulaForm (label,tipo,valor,id_form) Values ("$label","$tipoSelecionado",$valor,$idForm)');
                      }

                      setState(() {
                        if (isEditing) {
                          item.label = label;
                          item.tipo = tipoSelecionado;
                          item.percentual = double.parse(percent);
                          item.valor = double.parse(valor);
                        } else {
                          _formulario.itens.add(ItemFormulario(
                            id: _dbService.getProximoItemId(),
                            label: label,
                            tipo: tipoSelecionado,
                            percentual: double.parse(valor),
                            valor: double.parse(valor),
                          ));
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editando: ${_formulario.titulo}'),
      //  actions: [
        //  IconButton(icon: const Icon(Icons.save), onPressed: _salvarDados, tooltip: 'Salvar Ítens'),
       // ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _formulario.itens.isEmpty
              ? const Center(child: Text('Nenhum item adicionado ainda.'))
              : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                  child: Column(
                    children: _formulario.itens.map((item) => _buildItemRow(item)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _gerenciarItem(null),
        tooltip: 'Adicionar Novo Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemRow(ItemFormulario item) {
    // ... (O método _buildItemRow pode ser copiado da resposta anterior, ele já está bem dinâmico)
    // Pequena modificação para permitir editar qualquer item
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(item.label, style: TextStyle(
              fontSize: item.tipo == TipoItem.cabecalho ? 24 : 16,
              fontWeight: item.tipo == TipoItem.cabecalho ? FontWeight.bold : FontWeight.normal,
            )),
          ),
          if (item.percentual != null)
            Expanded(
              flex: 2,
              child: Text(
                _percentFormat.format(item.percentual! / 100),
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          if (item.valor > 0)
            Expanded(
              flex: 2,
              child: Text(
                _currencyFormat.format(item.valor),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: item.tipo == TipoItem.cabecalho ? 24 : 16,
                  fontWeight: item.tipo == TipoItem.cabecalho ? FontWeight.bold : FontWeight.normal,
                  color: item.tipo == TipoItem.cabecalho ? Colors.red.shade700 : Colors.black87,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
            onPressed: () => _gerenciarItem(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () async{
              final bool confirmar = await Utils.showDlg('Atenção','Confirma a exclusão?',context,'Sim','Não',);
              if (confirmar) {
               // print(item.label)
                print("DELETE FROM $TBSimulaForm WHERE id=${item.id}");
                await ApiMySql.executaSql("DELETE FROM $TBSimulaForm WHERE id=${item.id}");}
              setState(() { _formulario.itens.remove(item); });
              },
          ),
        ],
      ),
    );
  }
}


/// Formata o valor de um campo de texto para o padrão monetário brasileiro (ex: 9.999,99)
/// enquanto o usuário digita.
class ValorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Remove todos os caracteres não numéricos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 2. Converte a string de dígitos para um número (considerando os centavos)
    final number = double.parse(digitsOnly) / 100;

    // 3. Formata o número para o padrão pt_BR
    final newString = NumberFormat("#,##0.00", "pt_BR").format(number);

    // 4. Retorna o novo valor formatado, ajustando a posição do cursor
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}


/// Formata o valor de um campo de texto para um padrão de percentual com duas casas decimais (ex: 999,99)
/// enquanto o usuário digita.
class PercentInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Remove todos os caracteres não numéricos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // 2. Converte a string de dígitos para um número (considerando os centavos)
    final number = double.parse(digitsOnly) / 100;

    // 3. Formata o número com duas casas decimais usando a vírgula como separador
    final newString = NumberFormat("##0.00", "pt_BR").format(number);

    // 4. Retorna o novo valor formatado
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
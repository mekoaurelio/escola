import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/databaseService.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvando dados...')),
    );
    await _dbService.salvarFormulario(_formulario);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulário salvo com sucesso!'), backgroundColor: Colors.green),
    );
  }

  void _gerenciarItem([ItemFormulario? item]) {
    final formKey = GlobalKey<FormState>();
    bool isEditing = item != null;

    // Inicializa os dados para o diálogo
    final labelController = TextEditingController(text: isEditing ? item.label : '');
    final percentController = TextEditingController(text: isEditing ? item.percentual?.toString() ?? '' : '');
    final valorController = TextEditingController(text: isEditing ? item.valor.toString() : '');
    final valorProgressaoController = TextEditingController(text: isEditing ? item.valor_progressao.toString() : '');
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
                          controller: percentController,
                          decoration: const InputDecoration(labelText: 'Percentual (%)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      if (tipoSelecionado == TipoItem.cabecalho)
                        TextFormField(
                          controller: valorController,
                          decoration: const InputDecoration(labelText: 'Valor Base (R\$)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        final label = labelController.text;
                        final percent = double.tryParse(percentController.text);
                        final valor = double.tryParse(valorController.text) ?? 0.0;
                        final valorProgressao = double.tryParse(valorProgressaoController.text) ?? 0.0;

                        if (isEditing) {
                          item.label = label;
                          item.tipo = tipoSelecionado;
                          item.percentual = percent;
                          item.valor = valor;
                        } else {

                          _formulario.itens.add(
                              ItemFormulario(
                                id: _dbService.getProximoItemId(),
                                label: label,
                                nivel: label,
                                tipo: tipoSelecionado,
                                percentual: percent,
                                valor: valor,
                                valor_progressao: valorProgressao,
                                posicao:_formulario.itens.length+1,
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
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _salvarDados, tooltip: 'Salvar Formulário xxxx'),
        ],
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
            onPressed: () { setState(() { _formulario.itens.remove(item); }); },
          ),
        ],
      ),
    );
  }
}
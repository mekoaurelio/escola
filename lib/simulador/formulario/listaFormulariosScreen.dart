import 'package:GEM/data/api_my_sql.dart';
import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';

import '../../services/databaseService.dart';
import '../../services/utils.dart';
import 'formulario.dart';
import 'formularioBuilderScreen.dart';

class ListaFormulariosScreen extends StatefulWidget {
  const ListaFormulariosScreen({super.key});

  @override
  State<ListaFormulariosScreen> createState() => _ListaFormulariosScreenState();
}

class _ListaFormulariosScreenState extends State<ListaFormulariosScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Formulario>> _formulariosFuture;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() async{
    setState(() {
      _formulariosFuture = _dbService.carregarTodosOsFormularios();
    });
  }

  void _criarNovoFormulario(var titulo, var horas,var id) {
    final tituloController = TextEditingController();
    final horasController = TextEditingController();
    if(id!=null){
      tituloController.text=titulo;
      horasController.text=horas;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(titulo ?? 'Criar Novo Formulário'),
        content: Column(
          children: [
            //TITULO
            TextField(
              controller: tituloController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Título do Formulário'),
            ),
            //HORAS
            TextField(
              controller: horasController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Quantidade de Horas'),
            ),
          ],
        ),
        actions: [
          //BOTÃO CANCELAR
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          //BOTÃO SALVAR
          ElevatedButton(
            onPressed: () async {
              if (tituloController.text.isNotEmpty && horasController.text.isNotEmpty) {
                final tit=tituloController.text;
                final hor=horasController.text;

                if(id==null) {
                  final novoFormulario = await _dbService.criarNovoFormulario(tituloController.text, horasController.text);
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        FormularioBuilderScreen(formulario: novoFormulario),
                  ));
                }else{
                  var result = await ApiMySql.executaSql('update $TBSimulaCab  set descricao="$tit", horas=$hor where id=$id');
                }
                //Fecha o dialog
                Navigator.of(context).pop(); // Fecha o dialog

                _reloadData();
              }else{
                Utils.snak('Atenção', 'Preencha todos os Dados', false, Colors.red);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario(Formulario formulario) async {
    var _itens=await ApiMySql.getItensFromForm(TBSimulaForm,formulario.id,'id_form').timeout(const Duration(seconds: 30));
    formulario.itens.clear();
    for(int i = 0 ; i<_itens.length ; i++) {

      formulario.itens.add(
          ItemFormulario(
            id: int.parse(_itens[i]['id']),
            label: _itens[i]['label'],
            nivel: _itens[i]['nivel'],
            titulo: _itens[i]['titulo']??'',
            tipo:  getTipoItem(_itens[i]['tipo']),
            percentual: double.parse(_itens[i]['perc']?? '0.0'),
            valor: double.parse(_itens[i]['valor']),
            valor_progressao:  double.parse(_itens[i]['valor_progressao']),
            posicao: i,
      ));
    }

    // Navega e espera o retorno para atualizar a lista
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FormularioBuilderScreen(formulario: formulario),
    ));
    _reloadData();
  }

  getTipoItem(String item){
    if(item.contains('cabecalho')) return TipoItem.cabecalho;
    if(item.contains('progressao')) return TipoItem.progressao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estrutura das Carreiras'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Formulario>>(
        future: _formulariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Utils.vazio('Nenhum formulário criado.\nClique no botão "+" para começar.');
          }
          final formularios = snapshot.data ?? [];
          if (formularios.isEmpty) {
            return const Center(
              child: Text('Nenhum formulário criado.\nClique no botão "+" para começar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: formularios.length,
            itemBuilder: (context, index) {
              final form = formularios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${form.titulo}(${form.horas})'),
                  trailing: SizedBox(
                    width: 80,
                      child: Row(
                    children: [
                      //EDITAR
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () async {
                          _criarNovoFormulario(form.titulo,form.horas,form.id);
                          _reloadData();
                        },
                      ),
                      //EXCLUIR
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await _dbService.deletarFormulario(form.id,context);
                          _reloadData();
                        },
                      ),
                    ],
                  ),
              ),
                  onTap: () => _abrirFormulario(form),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _criarNovoFormulario(null,null,null);
          },
        tooltip: 'Criar Novo Formulário',
        child: const Icon(Icons.add),
      ),
    );
  }
}
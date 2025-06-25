import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';

class TabelasSimulador extends StatelessWidget {
  const TabelasSimulador({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projeção de Recursos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProjecaoRecursosScreen(),
    );
  }
}

class ProjecaoRecursosScreen extends StatefulWidget {
  const ProjecaoRecursosScreen({super.key});

  @override
  State<ProjecaoRecursosScreen> createState() => _ProjecaoRecursosScreenState();
}

class _ProjecaoRecursosScreenState extends State<ProjecaoRecursosScreen> {
  final List<Map<String, dynamic>> decenios = [];
  final List<Map<String, dynamic>> impostos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dadosDecenios = (await ApiMySql.get('a_decenio2501', null, null) as List).cast<Map<String, dynamic>>();
      final dadosImpostos = (await ApiMySql.get('a_impostos2501', null, null) as List).cast<Map<String, dynamic>>();

      setState(() {
        decenios.addAll(_mapearDados(dadosDecenios));
        impostos.addAll(_mapearDados(dadosImpostos));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Utils.snak('Atenção', 'Erro ao carregar dados: $e', false, Colors.red);
    }
  }

  List<Map<String, dynamic>> _mapearDados(List<Map<String, dynamic>> dados) {
    return dados.map((item) => {
      'id': int.tryParse(item['id'].toString()) ?? 0,
      'descricao': item['descricao'] as String,
      'valorProjetado': double.tryParse(item['vr1'].toString()) ?? 0.0,
      'recursoProprio': double.tryParse(item['vr2'].toString()) ?? 0.0,
    }).toList();
  }

  Future<void> _editarCampo({required int index, required bool isDecenio, required String campo}) async {
    final list = isDecenio ? decenios : impostos;
    final controller = TextEditingController(text: list[index][campo].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${campo == 'descricao' ? 'Descrição' : 'Valor Projetado'}'),
        content: TextField(
          controller: controller,
          keyboardType: campo == 'valorProjetado' ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: campo == 'valorProjetado'
              ? [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')]
              : [],
          decoration: InputDecoration(labelText: campo == 'descricao' ? 'Nova descrição' : 'Novo valor'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                if (campo == 'descricao') {
                  list[index][campo] = controller.text;
                } else {
                 // print()
                  final valor = double.tryParse(Utils.saldoToSave(controller.text)) ?? 0.0;
                  list[index]['valorProjetado'] = valor ;
                  list[index]['recursoProprio'] = valor * (isDecenio ? 0.05 : 0.25);
                }
              });
              _salvarDadosTabela(isDecenio: isDecenio, index: index);
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  double _calcularTotal(List<Map<String, dynamic>> items, String campo) {
    return items.fold(0.0, (sum, item) => sum + (item[campo] ?? 0.0));
  }

  Widget _buildTabela(String titulo, List<Map<String, dynamic>> dados, bool isDecenio, double percentual) {
    return Column(
      children: [
        Texto(tit: titulo, negrito: true, tam: 16, alin: TextAlign.center, bottom: 16),
        DataTable(
          columnSpacing: 16,
          columns:  [
            DataColumn(label: Texto(tit:'Descrição',cor:Colors.blue.shade800,negrito: true,)),
            DataColumn(label: Texto(tit:'Valor Projetado Ano',cor:Colors.blue.shade800,negrito: true)),
            DataColumn(label: Texto(tit:'Recurso Próprio',cor:Colors.blue.shade800,negrito: true)),
          ],
          rows: [
            ...dados.map((item) => DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => _editarCampo(index: dados.indexOf(item), isDecenio: isDecenio, campo: 'descricao'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Line(tex: item['descricao'], tam: 300, alin: Alignment.centerLeft),
                        Icon(Icons.edit, size: 10)
                      ],
                    ),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () => _editarCampo(index: dados.indexOf(item), isDecenio: isDecenio, campo: 'valorProjetado'),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Texto(tit: Utils.formatVr.format(item['valorProjetado'])),
                          Icon(Icons.edit, size: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Texto(tit: Utils.formatVr.format(item['recursoProprio'])),
                  ),
                ),
              ],
            )),

            ///TOTAIS
            DataRow(
              color: WidgetStateProperty.all(Colors.blue.shade50),
              cells: [

                DataCell(Texto(tit:'Total', negrito: true,cor:Colors.blue.shade800)),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Texto(tit: Utils.formatVr.format(_calcularTotal(dados, 'valorProjetado')), negrito: true,cor:Colors.blue.shade800),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Texto(tit: Utils.formatVr.format(_calcularTotal(dados, 'recursoProprio')), negrito: true,cor:Colors.blue.shade800),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Future<void> _salvarDadosTabela({required bool isDecenio, required int index}) async {
    final item = isDecenio ? decenios[index] : impostos[index];
    final tabela = isDecenio ? 'a_decenio2501' : 'a_impostos2501';
    final double vr1 = item['valorProjetado'] ?? 0.0;
    final double vr2 = item['recursoProprio'] ?? 0.0;
    var dados=isDecenio ? decenios:impostos;

    try {
      var des=item['descricao'];

      var tot1=_calcularTotal(dados, 'valorProjetado');
      var tot2=_calcularTotal(dados, 'recursoProprio');
      print("Update $tabela set descricao='$des', vr1=$vr1,vr2=$vr2, total1=$tot1,total2=$tot2  where id = ${item['id']}");
      await ApiMySql.executaSql("Update $tabela set descricao='$des', vr1=$vr1,vr2=$vr2, total1=$tot1,total2=$tot2  where id = ${item['id']}");
    } catch (e) {
      Utils.snak('Erro', 'Falha ao salvar: $e', false, Colors.red);
    }
  }

  Widget _resumo() {
    return Container(

      width: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Texto(tit: 'Consolidações de Recursos Anuais para MDE', negrito: true, tam: 15, alin: TextAlign.center),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza os filhos na horizontal
            children: [
              Line(tex: 'Receita/Complementação', tam: 520,cor: Colors.blue.shade800,negrito: true,fontSize: 15,
                alin: Alignment.centerLeft,),
              Line(tex: 'Valor', tam: 100,cor: Colors.blue.shade800,negrito: true,fontSize: 15,
                  alin: Alignment.centerRight,bottom: 20,),
            ],
          ),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('1.Receitas recebidas do FUNDEB', 4940940),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('1.1.Complementação da UNIÃO - FUNDEB - VAAF - 10%', 1250000),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('1.2.Complementação da UNIÃO - FUNDEB - VAAT - 10,5%', 320000),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('1.3.Complementação da UNIÃO - FUNDEB - VAAR - 2,5%', 320000),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('Receita  Total - FUNDEB', 320000),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('2. Receitas recursos próprios 5%', 320000),
          Divider(thickness: 1.5,color: Colors.grey.shade300,),
          linha('3. Receitas recursos próprios 25%', 320000),
        ],
      ),
    );
  }


  Widget linha(var tit,var vr){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Line(tex: tit, tam: 520,negrito: true,fontSize: 15,alin: Alignment.centerLeft,),
        Line(tex: vr.toString(), tam: 100,negrito: true,fontSize: 15,alin: Alignment.centerRight,bottom: 10,),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(title: Text('Projeção de Recursos')),
      appBar: AppBar(
        title: Texto(tit: 'Projeção de Recursos',cor:Colors.white ,negrito: true,tam: 20,),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:Column(
            children: [
              _resumo(),
              SizedBox(height:32 ),
              _buildTabela('Tabela 02 - Projeção do mínimo de 5% para investimento em MDE', decenios, true, 0.05),
              SizedBox(height: 32),
              _buildTabela('Tabela 03 - Projeção do mínimo de 25% para investimento em MDE', impostos, false, 0.25),
            ],
          ),
        )
      ),
    );
  }
}
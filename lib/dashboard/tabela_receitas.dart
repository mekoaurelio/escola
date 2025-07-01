import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycostatattoo/services/utils.dart';
import 'package:psycostatattoo/widgets/texto.dart';
import 'package:psycostatattoo/data/api_my_sql.dart';

import '../const/nome_tabelas.dart';

class TabelaReceitas extends StatefulWidget {
  @override
  _TabelaReceitasState createState() => _TabelaReceitasState();
}

class _TabelaReceitasState extends State<TabelaReceitas> {
  var  totais;
  String vrInput = '0,00';
  String receitaTotalFundeb = '0,00';
  String receitaTotal = '0,00';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await ApiMySql.get(TBTotais, null, null);
      if(dados.length==0){
        return;
      }
      setState(() {
        totais = dados;
        vrInput = Utils.formatVr.format(double.parse(dados[0]['fundeb_10_5']));

        // Calcular totais
        double receitaFundeb = double.parse(dados[0]['receita']) + double.parse(dados[0]['fundeb_10_5']);
        receitaTotalFundeb = Utils.formatVr.format(receitaFundeb);

        double totalGeral = receitaFundeb +
            double.parse(dados[0]['decendio_5']) +
            double.parse(dados[0]['imposto_25']);
        receitaTotal = Utils.formatVr.format(totalGeral);
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        totais = [
          {
            'receita': '0',
            'fundeb_10_5': '0',
            'decendio_5': '0',
            'imposto_25': '0'
          }
        ];
      });
    }
  }

  Widget _linhaCompacta(String descricao, String valor,
      {bool editavel = false,Color corContainer=Colors.transparent,double height=20}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: corContainer,
          borderRadius: BorderRadius.circular(
              10.0), // Opcional: bordas arredondadas
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Texto(tit: descricao,tam: 12,cor:Colors.black87 ,),
            ),
            if (editavel)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Texto(tit: valor,tam: 12,negrito: true,right: 10),
                  IconButton(
                    icon: Icon(Icons.edit, size: 16),
                    onPressed: () => _editarValor(),
                  ),
                ],
              )
            else
              Texto(tit:valor,tam: 12,negrito: true,right: 5),
          ],
        ),
      )
    );
  }

  Future<void> _editarValor() async {
    await Utils.mostrarDialogoEditarValor(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))
      ],
      context: context,
      titulo: 'Editar Valor',
      labelCampo: 'Valor',
      valorInicial: vrInput,
      aoSalvar: (novoValor) async {
        double valorNumerico = Utils.vrStringToDouble(novoValor);
        await ApiMySql.executaSql('Update $TBTotais set fundeb_10_5=$valorNumerico');
        var r = totais[0]['receita'];
        double nv = valorNumerico + double.parse(r);
        setState(() {
          vrInput = Utils.formatVr.format(valorNumerico);
          receitaTotalFundeb = Utils.formatVr.format(nv);double totalGeral = nv +
              double.parse(totais[0]['decendio_5']) +
              double.parse(totais[0]['imposto_25']);
          receitaTotal = Utils.formatVr.format(totalGeral);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.5,
      child:totais==null?Utils.vazio('Nenhum Dado Encontrado'):

      Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    'Valor (R\$)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),

              Divider(thickness: 1, color: Colors.grey.shade300),

              // Conteúdo rolável
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    children: [
                      _linhaCompacta('1. Receitas FUNDEB',
                      Utils.formatVr.format(double.parse(totais[0]['receita']))),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('1.1. Complementação VAAF 10%', '0'),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('1.2. Complementação VAAT 10,5%', vrInput),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('1.3. Complementação VAAR 2,5%', '0'),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('Total FUNDEB', receitaTotalFundeb),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('2. Recursos próprios 5%',
                          Utils.formatVr.format(double.parse(totais[0]['decendio_5']))),
                      Divider(thickness: 1, height: 1, color: Colors.grey.shade300),
                      _linhaCompacta('3. Recursos próprios 25%',
                          Utils.formatVr.format(double.parse(totais[0]['imposto_25']))),

                     // Divider(thickness: 1, height: 1, color: Colors.grey.shade200),
                      //_linhaCompacta('TOTAL GERAL', receitaTotal,corContainer: Colors.blue.shade200),
                    ],
                  ),
                ),
              ),

              // Rodapé
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _linhaCompacta(' TOTAL GERAL', receitaTotal,corContainer: Colors.blue.shade200,height: 30)
                //Texto(tit: 'Atualizado em ${DateTime.now().toString().substring(0, 16)}',
                  //tam: 10,cor: Colors.grey,alin:TextAlign.center ,
                //),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
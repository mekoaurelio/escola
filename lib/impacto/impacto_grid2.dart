import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Adicionado para formatação
import 'package:psycostatattoo/const/nome_tabelas.dart';
import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';
import 'hoverableDataRow.dart';
import 'impacto_Financeiro_Data.dart';

class ImpactoGrid2 extends StatefulWidget {
  const ImpactoGrid2({Key? key}) : super(key: key);

  @override
  _ImpactoGrid2State createState() => _ImpactoGrid2State();
}

class _ImpactoGrid2State extends State<ImpactoGrid2> with AnoBimestreListenerMixin{
  final ValueNotifier<Map<String, String>> valueUpdates = ValueNotifier({});
  ImpactoFinanceiroData? _impactoData;
  bool _isLoading = true;
  double receitaFundeb=0;
  double nro1=1;
  double nro2=2;
  double nro4=4;
  static  List<Texto> _dadosDoExercicio=[];
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '');
  //String ano='',bimestre='';

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    _atualizaTela(ano,bimestre);
  }

  _atualizaTela(var ano,var bimestre){
    setState(() {
      TBFolha='a$ano$bimestre';
      TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
      _loadData();
    });
  }

  ///A DESCRICAO DOS DADOS DA FOLHA
  static final List<Texto> _dadosDaFolhaDePagamento = [
    Texto(tit: '1. Valor da folha de vencimentos básicos - Mensal - R/\$',tooltip: d1,),
    Texto(tit: '2. Valor das vantagens pecuniárias - Mensal - R/\$', icone: Icons.help,tooltip: d2,),
    Texto(tit: '3. Percentual das vantagens pecuniárias sobre a folha de vencimento', icone: Icons.help,tooltip: d3,),
    Texto(tit: '4. Custo total da folha de pagamento líquida mensal', icone: Icons.help,tooltip: d4,),
    Texto(tit: '5. Encargos previdenciários', icone: Icons.help,tooltip: d5,),
    Texto(tit: '6. Encargos previdenciários (14%)', icone: Icons.help,tooltip: d6,),
    Texto(tit: '7. Valor do décimo terceiro 1/12', icone: Icons.help,tooltip: d7,),
    Texto(tit: '8. Valor 1/3 férias (proporcional)', icone: Icons.help,tooltip: d8,),
    Texto(tit: '9. Total folha mensal', icone: Icons.help,tooltip: d9,),
    Texto(tit: '10. Total folha bruta anual', icone: Icons.help,tooltip: d10,),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lista = await ApiMySql.getProfessor();
      final fundeb = await ApiMySql.get(TBReceitaFundebSimulador, null,null);

      /// A DESCRICAO DOS DADOS DO EXERCICIO
      _dadosDoExercicio = [
        Texto(tit: '1-Receita de Impostos ',left: 10,negrito: true,),
        Texto(tit: '2-Receitas de Transferências',tooltip: d12,icone: Icons.help),
        Texto(tit: 'Total Receita - (1 + 2)',negrito: true,),
        Texto(tit: ' 3-Receitas Destinadas ao Fundeb (20%) ', icone: Icons.help,tooltip: 'nro2 * 20%',),
        Texto(tit: ' 4-Receitas Recebidas do FUNDEB - (FNDE) ', icone: Icons.help,),
        Texto(tit: ' 5-Pag dos Profincionais do Magistério (70%) ', icone: Icons.help,tooltip: 'Total da Folha Bruta',),
        Texto(tit: ' GANHO/PERDA ', icone: Icons.help,negrito: true,tooltip: 'nro4 / nro3',),
        Texto(tit: ' 6- Conta 25% (1.104) - (25% - 1)', icone: Icons.help,tooltip: 'nro1 * 25%',),
        Texto(tit: ' 7 - Conta 5% (1.103) - (5% - 2)', icone: Icons.help,tooltip: 'nro2 * 5%',),
        Texto(tit: ' 8 - Mínimo 70% - Folha dos profissionais do magistério (5/4) ', icone: Icons.help,tooltip: 'nro5 / nro4',),
        Texto(tit: 'TOTAL - Consolidação de recursos para MDE - (4 + 6 + 7)', icone: Icons.help,negrito: true,),
      ];

      setState(() {
        receitaFundeb=double.parse(fundeb[4]['valor']);
        _impactoData = ImpactoFinanceiroData.fromApiData(lista);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _impactoData=null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _impactoData == null
          ? Utils.vazio('Nenhum dado de Impacto para esse ano/bimestre')
          : SingleChildScrollView( // Rolagem principal para a página inteira
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center( // Centraliza o conteúdo na tela
          child: ConstrainedBox( // Define uma largura máxima para o conteúdo
            constraints: const BoxConstraints(maxWidth: 800), // Largura generosa
            child: Column( // Organiza os cards verticalmente
              crossAxisAlignment: CrossAxisAlignment.stretch, // Faz os cards ocuparem a largura
              children: [
                // ===================================
                // CARD 1: DADOS DA FOLHA DE PAGAMENTO
                // ===================================
                _buildSectionCard(
                  title: 'DADOS DA FOLHA DE PAGAMENTO',
                  child: _buildDadosDaFolha(_impactoData!),
                ),

                const SizedBox(height: 32), // Espaço entre os cards

                // ===================================
                // CARD 2: DADOS DO EXERCÍCIO
                // ===================================
                _buildSectionCard(
                  title: 'DADOS DO EXERCÍCIO',
                  child: _buildDadosDoExercio(_impactoData!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


// NOVO WIDGET HELPER PARA OS CARDS
  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///TITULOS
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08), // Cor de fundo azul claro da imagem
              ),
              child: Center(
                child:Texto(tit: title,tam: 18,negrito: true,cor: Colors.blue,),
              ),
            ),
            // A rolagem horizontal garante que o conteúdo nunca cause overflow
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ],
        ),

    );
  }

  Widget _buildDadosDaFolha(ImpactoFinanceiroData data) {
    final values = [
      // Texto(tit: '1-Receita de Impostos',exibirIcone: false,icone: Icons.ac_unit),
      _currencyFormat.format(data.totalVencimentos),
      _currencyFormat.format(data.totalVantagens),
      '${data.percentualVantagens.toStringAsFixed(2)}%',
      _currencyFormat.format(data.custoTotalLiquido),
      '14%', // Valor fixo conforme o original
      _currencyFormat.format(data.encargosPrev14Percent),
      _currencyFormat.format(data.decimoTerceiroProporcional),
      _currencyFormat.format(data.feriasProporcional),
      _currencyFormat.format(data.totalFolhaMensal),
      _currencyFormat.format(data.totalFolhaAnual),
    ];

    return Column(
      children:

      List.generate(_dadosDaFolhaDePagamento.length, (index) {final bool isTotal = index >= 8;
        return
         HoverableDataRow(
          label: _dadosDaFolhaDePagamento[index].tit,
          icon: _dadosDaFolhaDePagamento[index].icone,
          tooltip: _dadosDaFolhaDePagamento[index].tooltip,
          value: values[index],
          isHighlighted: isTotal,
           onValueChanged: (label, newValue) {
          },
        );
      }),
    );
  }

  ///DADOS DO EXERCICIO 2025
  ///CALCULOS
  Widget _buildDadosDoExercio(ImpactoFinanceiroData data) {

    ///Faz todos os calculos
    final List<ValorComIcone> valoresComIcones = [
      ValorComIcone(_currencyFormat.format(nro1), icone: Icons.edit, tooltip: 'Receita de impostos municipais', editavel: true,),//1
      ValorComIcone(_currencyFormat.format(nro2), icone: Icons.edit, tooltip: 'Transferências constitucionais', editavel: true,),//2
      ValorComIcone(_currencyFormat.format(nro1 + nro2)), // SOMA
      ValorComIcone(_currencyFormat.format(nro2 *0.20)), //  3
      ValorComIcone(_currencyFormat.format(nro4), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//4
      ValorComIcone(_currencyFormat.format(data.totalFolhaAnual), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//5
      ValorComIcone(_currencyFormat.format(nro1-(nro1 + nro2)), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//ganhos e perdas
      ValorComIcone(_currencyFormat.format(nro1 * 0.25), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//6
      ValorComIcone(_currencyFormat.format(nro2 * 0.05), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//7
      ValorComIcone(_currencyFormat.format((nro4 / nro4)*100), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),//8
      ValorComIcone(_currencyFormat.format(nro4 + (nro1 * 0.25) + (nro2 * 0.05)), icone: Icons.edit, tooltip: 'Editar valor', editavel: true,),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_dadosDoExercicio.length, (index) {
          final valor = valoresComIcones[index];
          return HoverableDataRow(
            label: _dadosDoExercicio[index].tit,
            icon: _dadosDoExercicio[index].icone,
            tooltip: _dadosDoExercicio[index].tooltip,
            value: valor.valor,
            valueIcon: valor.icone,
            valueTooltip: valor.tooltip,
            isHighlighted: true,
            negrito: _dadosDoExercicio[index].negrito,
            onValueChanged: valor.editavel ? (label, newValue) {
              valueUpdates.value = {'label': label, 'value': newValue};
              String vr = Utils.saldoToSave(newValue);
              setState(() {
                if (label.contains('1-Receita de Impostos')) {
                  nro1 = double.tryParse(vr) ?? nro1;
                } else if (label.contains('2-Receitas de Transferências')) {
                  nro2 = double.tryParse(vr) ?? nro2;
                } else if (label.contains('4-Receitas Recebidas do FUNDEB')) {
                  nro4 = double.tryParse(vr) ?? nro4;
                }
              });
            } : null,
          );
        }),
      ]
    );
  }
}

class ValorComIcone {
  final String valor;
  final IconData? icone;
  final String? tooltip;
  final bool editavel;

  ValorComIcone(
      this.valor, {
        this.icone,
        this.tooltip,
        this.editavel = false,
      });
}
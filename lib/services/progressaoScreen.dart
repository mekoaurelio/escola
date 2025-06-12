import 'package:flutter/material.dart';
import '../data/api_my_sql.dart';
import '../simulador/simulador_alt.dart';
import '../widgets/line.dart';
import '../widgets/painel.dart';
import '../widgets/texto.dart';
import 'utils.dart';

class ProgressaoScreen extends StatefulWidget {
  const ProgressaoScreen({Key? key}) : super(key: key);

  @override
  _ProgressaoScreenState createState() => _ProgressaoScreenState();
}

class _ProgressaoScreenState extends State<ProgressaoScreen> {
  List<Map<String, dynamic>> prof = [];
  List<Map<String, dynamic>> infantil = [];
  List<Map<String, dynamic>> fundeb = [];
  List<Map<String, dynamic>> exercicio = [];

  double? fundebBase; // Valor da ordem 1 do FUNDEB RECEITA

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);

    final f = await ApiMySql.get('sim_prof', null, 'ordem');
    final i = await ApiMySql.get('sim_edu_infantil', null, 'ordem');
    final g = await ApiMySql.get('sim_fundeb_receita', null, 'ordem');
    final h = await ApiMySql.get('sim_exercicio', null, 'ordem');

    fundebBase = double.tryParse(
        g.firstWhere((e) => e['ordem'] == '1', orElse: () => {'valor': 0})['valor'].toString());

    setState(() {
      prof = List<Map<String, dynamic>>.from(f);
      infantil = List<Map<String, dynamic>>.from(i);
      fundeb = List<Map<String, dynamic>>.from(g);
      exercicio = List<Map<String, dynamic>>.from(h);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.7,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Section(
                title: 'SIMULADOR PCRM – PROFESSORES',
                table: 'sim_prof',
                items: prof,
                onEdited: _loadAll,
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'SIMULADOR PCRM – EDUCADOR INFANTIL (40h)',
                table: 'sim_edu_infantil',
                items: infantil,
                onEdited: _loadAll,
              ),
              const SizedBox(height: 24),
              _SectionFundebExercio(
                title: 'FUNDEB RECEITA',
                table: 'sim_fundeb_receita',
                items: fundeb,
                fundeb: [],
                onEdited: _loadAll,
                referencia: null, // Não usa referência
              ),
              const SizedBox(height: 24),
              _SectionFundebExercio(
                title: 'EXERCÍCIO',
                table: 'sim_exercicio',
                items: exercicio,
                fundeb: fundeb,
                onEdited: _loadAll,
                referencia: fundebBase, // 🔥 Usa o valor do FUNDEB
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Widget genérico para exibir uma seção com título e lista de itens
/// INFANTIL
class _Section extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items; //Tabela fundeb ou infantil
  final VoidCallback onEdited;
  final String table;

  const _Section({
    Key? key,
    required this.title,
    required this.items,
    required this.onEdited,
    required this.table,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula iterativamente os valores compostos:
    double? lastValue;
    double? firstValue;
    final cards = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final data = items[i];
      final rawValor = double.tryParse(data['valor'].toString()) ?? 0;
      final perc = double.tryParse(data['percentual'].toString()) ?? 0;

      // Primeiro item: usa rawValor. Depois, valor anterior * (1 + perc/100)
      var computed = (i == 0) ? rawValor : (lastValue! * (1 + perc / 100));
      if(data['ordem']=='0'){
        firstValue=computed;
      }
      if(data['ordem']=='1' || data['ordem']=='7'){
        computed=0;
      }
      if(data['ordem']=='2'){
        computed=(firstValue!*perc/100);
      }
      if(data['ordem']=='3'){
        computed=firstValue!;
      }

      lastValue = computed;
      print('TITULO : $title ORDEM : '+data['ordem']+' VALOR :$computed PERCENTUAL : $perc TABELA : $table');

      if(data['ordem']=='3'){
        updateValor(firstValue,data['ordem']);
      }
      if(data['ordem']=='2' || data['ordem']=='4' || data['ordem']=='5' || data['ordem']=='6' ) {
       updateValor(computed,data['ordem']);
      }

      cards.add(
        _ItemCard(
          data: data,
          displayValue: computed,
          isFirst: i == 0,
          index: i,
          onEdited: onEdited,
          table: table,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child:Card(
            color: Colors.grey.shade300,
            elevation: 0,
            shape: Utils.borda(),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Texto(
                tit: title,
                cor: Colors.black,
                alin: TextAlign.center,
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () async {
                  // abre o dialog e, quando fechar, dispara o callback:
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (_) => Panel(
                      width: MediaQuery.of(context).size.width * 0.44,
                      height: MediaQuery.of(context).size.height * 0.44,
                      child: SimuladorAlt(
                        data: null,
                        tb: table,
                        tipo: 'percentual',
                      ),
                      onClose: () => Navigator.of(context).pop(),
                    ),
                  );
                  onEdited(); // <— aqui recarrega a tela
                },
              ),
            ],
          ),
          )
        ),
        Center(child: Column(children: cards)),
      ],
    );
  }

  updateValor(var computed,var ordem)async{
    await ApiMySql.executaSql('UPDATE $table set valor=$computed where ordem=$ordem');
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isFirst;
  final int index;
  final VoidCallback onEdited;
  final double displayValue;
  final String table;

  const _ItemCard({
    Key? key,
    required this.data,
    required this.isFirst,
    required this.index,
    required this.onEdited,
    required this.displayValue,
    required this.table,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formata o valor em real
    String valorStr='0';
    if(displayValue!=0){
      valorStr = Utils.toReal(displayValue);
    }
    return Row(
        children: [
          /// Descrição
          Line(
            tex: data['descricao'] ?? '',
            tam: 350,
            cor: isFirst ? Colors.black : Colors.black54,
            alin: Alignment.centerLeft,
            negrito: isFirst,
            fontSize: isFirst ? 20 : 16,
          ),

          /// Percentual
          Line(
            tex: isFirst ? ' ' : '${data['percentual']}%',
            tam: 80,
            cor: Colors.black54,
            alin: Alignment.centerRight,
            fontSize: 16,
          ),

          ///EDITA O PERCENTUAL
          if (!isFirst)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey, size: 15),
              onPressed: () async {
                // abre o dialog e, quando fechar, dispara o callback:
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => Panel(
                    width: MediaQuery.of(context).size.width * 0.44,
                    height: MediaQuery.of(context).size.height * 0.44,
                    child: SimuladorAlt(
                      data: data,
                      tb: table,
                      tipo: 'percentual',
                    ),
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
                onEdited(); // <— aqui recarrega a tela
              },
            ),

          /// Valor calculado
          Line(
            tex: valorStr=='0'?'':valorStr,
            tam: 200,
            cor: isFirst ? Colors.red : Colors.black87,
            alin: Alignment.centerRight,
            negrito: isFirst,
            fontSize: isFirst ? 18 : 15,
          ),
          ///ICONE PARA DELETAR
         /*
          IconButton(
            onPressed: () => delete(),
            icon: Icon(Icons.delete, color: Colors.black38,),
          ),

          */

          ///EDITA O VALOR BÁSICO
          if (isFirst)
            IconButton(
              icon: const Icon(Icons.handshake_outlined, color: Colors.grey, size: 15,),
              onPressed: () async {
                // abre o dialog e, quando fechar, dispara o callback:
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => Panel(
                        width: MediaQuery.of(context).size.width * 0.44,
                        height: MediaQuery.of(context).size.height * 0.44,
                        child: SimuladorAlt(
                          data: data,
                          tb: table,
                          tipo: 'valor',
                        ),
                        onClose: () => Navigator.of(context).pop(),
                      ),
                );
                onEdited(); // <— aqui recarrega a tela
              },
            ),
        ],
      );

  }
  delete(){

  }
}

class _ItemFundebExercicio extends StatelessWidget {
  final Map<String, dynamic> data;
  final double perct;
  final int index;
  final VoidCallback onEdited;
  final double displayValue;
  final String table;

  const _ItemFundebExercicio({
    Key? key,
    required this.data,
    required this.perct,
    required this.index,
    required this.onEdited,
    required this.displayValue,
    required this.table,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formata o valor em real
    String valorStr='0';
    if(displayValue!=0){
      valorStr = Utils.toReal(displayValue);
    }
    return
      valorStr=='0'?Container():
      Row(
      children: [
        /// Descrição
        Line(
          tex: data['descricao'] ?? '',
          tam: 350,
          cor: Colors.black54,
          alin: Alignment.centerLeft,
          negrito: true,
          fontSize: 16,
        ),

        /// Valor calculado
        Line(
          tex: valorStr=='0'?'':valorStr,
          tam: 200,
          cor: Colors.black87,
          alin: Alignment.centerRight,
          negrito: true,
          fontSize:  16,
        ),
        ///EDITA O VALOR
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey, size: 15),
          onPressed: () async {
            // abre o dialog e, quando fechar, dispara o callback:
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (_) => Panel(
                width: MediaQuery.of(context).size.width * 0.44,
                height: MediaQuery.of(context).size.height * 0.44,
                child: SimuladorAlt(
                  data: data,
                  tb: table,
                  tipo: 'valor',
                ),
                onClose: () => Navigator.of(context).pop(),
              ),
            );
            onEdited(); // <— aqui recarrega a tela
          },
        ),

        /// Percentual
        Line(
          tex: perct==0?'':perct.toStringAsFixed(2)+'%',
          tam: 80,
          cor: Colors.black54,
          alin: Alignment.centerRight,
          fontSize: 16,
        ),
        ///ICONE PARA DELETAR
        /*
          IconButton(
            onPressed: () => delete(),
            icon: Icon(Icons.delete, color: Colors.black38,),
          ),

          */
      ],
    );
  }
  delete(){
  }
}

class _SectionFundebExercio extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> fundeb;
  final VoidCallback onEdited;
  final String table;
  final double? referencia; // <-- Nova variável de referência

  const _SectionFundebExercio({
    super.key,
    required this.title,
    required this.items,
    required this.fundeb,
    required this.onEdited,
    required this.table,
    this.referencia,
  });

  @override
  Widget build(BuildContext context) {
    double? lastValue;
    final cards = <Widget>[];
    int x=0;
    double vrFundeb=0.0;
    for (var data in items) {
      final rawValor = double.tryParse(data['valor'].toString()) ?? 0;
      double computed = rawValor;
      double perc = 0;
      if(fundeb.isNotEmpty) {
        if(x<=6) {
          vrFundeb=double.tryParse(fundeb[x]['valor'].toString()) ?? 0;
         // print('VALOR DA FUNDEB $x');
          print(fundeb[x]['valor']);
        }
      }

      if (data['ordem'] == '1') {
        computed = rawValor;
        if(title=='EXERCÍCIO'){
          ///PEGA O PRIMEIRO VALOR E O PRIMEIRO PERCENTUAL
          perc =   (rawValor!/referencia!)*100;
        }
      } else if (referencia != null) {
        /// PEGA TODOS OS VALORES
          perc = (rawValor/vrFundeb)*100;
          //print('VALOR FUNDEB  $vrFundeb VALOR EXERCICIO $rawValor PERCENTUAL $perc');

          computed = rawValor;
      }

      if(title=='FUNDEB RECEITA') {
        if (lastValue != null && lastValue != 0) {
          perc = ((rawValor - lastValue) / lastValue) * 100;
        }
      }

      lastValue = computed;

      cards.add(
        _ItemFundebExercicio(
          data: data,
          displayValue: computed,
          perct: perc,
          index: items.indexOf(data),
          onEdited: onEdited,
          table: table,
        ),
      );
      x++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(context),
        ...cards,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.grey.shade300,
      elevation: 0,
      shape: Utils.borda(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Texto(
            tit: title,
            cor: Colors.black,
            alin: TextAlign.center,
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () async {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Panel(
                  width: MediaQuery.of(context).size.width * 0.44,
                  height: MediaQuery.of(context).size.height * 0.44,
                  child: SimuladorAlt(
                    data: null,
                    tb: table,
                    tipo: 'valor',
                  ),
                  onClose: () => Navigator.of(context).pop(),
                ),
              );
              onEdited();
            },
          ),
        ],
      ),
    );
  }
}
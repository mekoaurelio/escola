import 'package:flutter/material.dart';
import '../data/api_my_sql.dart';
import '../simulador/simulador_alt.dart';
import '../widgets/line.dart';
import '../widgets/painel.dart';
import '../widgets/texto.dart';
import 'utils.dart';

/*
/// Tela que mostra duas seções: Fundeb e Infantil
class ProgressaoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> fundeb;
  final List<Map<String, dynamic>> infantil;

  const ProgressaoScreen({
    Key? key,
    required this.fundeb,
    required this.infantil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SingleChildScrollView(
          // Reduz o padding top para diminuir o espaço acima
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),  // Alterado de EdgeInsets.all(16)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                title: 'SIMULADOR PCRM – PROFESSORES',
                items: fundeb,
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'SIMULADOR PCRM – EDUCADOR INFANTIL (40h)',
                items: infantil,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget genérico para exibir uma seção com título e lista de itens
class _Section extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const _Section({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula iterativamente os valores compostos:
    double? lastValue;
    final cards = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final data = items[i];
      final rawValor = double.tryParse(data['valor'].toString()) ?? 0;
      final perc      = double.tryParse(data['percentual'].toString()) ?? 0;

      // Primeiro item: usa rawValor. Depois, valor anterior * (1 + perc/100)
      final computed = (i == 0)
          ? rawValor
          : (lastValue! * (1 + perc / 100));

      lastValue = computed;

      cards.add(_ItemCard(
        data: data,
        displayValue: computed,
        isFirst: i == 0,
        index: i,
      ));
    }

    return   Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child:Texto(tit: title, cor: Colors.black, bottom: 8,alin: TextAlign.center,),
        ),
        Center(
          child: Column(
            children: cards,
          ),
        ),
      ],
    );
  }
}

/// Card simples para mostrar os campos de cada Map
class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final double displayValue;
  final bool isFirst;
  final int index;

  const _ItemCard({
    Key? key,
    required this.data,
    required this.displayValue,
    this.isFirst = false,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formata o valor em real
    final valorStr = Utils.toReal(displayValue);
    return Padding(
        padding: const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
        child: Row(
          children: [
            // Descrição
            Line(
              tex: data['descricao'] ?? '',
              tam: 200,
              cor: isFirst ? Colors.black : Colors.black54,
              top: 5,
              bottom: 5,
              alin: Alignment.centerLeft,
              negrito: isFirst,
              fontSize: isFirst ? 18 : 14,
            ),

            // Percentual
            Line(
              tex: '${data['percentual']}%',
              tam: 80,
              cor: Colors.black54,
              top: 5,
              bottom: 5,
              alin: Alignment.centerRight,
            ),

            // Valor calculado
            Line(
              tex: valorStr,
              tam: 120,
              cor: isFirst ? Colors.red : Colors.black87,
              top: 5,
              bottom: 5,
              alin: Alignment.centerRight,
              negrito: isFirst,
              fontSize: isFirst ? 18 : 15,
            ),

            if(isFirst)
              IconButton(
                onPressed: () {
                  prefixIconOnPressed(data,context,index); // Chamada correta com função anônima
                },
                icon: const Icon(
                  Icons.edit,
                  size: 25,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
  }
   void prefixIconOnPressed(final Map<String, dynamic> data,BuildContext context,int index) {
    String tb='';
    if(index==0) tb='sim_fundeb_receita';
    if(index==1) tb='sim_edu_infantil';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Panel(
        width: MediaQuery.of(context).size.width *0.44,
        height: MediaQuery.of(context).size.height *0.44,
        child: SimuladorAlt(data:data,tb: tb,),
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

 */

class ProgressaoScreen extends StatefulWidget {
  const ProgressaoScreen({Key? key}) : super(key: key);

  @override
  _ProgressaoScreenState createState() => _ProgressaoScreenState();
}

class _ProgressaoScreenState extends State<ProgressaoScreen> {
  List<Map<String, dynamic>> fundeb = [];
  List<Map<String, dynamic>> infantil = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    // Exemplo de chamadas, adapte para a sua API
    final f = await ApiMySql.get('sim_fundeb_receita', null);
    final i = await ApiMySql.get('sim_edu_infantil', null);
    setState(() {
      fundeb = List<Map<String, dynamic>>.from(f);
      infantil = List<Map<String, dynamic>>.from(i);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Section(
                title: 'SIMULADOR PCRM – PROFESSORES',
                table: 'sim_fundeb_receita',
                items: fundeb,
                onEdited: () => _loadAll(), // <-- callback
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'SIMULADOR PCRM – EDUCADOR INFANTIL (40h)',
                table: 'sim_edu_infantil',
                items: infantil,
                onEdited: () => _loadAll(), // <-- callback
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget genérico para exibir uma seção com título e lista de itens
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
    final cards = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final data = items[i];
      final rawValor = double.tryParse(data['valor'].toString()) ?? 0;
      final perc = double.tryParse(data['percentual'].toString()) ?? 0;

      // Primeiro item: usa rawValor. Depois, valor anterior * (1 + perc/100)
      final computed = (i == 0) ? rawValor : (lastValue! * (1 + perc / 100));

      lastValue = computed;
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
        ),
        Center(child: Column(children: cards)),
      ],
    );
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
    final valorStr = Utils.toReal(displayValue);
    return Card(
      child: Row(
        children: [
          // Descrição
          Line(
            tex: data['descricao'] ?? '',
            tam: 350,
            cor: isFirst ? Colors.black : Colors.black54,
            top: 5,
            bottom: 5,
            alin: Alignment.centerLeft,
            negrito: isFirst,
            fontSize: isFirst ? 20 : 16,
          ),

          // Percentual
          Line(
            tex: isFirst ? ' ' : '${data['percentual']}%',
            tam: 80,
            cor: Colors.black54,
            top: 5,
            bottom: 5,
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

          // Valor calculado
          Line(
            tex: valorStr,
            tam: 200,
            cor: isFirst ? Colors.red : Colors.black87,
            top: 5,
            bottom: 5,
            alin: Alignment.centerRight,
            negrito: isFirst,
            fontSize: isFirst ? 18 : 15,
          ),

          ///EDITA O VALOR BÁSICO
          if (isFirst)
            IconButton(
              icon: const Icon(
                Icons.handshake_outlined,
                color: Colors.grey,
                size: 15,
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
      ),
    );
  }
}

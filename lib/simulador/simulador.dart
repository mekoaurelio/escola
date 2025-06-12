
import 'package:flutter/material.dart';
import 'simulador_lista.dart';

class Simulador extends StatelessWidget {
  const Simulador({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Defina aqui suas 4 tabelas e títulos
    final tabs = [
      {'table': 'sim_prof',         'title': 'Professor'},
      {'table': 'sim_edu_infantil', 'title': 'Educação Infantil'},
      {'table': 'sim_fundeb_receita','title': 'Fundeb Receita'},
      {'table': 'sim_exercicio',    'title': 'Exercício'},
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          // Título opcional:
          // title: const Text('Simulador PCRM'),
          bottom: TabBar(
            // distribui as abas igualmente
            isScrollable: false,
            // faz o indicador ter a largura da aba inteira
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: tabs
                .map((t) => Tab(text: t['title'] as String))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: tabs.map((t) {
            return SimuladorLista(
              table: t['table'] as String,
              title: t['title'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}


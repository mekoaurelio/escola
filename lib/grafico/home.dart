import 'package:flutter/material.dart';

import 'grafico_fundeb.dart';
import 'grafico_fundeb_exercicio.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      //  appBar: AppBar(title: const Text('Receita FUNDEB')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FundebChart(table:'sim_fundeb_receita' ,title: 'Receita Fundeb anualmente',),
              SizedBox(height: 20,),
              const Divider(thickness: 2,color: Colors.blue,),
              FundebChart(table: 'sim_exercicio',title: 'Evolução da folha anualmente'),
            ],
          )

        ),
      ),
    );
  }
}
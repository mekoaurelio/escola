import 'package:flutter/material.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';

import '../services/anoBimestreListenerMixin.dart';
import '../services/utils.dart';
import 'grafico_fundeb.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>{
  @override
  void initState() {
    super.initState();
  }
/*
  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    Utils.snak('NO HOME', 'ANO $ano BIMESTRE $bimestre', false, Colors.green);
    setState(() {
      TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
      TBExercicio='a_exercicio$ano$bimestre';

    });
  }

 */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              FundebChart(tipo:'receita', title: 'Receita Fundeb anualmente',),
              SizedBox(height: 20,),
              const Divider(thickness: 2,color: Colors.blue,),
              FundebChart(tipo:'EXERCICIO' ,title: 'Evolução da folha anualmente'),
            ],
          )
        ),



      ),
    );
  }
}
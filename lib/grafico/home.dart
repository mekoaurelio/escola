import 'package:flutter/material.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';

import 'grafico_fundeb.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              FundebChart(title: 'Receita Fundeb anualmente',),
              SizedBox(height: 20,),
              const Divider(thickness: 2,color: Colors.blue,),
              FundebChart(title: 'Evolução da folha anualmente'),
            ],
          )
        ),



      ),
    );
  }
}
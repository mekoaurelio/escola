import 'package:flutter/material.dart';


class Qwen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Indicadores Educacionais'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Município:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      color: Colors.yellow,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Toledo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Previsão Dist. IQEP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ 17.137.590,52',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Diferença:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ 17.137.590,52',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(color: Colors.black),

                // Tabela Principal
                DataTable(
                  columnSpacing: 16,
                  columns: [
                    DataColumn(label: Text('Indicador de Ensino')),
                    DataColumn(label: Text('IDEB 2021')),
                    DataColumn(label: Text('META')),
                    DataColumn(label: Text('Atingimento da Meta do IDEB')),
                    DataColumn(label: Text('Indicadores * Matrículas')),
                    DataColumn(label: Text('Índice de Qualidade da Educação do Paraná (IQEP)')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('(Peso 0,5)')),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('6,2'),
                      )),
                      DataCell(Container(
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('6,6'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('1,0'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('14.201,17'),
                      )),
                      DataCell(Container(
                        color: Colors.greenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('0,01347696406159'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('(Peso 0,3)')),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('6,5'),
                      )),
                      DataCell(Container(
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('6,7'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('1,02'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('14.201,17'),
                      )),
                      DataCell(Container(
                        color: Colors.greenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('0,01347696406159'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('(Peso 0,1)')),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('730'),
                      )),
                      DataCell(Container(
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('1.040'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('0,5'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('14.201,17'),
                      )),
                      DataCell(Container(
                        color: Colors.greenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('0,01347696406159'),
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('(Peso 0,1)')),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('5,4'),
                      )),
                      DataCell(Container(
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('5,2'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('1,0'),
                      )),
                      DataCell(Container(
                        color: Colors.lightGreenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('14.201,17'),
                      )),
                      DataCell(Container(
                        color: Colors.greenAccent,
                        padding: EdgeInsets.all(8),
                        child: Text('0,01347696406159'),
                      )),
                    ]),
                  ],
                ),

                // Coluna de Resultados
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INDICADORES * MATRÍCULAS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('(DESTE MUNICÍPIO)'),
                    Text('(IDEB *0,5 + ALFAB. *0,3 + INTEGRAL *0,1 + FATOR SOCIAL *0,1)'),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.lightGreenAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('14.201,17'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'PREVISÃO RECURSO PARA DISTRIBUIÇÃO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.lightBlueAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('1.271.621.000,00'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'SOMA (INDICADORES * MATRÍCULAS) DE TODOS OS MUNICÍPIOS DO ESTADO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.lightBlueAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('1.053.736.28'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'PREVISÃO DE VALOR PARA ESTE MUNICÍPIO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.greenAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('R\$ 17.137.590,52'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'ÍNDICE DE QUALIDADE DA EDUCAÇÃO DO PARANÁ (IQEP) DESTE MUNICÍPIO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.greenAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('0,01347696406159'),
                    ),
                    SizedBox(height: 16),

                    Text(
                      'PER CAPITA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      color: Colors.greenAccent,
                      padding: EdgeInsets.all(8),
                      child: Text('R\$ 1.165,74'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
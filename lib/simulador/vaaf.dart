import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/utils.dart';
import '../widgets/texto.dart';

class VAAF extends StatelessWidget {
  const VAAF({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora FUNDEB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FUNDEBCalculatorScreen(),
    );
  }
}

class FUNDEBCalculatorScreen extends StatefulWidget {
  const FUNDEBCalculatorScreen({super.key});

  @override
  State<FUNDEBCalculatorScreen> createState() => _FUNDEBCalculatorScreenState();
}

class _FUNDEBCalculatorScreenState extends State<FUNDEBCalculatorScreen> {
  final double vaafPr = 6290.1;
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> etapas = [
    {
      'nome': 'Creche em tempo integral - Pública',
      'fator': 1.55,
      'matricula': null,
    },
    {
      'nome': 'Creche em tempo integral - Conveniada',
      'fator': 1.45,
      'matricula': null,
    },
    {
      'nome': 'Creche em tempo parcial Pública',
      'fator': 1.25,
      'matricula': null,
    },
    {
      'nome': 'Creche em tempo parcial Conveniada',
      'fator': 1.15,
      'matricula': null,
    },
    {
      'nome': 'Pré-escola em tempo integral - Pública',
      'fator': 1.5,
      'matricula': null,
    },
    {
      'nome': 'Pré-escola em tempo parcial - Pública',
      'fator': 1.15,
      'matricula': null,
    },
    {
      'nome': 'Pré-escola em tempo integral -Conveniada',
      'fator': 1.4,
      'matricula': null,
    },
    {
      'nome': 'Pré-escola em tempo parcial -Conveniada',
      'fator': 1.05,
      'matricula': null,
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental urbano',
      'fator': 1.15,
      'matricula': null,
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental no campo',
      'fator': 1.15,
      'matricula': null,
    },
    {
      'nome': 'Anos finais do ensino fundamental urbana',
      'fator': 1.1,
      'matricula': null,
    },
    {
      'nome': 'Anos finais do ensino fundamental no campo',
      'fator': 1.265,
      'matricula': null,
    },
    {
      'nome': 'Ensino Fundamental em tempo integral',
      'fator': 1.5,
      'matricula': null,
    },
    {
      'nome': 'Ensino Médio urbano',
      'fator': 1.25,
      'matricula': null,
    },
    {
      'nome': 'Ensino Médio em tempo Integral',
      'fator': 1.52,
      'matricula': null,
    },
    {
      'nome': 'Ensino Médio integrado à educação profissional',
      'fator': 1.6875,
      'matricula': null,
    },
    {
      'nome': 'Educação especial',
      'fator': 1.4,
      'matricula': null,
    },
    {
      'nome': 'Atendimento educacional especializado - AEE',
      'fator': 1.96,
      'matricula': null,
    },
    {
      'nome': 'Educação indígena e quilombola',
      'fator': 1.4,
      'matricula': null,
    },
    {
      'nome': 'Educação de jovens e adultos (EJA)',
      'fator': 1.0,
      'matricula': null,
    },
    {
      'nome': 'EJA integrada à educação profissional de nível médio',
      'fator': 1.2,
      'matricula': null,
    },
  ];

  double get totalMatriculas {
    return etapas.fold(0, (sum, item) => sum + (item['matricula'] ?? 0));
  }

  double get totalReceitas {
    return etapas.fold(0, (sum, item) {
      final matricula = item['matricula'] ?? 0;
      final fator = item['fator'];
      final vaafPonderado = matricula * fator * vaafPr;
      return sum + vaafPonderado;
    });
  }

  void _editMatricula(int index) async {
    var currentValue = etapas[index]['matricula']?.toString() ?? '';

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Matrícula - ${etapas[index]['nome']}'),
        content: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: const InputDecoration(
            labelText: 'Número de matrículas',
            hintText: 'Digite o valor',
          ),
          controller:_controller,
         // autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              //final text = (context as Element).findAncestorWidgetOfExactType<AlertDialog>()?.content is TextField
                //  ? ((context as Element).findAncestorWidgetOfExactType<AlertDialog>()?.content as TextField).controller?.text
                //  : '';
              //setState(() {
                //_Controller.text='8875';
              //  currentValue='10990';
             // });
              Navigator.pop(context, _controller.text);
              _controller.text='';
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newValue != null && newValue != currentValue) {
      setState(() {
        etapas[index]['matricula'] = double.tryParse(newValue) ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeção dos recursos do FUNDEB'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VAAF/PR: $vaafPr - Portaria Interministerial MEC/MF nº 04/2025',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DataTable(
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Etapas e Modalidades da Educação Básica')),
                    DataColumn(label: Text('Matrículas Censo do Ano Anterior')),
                    DataColumn(label: Text('Fatores de Ponderação')),
                    DataColumn(label: Text('VAA Ponderado')),
                    DataColumn(label: Text('Projeção de Receitas')),
                  ],
                  rows: [
                    ...etapas.map((etapa) {
                      final matricula = etapa['matricula'] ?? 0;
                      final fator = etapa['fator'];
                      final vaafPonderado = matricula * fator * vaafPr;
                      final receita = matricula * vaafPonderado;

                      return  DataRow(cells: [
                        DataCell(Text(etapa['nome'])),
                        DataCell(
                          Container(
                            color: Colors.grey[200],
                            child: InkWell(
                              onTap: () => _editMatricula(etapas.indexOf(etapa)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(matricula == 0 ? '' : matricula.toStringAsFixed(2)),
                                    const Icon(Icons.edit, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                       ///fators de ponderaçao
                        DataCell( // Célula do Fator de Ponderação (agora centralizada)
                          Center(
                            child: Text(fator.toString()),
                          ),
                        ),
                        ///VAA ponderado
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(vaafPonderado.toStringAsFixed(2)),
                          ),
                        ),

                        ///Projeção de receitas
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(receita.toStringAsFixed(2)),
                          ),
                        ),
                      ]);
                    }).toList(),
                    DataRow(
                      cells: [
                        const DataCell(Text('Total FUNDEB (20%)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Texto(tit:Utils.formatVr.format(totalMatriculas),negrito: true,),
                          ),
                        ),

                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Texto(tit:Utils.formatVr.format(totalReceitas),negrito: true,),
                          ),
                        ),

                        //DataCell(Text(totalReceitas.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
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
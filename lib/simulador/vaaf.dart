import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../const/const.dart';
import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class VAAF extends StatelessWidget {
  const VAAF({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora FUNDEB',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final _base = TextEditingController();
  Map<String, dynamic>? tabela; // Dados do banco (uma única linha)
  bool isLoading = true;

  final List<Map<String, dynamic>> etapas = [
    {
      'nome': 'Creche em tempo integral - Pública',
      'fator': 1.55,
      'campo': 'vr1',
    },
    {
      'nome': 'Creche em tempo integral - Conveniada',
      'fator': 1.45,
      'campo': 'vr2',
    },
    {'nome': 'Creche em tempo parcial Pública', 'fator': 1.25, 'campo': 'vr3'},
    {
      'nome': 'Creche em tempo parcial Conveniada',
      'fator': 1.15,
      'campo': 'vr4',
    },
    {
      'nome': 'Pré-escola em tempo integral - Pública',
      'fator': 1.5,
      'campo': 'vr5',
    },
    {
      'nome': 'Pré-escola em tempo parcial - Pública',
      'fator': 1.15,
      'campo': 'vr6',
    },
    {
      'nome': 'Pré-escola em tempo integral -Conveniada',
      'fator': 1.4,
      'campo': 'vr7',
    },
    {
      'nome': 'Pré-escola em tempo parcial -Conveniada',
      'fator': 1.05,
      'campo': 'vr8',
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental urbano',
      'fator': 1.00,
      'campo': 'vr9',
    },
    {
      'nome': 'Anos iniciais do Ensino Fundamental no campo',
      'fator': 1.15,
      'campo': 'vr10',
    },
    {
      'nome': 'Anos finais do ensino fundamental urbana',
      'fator': 1.1,
      'campo': 'vr11',
    },
    {
      'nome': 'Anos finais do ensino fundamental no campo',
      'fator': 1.265,
      'campo': 'vr12',
    },
    {
      'nome': 'Ensino Fundamental em tempo integral',
      'fator': 1.5,
      'campo': 'vr13',
    },
    {'nome': 'Ensino Médio urbano', 'fator': 1.25, 'campo': 'vr14'},
    {'nome': 'Ensino Médio em tempo Integral', 'fator': 1.52, 'campo': 'vr15'},
    {
      'nome': 'Ensino Médio integrado à educação profissional',
      'fator': 1.6875,
      'campo': 'vr16',
    },
    {'nome': 'Educação especial', 'fator': 1.4, 'campo': 'vr17'},
    {
      'nome': 'Atendimento educacional especializado - AEE',
      'fator': 1.96,
      'campo': 'vr18',
    },
    {'nome': 'Educação indígena e quilombola', 'fator': 1.4, 'campo': 'vr19'},
    {
      'nome': 'Educação de jovens e adultos (EJA)',
      'fator': 1.0,
      'campo': 'vr20',
    },
    {
      'nome': 'EJA integrada à educação profissional de nível médio',
      'fator': 1.2,
      'campo': 'vr21',
    },
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosBanco();
  }

  Future<void> _carregarDadosBanco() async {
    try {
      // Supondo que a tabela só tem uma linha com id=1
      final dados = await ApiMySql.get(TBVaaf, null, null);

      setState(() {
        tabela = dados.isNotEmpty ? dados.first : {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Tratar erro
      print('Erro ao carregar dados: $e');
    }
  }

  double _obterMatricula(int index) {
    final campo = etapas[index]['campo'];
    if (tabela == null || !tabela!.containsKey(campo)) {
      return 0.0;
    }
    return double.tryParse(tabela![campo].toString()) ?? 0.0;
  }

  Future<void> _salvarMatricula(int index, double valor) async {
    final campo = etapas[index]['campo'];

    try {
      // Atualizar no banco de dados
      await ApiMySql.executaSql('update $TBVaaf set $campo=$valor');
      // Atualizar localmente
      setState(() {
        tabela?[campo] = valor;
      });
    } catch (e) {
      // Tratar erro
      print('Erro ao salvar matrícula: $e');
    }
  }

  double get totalMatriculas {
    return etapas.fold(
      0,
      (sum, item) => sum + _obterMatricula(etapas.indexOf(item)),
    );
  }

  double get totalReceitas {
    return etapas.fold(0, (sum, item) {
      final index = etapas.indexOf(item);
      final matricula = _obterMatricula(index);
      final fator = item['fator'];
      final vaafPonderado = matricula*fator * vaafPr;
      return sum + vaafPonderado;
    });
  }

  void _editMatricula(int index) async {
    final currentValue = _obterMatricula(index);
    _controller.text = currentValue.toString();

    await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar Matrícula - ${etapas[index]['nome']}'),
            content: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Número de matrículas',
                hintText: 'Digite o valor',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final valor = double.tryParse(_controller.text) ?? 0;
                  await _salvarMatricula(index, valor);
                  Navigator.pop(context);
                  _controller.clear();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Texto(tit: 'Projeção dos recursos do FUNDEB',cor:Colors.white ,negrito: true,tam: 20,),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
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

                const SizedBox(height: 16),
                DataTable(
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(
                      label: Text('Etapas e Modalidades da Educação Básica'),
                    ),
                    DataColumn(label: Text('Matrículas Censo do Ano Anterior')),
                    DataColumn(label: Text('Fatores de Ponderação')),
                    DataColumn(label: Text('VAA Ponderado')),
                    DataColumn(label: Text('Projeção de Receitas')),
                  ],
                  rows: [
                    ...etapas.map((etapa) {
                      final index = etapas.indexOf(etapa);
                      final matricula = _obterMatricula(index);
                      final fator = etapa['fator'];
                      final vaafPonderado = fator * vaafPr;
                      final receita = matricula * vaafPonderado;

                      return DataRow(
                        cells: [
                          ///Descrição
                          DataCell(Text(etapa['nome'])),
                          ///Matrícula
                          DataCell(
                            Container(
                              color: Colors.grey[200],
                              child: InkWell(
                                onTap: () => _editMatricula(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        matricula == 0
                                            ? ''
                                            : matricula.toStringAsFixed(2),
                                      ),
                                      const Icon(Icons.edit, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ///Fator de Ponderação
                          DataCell(Center(child: Text(fator.toString()))),
                          ///VAA ponderado
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(Utils.formatVr.format(vaafPonderado)),
                            ),
                          ),
                          ///Projeção de receitas
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(Utils.formatVr.format(receita)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),

                    DataRow(
                      cells: [
                         DataCell(
                          Texto(tit:'Total FUNDEB (20%)',negrito: true,)
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Texto(tit: Utils.formatVr.format(totalMatriculas),negrito: true,),
                          ),
                        ),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child:Texto(tit: Utils.formatVr.format(totalReceitas),negrito: true,),
                          ),
                        ),
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

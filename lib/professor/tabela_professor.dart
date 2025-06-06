import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import para FilteringTextInputFormatter

import '../data/api_my_sql.dart';
import '../services/utils.dart'; // Assumindo que Utils.formatVr existe
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';

class SimuladorTabelaProfessor extends StatefulWidget {
  const SimuladorTabelaProfessor({super.key});

  @override
  State<SimuladorTabelaProfessor> createState() => _SimuladorTabelaProfessorState();
}

class _SimuladorTabelaProfessorState extends State<SimuladorTabelaProfessor> {
  int cargaHoraria = 20;
  final List<String> niveis = ['BASE','NA','NB', 'NC', 'ND', 'NE'];

  var profs; // Dados brutos da API
  double valorBase = 0; // Valor inicial 'valor'
  double penA = 0; // Diferença NB-NC (ou valor inicial de NC)
  double penB = 0; // Diferença NB-NC (ou valor inicial de NC)
  double penC = 0; // Diferença NC-ND (ou valor inicial de ND)
  double penD = 0; // Diferença ND-NE (ou valor inicial de NE)
  double penE = 0; // Diferença ND-NE (ou valor inicial de NE)

 // double percCalc = 0; // Percentual de cálculo

  bool isLoading = true;

  // Variáveis para armazenar os resultados calculados
  List<List<double>> _calculatedTableValues = [];
  String _dispersaoHorizontal = '0.00%'; // Valor inicial como string formatada
  String _dispersaoTotal = '0.00%'; // Valor inicial como string formatada

  // Controladores para os campos de texto
  late TextEditingController _cargaHorariaController;
  late TextEditingController _percEntreColunas;


  @override
  void initState() {
    super.initState();
    _cargaHorariaController = TextEditingController(text: cargaHoraria.toString());
    _percEntreColunas=TextEditingController(text:'');
    _loadDataAndCalculate(); // Método para carregar dados e calcular tudo
  }

  @override
  void dispose() {
    _cargaHorariaController.dispose();
    _percEntreColunas.dispose();
    super.dispose();
  }

  // Método para carregar dados e iniciar os cálculos
  Future<void> _loadDataAndCalculate() async {
    setState(() {
      isLoading = true; // Mostra o indicador de carregamento
    });

    try {
      profs = await ApiMySql.get('sim_prof', null, 'ordem');
      valorBase = double.parse(profs[0]['valor']); ///PISO INFANTIL
      penA = double.parse(profs[2]['valor']); ///PROGRESSÃO ENTRE NÍVEIS
      penB = double.parse(profs[3]['valor']);
      penC = double.parse(profs[4]['valor']);
      penD = double.parse(profs[5]['valor']);
      penE = double.parse(profs[6]['valor']);
      /*
      nanaDiff = 1952;
      valorBase = 2400;
      nbncDiff = 2684;
      ncndDiff = 2952.40;
      ndneDiff = 3973.54;

       */
     // percCalc = double.parse(profs[1]['percentual']);
      _percEntreColunas.text=profs[1]['percentual']; ///Percentual de cálculo entre as colunas
      _calculateTableAndDispersions(); // Calcula a tabela e dispersões
    } catch (e) {
      print('Erro ao carregar dados ou calcular: $e');
      // Tratar erro, talvez mostrar uma mensagem ao usuário
    } finally {
      setState(() {
        isLoading = false; // Esconde o indicador de carregamento
      });
    }
  }

  // Método para calcular todos os valores da tabela e as dispersões
  void _calculateTableAndDispersions() {
    List<List<double>> tempTable = [];
    double primeiroValorTabela = 0; // Primeira coluna da primeira linha (NB, classe 1)
    double ultimaColunaPrimeiraLinha = 0; // Última coluna da primeira linha (NB, última classe)
    double ultimaColunaUltimaLinha = 0; // Última coluna da última linha (NE, última classe)

    for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++) {
      List<double> rowValues = [];
      double vrAnteriorDaLinha = 0;

      // Define o valor inicial da linha com base no nível
      if (nivelIndex == 0) vrAnteriorDaLinha = valorBase;//3
      if (nivelIndex == 1) vrAnteriorDaLinha = penA;//tava 0
      if (nivelIndex == 2) vrAnteriorDaLinha = penB;//1
      if (nivelIndex == 3) vrAnteriorDaLinha = penC;//2
      if (nivelIndex == 4) vrAnteriorDaLinha = penD;//3
      if (nivelIndex == 5) vrAnteriorDaLinha = penE;//3

      for (int coluna = 1; coluna <= cargaHoraria; coluna++) {
        double valorAtual;
        if (coluna == 1) {
          valorAtual = vrAnteriorDaLinha;
          // Captura o primeiro valor da tabela (NB, Classe 1)
          if (nivelIndex == 0) {
            primeiroValorTabela = valorAtual;
          }
        } else {
          double percCalc=double.parse(_percEntreColunas.text);
          print('PERCENT $percCalc');
          valorAtual = ((vrAnteriorDaLinha * percCalc)/100)+vrAnteriorDaLinha;
          //valorAtual = ((vrAnteriorDaLinha * percCalc)/100)+vrAnteriorDaLinha;
        }

        rowValues.add(valorAtual);
        vrAnteriorDaLinha = valorAtual;

        // Captura a última coluna da primeira linha (NB)
        if (nivelIndex == 0 && coluna == cargaHoraria) {
          ultimaColunaPrimeiraLinha = valorAtual;
        }

        // Captura a última coluna da última linha (NE)
        if (nivelIndex == 4 && coluna == cargaHoraria) {
          ultimaColunaUltimaLinha = valorAtual;
          print('ultimaColunaUltimaLinha $ultimaColunaUltimaLinha');
        }
      }
      tempTable.add(rowValues);
    }

    // Cálculo das dispersões conforme especificado
    double calcDispersaoHorizontal = 0;
    double calcDispersaoTotal = 0;

    if (primeiroValorTabela != 0) {
      // Dispersão Horizontal: (última coluna da primeira linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
      calcDispersaoHorizontal = ((ultimaColunaPrimeiraLinha - primeiroValorTabela) / primeiroValorTabela) * 100;

      // Dispersão Total: (última coluna da última linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
     // print('primeiroValorTabela : $primeiroValorTabela ultimaColunaUltimaLinha : $ultimaColunaUltimaLinha');
      calcDispersaoTotal = ((ultimaColunaUltimaLinha - primeiroValorTabela) / primeiroValorTabela) * 100;
    }

    setState(() {
      _calculatedTableValues = tempTable;
      _dispersaoHorizontal = calcDispersaoHorizontal.toStringAsFixed(2);
      _dispersaoTotal = calcDispersaoTotal.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Cabeçalho, carga horário. dispersão horizontal e dispersão total
              Container(
                  color: Colors.blue.shade200,
                child: Row(
                children: [
                  Texto(tit:'Carga Horária:',right: 10,left: 10,),
                  ///Quantidade de colunas
                  SizedBox(
                    width: 60,
                    child: CustomTextFiel(
                      controller: _cargaHorariaController,
                      label: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        int? newCargaHoraria = int.tryParse(value);
                        if (newCargaHoraria != null && newCargaHoraria > 0) {
                          setState(() {
                            cargaHoraria = newCargaHoraria;
                            _calculateTableAndDispersions(); // Recalcula ao mudar a carga horária
                          });
                        }
                      },
                    )
                  ),

                Texto(tit:'% de progressão entre colunas',left: 10,right: 10,),
                  SizedBox(
                      width: 60,
                      child: CustomTextFiel(
                        controller: _percEntreColunas,
                        label: '',
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          int? newCargaHoraria = int.tryParse(value);
                          if (newCargaHoraria != null && newCargaHoraria > 0) {
                            setState(() {
                             // cargaHoraria = newCargaHoraria;
                              _calculateTableAndDispersions(); // Recalcula ao mudar a carga horária
                            });
                          }
                        },
                      )
                  ),
                //  const Text(' h'),
                  const SizedBox(width: 40),
                  const Text('Dispersão Horizontal (NE):'), // Especifique que é da última linha
                  const SizedBox(width: 10),
                  Texto(tit: '$_dispersaoHorizontal%',cor: Colors.blue,negrito: true,tam: 16,),
                  const SizedBox(width: 40),
                  const Text('Dispersão Total:'),
                  const SizedBox(width: 10),
                  Texto(tit: '$_dispersaoTotal%',cor: Colors.blue,negrito: true,tam: 16,right: 10,),
                ],
              ),
              ),
              const SizedBox(height: 20),

              /// Nível e Classe
              const Row(
                children: [
                  SizedBox(width: 80, child: Text('Nível')),
                  Text('CLASSE'),
                ],
              ),
              const SizedBox(height: 10),

              /// Classes header row (dynamic columns)
             Container(
               color: Colors.grey.shade200,
               child: Row(
                 children: [
                   const SizedBox(width: 40), // Empty space for level column
                   for (int i = 1; i <= cargaHoraria; i++)
                     Line(tex: i.toString(), tam: 100, cor: Colors.black, alin: Alignment.center, negrito: true,fontSize: 16,),
                 ],
               )
             ),
              const SizedBox(height: 10),

              /// Níveis rows (NB, NC, ND, NE)
              for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++)
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Texto(tit:niveis[nivelIndex],negrito: true,cor: nivelIndex==0?Colors.blue:Colors.black,),
                    ),
                    for (int i = 0; i < _calculatedTableValues[nivelIndex].length; i++)
                      Line(
                        tex: Utils.formatVr.format(_calculatedTableValues[nivelIndex][i]).toString(),
                        tam: 100,
                        cor: i==0?Colors.blue:Colors.black,
                        alin: Alignment.center,
                        negrito: true,
                        fontSize: i==0?16:13,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
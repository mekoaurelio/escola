import 'package:flutter/material.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart'; // Assumindo que Utils.formatVr existe
import '../widgets/line.dart';
import '../widgets/texto.dart';

class SimuladorTabelaProfessor extends StatefulWidget {
  const SimuladorTabelaProfessor({super.key});

  @override
  State<SimuladorTabelaProfessor> createState() => _SimuladorTabelaProfessorState();
}

class _SimuladorTabelaProfessorState extends State<SimuladorTabelaProfessor> {
  final anoBimestreController = Get.find<AnoBimestreController>();
  int cargaHoraria = 20;
  double _percEntreColunas=0;
  final List<String> niveis = ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'];

  var profs; // Dados brutos da API
  double valorBase = 0; // Valor inicial 'valor'
  double penA = 0; // Diferença NB-NC (ou valor inicial de NC)
  double penB = 0; // Diferença NB-NC (ou valor inicial de NC)
  double penC = 0; // Diferença NC-ND (ou valor inicial de ND)
  double penD = 0; // Diferença ND-NE (ou valor inicial de NE)
  double penE = 0; // Diferença ND-NE (ou valor inicial de NE)
  bool isLoading = true;

  // Variáveis para armazenar os resultados calculados
  List<List<double>> _calculatedTableValues = [];
  Map<String, int> _professoresPorNivel = {};

  String _dispersaoHorizontal = '0.00%'; // Valor inicial como string formatada
  String _dispersaoTotal = '0.00%'; // Valor inicial como string formatada


  int? selectedRow;
  int? selectedColumn;
  String selectedValue = 'Nenhuma célula selecionada';
  String nivel = '',
      coluna = '';
  var professores;

// Adicione este método para lidar com a seleção
  void _handleCellSelection(int row, int column) async {
    setState(() {
      selectedRow = row;
      selectedColumn = column;
      selectedValue = '${niveis[row]}  ${column + 1}';
    });

    nivel = niveis[row].substring(1, 2);
    coluna = (column + 1).toString();
    if (coluna.length == 1) {
      coluna = '0$coluna';
    }
    String ni = nivel + coluna;
    String Profs = '';
    for (var item in professores) {
      if (item['nivel'] == ni) {
        Profs += item['nome'] + '\n';
      }
    }
    if (Profs.length == 0) {
      Profs = 'Não existe';
    }
    Utils.snak('Valor', Profs, false, Colors.green);
  }

  int quantidadeDeProfessores(String nivel, int coluna) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    return _professoresPorNivel[chave] ?? 0;
  }

  @override
  void initState() {
    super.initState();
    ever(anoBimestreController.ano, (novoAno) {
      var bimestre=anoBimestreController.bimestre;
      _atualizaTela(novoAno,bimestre);
    });

    ever(anoBimestreController.bimestre, (novoBimestre) {
      var ano=anoBimestreController.ano;
      _atualizaTela(ano,novoBimestre);
    });

    _loadDataAndCalculate(); // Método para carregar dados e calcular tudo
  }

  _atualizaTela(var ano,var bimestre){
    setState(() {
      TBFolha='a$ano$bimestre';
      TBProfessor='a_professor$ano$bimestre';
      professores=[];
      profs=[];
      valorBase=0;
      _calculatedTableValues=[];
      _loadDataAndCalculate();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Método para carregar dados e iniciar os cálculos
  Future<void> _loadDataAndCalculate() async {
    professores = await ApiMySql.executaSql('select * from $TBFolha');

    // Pré-processa a contagem de professores por nível
    _professoresPorNivel = {};
    for (var item in professores) {
      final nivel = item['nivel']?.toString() ?? '';
      _professoresPorNivel[nivel] = (_professoresPorNivel[nivel] ?? 0) + 1;
    }

    /// Pré-processa a contagem de professores por nível
    _professoresPorNivel = {};
    for (var item in professores) {
      final nivel = item['nivel']?.toString() ?? '';
      _professoresPorNivel[nivel] = (_professoresPorNivel[nivel] ?? 0) + 1;
    }

    setState(() {
      isLoading = true; // Mostra o indicador de carregamento
    });

    try {
      profs = await ApiMySql.get(TBProfessor, null, 'ordem');
      valorBase = double.parse(profs[0]['valor']);

      ///PISO INFANTIL
      penA = double.parse(profs[2]['valor']);

      ///PROGRESSÃO ENTRE NÍVEIS
      penB = double.parse(profs[3]['valor']);
      penC = double.parse(profs[4]['valor']);
      penD = double.parse(profs[5]['valor']);
      penE = double.parse(profs[6]['valor']);
      _percEntreColunas = double.parse(profs[1]['percentual']);

      ///Percentual de cálculo entre as colunas

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
      if (nivelIndex == 0) vrAnteriorDaLinha = valorBase; //3
      if (nivelIndex == 1) vrAnteriorDaLinha = penA; //tava 0
      if (nivelIndex == 2) vrAnteriorDaLinha = penB; //1
      if (nivelIndex == 3) vrAnteriorDaLinha = penC; //2
      if (nivelIndex == 4) vrAnteriorDaLinha = penD; //3
      if (nivelIndex == 5) vrAnteriorDaLinha = penE; //3

      for (int coluna = 1; coluna <= cargaHoraria; coluna++) {
        double valorAtual;
        if (coluna == 1) {
          valorAtual = vrAnteriorDaLinha;
          // Captura o primeiro valor da tabela (NB, Classe 1)
          if (nivelIndex == 0) {
            primeiroValorTabela = valorAtual;
          }
        } else {
          double percCalc = _percEntreColunas;
          valorAtual =
              ((vrAnteriorDaLinha * percCalc) / 100) + vrAnteriorDaLinha;
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
        }
      }
      tempTable.add(rowValues);
    }

    // Cálculo das dispersões conforme especificado
    double calcDispersaoHorizontal = 0;
    double calcDispersaoTotal = 0;

    if (primeiroValorTabela != 0) {
      // Dispersão Horizontal: (última coluna da primeira linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
      calcDispersaoHorizontal =
          ((ultimaColunaPrimeiraLinha - primeiroValorTabela) /
              primeiroValorTabela) * 100;

      // Dispersão Total: (última coluna da última linha - primeira coluna da primeira linha) / primeira coluna da primeira linha
      // print('primeiroValorTabela : $primeiroValorTabela ultimaColunaUltimaLinha : $ultimaColunaUltimaLinha');
      calcDispersaoTotal = ((ultimaColunaUltimaLinha - primeiroValorTabela) /
          primeiroValorTabela) * 100;
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
              Row(
                children: [
                  Texto(
                      tit: 'Carga Horária: $cargaHoraria',
                    aoClicarIcone: () {
                        Utils.mostrarDialogoEditarValor(
                          context: context,
                          titulo: 'Editar Carga Horária',
                          labelCampo: 'Horas',
                          valorInicial: cargaHoraria.toString(),
                          aoSalvar: (novoValor) {
                            setState(() {
                              cargaHoraria = int.tryParse(novoValor)!;
                              _calculateTableAndDispersions();
                            });
                          },
                        );
                      },
                    ),
                  SizedBox(width: 10,),
                  Texto(tit: '% de progressão entre colunas $_percEntreColunas', left: 10, right: 10,
                      aoClicarIcone: () {
                        Utils.mostrarDialogoEditarValor(
                          context: context,
                          titulo: 'Editar Progressão Entre Colunas',
                          labelCampo: 'Colunas',
                          valorInicial: _percEntreColunas.toString(),
                          aoSalvar: (novoValor) {
                            setState(() {
                              _percEntreColunas = double.tryParse(novoValor)!;
                              _calculateTableAndDispersions();
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(width: 40),
                  const Text('Dispersão Horizontal (NE):'),
                  // Especifique que é da última linha
                  const SizedBox(width: 10),
                  Texto(tit: '$_dispersaoHorizontal%',
                      cor: Colors.blue,
                      negrito: true,
                      tam: 16,),
                  const SizedBox(width: 40),
                  const Text('Dispersão Total:'),
                  const SizedBox(width: 10),
                  Texto(tit: '$_dispersaoTotal%',
                      cor: Colors.blue,
                      negrito: true,
                      tam: 16,
                      right: 10,),
                ],
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
                        Line(tex: i.toString(),
                          tam: 109,
                          cor: Colors.black,
                          alin: Alignment.center,
                          negrito: true,
                          fontSize: 16,),
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
                      child: Texto(tit: niveis[nivelIndex],
                        negrito: true,
                        cor: nivelIndex == 0 ? Colors.blue : Colors.black,),
                    ),
                    for (int coluna = 0; coluna <
                        _calculatedTableValues[nivelIndex].length; coluna++)
                      GestureDetector(
                        onTap: () => _handleCellSelection(nivelIndex, coluna),
                        child: Container(
                            color: selectedRow == nivelIndex &&
                                selectedColumn == coluna
                                ? Colors.blue
                                : Colors.transparent,
                            child: Tooltip(
                                message: '${quantidadeDeProfessores(
                                    niveis[nivelIndex],
                                    coluna + 1)} professores',
                                child:
                                Row(
                                  children: [
                                    Line(
                                      tex: Utils.formatVr.format(
                                          _calculatedTableValues[nivelIndex][coluna]),
                                      tam: 90,
                                      alin: Alignment.centerRight,
                                      fontSize: coluna == 0 ? 16 : 13,
                                      cor: coluna == 0 ? Colors.blue : Colors
                                          .black,
                                      negrito: true,
                                    ),

                                    Line(
                                      tex: '(${quantidadeDeProfessores(
                                          niveis[nivelIndex], coluna + 1)})',
                                      tam: 19,
                                      fontSize: 9,
                                      cor: Colors.black54,
                                      alin: Alignment.centerLeft,
                                      negrito: true,),
                                  ],
                                )
                            )
                        ),
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
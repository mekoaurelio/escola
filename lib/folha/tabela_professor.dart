import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart'; // Assumindo que Utils.formatVr existe
import '../widgets/line.dart';
import '../widgets/texto.dart';
import 'buildSummaryTable.dart';
import 'professor_distribution_table.dart';
import 'salary_totals_table.dart';
import 'tabela_salarial.dart';

class SimuladorTabelaProfessor extends StatefulWidget {
  final String table;

  const SimuladorTabelaProfessor({
    Key? key,
    required this.table,
  }) : super(key: key);

  @override
  State<SimuladorTabelaProfessor> createState() => _SimuladorTabelaProfessorState();
}

class _SimuladorTabelaProfessorState extends State<SimuladorTabelaProfessor> {
  // ... (mantenha todas as variáveis existentes)

  // Adicione estas cores no início da classe
  static const Color _primaryColor = Color(0xFF1976D2);
  static const Color _backgroundColor = Color(0xFFFAFAFA);
  static const Color _textColor = Color(0xFF212121);
  static const Color _borderColor = Color(0xFFE0E0E0);
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
  int totProf=0;

  double totalFolha=0;

  _atualizaTela(var ano,var bimestre){
    setState(() {
      TBFolha='a$ano$bimestre';
      var tb=widget.table;
      TBVantagens='a_vantagens$ano$bimestre';
      TBProfessor='$tb$ano$bimestre';
      _calculatedTableValues=[];
      professores=null;
      _loadDataAndCalculate();
    });
  }

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

  Future<void> _loadDataAndCalculate() async {
    //professores = await ApiMySql.executaSql('select * from $TBFolha');
    professores = await ApiMySql.getProfessor();
    if(professores.length==0){
      return;
    }
    totProf=professores.length;
    setState(() => isLoading = true);
    /// Pré-processa a contagem de professores por nível
    _professoresPorNivel = {};
    for (var item in professores) {
      final nivel = item['nivel']?.toString() ?? '';
      _professoresPorNivel[nivel] = (_professoresPorNivel[nivel] ?? 0) + 1;
    }

    totalFolha=double.parse(professores[0]['total_vencimentos_geral']);

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
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final controller = Get.find<AnoBimestreController>();
    _atualizaTela(controller.ano, controller.bimestre);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
            Texto(tit: 'Carregando dados...',cor: _textColor,tam: 16,bottom: 16,),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Texto(tit: 'Plano de Carreira Docente',cor:Colors.white ,negrito: true,tam: 20,),
        centerTitle: true,
        backgroundColor: _primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadDataAndCalculate(),
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: professores == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Texto(tit: 'Sem dados disponíveis para este período',cor:_textColor ,tam: 18,),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ///Cartão com cabecalho: Carga horária, progressão etc....
              buildSummaryCards(),
              SizedBox(height: 24),
              ///valores calculados para cada nível e classe
              TabelaSalarial(
                primaryColor: Colors.blue, // Sua cor primária
                textColor: Colors.black,   // Sua cor de texto
                borderColor: Colors.grey.shade200,
                cargaHoraria: 20, // Sua carga horária
                niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'], // Seus níveis
                calculatedTableValues: _calculatedTableValues, // Seus valores calculados
                quantidadeDeProfessores: (nivel, coluna) {
                  // Sua implementação para contar professores
                  return quantidadeDeProfessores(nivel, coluna);
                },
                onCellSelected: (row, column) {
                  // Ação quando uma célula é selecionada
                  _handleCellSelection(row, column);
                },
              ),
              SizedBox(height: 24),
              ///Quantidade de professores por nível e classe
              ///Acho que deveria sar
              ProfessorDistributionTable(
                primaryColor: Colors.blue, // Your primary color
                textColor: Colors.black,   // Your text color
                borderColor: Colors.grey.shade200,
                cargaHoraria: 20, // Your workload value
                niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'], // Your levels
                calculatedTableValues: _calculatedTableValues, // Your calculated values
                quantidadeDeProfessores: (nivel, coluna) {
                  // Your implementation to count professors
                  return quantidadeDeProfessores(nivel, coluna);
                },
                onCellSelected: (row, column) {
                  // Action when a cell is selected
                  _handleCellSelection(row, column);
                },
              ),
              SizedBox(height: 24),
              ///Quantidade de professores com as somas dos saários
              ///Somatório de vencimentos por nível e classe
              SalaryTotalsTable(
                primaryColor: Colors.blue, // ou sua cor primária
                textColor: Colors.black,   // ou sua cor de texto
                borderColor: Colors.grey.shade200,
                cargaHoraria: 20, // ou seu valor
                niveis: ['NA', 'NB', 'NC', 'ND', 'NE'], // sua lista de níveis
                calculatedTableValues: _calculatedTableValues, // seus valores calculados
                quantidadeDeProfessores: (nivel, coluna) {
                  // Sua implementação para contar professores
                  return quantidadeDeProfessores(nivel, coluna);
                },
                professores: professores, // sua lista de professores
              ),

              SizedBox(height: 24),
              SummaryTable(
                totalProfissionais: totProf,
                custoMensal: totalFolha,
                meses: 12,
                ferias: 0.033,
                remuneracaoTotal: 20993884.21,
                encargosPercentual: 22,
                totalEncargos: 6968798,
                totalComEncargos: 0697079709

              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCards() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Primeira linha de itens
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Carga Horária',
                        '$cargaHoraria horas',
                        Icons.access_time,
                        onTap: () => _editWorkingHours(),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Progressão',
                        '${_percEntreColunas.toStringAsFixed(2)}%',
                        Icons.trending_up,
                        onTap: () => _editProgression(),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16),
            // Segunda linha de itens
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Dispersão Horizontal',
                        '$_dispersaoHorizontal%',
                        Icons.compare_arrows,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Dispersão Total',
                        '$_dispersaoTotal%',
                        Icons.bar_chart,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
          BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
          ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: _primaryColor),
            SizedBox(height: 8),
            Texto(tit: title,cor: _textColor.withOpacity(0.7),tam: 12,),
            SizedBox(height: 4),
            Texto(tit: value,cor:_primaryColor ,tam: 16,negrito: true,),
          ],
        ),
      ),
    );
  }

  void _editWorkingHours() {
    Utils.mostrarDialogoEditarValor(
      context: context,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
  }

  void _editProgression() {
    Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: 'Editar Progressão',
      labelCampo: 'Percentual',
      valorInicial: _percEntreColunas.toString(),
      aoSalvar: (novoValor) {
        setState(() {
          _percEntreColunas = double.tryParse(novoValor)!;
          _calculateTableAndDispersions();
        });
      },
    );
  }
}//977
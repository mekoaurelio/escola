import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';
import 'package:get/get.dart';
import 'package:psycostatattoo/professor/professor_utils.dart';

import '../data/api_my_sql.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/utils.dart'; // Assumindo que Utils.formatVr existe
import '../widgets/line.dart';
import '../widgets/texto.dart';
import 'buildSummaryTable.dart';

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
  static const Color _secondaryColor = Color(0xFF42A5F5);
  static const Color _accentColor = Color(0xFFFF9800);
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
  var resultado;
  bool _isHovered = false;
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

  /*
  double totalDeVencimentos(String nivel, int coluna) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    double total = 0.0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        total += double.tryParse(professor['vencimento'].toString()) ?? 0.0;
      }
    }

    return total;
  }

   */

  Widget _buildProfessorCountTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Texto(tit: 'Distribuição de Professores',cor:_textColor ,tam: 18,negrito: true,bottom: 8,),
            Texto(tit: 'Quantidade de professores por nível e classe',cor: _textColor.withOpacity(0.6),tam: 14,bottom: 16,),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Nível',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        for (int i = 1; i <= cargaHoraria; i++)
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Classe $i',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Rows
                  for (int nivelIndex = 1; nivelIndex < niveis.length; nivelIndex++)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _borderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: Material(
                          color: _isHovered
                              ? Colors.transparent
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  niveis[nivelIndex],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                              for (int coluna = 0;
                              coluna < _calculatedTableValues[nivelIndex].length;
                              coluna++)
                                GestureDetector(
                                  onTap: () =>
                                      _handleCellSelection(nivelIndex, coluna),
                                  child: Container(
                                    width: 80,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    child: Text(
                                      quantidadeDeProfessores(
                                          niveis[nivelIndex], coluna + 1) ==
                                          0
                                          ? '-'
                                          : quantidadeDeProfessores(
                                          niveis[nivelIndex], coluna + 1)
                                          .toString(),
                                      style: TextStyle(
                                        color: _textColor,
                                        fontWeight:
                                        selectedRow == nivelIndex &&
                                            selectedColumn == coluna
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSalaryTotalsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Totais de Vencimentos',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Somatório de vencimentos por nível e classe',
              style: TextStyle(
                color: _textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Nível',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        for (int i = 1; i <= cargaHoraria; i++)
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Classe $i',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        // Coluna para o total
                        Container(
                          width: 120,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Total Nível',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rows
                  for (int nivelIndex = 1; nivelIndex < niveis.length; nivelIndex++)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _borderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: Material(
                          color: _isHovered
                              ? _primaryColor.withOpacity(0.05)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  niveis[nivelIndex],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _textColor,
                                  ),
                                ),
                              ),
                              for (int coluna = 0; coluna < _calculatedTableValues[nivelIndex].length; coluna++)
                                Container(
                                  width: 100,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      if (quantidadeDeProfessores(niveis[nivelIndex], coluna + 1) != 0)
                                        Text(
                                          '${quantidadeDeProfessores(niveis[nivelIndex], coluna + 1)} Profs.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _textColor.withOpacity(0.8),
                                          ),
                                        ),
                                      if (quantidadeDeProfessores(niveis[nivelIndex], coluna + 1) != 0)
                                        Text(
                                          Utils.formatVr.format(ProfessorUtils.totalDeVencimentos(niveis[nivelIndex], coluna + 1,professores)),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              // Célula de total por nível
                              Container(
                                width: 120,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _textColor.withOpacity(0.8),
                                      ),
                                    ),
                                    Text(
                                      Utils.formatVr.format(ProfessorUtils.calculateTotalForLevel(niveis[nivelIndex],professores,cargaHoraria),
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Método auxiliar para calcular o total por nível
  /*
  double _calculateTotalForLevel(String nivel) {
    double total = 0.0;
    for (int coluna = 0; coluna < cargaHoraria; coluna++) {
      total += ProfessorUtils.totalDeVencimentos(nivel, coluna + 1,professores);
      //ProfessorUtils.totalDeVencimentos(niveis[nivelIndex], coluna + 1,professores)),
    }
    return total;
  }

   */

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
            SizedBox(height: 16),
            Text(
              'Carregando dados...',
              style: TextStyle(
                color: _textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Plano de Carreira Docente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
            Text(
              'Sem dados disponíveis para este período',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
              ),
            ),
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
              dados1(),
              SizedBox(height: 24),
              ///Quantidade de professores por nível e classe
              ///Acho que deveria sar
              _buildProfessorCountTable(),
              SizedBox(height: 24),
              ///Quantidade de professores com as somas dos saários
              ///Somatório de vencimentos por nível e classe
              _buildSalaryTotalsTable(),
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
            Text(
              title,
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dados1() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tabela Salarial',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Valores calculados para cada nível e classe',
              style: TextStyle(
                color: _textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header
                  Container(
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'Nível',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              ),
                            ),
                            for (int i = 1; i <= cargaHoraria; i++)
                              Container(
                                width: 90,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  'Classe $i',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Rows
                      for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _borderColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: Material(
                        color: _isHovered
                            ? _primaryColor.withOpacity(0.05)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                niveis[nivelIndex],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: nivelIndex == 0 ? Colors.blue : _textColor,
                                ),
                              ),
                            ),
                            for (int coluna = 0; coluna < _calculatedTableValues[nivelIndex].length; coluna++)
                              GestureDetector(
                                onTap: () => _handleCellSelection(nivelIndex, coluna),
                                child: Container(
                                  width: 90,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  color: selectedRow == nivelIndex && selectedColumn == coluna
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          Utils.formatVr.format(_calculatedTableValues[nivelIndex][coluna]),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: coluna == 0 ? 16 : 13,
                                            color: coluna == 0 ? Colors.blue : _textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '(${quantidadeDeProfessores(niveis[nivelIndex], coluna + 1)})',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
}
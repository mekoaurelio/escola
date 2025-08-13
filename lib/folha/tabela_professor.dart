import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';

import '../const/const.dart';
import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/calc_dispersao_valores.dart';
import '../services/utils.dart'; // Assumindo que Utils.formatVr existe
import '../widgets/texto.dart';
import 'buildSummaryTable.dart';
import 'salary_totals_table.dart';
import 'tabela_salarial.dart';

class SimuladorTabelaProfessor extends StatefulWidget {
  final String table;
  final String horas;

  const SimuladorTabelaProfessor({
    Key? key,
    required this.table,
    required this.horas,
  }) : super(key: key);

  @override
  State<SimuladorTabelaProfessor> createState() => _SimuladorTabelaProfessorState();
}

class _SimuladorTabelaProfessorState extends State<SimuladorTabelaProfessor> {
  int cargaHoraria = 15;
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
  double perAumentoInfantil=0.00;
  double perAumentoAdulto=0.00;
  double _custoMensal = 0.0;
  double totalFolha=0;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

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
    List<Map<String, String>> professoresFiltrados = [];
    for (var item in professores) {
      if (item['nivel'] == ni) {
        professoresFiltrados.add({
          'nome': item['nome']?.toString() ?? 'Nome não disponível',
          'matricula': item['matricula']?.toString() ?? 'Matrícula não disponível'
        });
      }
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.groups_rounded, color: Colors.blue),
              const SizedBox(width: 10),
              Text(
                'Professores (${professoresFiltrados.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (professoresFiltrados.isEmpty)
                  const Text('Nenhum professor encontrado', style: TextStyle(color: Colors.grey))
                else
                  ...professoresFiltrados.map((prof) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Texto(tit: 'Matrícula: ${prof['matricula']}',tam: 12,cor:Colors.grey[600]!),
                        Texto(tit: prof['nome']!,negrito: true,),
                        const Divider(height: 16, thickness: 0.5),
                      ],
                    ),
                  )).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  int quantidadeDeProfessores(String nivel, int coluna) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';
    return _professoresPorNivel[chave] ?? 0;
  }

  Future<void> _loadDataAndCalculate() async {
    try{
      //getProfessorPorHora
     // professores = await ApiMySql.getProfessorPorHora(widget.tipo,TBFolha,TBVantagens).timeout(const Duration(seconds: 30));
      professores = await ApiMySql.getProfessorPorHora(widget.horas);

      if(professores==null){
        setState(() => isLoading = false);
        return;
      }
      if(professores.isEmpty){
        setState(() => isLoading = false);
        return;
      }
      ///Pega os totais
      final totais = await ApiMySql.get(TBTotais,null,null);
      perAumentoInfantil=double.parse(totais[0]['perc_aumento_infantil']);
      perAumentoAdulto=double.parse(totais[0]['perc_aumento_adulto']);

      /// Pré-processa a contagem de professores por nível
      _professoresPorNivel = {};
      for (var item in professores) {
        final nivel = item['nivel']?.toString() ?? '';
        _professoresPorNivel[nivel] = (_professoresPorNivel[nivel] ?? 0) + 1;
      }
      ///Pega a quantidade de professores
      final totals = await Future.wait([
        Utils.calculateTotals(professores),
        Utils.calculateTotals(professores),
      ]);
      setState(() {
        _custoMensal = totals[0]['total']!;
        totProf=professores.length;
        isLoading = true;
      });
      totalFolha=double.parse(professores[0]['total_vencimentos_geral']);
    } catch (e) {
      print('Erro ao carregar dados ou calcular: $e');

    }
    try {
      String tB=TBProfessor;

      //if(widget.tipo=='INFANTIL'){
        //tB=TBInfantil;
     // }
      profs = await ApiMySql.get(tB, null, 'ordem');

      valorBase = double.parse(profs[0]['valor']);

      //if(perAumentoAdulto>0 && widget.tipo=='ADULTO' ){
        //valorBase=valorBase+(valorBase*perAumentoAdulto/100);
     // }

      //if(perAumentoInfantil>0 && widget.tipo=='INFANTIL'){
        //valorBase=valorBase+(valorBase*perAumentoInfantil/100);
     // }
      ///PISO INFANTIL
      penA = double.parse(profs[2]['valor']);
      ///PROGRESSÃO ENTRE NÍVEIS
      penB = double.parse(profs[3]['valor']);
      penC = double.parse(profs[4]['valor']);
      penD = double.parse(profs[5]['valor']);
      penE = double.parse(profs[6]['valor']);
      _percEntreColunas = double.parse(profs[1]['percentual']);

      ///Percentual de cálculo entre as colunas

      final result = calculateTableAndDispersions(
        niveis: ['NA', 'NB', 'NC', 'ND', 'NE'], // Exemplo de níveis
        //niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'], // Exemplo de níveis
        valorBase: valorBase,
        penA: penA,
        penB: penB,
        penC: penC,
        penD: penD,
        penE: penE,
        cargaHoraria: cargaHoraria,
        percEntreColunas: _percEntreColunas,
      );

      setState(() {
        _calculatedTableValues = result.calculatedTableValues;
        _dispersaoHorizontal = result.dispersaoHorizontal;
        _dispersaoTotal = result.dispersaoTotal;
      });

      // Calcula a tabela e dispersões
    } catch (e) {
      print('Erro ao carregar dados ou calcular: $e');

    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Registra os listeners. Eles reagirão a mudanças SE a tela estiver visível.
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    _calculatedTableValues=[];
    professores=null;
    _loadDataAndCalculate();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            Texto(tit: 'Carregando dados...',cor: textColor,tam: 16,bottom: 16,),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      professores==null?Center(
          child: Utils.vazio('Nenhum dado Encontrado')
      ):
      SingleChildScrollView(
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
                borderColor: Colors.grey.shade300,
                cargaHoraria: cargaHoraria, // Sua carga horária
                niveis: ['NB', 'NC', 'ND', 'NE'], // Seus níveis
               // niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'], // Seus níveis
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
/*
              ProfessorDistributionTable(
                primaryColor: Colors.blue, // Your primary color
                textColor: Colors.black,   // Your text color
                borderColor: Colors.grey.shade300,
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

 */
              SizedBox(height: 24),
              ///Quantidade de professores com as somas dos saários
              ///Somatório de vencimentos por nível e classe
              SalaryTotalsTable(
                primaryColor: Colors.blue, // ou sua cor primária
                textColor: Colors.black,   // ou sua cor de texto
                tipo: widget.horas,
                cargaHoraria: cargaHoraria, // ou seu valor
                niveis: ['NA', 'NB', 'NC', 'ND', 'NE'], // sua lista de níveis
                calculatedTableValues: _calculatedTableValues, // seus valores calculados
                quantidadeDeProfessores: (nivel, coluna) {
                  return quantidadeDeProfessores(nivel, coluna);
                },
                professores: professores, // sua lista de professores
              ),
              SizedBox(height: 24),

              SummaryTable(
                  totalProfissionais: totProf,
                  custoMensal: _custoMensal,
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
                        'Quantidade de Classes',
                        '$cargaHoraria classes',
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
            Icon(icon, size: 24, color: primaryColor),
            SizedBox(height: 8),
            Texto(tit: title,cor: textColor.withOpacity(0.7),tam: 12,),
            SizedBox(height: 4),
            Texto(tit: value,cor:primaryColor ,tam: 16,negrito: true,),
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
          final result = calculateTableAndDispersions(
            niveis: ['NA', 'NB', 'NC', 'ND', 'NE'],
            //niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'],// Exemplo de níveis
            valorBase: valorBase,
            penA: penA,
            penB: penB,
            penC: penC,
            penD: penD,
            penE: penE,
            cargaHoraria: cargaHoraria,
            percEntreColunas: _percEntreColunas,
          );

          setState(() {
            _calculatedTableValues = result.calculatedTableValues;
            _dispersaoHorizontal = result.dispersaoHorizontal;
            _dispersaoTotal = result.dispersaoTotal;

          });
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
        novoValor=novoValor.replaceAll('R\$', '');
        novoValor=novoValor.replaceAll(',', '.');
        setState(() {
          _percEntreColunas = double.tryParse(novoValor)!;
          final result = calculateTableAndDispersions(
            niveis: [ 'NA', 'NB', 'NC', 'ND', 'NE'], // Exemplo de níveis
            // niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'],
            valorBase: valorBase,
            penA: penA,
            penB: penB,
            penC: penC,
            penD: penD,
            penE: penE,
            cargaHoraria: cargaHoraria,
            percEntreColunas: _percEntreColunas,
          );

          setState(() {
            _calculatedTableValues = result.calculatedTableValues;
            _dispersaoHorizontal = result.dispersaoHorizontal;
            _dispersaoTotal = result.dispersaoTotal;

          });
        });
      },
    );
  }
}//565
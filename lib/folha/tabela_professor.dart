import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

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
  final String hora;
  final String idItens;
  final String descricao;

  const SimuladorTabelaProfessor({
    Key? key,
    required this.table,
    required this.idItens,
    required this.hora,
    required this.descricao
  }) : super(key: key);

  @override
  State<SimuladorTabelaProfessor> createState() => _SimuladorTabelaProfessorState();
}

class _SimuladorTabelaProfessorState extends State<SimuladorTabelaProfessor> {
  int cargaHoraria = 30;
  double _percEntreColunas=0;
  var profs; // Dados brutos da API
  bool isLoading = true;
  // Variáveis para armazenar os resultados calculados
  List<List<double>> _calculatedTableValues = [];
  Map<String, int> _professoresPorNivel = {};
  String _dispersaoHorizontal = '0.00%'; // Valor inicial como string formatada
  String _dispersaoTotal = '0.00%'; // Valor inicial como string formatada
  int? selectedRow;
  int? selectedColumn;
  String selectedValue = 'Nenhuma célula selecionada';
  String nivel = '';
  String  coluna = '';
  var professores;
  int totProf=0;
  double perProgressaoEntreClasse=2;
  //double perAumentoAdulto=0.00;
  double _custoMensal = 0.0;
  double totalFolha=0;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  List<String> novosNiveis=[];
  List<String> valorNivel=[];
  List<String> niveisUnicos=[];

  // Adicione este método para lidar com a seleção
  void _handleCellSelection(int row, int column) async {
    setState(() {
      selectedRow = row;
      selectedColumn = column;
      selectedValue = '${niveisUnicos[row]}  ${column + 1}';
    });

    nivel = niveisUnicos[row];
    //nivel = niveis[row].substring(1, 2);
    coluna = (column + 1).toString();
    if (coluna.length == 1) {
      coluna = '0$coluna';
    }
    var n=nivel.substring(0,1);
    String ni = n + coluna;
   // print('xxxxxxxxxxxx => $ni');
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
    print('nivel $nivel coluna $coluna');
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivel$colunaFormatada';
    chave=chave.replaceAll('NIVEL', '').trim();
    print('CHAVE : $chave');

    return _professoresPorNivel[chave] ?? 0;
  }

  Future<void> _loadDataAndCalculate() async {
    try{
      //Pega os novos níveis
      var hs=widget.hora;

      var getNiveis=await ApiMySql.getItensFromForm(TBSimulaForm,widget.idItens,null).timeout(const Duration(seconds: 30));
      if(getNiveis.isEmpty){
        Utils.snak('Atenção', 'Não tem nenhum nível cadastrado para ${widget.descricao}', false, Colors.red);
        setState(() => isLoading = false);
        return;
      }
      if(getNiveis.contains('Erro')){
        Utils.snak('Atenção', 'Não foi possível conectar com o servidor. Tente novamente', false, Colors.red);
        return;
      }
      novosNiveis = getNiveis.map((item) => item['label'].toString()).toList();
      valorNivel = getNiveis.map((item) => item['valor'].toString()).toList();

      var nu=await ApiMySql.getProfPorNivel(TBFolha,widget.hora).timeout(const Duration(seconds: 30));
      niveisUnicos = nu.map((item) => item['nivel'].toString()).toList();
      //print('NIVEIS UNICO');
      //print(niveisUnicos);


      professores = await ApiMySql.getProPorHora(widget.hora,TBFolha,TBVantagens).timeout(const Duration(seconds: 30));
     // print(professores);
      if(professores==null){
        setState(() => isLoading = false);
        return;
      }
      if(professores.isEmpty){
        setState(() => isLoading = false);
        return;
      }
     // print(professores);
     // if(professores.erro!=null){
       // print('MMMMMMMMMMMMMMMM');
     // }

      ///Pega os totais
      final totais = await ApiMySql.get(TBTotais,null,null).timeout(const Duration(seconds: 30));
      print('TOTAIS $totais');

      perProgressaoEntreClasse=double.parse(totais[0]['perc_aumento_infantil']);
      print('perProgressaoEntreClasse $perProgressaoEntreClasse');
      cargaHoraria=int.parse(totais[0]['qtde_classe']);
      print('CARGA HORARIA =$cargaHoraria');

      /// Pré-processa a contagem de professores por nível
      _professoresPorNivel = {};
      for (var item in professores) {
        final nivel = item['nivel']?.toString() ?? '';
        _professoresPorNivel[nivel] = (_professoresPorNivel[nivel] ?? 0) + 1;
      }
     // print('_professoresPorNivel $_professoresPorNivel');
      ///Pega a quantidade de professores
      final tot = await Future.wait([
        Utils.calculateTotals(professores),
      ]);
    //  print('totals $totals');
      setState(() {
        _custoMensal = tot[0]['total']!;
        print('custo toal => $_custoMensal');
        totProf=professores.length;
        print('totla de professores $totProf');
        isLoading = true;
      });

      totalFolha=double.parse(professores[0]['total_vencimentos_geral']);
    } catch (e) {
      print('Erro ao carregar dados ou calcular: $e');
    }
    try {
      double  valorBase = double.parse(valorNivel[0]);
      valorBase=valorBase+(valorBase*perProgressaoEntreClasse/100);
      _percEntreColunas = perProgressaoEntreClasse;

      ///Percentual de cálculo entre as colunas
      final result = calculateTableAndDispersions(
        niveis: novosNiveis,
        valoresIniciaisNiveis:valorNivel ,
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
      Utils.snak('Atenção', 'Erro ao caulcular', false, Colors.red);
      setState(() {
        _calculatedTableValues = [];
        _dispersaoHorizontal = '0';
        _dispersaoTotal = '0';
      });
      print('Erro ao carregar dados ou calcular KKKKKKKKKKKKKKK: $e');

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
                niveis: novosNiveis,
                niveisP: niveisUnicos,
                descricao: widget.descricao,
                calculatedTableValues: _calculatedTableValues, // Seus valores calculados
                quantidadeDeProfessores: (nivel, coluna) {
                  return quantidadeDeProfessores(nivel, coluna);
                },
                onCellSelected: (row, column) {
                  _handleCellSelection(row, column);
                },
              ),
              SizedBox(height: 24),
              ///Quantidade de professores com as somas dos saários
              ///Somatório de vencimentos por nível e classe
              SalaryTotalsTable(
                primaryColor: Colors.blue, // ou sua cor primária
                textColor: Colors.black,   // ou sua cor de texto
                tipo: widget.hora,
                cargaHoraria: cargaHoraria, // ou seu valor
                //niveis: novosNiveis,
                novosNiveis: novosNiveis,
                //niveisP: niveisUnicos,
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
      aoSalvar: (novoValor)async {
        await ApiMySql.executaSql('update $TBTotais set qtde_classe=$novoValor').timeout(const Duration(seconds: 30));
        setState(() {
          cargaHoraria = int.tryParse(novoValor)!;
          final result = calculateTableAndDispersions(
           niveis: novosNiveis,
           valoresIniciaisNiveis: valorNivel,
            cargaHoraria: cargaHoraria,
            percEntreColunas: _percEntreColunas,
          );

          setState(() {
            _calculatedTableValues = result.calculatedTableValues;//São os valores calculados
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
      inputFormatters: [
        CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')
      ],
      aoSalvar: (novoValor) async {
        novoValor=novoValor.replaceAll('%', '');
        novoValor=novoValor.replaceAll(',', '.');
        novoValor=novoValor.trim();
        setState(() {
          _percEntreColunas = double.tryParse(novoValor)!;
          final result = calculateTableAndDispersions(
            niveis: novosNiveis,
            valoresIniciaisNiveis: valorNivel,
            cargaHoraria: cargaHoraria,
            percEntreColunas: _percEntreColunas,
          );

          setState(() {
            _calculatedTableValues = result.calculatedTableValues;
            _dispersaoHorizontal = result.dispersaoHorizontal;
            _dispersaoTotal = result.dispersaoTotal;

          });
        });
        ///atualiza a base de dados
       var vr=Utils.saldoToSave(novoValor);
        double? vr2=double.tryParse(vr);
        vr2=(vr2! / 100)!;
        print('Update $TBTotais set perc_aumento_infantil=$vr2');
        await ApiMySql.executaSql('Update $TBTotais set perc_aumento_infantil=$vr2').timeout(const Duration(seconds: 30));
      },
    );
  }
}//565
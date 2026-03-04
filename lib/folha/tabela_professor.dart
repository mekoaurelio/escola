import 'dart:convert';

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
import 'professor_utils.dart';
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
  //double _percEntreColunas=0;
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
  double _custoMensal = 0.0;
  double totalFolha=0;
  String? _meses;
  String? _decimo_ter_ferias;
  String? _encargos_sociais;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  List<String> novosNiveis=[];
  List<String> titulos=[];
  List<String> valorNivel=[];
  List<String> niveisUnicos=[];

  final ScrollController _horizontalController = ScrollController();

  int quantidadeDeProfessores(String nivel, int coluna) {
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivel$colunaFormatada';
    chave=chave.replaceAll('NIVEL', '').trim();
    final ScrollController _horizontalController = ScrollController();
    return _professoresPorNivel[chave] ?? 0;
  }

  Future<void> _loadDataAndCalculate() async {
    setState(() => isLoading = true); // Apenas no início

    try {
      // ======= Parte 1: Carregar dados =======
      final getNiveis = await ApiMySql.getItensFromForm(TBSimulaForm, widget.idItens, 'id_form',).timeout(const Duration(seconds: 30));
      if (getNiveis.isEmpty) {
        Utils.snak('Atenção', 'Não tem nenhum nível cadastrado para ${widget.descricao}', false, Colors.red);
        return;
      }
      if (getNiveis.contains('Erro')) {
        Utils.snak('Atenção', 'Não foi possível conectar com o servidor. Tente novamente', false, Colors.red);
        return;
      }

      final novosNiveisTmp = getNiveis.map((item) => item['label'].toString()).toList();
      final titulosTmp = getNiveis.map((item) => item['titulo'].toString()).toList();
      final valorNivelProgressaoTmp = getNiveis.map((item) => item['valor_progressao'].toString()).toList();
      final nu = await ApiMySql.getProfPorNivel(TBFolha, widget.hora,).timeout(const Duration(seconds: 30));
      final niveisUnicosTmp = nu.map((item) => item['nivel'].toString()).toList();
      final professoresTmp = await ApiMySql.getProPorHora(widget.hora, TBFolha, TBVantagens,).timeout(const Duration(seconds: 30));

      if (professoresTmp == null || professoresTmp.isEmpty) {
        Utils.snak('Atenção', 'Não foi possível carregar os professores. Tente novamente', false, Colors.red);
        return;
      }

      final totais = await ApiMySql.get(TBTotais, null, null).timeout(const Duration(seconds: 30));
      final getHoraProgressao = await ApiMySql.getItensFromForm(TBSimulaCab, widget.idItens, 'id',).timeout(const Duration(seconds: 30));

      final perProgressaoEntreClasseTmp = double.parse(getHoraProgressao[0]['progressao']);
      final cargaHorariaTmp = int.parse(getHoraProgressao[0]['classes']);

      // Pré-processa a contagem de professores por nível
      final professoresPorNivelTmp = <String, int>{};
      for (var item in professoresTmp) {
        final nivel = item['nivel']?.toString() ?? '';
        professoresPorNivelTmp[nivel] = (professoresPorNivelTmp[nivel] ?? 0) + 1;
      }
      // Totais
      final mesesTmp = totais[0]['meses'].toString();
      final decimoTerFeriasTmp = totais[0]['decimo_ter_ferias'].toString();
      final encargosSociaisTmp = totais[0]['encargos_sociais'].toString();
      final totProfTmp = professoresTmp.length;
      final totalFolhaTmp = double.parse(professoresTmp[0]['total_vencimentos_geral']);

      // ======= Parte 2: Calcular tabela e dispersões =======
      List<List<double>> calculatedTableValuesTmp = [];
      String dispersaoHorizontalTmp = '0';
      String dispersaoTotalTmp = '0';

      try {

        final result = calculateTableAndDispersions(
          niveis: novosNiveisTmp,
         // valoresIniciaisNiveis: valorNivelTmp,
          valoresIniciaisNiveis: valorNivelProgressaoTmp,

          cargaHoraria: cargaHorariaTmp,
          percEntreColunas: perProgressaoEntreClasseTmp,
        );

        calculatedTableValuesTmp = result.calculatedTableValues;

        dispersaoHorizontalTmp = result.dispersaoHorizontal;
        dispersaoTotalTmp = result.dispersaoTotal;
      } catch (e) {
        Utils.snak('Atenção', 'Erro ao calcular', false, Colors.red);
        print('Erro ao calcular tabela/dispersão: $e');
      }

      // ======= Atualiza tudo de uma vez =======
      double cm=await calculaCustoMensal(novosNiveisTmp,calculatedTableValuesTmp,professoresTmp);

      setState(() {
        novosNiveis = novosNiveisTmp;
        titulos = titulosTmp;

        valorNivel = valorNivelProgressaoTmp;

        niveisUnicos = niveisUnicosTmp;
        professores = professoresTmp;
        perProgressaoEntreClasse = perProgressaoEntreClasseTmp;
        cargaHoraria = cargaHorariaTmp;
        _professoresPorNivel = professoresPorNivelTmp;
        _custoMensal = cm;
        _meses = mesesTmp;
        _decimo_ter_ferias = decimoTerFeriasTmp;
        _encargos_sociais = encargosSociaisTmp;
        totProf = totProfTmp;
        totalFolha = totalFolhaTmp;
        perProgressaoEntreClasse = perProgressaoEntreClasseTmp;
        _calculatedTableValues = calculatedTableValuesTmp;
        _dispersaoHorizontal = dispersaoHorizontalTmp;
        _dispersaoTotal = dispersaoTotalTmp;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados ou calcular: $e');
      return;
    }
  }

  Future<double> calculaCustoMensal(final niveis,List<List<double>> calculatedTableValues, final professoresTmp)async{
    double total=0;
    for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++){
      for (int coluna = 0; coluna < calculatedTableValues[nivelIndex].length; coluna++){
        double x=await ProfessorUtils.totalDeVencimentosProposta(
            niveis[nivelIndex].toString(), coluna + 1, professoresTmp,calculatedTableValues);
        if(x>0) {
          total+=x;
        }
      }
    }
    print('VALOR MENSAL 40 horas $total');
    return total;
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
      body: professores==null?Center(
          child: Utils.vazio('Nenhum dado Encontrado')
      ):

      Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
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
                titulos: titulos,
                niveisP: niveisUnicos,
                descricao: widget.descricao,
                calculatedTableValues: _calculatedTableValues, // Seus valores calculados
                quantidadeDeProfessores: (nivel1, coluna) {
                  return quantidadeDeProfessores(nivel1, coluna);
                },
                onCellSelected: (row, column) {
                  //_handleCellSelection(row, column);
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
                novosNiveis: novosNiveis,
                percAumento: perProgressaoEntreClasse,
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
                  meses: int.parse(_meses!),
                  ferias: double.parse(_decimo_ter_ferias!),
                  remuneracaoTotal: 20993884.21,
                  encargosPercentual: double.parse(_encargos_sociais!),
                  totalEncargos: 6968798,
                  totalComEncargos: 0697079709,
                professores: professores,
              )
            ],
          ),
        ),
      ),
      )
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
                        Colors.white,
                        primaryColor,
                        onTap: () => _editWorkingHours(),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.45,
                      ),
                      child: _buildSummaryItem(
                        'Progressão',
                        '${perProgressaoEntreClasse.toStringAsFixed(2)}%',
                        Icons.trending_up,
                        Colors.white,
                        primaryColor,
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
                          double.parse(Utils.saldoToSave(_dispersaoHorizontal))>30?Colors.red:Colors.white,
                        double.parse(Utils.saldoToSave(_dispersaoHorizontal))>30?Colors.white:primaryColor,
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
                          double.parse(Utils.saldoToSave(_dispersaoTotal))>95?Colors.red:Colors.white,
                        double.parse(Utils.saldoToSave(_dispersaoTotal))>95?Colors.white:primaryColor,
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

  Widget _buildSummaryItem(String title, String value, IconData icon,Color cor,Color corTexto, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cor,
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
            Texto(tit: title,cor: corTexto,tam: 12,),
            SizedBox(height: 4),
            Texto(tit: value,cor:corTexto ,tam: 16,negrito: true,),
          ],
        ),
      ),
    );
  }

  void _editWorkingHours() {
    Utils.mostrarDialogoEditarValor(
      context: context,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      titulo: 'Editar Classes',
      labelCampo: 'Classes',
      valorInicial: cargaHoraria.toString(),
      aoSalvar: (novoValor)async {
        var id=widget.idItens;
        final result = calculateTableAndDispersions(
          niveis: novosNiveis,
          valoresIniciaisNiveis: valorNivel,
          cargaHoraria: cargaHoraria,
          percEntreColunas: double.parse(novoValor),
        );
        await ApiMySql.executaSql('update $TBSimulaCab set classes=$novoValor where id=$id').timeout(const Duration(seconds: 30));

        final cm=await calculaCustoMensal(novosNiveis,result.calculatedTableValues,professores);
        setState(() {
          _custoMensal=cm;
          cargaHoraria = int.tryParse(novoValor)!;
          _calculatedTableValues = result.calculatedTableValues;//São os valores calculados
          _dispersaoHorizontal = result.dispersaoHorizontal;
          _dispersaoTotal = result.dispersaoTotal;
        });
      },
    );
  }

  void _editProgression() {
    Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: 'Editar Progressão',
      labelCampo: 'Percentual',
      valorInicial: perProgressaoEntreClasse.toString(),
      inputFormatters: [
        CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')
      ],
      aoSalvar: (novoValor) async {
        novoValor=novoValor.replaceAll('%', '');
        novoValor=novoValor.replaceAll(',', '.');
        novoValor=novoValor.trim();
        final result = calculateTableAndDispersions(
          niveis: novosNiveis,
          valoresIniciaisNiveis: valorNivel,
          cargaHoraria: cargaHoraria,
          percEntreColunas: double.parse(novoValor),
        );
        final cm=await calculaCustoMensal(novosNiveis,result.calculatedTableValues,professores);
        setState(() {
          _custoMensal=cm;
          perProgressaoEntreClasse = double.tryParse(novoValor)!;
          _calculatedTableValues = result.calculatedTableValues;
          _dispersaoHorizontal = result.dispersaoHorizontal;
          _dispersaoTotal = result.dispersaoTotal;
        });
        ///atualiza a base de dados
       var vr=Utils.saldoToSave(novoValor);
        double? vr2=double.tryParse(vr);
        vr2=(vr2! / 100)!;
        var id=widget.idItens;
        await ApiMySql.executaSql('Update $TBSimulaCab set progressao=$vr2 where id=$id').timeout(const Duration(seconds: 30));
      },
    );
  }
}//565
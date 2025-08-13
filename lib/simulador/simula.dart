import 'package:GEM/services/GlobalFilterController.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../const/const.dart';
import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/calc_dispersao_valores.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class Simula extends StatefulWidget {
  const Simula({super.key});

  @override
  State<Simula> createState() => _SimulaState();
}

class _SimulaState extends State<Simula> {
  List<dynamic> _adulto = [];
  List<dynamic> _infantil = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _totalAdulto = 0;
  double _totalInfantil = 0;
  double _atsAdulto = 0;
  double _atsInfantil = 0;
  int _countAdulto = 0;
  int _countInfantil = 0;
  var percAUmAdulto = '0';
  var perAumentoInf = '0';
  double totalGeralProfessor = 0;
  double totalPropostaProfessor = 0;
  double totalGeralInfantil = 0;
  double totalPropostaInfantil = 0;
  String _dispersaoHorizontal = '0.00%'; // Valor inicial como string formatada
  String _dispersaoTotal = '0.00%';
  final GlobalFilterController filterController =
      Get.find<GlobalFilterController>();

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _reactToFilterChange());
    filterController.ano.listen((_) => _reactToFilterChange());
    filterController.bimestre.listen((_) => _reactToFilterChange());
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    _loadData();
  }

  void _reactToFilterChange() {
    print("Listener do GetX acionado! (Mudança ocorreu com a tela aberta)");
    _loadDataBasedOnCurrentFilters();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      ///PEGA OS PERCENTUAIS DE AUMENTO
      final totais = await ApiMySql.get(TBTotais, null, null);
      final profs = await ApiMySql.get(TBProfessor, null, 'ordem');
      final profInfantil = await ApiMySql.get(TBInfantil, null, 'ordem');

      perAumentoInf = '0';
      percAUmAdulto = '0';

      if(profs.isNotEmpty){
        percAUmAdulto=profs[1]['percentual'];
      }
      if(profInfantil.isNotEmpty){
        perAumentoInf=profInfantil[1]['percentual'];
      }

      if (totais.isNotEmpty) {
        //perAumentoInf = totais[0]['perc_aumento_infantil'] ?? '0';
        //percAUmAdulto = totais[0]['perc_aumento_adulto'] ?? '0';

      } else {
        // Defina valores padrão ou lance um erro se esses dados são essenciais
       // perAumentoInf = '0';
       // percAUmAdulto = '0';
      }

      ///PEGA OS PROFESSORES EDUCADORES
      final adulto = await ApiMySql.getProfessores(
        'ADULTO',
        TBFolha,
        TBVantagens,
      ).timeout(const Duration(seconds: 30));

      ///PEGA OSPROFESSORES INFANTIL
      final infantil = await ApiMySql.getProfessores('INFANTIL',
        TBFolha,
        TBVantagens,
      ).timeout(const Duration(seconds: 30));

      final totals = await Future.wait([
        Utils.calculateTotals(adulto),
        Utils.calculateTotals(infantil),
      ]);


      ///PROGRESSÃO ENTRE NÍVEIS EDUCADOR
     /*
      final valorBase = double.parse(profs[0]['valor']);
      final penA = double.parse(profs[2]['valor']);
      final penB = double.parse(profs[3]['valor']);
      final penC = double.parse(profs[4]['valor']);
      final penD = double.parse(profs[5]['valor']);
      final penE = double.parse(profs[6]['valor']);
      final cargaHoraria = 11;
      final _percEntreColunas = double.parse(profs[1]['percentual']);
      //Progressão entre Classes

      */

      final valorBase = double.parse(profs[0]['valor']);
      final penA = double.parse(profs[2]['valor']);
      ///PROGRESSÃO ENTRE NÍVEIS
      final penB = double.parse(profs[3]['valor']);
      final penC = double.parse(profs[4]['valor']);
      final penD = double.parse(profs[5]['valor']);
      final penE = double.parse(profs[6]['valor']);
      final _percEntreColunas = double.parse(profs[1]['percentual']);

      final result = calculateTableAndDispersions(
        niveis: ['NA', 'NB', 'NC', 'ND', 'NE'], // Exemplo de níveis
        //niveis: ['BASE', 'NA', 'NB', 'NC', 'ND', 'NE'], // Exemplo de níveis
        valorBase: valorBase,
        penA: penA,
        penB: penB,
        penC: penC,
        penD: penD,
        penE: penE,
        cargaHoraria: 15,
        percEntreColunas: _percEntreColunas,
      );


      setState(() {
        _adulto = adulto;
        _infantil = infantil;
        _totalAdulto = totals[0]['total'] ?? 0;
        _atsAdulto = totals[0]['ats'] ?? 0;
        _countAdulto = adulto.length;
        _totalInfantil = totals[1]['total'] ?? 0;
        _atsInfantil = totals[1]['ats'] ?? 0;
        _countInfantil = infantil.length;
        _isLoading = false;
        _hasError = false;
        _dispersaoHorizontal = result.dispersaoHorizontal;
        _dispersaoTotal = result.dispersaoTotal;
      });
    } on TimeoutException {
      _handleError('Tempo excedido ao carregar dados. Verifique sua conexão.');
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar dados: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleError('Erro ao carregar dados: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
    });
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            _hasError ? 'Recarregando...' : 'Carregando dados...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _errorMessage,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget lin(
    var text,
    bool negrito,
    Alignment alin, {
    Color cor = Colors.black54,
  }) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Align(
        alignment: alin, // Alinha o conteúdo à direita
        child: Texto(tit: text, negrito: negrito, cor: cor),
      ),
    );
  }

  Widget _buildProfessorTable() {
    final encargos = _totalAdulto * 0.14;
    final proposta = _totalAdulto + (_totalAdulto * (double.parse(percAUmAdulto) / 100));
    final dif = proposta - _totalAdulto;

    ///APTS
    final proAPTS =
        _atsAdulto + (_atsAdulto * (double.parse(percAUmAdulto) / 100));
    final difAPTS = proAPTS - _atsAdulto;

    ///VATAGENS PECUNIÁRIAS
    final vatagensPecuniarias = _totalAdulto * 0.1;
    final proVatagensPecuniarias =
        vatagensPecuniarias +
        (vatagensPecuniarias * (double.parse(percAUmAdulto) / 100));
    final difVatagensPecuniarias = proVatagensPecuniarias - vatagensPecuniarias;

    ///ENCARGOS
    final proEncargos =
        encargos + (encargos * (double.parse(percAUmAdulto) / 100));
    final difEncargos = proEncargos - encargos;

    ///TOTAL REMUNERAÇÃO
    final _proTot =
        proposta +
        proAPTS +
        proEncargos +
        proVatagensPecuniarias; // Corrigido o cálculo
    final difTot = dif + difAPTS + difEncargos + difVatagensPecuniarias;
    totalGeralProfessor =
        _totalAdulto + _atsAdulto + encargos + (_totalAdulto * 0.1);
    totalPropostaProfessor = _proTot;
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          border: TableBorder.all(color: Colors.grey[300]!),
          children: [
            ///CABEÇALHO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                lin('Vantagens', true, Alignment.centerLeft),
                lin('Atual', true, Alignment.center),
                lin('Proposta', true, Alignment.center),
                lin('Variação', true, Alignment.center),
              ],
            ),

            ///VECTO BÁSICO
            TableRow(
              children: [
                lin('Vencimento Básico', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(_totalAdulto),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(proposta),
                  false,
                  Alignment.centerRight,
                ),
                lin(Utils.formatVr.format(dif), false, Alignment.centerRight),
              ],
            ),

            ///ADTS
            TableRow(
              children: [
                lin('Adicional Tempo Serviço', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(_atsAdulto),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(proAPTS),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(difAPTS),
                  false,
                  Alignment.centerRight,
                ),
              ],
            ),

            ///VANTAGENS
            TableRow(
              children: [
                lin('Vantagens Pecuniárias', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(vatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(proVatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(difVatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ),
              ],
            ),

            ///ENCARGOS SOCIAIS (14%)
            TableRow(
              children: [
                lin('Encargos Sociais (14%)', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(encargos),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(proEncargos),
                  true,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(difEncargos),
                  true,
                  Alignment.centerRight,
                ),
              ],
            ),

            ///TOTAL REMUNERAÇÃO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                lin(
                  'TOTAL REMUNERAÇÃO',
                  true,
                  Alignment.centerLeft,
                  cor: Colors.blue.shade800,
                ),
                lin(
                  Utils.formatVr.format(
                    _totalAdulto + _atsAdulto + encargos + (_totalAdulto * 0.1),
                  ),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ),
                lin(
                  Utils.formatVr.format(_proTot),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ),

                ///Proposta
                lin(
                  Utils.formatVr.format(difTot),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ), //DIF
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducInfantilTable() {
    final encargos = _totalInfantil * 0.14;
    final proposta =
        _totalInfantil + (_totalInfantil * (double.parse(perAumentoInf) / 100));
    final dif = proposta - _totalInfantil;

    ///APTS
    final proAPTS =
        _atsInfantil + (_atsInfantil * (double.parse(perAumentoInf) / 100));
    final difAPTS =
        proAPTS -
        _atsInfantil; // Corrigido: usando _atsInfantil em vez de _atsAdulto

    ///VATAGENS PECUNIÁRIAS
    final vatagensPecuniarias = _atsInfantil * 0.1;
    final proVatagensPecuniarias =
        vatagensPecuniarias +
        (vatagensPecuniarias * (double.parse(perAumentoInf) / 100));
    final difVatagensPecuniarias = proVatagensPecuniarias - vatagensPecuniarias;

    ///ENCARGOS
    final proEncargos =
        encargos + (encargos * (double.parse(perAumentoInf) / 100));
    final difEncargos = proEncargos - encargos;

    ///TOTAL REMUNERAÇÃO - Cálculo corrigido incluindo todos os componentes
    final totalAtual =
        _totalInfantil + _atsInfantil + encargos + vatagensPecuniarias;
    final _proTot =
        proposta +
        proAPTS +
        proEncargos +
        proVatagensPecuniarias; // Corrigido o cálculo
    final difTot = dif + difAPTS + difEncargos + difVatagensPecuniarias;
    totalGeralInfantil = totalAtual;
    totalPropostaInfantil = _proTot;

    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          border: TableBorder.all(color: Colors.grey[300]!),
          children: [
            ///CABEÇALHO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                lin('Vantagens', true, Alignment.centerLeft),
                lin('Atual', true, Alignment.center),
                lin('Proposta', true, Alignment.center),
                lin('Variação', true, Alignment.center),
              ],
            ),

            ///VECTO BÁSICO
            TableRow(
              children: [
                lin('Vencimento Básico', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(_totalInfantil),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(proposta),
                  false,
                  Alignment.centerRight,
                ),
                lin(Utils.formatVr.format(dif), false, Alignment.centerRight),
              ],
            ),

            ///ADTS
            TableRow(
              children: [
                lin('Adicional Tempo Serviço', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(_atsInfantil),
                  false,
                  Alignment.centerRight,
                ), // Corrigido: usando _atsInfantil
                lin(
                  Utils.formatVr.format(proAPTS),
                  false,
                  Alignment.centerRight,
                ),
                lin(
                  Utils.formatVr.format(difAPTS),
                  false,
                  Alignment.centerRight,
                ),
              ],
            ),

            ///VANTAGENS PECUNIÁRIAS
            TableRow(
              children: [
                lin('Vantagens Pecuniárias', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(vatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ), // Corrigido: usando _totalInfantil
                lin(
                  Utils.formatVr.format(proVatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ), // Corrigido: usando _totalInfantil
                lin(
                  Utils.formatVr.format(difVatagensPecuniarias),
                  false,
                  Alignment.centerRight,
                ),
              ],
            ),

            ///ENCARGOS SOCIAIS (14%)
            TableRow(
              children: [
                lin('Encargos Sociais (14%)', false, Alignment.centerLeft),
                lin(
                  Utils.formatVr.format(encargos),
                  false,
                  Alignment.centerRight,
                ),

                ///Atual
                lin(
                  Utils.formatVr.format(proEncargos),
                  false,
                  Alignment.centerRight,
                ),

                ///Proposta
                lin(
                  Utils.formatVr.format(difEncargos),
                  false,
                  Alignment.centerRight,
                ),

                ///Dif
              ],
            ),

            ///TOTAL REMUNERAÇÃO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                lin(
                  'TOTAL REMUNERAÇÃO',
                  true,
                  Alignment.centerLeft,
                  cor: Colors.blue.shade800,
                ),
                lin(
                  Utils.formatVr.format(totalAtual),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ),
                // Total atual correto
                lin(
                  Utils.formatVr.format(_proTot),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ),
                // Proposta total correta
                lin(
                  Utils.formatVr.format(difTot),
                  true,
                  Alignment.centerRight,
                  cor: Colors.blue.shade800,
                ),
                // Diferença correta
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariationCell({
    required double variationValue,
    required double percentage,
    TextStyle? textStyle,
  }) {
    // Define a cor e o ícone com base no valor do percentual
    final Color chipColor;
    final IconData iconData;

    String espaco = '';
    if (percentage.toString().length == 1) {
      espaco = ' ';
    }
    if (percentage > 0.01) {
      chipColor = Colors.green.shade700;
      iconData = Icons.arrow_upward_rounded;
    } else if (percentage < -0.01) {
      chipColor = Colors.red.shade700;
      iconData = Icons.arrow_downward_rounded;
    } else {
      chipColor = Colors.grey.shade600;
      iconData = Icons.remove_rounded;
    }

    // Defina uma largura fixa para o chip para garantir uniformidade
    const double chipWidth = 95.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Usamos Row para alinhar os itens no final da célula
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Alinha tudo à direita
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. O valor da diferença em moeda
          // Usamos Expanded para que o texto não empurre o chip para fora da tela
          // se o número for muito grande, mas ainda o alinhamos à direita.
          Expanded(
            child: Text(
              Utils.formatVr.format(variationValue),
              style: textStyle,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis, // Evita quebra de layout
            ),
          ),

          const SizedBox(width: 8.0),
          // Espaço entre o valor e o chip

          // 2. O "Chip" dentro de um SizedBox de largura fixa
          SizedBox(
            width: chipWidth,
            child: Chip(
              avatar: Icon(iconData, color: Colors.white, size: 14),
              label: Text(
                '$espaco ${percentage.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: chipColor,
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
              labelPadding: const EdgeInsets.only(left: 2.0, right: 4.0),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoTable() {
    ///TOTAL GERAL
    final totGeral = totalGeralProfessor + totalGeralInfantil;
    final proGeral = totalPropostaInfantil + totalPropostaProfessor;
    final difGeral = proGeral - totGeral;
    final percAumento = (totGeral > 0) ? (totGeral / proGeral) * 100 : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'RESUMO GERAL',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.2), // Ajustando larguras
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    lin('Cargo', true, Alignment.centerLeft),
                    lin('Total', true, Alignment.center),
                    Align(
                      alignment: Alignment.center,
                      // Alinha o conteúdo à direita
                      child: Texto(
                        tit: 'Proposta',
                        negrito: true,
                        top: 10,
                        alin: TextAlign.center,
                        icone: Icons.edit,
                        tooltip: 'Click aqui para ....',
                        aoClicarIcone: () {
                          Utils.mostrarDialogoEditarValor(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]'),
                              ),
                            ],
                            context: context,
                            titulo: 'Simular para quantos meses ',
                            labelCampo: 'Meses',
                            valorInicial: '0',
                            aoSalvar: (novoValor) {
                              setState(() {
                                // percP = double.tryParse(novoValor)!;
                                //_calculateTableAndDispersions();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    lin('Variação', true, Alignment.center),
                  ],
                ),
                TableRow(
                  children: [
                    lin('Professores', true, Alignment.centerLeft),
                    lin(
                      Utils.formatVr.format(totalGeralProfessor),
                      true,
                      Alignment.centerRight,
                    ),

                    ///TOTAL
                    lin(
                      Utils.formatVr.format(totalPropostaProfessor),
                      true,
                      Alignment.centerRight,
                    ),

                    ///PROPOSTA
                    _buildVariationCell(
                      variationValue:
                          totalPropostaProfessor - totalGeralProfessor,
                      percentage:
                          (totalGeralProfessor > 0)
                              ? totalGeralProfessor /
                                  totalPropostaProfessor *
                                  100
                              : 0.0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    lin('Educador Infantil', true, Alignment.centerLeft),
                    lin(
                      Utils.formatVr.format(totalGeralInfantil),
                      true,
                      Alignment.centerRight,
                    ),

                    ///TOTAL
                    lin(
                      Utils.formatVr.format(totalPropostaInfantil),
                      true,
                      Alignment.centerRight,
                    ),

                    ///PROPOSTA
                    _buildVariationCell(
                      variationValue:
                          totalPropostaInfantil - totalGeralInfantil,
                      percentage:
                          (totalGeralInfantil > 0)
                              ? (totalGeralInfantil / totalPropostaInfantil) *
                                  100
                              : 0.0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    lin(
                      'Total Geral',
                      true,
                      Alignment.centerLeft,
                      cor: Colors.blue.shade800,
                    ),
                    lin(
                      Utils.formatVr.format(totGeral),
                      true,
                      Alignment.centerRight,
                      cor: Colors.blue.shade800,
                    ),

                    ///TOTAL
                    lin(
                      Utils.formatVr.format(proGeral),
                      true,
                      Alignment.centerRight,
                      cor: Colors.blue.shade800,
                    ),

                    ///PROPOSTA
                    _buildVariationCell(
                      variationValue: difGeral,
                      percentage: percAumento,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dentro da sua classe _SimulaState
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required int count,
    required String tipo,
    Widget? child,
  }) {

    Widget _buildInfoChip({
      required String text,
      required IconData trailingIcon,
      required VoidCallback onTap,
      required Color bgColor,
      required Color borderColor,
      required Color textColor,
      required Color iconColor,
      String? tooltip,
    }) {
      return Container(
        // REMOVA a largura fixa. Deixe o Expanded controlar.
        // width: 40,

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor, // Removido o amarelo de debug
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          // mainAxisSize foi removido para permitir que a Row preencha o Container
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaça o texto e o ícone
          children: [
            // 1. O Texto agora é Flexible, ele pode quebrar a linha.
            Flexible(
              child: Texto(
                tit: text,
                tam: 11,
                fontWeight: FontWeight.w600,
                cor: textColor,
                tooltip: 'Clique para editar',
              ),
            ),
            const SizedBox(width: 4), // Pequeno espaço
            // 2. O ícone tem tamanho fixo, então não precisa ser flexível.
            Tooltip(
              message: tooltip ?? 'Clique para editar',
              child: GestureDetector(
                onTap: onTap,
                child: Icon(trailingIcon, size: 18, color: iconColor),
              ),
            ),
          ],
        ),
      );
    }
    return Card(
      elevation: 2,
      color: const Color(0xFFF9F9FB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // LINHA 1: TÍTULO E CONTAGEM (DISTRIBUÍDOS)
            // ==========================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // A MÁGICA ACONTECE AQUI
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Parte Esquerda: Ícone e Título
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Parte Direita: Contagem
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(), // Divisor para separar as seções
            const SizedBox(height: 20),

            // ==========================================================
            // LINHA 2: CHIPS DE INFORMAÇÃO (DISTRIBUÍDOS)
            // ==========================================================
            Row(
              children: [
                // Chip de Aumento
                Expanded(
                  flex: 2,
                  child: _buildInfoChip(
                    text: 'Aumento ${tipo == "INFANTIL" ? perAumentoInf : percAUmAdulto}%',
                    trailingIcon: Icons.edit,
                    bgColor: Colors.grey[50]!,
                    borderColor: Colors.grey[100]!,
                    textColor: Colors.grey[800]!,
                    iconColor: Colors.grey[600]!,
                    onTap: () {
                      Utils.mostrarDialogoEditarValor(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                          ),
                        ],
                        context: context,
                        titulo: tipo == 'INFANTIL' ? perAumentoInf : percAUmAdulto,
                        labelCampo: 'Percentual',
                        valorInicial: tipo == 'INFANTIL' ? perAumentoInf : percAUmAdulto,
                        aoSalvar: (novoValor) async {
                          if (tipo == 'INFANTIL') {
                            await ApiMySql.executaSql(
                              'UPDATE $TBInfantil set percentual=$novoValor where ordem=8',
                            );
                            await ApiMySql.executaSql(
                              'UPDATE $TBTotais set perc_aumento_infantil=$novoValor',
                            );
                          } else {
                            await ApiMySql.executaSql(
                              'UPDATE $TBProfessor set percentual=$novoValor where ordem=8',
                            );
                            await ApiMySql.executaSql(
                              'UPDATE $TBTotais set perc_aumento_adulto=$novoValor',
                            );
                          }
                          setState(() {
                            if (tipo == 'INFANTIL') {
                              perAumentoInf = novoValor;
                            } else {
                              percAUmAdulto = novoValor;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                /// Chip de Dispersão Horizontal
                Expanded(
                  flex: 2,
                  child: _buildInfoChip(
                    text: 'Disp. Horizontal ${_dispersaoHorizontal}%',
                    trailingIcon: Icons.info_outline,
                    tooltip: 'Dispersão salarial entre classes \nClick Aqui Para Saber Mais',
                    bgColor:
                        double.parse(_dispersaoHorizontal) > 29.5
                            ? Colors.red!
                            : Colors.green[100]!,
                    borderColor:
                        double.parse(_dispersaoHorizontal) > 29.5
                            ? Colors.red!
                            : Colors.green[100]!,
                    textColor: Colors.black54,
                    iconColor: Colors.black54,
                    onTap: dicas,
                  ),
                ),
                const SizedBox(width: 8),
                /// Chip de Dispersão Vertical
                Expanded(
                  flex: 2,
                  child: _buildInfoChip(
                    text: 'Disp. Total ${_dispersaoTotal}%',
                    trailingIcon: Icons.info_outline,
                    tooltip:
                        'Dispersão salarial entre níveis\nClick Aqui Para Saber Mais',
                    bgColor:
                        double.parse(_dispersaoTotal) > 95
                            ? Colors.red[100]!
                            : Colors.green[100]!,
                    borderColor:
                        double.parse(_dispersaoTotal) > 95
                            ? Colors.red[100]!
                            : Colors.green[100]!,
                    textColor: Colors.black54,
                    iconColor: Colors.black54,
                    onTap: dicas,
                  ),
                ),
              ],
            ),

            // O conteúdo expansível (tabela)
            if (child != null) ...[const SizedBox(height: 34), child],
          ],
        ),
      ),
    );
  }

  dicas() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Texto(tit: 'Significado das cores ', tam: 20, negrito: true),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Texto(
                  tit:
                      'VERDE : Significa que a progressao da sua instituição está  aceitável',
                  cor: Colors.green[500]!,
                ),
                Texto(
                  tit: 'VERMELHO : Significa que a progressao da sua instituição está  ACIMA do aceitável',
                  cor: Colors.red,negrito: true,
                ),
                SizedBox(height: 10),
                Texto(
                  tit: 'Valor aceitável dispersão HORIZONTAL é de 29,5%',
                  negrito: true,
                ),
                Texto(
                  tit: 'Valor aceitável dispersão TOTAL é de 95%',
                  negrito: true,
                ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: corFundoOadrao, body: _buildLoading());
    }

    if (_hasError) {
      return Scaffold(backgroundColor: corFundoOadrao, body: _buildErrorView());
    }

    if (_adulto.isEmpty && _infantil.isEmpty) {
      return Scaffold(
        backgroundColor: corFundoOadrao,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Utils.vazio('Nenhum dado encontrado'),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Recarregar dados'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Ou corFundoOadrao
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define um "breakpoint": a largura a partir da qual mudamos o layout.
            // 900 é um bom valor para este tipo de card.
            const double breakpointWidth = 900;
            final bool isWideScreen = constraints.maxWidth > breakpointWidth;

            // SE a tela for larga, usamos um Row.
            if (isWideScreen) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Envolvemos cada card em um Expanded para que dividam o espaço
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.groups_rounded,
                          iconColor: const Color(0xFF007BFF),
                          backgroundColor: const Color(0xFFD6EAF8),
                          label: 'Professores',
                          count: _countAdulto,
                          child: _buildProfessorTable(),
                          tipo: 'ADULTO',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.face_retouching_natural,
                          iconColor: const Color(0xFFE67E22),
                          backgroundColor: const Color(0xFFFCF3CF),
                          label: 'Educ. Infantil',
                          count: _countInfantil,
                          child: _buildEducInfantilTable(),
                          tipo: 'INFANTIL',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Espaço antes da tabela de resumo
                  _buildResumoTable(),
                ],
              );
            }
            // SENÃO (tela estreita), usamos uma Column.
            else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Os cards são colocados diretamente na Column, sem Expanded.
                  _buildSummaryCard(
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF007BFF),
                    backgroundColor: const Color(0xFFD6EAF8),
                    label: 'Professores',
                    count: _countAdulto,
                    child: _buildProfessorTable(),
                    tipo: 'ADULTO',
                  ),
                  const SizedBox(height: 16),
                  // Espaço entre os cards
                  _buildSummaryCard(
                    icon: Icons.face_retouching_natural,
                    iconColor: const Color(0xFFE67E22),
                    backgroundColor: const Color(0xFFFCF3CF),
                    label: 'Educ. Infantil',
                    count: _countInfantil,
                    child: _buildEducInfantilTable(),
                    tipo: 'INFANTIL',
                  ),
                  const SizedBox(height: 16),
                  // Espaço antes da tabela de resumo
                  _buildResumoTable(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


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
import '../widgets/line.dart';
import '../widgets/texto.dart';
import 'dadosFinanceiros.dart';
import 'financialDetailsTable.dart';

class Simula extends StatefulWidget {
  const Simula({super.key});

  @override
  State<Simula> createState() => _SimulaState();
}

class _SimulaState extends State<Simula> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _totalAdulto = 0;
  double _atsAdulto = 0;
  var percAumento = '0';
  double totalGeralProfessor = 0;
  double totalPropostaProfessor = 0;
  String _dispersaoHorizontal = '0.00%'; // Valor inicial como string formatada
  String _dispersaoTotal = '0.00%';
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  List<String> novosNiveis=[];
  List<String> niveisUnicos=[];
  List<String> valorNivel=[];
  List<Map<String, dynamic>> professores = [];

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
      ///PEGA OS TOTAIS DE  PROFESSORES POR HORA
      var getProfessores = await ApiMySql.getTotolSalPorHora(TBFolha,TBSimulaCab,TBVantagens).timeout(const Duration(seconds: 30));
      //print(getProfessores);

      if(getProfessores[0]['error']!=null){
        Utils.snak('Atenção', 'Erro pegar total por hora', false, Colors.red);
        return;
      }
      ///PEGA OS PERCENTUAIS DE AUMENTO
      final totais = await ApiMySql.get(TBTotais, null, null);
      percAumento = totais[0]['perc_aumento_infantil'].toString();
      var cargaHorario=totais[0]['qtde_classe'].toString();

      professores.clear();
      totalGeralProfessor=0;
      totalPropostaProfessor=0;

      for(int i = 0 ; i<getProfessores.length ; i++) {
        if(getProfessores[i]['descricao']!=null) {

          totalGeralProfessor+=double.parse(getProfessores[i]['total_vencimento']);
          totalPropostaProfessor+= totalGeralProfessor + (totalGeralProfessor * (double.parse(percAumento) / 100));

          var getNiveis=await ApiMySql.getItensFromForm(TBSimulaForm,getProfessores[i]['id'],null);
          novosNiveis = getNiveis.map((item) => item['label'].toString()).toList();
          valorNivel = getNiveis.map((item) => item['valor'].toString()).toList();

          final result = calculateTableAndDispersions(
            niveis: novosNiveis,
            valoresIniciaisNiveis:valorNivel ,
            cargaHoraria: int.parse(cargaHorario),
            percEntreColunas: double.parse(percAumento),
          );

          professores.add({
            'descricao': getProfessores[i]['descricao']?.toString() ?? 'Nome não disponível',
            'quantidade': getProfessores[i]['quantidade_registros']?.toString() ?? '0',
            'totalVencimentos': getProfessores[i]['total_vencimento']?.toString() ?? '0',
            'totalVantagens': getProfessores[i]['total_vantagens']?.toString() ?? '0',

            'dispersaoHorizontal': result.dispersaoHorizontal.replaceAll(',', '.'),
            'dispersaoTotal': result.dispersaoTotal.replaceAll(',', '.'),
          });
        }
      }


      setState(() {
        _isLoading = false;
        _hasError = false;
        //var dh=result.dispersaoHorizontal.replaceAll(',', '.');
        //_dispersaoHorizontal = dh;
        //var dt=result.dispersaoTotal.replaceAll(',', '.');
        //_dispersaoTotal = dt;
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
    final proposta = _totalAdulto + (_totalAdulto * (double.parse(percAumento) / 100));
    final dif = proposta - _totalAdulto;
    ///APTS
    final proAPTS = _atsAdulto + (_atsAdulto * (double.parse(percAumento) / 100));
    final difAPTS = proAPTS - _atsAdulto;

    ///VATAGENS PECUNIÁRIAS
    final vatagensPecuniarias = _totalAdulto * 0.1;
    final proVatagensPecuniarias =
        vatagensPecuniarias + (vatagensPecuniarias * (double.parse(percAumento) / 100));
    final difVatagensPecuniarias = proVatagensPecuniarias - vatagensPecuniarias;

    ///ENCARGOS
    final proEncargos = encargos + (encargos * (double.parse(percAumento) / 100));
    final difEncargos = proEncargos - encargos;

    ///TOTAL REMUNERAÇÃO
    final _proTot = proposta + proAPTS + proEncargos + proVatagensPecuniarias; // Corrigido o cálculo
    final difTot = dif + difAPTS + difEncargos + difVatagensPecuniarias;
    totalGeralProfessor = _totalAdulto + _atsAdulto + encargos + (_totalAdulto * 0.1);
    //totalPropostaProfessor = _proTot;
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
    final totalGeral = totalGeralProfessor ;
    final propostaGeral = totalPropostaProfessor;
    final difGeral = totalGeral - propostaGeral;
    final percAumento = (totalGeral > 0) ? (totalGeral / propostaGeral) * 100 : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ///TITULO
            const Text('RESUMO GERAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
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
                ///Cabeçalho
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    lin('Cargo', true, Alignment.centerLeft,cor: Colors.black),
                    lin('Total', true, Alignment.center,cor: Colors.black),
                    Align(
                      alignment: Alignment.center,
                      // Alinha o conteúdo à direita
                      child: Texto(tit: 'Proposta', negrito: true, top: 10,cor: Colors.black, alin: TextAlign.center, icone: Icons.edit,
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
                    lin('Variação', true, Alignment.center,cor: Colors.black),
                  ],
                ),
                ///professores
                TableRow(
                  children: [
                    lin('Professores', true, Alignment.centerLeft),
                    lin(Utils.formatVr.format(totalGeralProfessor), true, Alignment.centerRight,),

                    ///TOTAL
                    lin(Utils.formatVr.format(totalPropostaProfessor), true, Alignment.centerRight,),

                    ///PROPOSTA
                    _buildVariationCell(
                      variationValue:
                      totalPropostaProfessor - totalGeralProfessor,
                      percentage:
                      (totalGeralProfessor > 0) ? totalGeralProfessor / totalPropostaProfessor * 100 : 0.0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ///TOTAL GERAL
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    lin('Total Geral', true, Alignment.centerLeft, cor: Colors.blue.shade800,),
                    lin(Utils.formatVr.format(totalGeral), true, Alignment.centerRight, cor: Colors.blue.shade800,),
                    ///TOTAL
                    lin(Utils.formatVr.format(propostaGeral), true, Alignment.centerRight, cor: Colors.blue.shade800,
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

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String label,
    required int count,
    required String dispersaoHorizontal,
    required String dispersaoTotal,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor, // Removido o amarelo de debug
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
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

            const SizedBox(height: 10),
            const Divider(), // Divisor para separar as seções
            const SizedBox(height: 10),

            // ==========================================================
            // LINHA 2: CHIPS DE INFORMAÇÃO (DISTRIBUÍDOS)
            // ==========================================================
            Row(
              children: [
                // Chip de Aumento
                Expanded(
                  flex: 2,
                  child: _buildInfoChip(
                    text: 'Aumento ${ percAumento}%',
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
                        titulo: 'teste de titulo',
                        labelCampo: 'Percentual',
                        valorInicial: percAumento,
                        aoSalvar: (novoValor) async {
                          await ApiMySql.executaSql('UPDATE $TBTotais set perc_aumento_adulto=$novoValor',
                          );
                          setState(() {
                            percAumento = novoValor;
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
                    text: 'Disp. Horizontal $dispersaoHorizontal%',
                    trailingIcon: Icons.info_outline,
                    tooltip: 'Dispersão salarial entre classes \nClick Aqui Para Saber Mais',
                    bgColor:
                    double.parse(dispersaoHorizontal) > 29.5
                        ? Colors.red!
                        : Colors.green[100]!,
                    borderColor:
                    double.parse(dispersaoHorizontal) > 29.5
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
                    text: 'Disp. Total $dispersaoTotal%',
                    trailingIcon: Icons.info_outline,
                    tooltip:
                    'Dispersão salarial entre níveis\nClick Aqui Para Saber Mais',
                    bgColor:
                    double.parse(dispersaoTotal) > 95
                        ? Colors.red[100]!
                        : Colors.green[100]!,
                    borderColor:
                    double.parse(dispersaoTotal) > 95
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
            if (child != null) ...[const SizedBox(height: 14), child],
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
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :
      SingleChildScrollView(
        child:  Column(
          children: [
            SizedBox(
              height: 560, // Dê uma altura fixa para a lista horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // Adiciona um espaçamento nas bordas da lista
                padding: const EdgeInsets.all(16.0),
                itemCount: professores.length,
                itemBuilder: (context, index) {
                  final data = professores[index];
                  final totVecto=double.parse(data['totalVencimentos']);
                  final proposta = totVecto + (totVecto * (double.parse(percAumento) / 100));
                 // final dif = proposta - totVecto;

                  ///APTS
                 // final proAPTS = _atsAdulto + (_atsAdulto * (double.parse(percAumento) / 100));
                //  final difAPTS = proAPTS - _atsAdulto;

                  ///VATAGENS PECUNIÁRIAS
                  final vatagensPecuniarias = double.parse(data['totalVantagens']);
                  final propostaVantagens = vatagensPecuniarias + (vatagensPecuniarias * (double.parse(percAumento) / 100));
                 // final difVatagensPecuniarias = propostaVantagens - vatagensPecuniarias;

                  ///ENCARGOS
                  final encargos = totVecto * 0.14;
                  final proEncargos = encargos + (encargos * (double.parse(percAumento) / 100));
                 // final difEncargos = proEncargos - encargos;

                  ///TOTAL REMUNERAÇÃO
                //  final _proTot = proposta + proAPTS + proEncargos + propostaVantagens; // Corrigido o cálculo
                  //final difTot = dif + difAPTS + difEncargos + difVatagensPecuniarias;
                  //totalGeralProfessor = _totalAdulto + _atsAdulto + encargos + (_totalAdulto * 0.1);
                  //totalPropostaProfessor = _proTot;

                  final dadosExemplo = DadosFinanceiros(
                    vencimentoAtual: double.parse(data['totalVencimentos']) ?? 0.0,
                    vencimentoProposta:proposta,

                    adicionalAtual: 0.00,
                    adicionalProposta: 0.00,

                    vantagensAtual: vatagensPecuniarias,
                    vantagensProposta: propostaVantagens,

                    encargosAtual: encargos,
                    encargosProposta: proEncargos,

                    dispersaoHorizontal: double.parse(data['dispersaoHorizontal']) ?? 0.0,
                    dispersaoTotal: double.parse(data['dispersaoTotal']) ?? 0.0,

                  );

                  final String descricao = data['descricao']?.toString() ?? data['horas']?.toString() ?? 'Não especificado';
                  final int quantidade = int.parse(data['quantidade']) ?? 0;

                  final String dispersaoHorizontal= data['dispersaoHorizontal'];
                  final String dispersaoTotal= data['dispersaoTotal'];
                  print('dispersaoHorizontal $dispersaoHorizontal');
                  print('dispersaoTotal $dispersaoTotal');

                  return Container(
                    width: 800, // Largura de cada card
                    margin: const EdgeInsets.only(right: 16.0), // Espaçamento entre os cards
                    child: _buildSummaryCard(
                      icon: Icons.school_rounded,
                      iconColor: const Color(0xFF007BFF),
                      backgroundColor: const Color(0xFFD6EAF8),
                      label: descricao,
                      count: quantidade,
                      dispersaoHorizontal: dispersaoHorizontal,
                      dispersaoTotal: dispersaoTotal,
                      child: FinancialDetailsTable(dados: dadosExemplo),
                    ),
                  );
                },
              ),
            ),
            _buildResumoTable(),
          ],
        )
      )
    );
  }
}//868

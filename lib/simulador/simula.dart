
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
  var percAumento = '0';
  double totalGeralProfessor = 0;
  double totalPropostaProfessor = 0;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  List<String> novosNiveis=[];
  List<String> niveisUnicos=[];
  List<String> valorNivel=[];
  List<Map<String, dynamic>> professores = [];
  final ScrollController _horizontalController = ScrollController();

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

      if(getProfessores[0]['error']!=null){
        Utils.snak('Atenção', 'Você ainda não informou os dados( 20horas,30horas...etc) no SIMULADOR', false, Colors.red);
        return;
      }

      professores.clear();
      totalGeralProfessor=0;
      totalPropostaProfessor=0;

      for(int i = 0 ; i<getProfessores.length ; i++) {
        if(getProfessores[i]['descricao']!=null) {
          percAumento=getProfessores[i]['progressao'];

          totalGeralProfessor+=double.parse(getProfessores[i]['total_vencimento']);
          totalPropostaProfessor+= totalGeralProfessor + (totalGeralProfessor * (double.parse(percAumento) / 100));

          var getNiveis=await ApiMySql.getItensFromForm(TBSimulaForm,getProfessores[i]['id'],null).timeout(const Duration(seconds: 30));
          novosNiveis = getNiveis.map((item) => item['label'].toString()).toList();
          valorNivel = getNiveis.map((item) => item['valor'].toString()).toList();

          final result = calculateTableAndDispersions(
            niveis: novosNiveis,
            valoresIniciaisNiveis:valorNivel ,
            cargaHoraria: int.parse(getProfessores[i]['classes']),
            percEntreColunas: double.parse(getProfessores[i]['progressao']),
          );

          professores.add({
            'descricao': getProfessores[i]['descricao']?.toString() ?? 'Nome não disponível',
            'quantidade': getProfessores[i]['quantidade_registros']?.toString() ?? '0',
            'totalVencimentos': getProfessores[i]['total_vencimento']?.toString() ?? '0',
            'totalVantagens': getProfessores[i]['total_vantagens']?.toString() ?? '0',

            'dispersaoHorizontal': result.dispersaoHorizontal.replaceAll(',', '.'),
            'dispersaoTotal': result.dispersaoTotal.replaceAll(',', '.'),
            'classes':int.parse(getProfessores[i]['classes']),
            'progressao':double.parse(getProfessores[i]['progressao']),
            'id':int.parse(getProfessores[i]['id']),
          });
        }
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
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
    required String classes,
    required String progressao,
    required int id,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconeNomeDoProfessor(icon,label,iconColor),
                quantidadeDeProfessores(count),
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
                   child:Container(
                     width:300,
                     child: Row(
                       children: [
                         Expanded(
                           flex: 2,
                           child: _buildSummaryItem(
                             '$classes Classes',
                             Icons.access_time,
                             onTap: () {
                               Utils.mostrarDialogoEditarValor(
                                 inputFormatters: [
                                   FilteringTextInputFormatter.allow(
                                     RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                                   ),
                                 ],
                                 context: context,
                                 titulo: 'Classes - $label',
                                 labelCampo: 'Percentual',
                                 valorInicial: classes,
                                 aoSalvar: (novoValor) async {
                                   await ApiMySql.executaSql('UPDATE $TBSimulaCab set classes=$novoValor where id=$id',).timeout(const Duration(seconds: 30));
                                   _loadData();
                                   setState(() {
                                    // percAumento = novoValor;
                                   });
                                 },
                               );
                             },
                           ),
                         ),
                         SizedBox(width: 10,),
                         Expanded(
                           flex: 3,
                           child:_buildSummaryItem(
                             'Progressão ${ progressao}%',
                             Icons.trending_up,
                             onTap: () {
                               Utils.mostrarDialogoEditarValor(
                                 inputFormatters: [
                                   FilteringTextInputFormatter.allow(
                                     RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                                   ),
                                 ],
                                 context: context,
                                 titulo: 'Progressão',
                                 labelCampo: 'Percentual',
                                 valorInicial: progressao,
                                 aoSalvar: (novoValor) async {
                                   await ApiMySql.executaSql('UPDATE $TBSimulaCab set progressao=$novoValor where id=$id',).timeout(const Duration(seconds: 30));
                                   _loadData();
                                   setState(() {
                                     //percAumento = novoValor;
                                   });
                                 },
                               );
                             },
                           ),
                         ),
                       ],
                     ),
                   )
               ),

                const SizedBox(width: 8),
                /// Chip de Dispersão Horizontal
                Expanded(
                  flex: 1,
                  child: _buildInfoChip(
                    text: 'Disp. Horizontal $dispersaoHorizontal%',
                    trailingIcon: Icons.info_outline,
                    tooltip: 'Dispersão salarial entre classes \nClick Aqui Para Saber Mais',
                    bgColor:
                    double.parse(dispersaoHorizontal) > 29.5
                        ? Colors.red
                        : Colors.green[100]!,
                    borderColor:
                    double.parse(dispersaoHorizontal) > 29.5
                        ? Colors.red
                        : Colors.green[100]!,
                    textColor: Colors.black54,
                    iconColor: Colors.black54,
                    onTap: dicas,
                  ),
                ),
                const SizedBox(width: 8),
                /// Chip de Dispersão Vertical
                Expanded(
                  flex: 1,
                  child: _buildInfoChip(
                    text: 'Disp. Total $dispersaoTotal%',
                    trailingIcon: Icons.info_outline,
                    tooltip: 'Dispersão salarial entre níveis\nClick Aqui Para Saber Mais',
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

  Widget IconeNomeDoProfessor(IconData icon,String label,Color iconColor){
    return  Row(
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
    );
  }

  Widget quantidadeDeProfessores(int count){
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
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
    );

  }

  Widget _buildSummaryItem(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
            Texto(tit: title,cor: textColor.withOpacity(0.7),tam: 12,),
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


/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(
            height: 560,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(professores.length, (index) {
                  final data = professores[index];
                  final totVecto = double.parse(data['totalVencimentos']);
                  final proposta = totVecto +
                      (totVecto * (double.parse(percAumento) / 100));

                  /// VANTAGENS PECUNIÁRIAS
                  final vatagensPecuniarias =
                  double.parse(data['totalVantagens']);
                  final propostaVantagens = vatagensPecuniarias +
                      (vatagensPecuniarias *
                          (double.parse(percAumento) / 100));

                  /// ENCARGOS
                  final encargos = totVecto * 0.14;
                  final proEncargos = encargos +
                      (encargos * (double.parse(percAumento) / 100));

                  final dadosExemplo = DadosFinanceiros(
                    vencimentoAtual:
                    double.tryParse(data['totalVencimentos']) ?? 0.0,
                    vencimentoProposta: proposta,
                    adicionalAtual: 0.00,
                    adicionalProposta: 0.00,
                    vantagensAtual: vatagensPecuniarias,
                    vantagensProposta: propostaVantagens,
                    encargosAtual: encargos,
                    encargosProposta: proEncargos,
                    dispersaoHorizontal:
                    double.tryParse(data['dispersaoHorizontal']) ?? 0.0,
                    dispersaoTotal:
                    double.tryParse(data['dispersaoTotal']) ?? 0.0,
                  );

                  final String descricao =
                      data['descricao']?.toString() ??
                          data['horas']?.toString() ??
                          'Não especificado';
                  final int quantidade = int.tryParse(data['quantidade']) ?? 0;

                  return Container(
                    width: 800,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: _buildSummaryCard(
                      icon: Icons.school_rounded,
                      iconColor: const Color(0xFF007BFF),
                      backgroundColor: const Color(0xFFD6EAF8),
                      label: descricao,
                      count: quantidade,
                      dispersaoHorizontal: data['dispersaoHorizontal'],
                      dispersaoTotal: data['dispersaoTotal'],
                      classes: data['classes'].toString(),
                      progressao: data['progressao'].toString(),
                      id: data['id'],
                      child: FinancialDetailsTable(dados: dadosExemplo),
                    ),
                  );
                }),
              ),
            ),
          ),
          /// Tabela de resumo
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.99,
            child: _buildResumoTable(),
          ),
        ],
      ),
    );
  }

 */



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          /// ÁREA QUE PRECISA SCROLL HORIZONTAL
          SizedBox(
            height: 560,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width,
                  ),
                  child: Row(
                    children: List.generate(professores.length, (index) {
                      final data = professores[index];

                      final totVecto = double.parse(data['totalVencimentos']);
                      final proposta = totVecto +
                          (totVecto * (double.parse(percAumento) / 100));

                      final vatagensPecuniarias =
                      double.parse(data['totalVantagens']);
                      final propostaVantagens = vatagensPecuniarias +
                          (vatagensPecuniarias *
                              (double.parse(percAumento) / 100));

                      final encargos = totVecto * 0.14;
                      final proEncargos = encargos +
                          (encargos * (double.parse(percAumento) / 100));

                      final dadosExemplo = DadosFinanceiros(
                        vencimentoAtual:
                        double.tryParse(data['totalVencimentos']) ?? 0.0,
                        vencimentoProposta: proposta,
                        adicionalAtual: 0.00,
                        adicionalProposta: 0.00,
                        vantagensAtual: vatagensPecuniarias,
                        vantagensProposta: propostaVantagens,
                        encargosAtual: encargos,
                        encargosProposta: proEncargos,
                        dispersaoHorizontal:
                        double.tryParse(data['dispersaoHorizontal']) ??
                            0.0,
                        dispersaoTotal:
                        double.tryParse(data['dispersaoTotal']) ?? 0.0,
                      );

                      final String descricao = data['descricao']?.toString() ??
                          data['horas']?.toString() ??
                          'Não especificado';
                      final int quantidade =
                          int.tryParse(data['quantidade']) ?? 0;

                      return Container(
                        width: 800,
                        margin: const EdgeInsets.only(right: 16.0),
                        child: _buildSummaryCard(
                          icon: Icons.school_rounded,
                          iconColor: const Color(0xFF007BFF),
                          backgroundColor: const Color(0xFFD6EAF8),
                          label: descricao,
                          count: quantidade,
                          dispersaoHorizontal: data['dispersaoHorizontal'],
                          dispersaoTotal: data['dispersaoTotal'],
                          classes: data['classes'].toString(),
                          progressao: data['progressao'].toString(),
                          id: data['id'],
                          child: FinancialDetailsTable(
                            dados: dadosExemplo,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          /// Tabela de resumo
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.99,
            child: _buildResumoTable(),
          ),
        ],
      ),
    );
  }


}//868

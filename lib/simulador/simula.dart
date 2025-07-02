import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/line.dart';
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
  var percAUmAdulto='0';
  var perAumentoInf='0';
  double totalGeralProfessor=0;
  double totalPropostaProfessor=0;
  double totalGeralInfantil=0;
  double totalPropostaInfantil=0;

  @override
  void initState() {
    super.initState();
    _loadData();
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

      if (totais.isNotEmpty) {
        perAumentoInf = totais[0]['perc_aumento_infantil'] ?? '0';
        percAUmAdulto = totais[0]['perc_aumento_adulto'] ?? '0';
      } else {
        // Defina valores padrão ou lance um erro se esses dados são essenciais
        perAumentoInf = '0';
        percAUmAdulto = '0';
        debugPrint("Aviso: A tabela de totais retornou vazia. Usando percentuais padrão.");
      }

      ///PEGA OS PROFESSORES EDUCADORES
      final adulto = await ApiMySql.getProfessores('ADULTO').timeout(const Duration(seconds: 30));
      ///PEGA OSPROFESSORES INFANTIL
      final infantil = await ApiMySql.getProfessores('INFANTIL').timeout(const Duration(seconds: 30));

      final totals = await Future.wait([
        Utils.calculateTotals(adulto),
        Utils.calculateTotals(infantil),
      ]);



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
      });

      debugPrint('Dados carregados e estado atualizado com sucesso');
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

  Widget lin(var text,bool negrito,Alignment alin,{Color cor=Colors.black54}){
    return  Padding(
      padding: EdgeInsets.all(8),
      child: Align(
        alignment: alin, // Alinha o conteúdo à direita
        child: Texto(tit:text,negrito: negrito,cor: cor,),
      )
    );
  }

  Widget _buildProfessorTable() {
    final encargos = _totalAdulto * 0.14;
    final proposta = _totalAdulto + (_totalAdulto * (double.parse(percAUmAdulto) / 100));
    final dif = proposta - _totalAdulto;

    ///APTS
    final proAPTS = _atsAdulto + (_atsAdulto * (double.parse(percAUmAdulto) / 100));
    final difAPTS = proAPTS - _atsAdulto;

    ///VATAGENS PECUNIÁRIAS
    final vatagensPecuniarias=_totalAdulto * 0.1;
    final proVatagensPecuniarias=vatagensPecuniarias + (vatagensPecuniarias * (double.parse(percAUmAdulto) / 100));
    final difVatagensPecuniarias=proVatagensPecuniarias-vatagensPecuniarias;

    ///ENCARGOS
    final proEncargos = encargos + (encargos * (double.parse(percAUmAdulto) / 100));
    final difEncargos = proEncargos - encargos;

    ///TOTAL REMUNERAÇÃO
    final _proTot = proposta + proAPTS + proEncargos+proVatagensPecuniarias; // Corrigido o cálculo
    final difTot = dif+difAPTS+difEncargos+difVatagensPecuniarias;
    totalGeralProfessor=_totalAdulto + _atsAdulto + encargos+(_totalAdulto * 0.1);
    totalPropostaProfessor=_proTot;
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
                lin(Utils.formatVr.format(_totalAdulto), false, Alignment.centerRight),
                lin(Utils.formatVr.format(proposta), false, Alignment.centerRight),
                lin(Utils.formatVr.format(dif), false, Alignment.centerRight),
              ],
            ),

            ///ADTS
            TableRow(
              children: [
                lin('Adicional Tempo Serviço', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(_atsAdulto), false, Alignment.centerRight),
                lin(Utils.formatVr.format(proAPTS), false, Alignment.centerRight),
                lin(Utils.formatVr.format(difAPTS), false, Alignment.centerRight),
              ],
            ),

            ///VANTAGENS
            TableRow(
              children: [
                lin('Vantagens Pecuniárias', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(vatagensPecuniarias), false, Alignment.centerRight),
                lin(Utils.formatVr.format(proVatagensPecuniarias), false, Alignment.centerRight),
                lin(Utils.formatVr.format(difVatagensPecuniarias), false, Alignment.centerRight),
              ],
            ),

            ///ENCARGOS SOCIAIS (14%)
            TableRow(
              children: [
                lin('Encargos Sociais (14%)', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(encargos), false, Alignment.centerRight),
                lin(Utils.formatVr.format(proEncargos), true, Alignment.centerRight),
                lin(Utils.formatVr.format(difEncargos), true, Alignment.centerRight),
              ],
            ),

            ///TOTAL REMUNERAÇÃO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                lin('TOTAL REMUNERAÇÃO', true, Alignment.centerLeft, cor: Colors.blue.shade800),
                lin(Utils.formatVr.format(_totalAdulto + _atsAdulto + encargos+(_totalAdulto * 0.1)), true, Alignment.centerRight, cor: Colors.blue.shade800),
                lin(Utils.formatVr.format(_proTot), true, Alignment.centerRight, cor: Colors.blue.shade800),///Proposta
                lin(Utils.formatVr.format(difTot), true, Alignment.centerRight, cor: Colors.blue.shade800),//DIF
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducInfantilTable() {
    final encargos = _totalInfantil * 0.14;
    final proposta = _totalInfantil + (_totalInfantil * (double.parse(perAumentoInf) / 100));
    final dif = proposta - _totalInfantil;

    ///APTS
    final proAPTS = _atsInfantil + (_atsInfantil * (double.parse(perAumentoInf) / 100));
    final difAPTS = proAPTS - _atsInfantil; // Corrigido: usando _atsInfantil em vez de _atsAdulto

    ///VATAGENS PECUNIÁRIAS
    final vatagensPecuniarias=_atsInfantil * 0.1;
    final proVatagensPecuniarias=vatagensPecuniarias + (vatagensPecuniarias * (double.parse(perAumentoInf) / 100));
    final difVatagensPecuniarias=proVatagensPecuniarias-vatagensPecuniarias;

    ///ENCARGOS
    final proEncargos = encargos + (encargos * (double.parse(perAumentoInf) / 100));
    final difEncargos = proEncargos - encargos;

    ///TOTAL REMUNERAÇÃO - Cálculo corrigido incluindo todos os componentes
    final totalAtual = _totalInfantil + _atsInfantil + encargos+vatagensPecuniarias;
    final _proTot = proposta + proAPTS + proEncargos+proVatagensPecuniarias; // Corrigido o cálculo
    final difTot = dif+difAPTS+difEncargos+difVatagensPecuniarias;
    totalGeralInfantil=totalAtual;
    totalPropostaInfantil=_proTot;

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
                lin(Utils.formatVr.format(_totalInfantil), false, Alignment.centerRight),
                lin(Utils.formatVr.format(proposta), false, Alignment.centerRight),
                lin(Utils.formatVr.format(dif), false, Alignment.centerRight),
              ],
            ),

            ///ADTS
            TableRow(
              children: [
                lin('Adicional Tempo Serviço', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(_atsInfantil), false, Alignment.centerRight), // Corrigido: usando _atsInfantil
                lin(Utils.formatVr.format(proAPTS), false, Alignment.centerRight),
                lin(Utils.formatVr.format(difAPTS), false, Alignment.centerRight),
              ],
            ),

            ///VANTAGENS PECUNIÁRIAS
            TableRow(
              children: [
                lin('Vantagens Pecuniárias', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(vatagensPecuniarias), false,Alignment.centerRight), // Corrigido: usando _totalInfantil
                lin(Utils.formatVr.format(proVatagensPecuniarias), false, Alignment.centerRight), // Corrigido: usando _totalInfantil
                lin(Utils.formatVr.format(difVatagensPecuniarias), false, Alignment.centerRight),
              ],
            ),

            ///ENCARGOS SOCIAIS (14%)
            TableRow(
              children: [
                lin('Encargos Sociais (14%)', false, Alignment.centerLeft),
                lin(Utils.formatVr.format(encargos), false, Alignment.centerRight),///Atual
                lin(Utils.formatVr.format(proEncargos), false, Alignment.centerRight),///Proposta
                lin(Utils.formatVr.format(difEncargos), false, Alignment.centerRight),///Dif
              ],
            ),

            ///TOTAL REMUNERAÇÃO
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[100]),
              children: [
                lin('TOTAL REMUNERAÇÃO', true, Alignment.centerLeft, cor: Colors.blue.shade800),
                lin(Utils.formatVr.format(totalAtual), true, Alignment.centerRight, cor: Colors.blue.shade800),
                // Total atual correto
                lin(Utils.formatVr.format(_proTot), true, Alignment.centerRight, cor: Colors.blue.shade800),
                // Proposta total correta
                lin(Utils.formatVr.format(difTot), true, Alignment.centerRight, cor: Colors.blue.shade800),
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

    String espaco='';
    if(percentage.toString().length==1){
      espaco=' ';
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

          const SizedBox(width: 8.0), // Espaço entre o valor e o chip

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
    final totGeral=totalGeralProfessor+totalGeralInfantil;
    final proGeral=totalPropostaInfantil+totalPropostaProfessor;
    final difGeral=proGeral-totGeral;
    final percAumento = (totGeral > 0) ? (totGeral / proGeral) * 100 : 0.0;


    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('RESUMO GERAL',
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
                  children:  [
                    lin('Cargo',true,Alignment.centerLeft),
                    lin('Total',true,Alignment.center),
                    Align(
                      alignment: Alignment.center, // Alinha o conteúdo à direita
                      child: Texto(tit:'Proposta',negrito: true,top: 10,alin: TextAlign.center,
                        icone: Icons.edit,
                        tooltip: 'Click aqui para ....',
                        aoClicarIcone: () {
                          Utils.mostrarDialogoEditarValor(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))
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

                    /*
                    Tooltip(
                      message: 'Click aqui para simular para vários meses',
                      child:Row(
                        children: [
                          lin('Proposta',true,Alignment.center),///PROPOSTA
                         /*
                          IconButton(
                            onPressed: () => Utils.snak('oi', 'teste', false, Colors.green),
                            icon: Icon(Icons.edit, size: 15, color: Colors.black38,),
                          ),

                          */
                        ],
                      )


                    ),

                     */
                    lin('Variação',true,Alignment.center),
                  ],
                ),
                TableRow(
                  children: [
                    lin('Professores',true,Alignment.centerLeft),
                    lin(Utils.formatVr.format(totalGeralProfessor),true,Alignment.centerRight),///TOTAL
                    lin(Utils.formatVr.format(totalPropostaProfessor),true,Alignment.centerRight),///PROPOSTA
                    _buildVariationCell(
                      variationValue: totalPropostaProfessor-totalGeralProfessor,
                      percentage: (totalGeralProfessor > 0) ? totalGeralProfessor / totalPropostaProfessor * 100 : 0.0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    lin('Educador Infantil',true,Alignment.centerLeft),
                    lin(Utils.formatVr.format(totalGeralInfantil),true,Alignment.centerRight),///TOTAL
                    lin(Utils.formatVr.format(totalPropostaInfantil),true,Alignment.centerRight),///PROPOSTA

                    _buildVariationCell(
                      variationValue: totalPropostaInfantil - totalGeralInfantil,
                      percentage: (totalGeralInfantil > 0) ? (totalGeralInfantil / totalPropostaInfantil) * 100 : 0.0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    lin('Total Geral',true,Alignment.centerLeft,cor: Colors.blue.shade800 ),
                    lin(Utils.formatVr.format(totGeral),true,Alignment.centerRight,cor: Colors.blue.shade800),///TOTAL
                    lin(Utils.formatVr.format(proGeral),true,Alignment.centerRight,cor: Colors.blue.shade800),///PROPOSTA
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
    required String tipo,
    Widget? child, // NOVO PARÂMETRO OPCIONAL
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: const Color(0xFFF9F9FB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ///ICONE
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      ///TEXTO
                      Text(label,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Texto(tit:'Aumento ${tipo == "INFANTIL" ? perAumentoInf : percAUmAdulto}%',left: 20,negrito: true,
                        icone: Icons.edit,
                        aoClicarIcone: () {
                          Utils.mostrarDialogoEditarValor(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))
                            ],
                            context: context,
                            titulo: tipo=='INFANTIL'?perAumentoInf:percAUmAdulto,
                            labelCampo: 'Percentual',
                            valorInicial: '10',
                            aoSalvar: (novoValor) {
                              setState(() {
                                if(tipo=='INFANTIL'){
                                  perAumentoInf=novoValor;
                                }else{
                                  percAUmAdulto=novoValor;
                                }
                               // percP = double.tryParse(novoValor)!;
                                //_calculateTableAndDispersions();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  ///QUANTIDADE
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              if (child != null) ...[
                const SizedBox(height: 24),
                child, // ADICIONA O WIDGET DETALHADO (a tabela)
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Simulador Magistério')), body: _buildLoading());
    }

    if (_hasError) {
      return Scaffold(appBar: AppBar(title: const Text('Simulador Magistério')), body: _buildErrorView());
    }

    if (_adulto.isEmpty && _infantil.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Simulador Magistério')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 50),
              const SizedBox(height: 20),
              const Text('Nenhum dado encontrado', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
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
      appBar: AppBar(
        title: const Text('Simulador Magistério'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Recarregar Dados',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF007BFF),
                  backgroundColor: const Color(0xFFD6EAF8),
                  label: 'Professores',
                  count: _countAdulto,
                  child: _buildProfessorTable(),
                  tipo: 'ADULTO'
                ),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  icon: Icons.face_retouching_natural,
                  iconColor: const Color(0xFFE67E22),
                  backgroundColor: const Color(0xFFFCF3CF),
                  label: 'Educ. Infantil',
                  count: _countInfantil,
                  child: _buildEducInfantilTable(),
                  tipo: 'INFANTIL'
                ),
              ],
            ),
            _buildResumoTable(),
          ],
        ),
      ),
    );
  }
}




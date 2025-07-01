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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
      perAumentoInf = totais[0]['perc_aumento_infantil'];
      percAUmAdulto= totais[0]['perc_aumento_adulto'];
      ///PEGA OS PROFESSORES EDUCADORES
      final adulto = await ApiMySql.getProfessores('ADULTO').timeout(const Duration(seconds: 30));
      ///PEGA OSPROFESSORES INFANTIL
      final infantil = await ApiMySql.getProfessores('INFANTIL').timeout(const Duration(seconds: 30));

      final totals = await Future.wait([
        Utils.calculateTotals(adulto),
        Utils.calculateTotals(infantil),
      ]);

      if (!mounted) return;

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
    _totalAdulto ;
    final proposta=_totalAdulto+(_totalAdulto*(double.parse(percAUmAdulto)/100));
    final dif=proposta-_totalAdulto;
    ///APTS
    //_atsAdulto=_atsAdulto*-1;
    final proAPTS=_atsAdulto+(_atsAdulto*(double.parse(percAUmAdulto)/100));
    final difAPTS=proAPTS-_atsAdulto;

    ///ENCARGOS
   final proEncargos=encargos+(encargos*(double.parse(percAUmAdulto)/100));
   final difEncargos=proEncargos-encargos;

   ///TOTAL REMUNERAçÃO
    final proTot=_totalAdulto+(_totalAdulto*(double.parse(percAUmAdulto)/100));
    final difTot=proTot-_totalAdulto;

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
                    lin('Vantagens',true,Alignment.centerLeft),
                    lin('Atual',true,Alignment.center),
                    lin('Proposta',true,Alignment.center),
                    lin('Variação',true,Alignment.center),
                  ],
                ),

                ///VECTO BÁSICO
                TableRow(
                  children: [
                    lin('Vencimento Básico',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_totalAdulto),false,Alignment.centerRight),///atual
                    lin(Utils.formatVr.format(proposta),false,Alignment.centerRight),///proposta
                    lin(Utils.formatVr.format(dif),false,Alignment.centerRight),
                  ],
                ),
               ///ADTS
                TableRow(
                  children: [
                    lin('Adicional Tempo Serviço',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_atsAdulto),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(proAPTS),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(difAPTS),false,Alignment.centerRight),
                  ],
                ),
               ///VANTAGENS
                TableRow(
                  children: [
                    lin('Vantagens Pecuniárias',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_totalAdulto * 0.1),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(_totalAdulto * 0.1),false,Alignment.centerRight),
                    lin('0,00',false,Alignment.centerRight),

                  ],
                ),
                ///ENCARGOS SOCIAIS (14%)
                TableRow(
                  children: [
                    lin('Encargos Sociais (14%)',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(encargos),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(proEncargos),true,Alignment.centerRight),
                    lin(Utils.formatVr.format(difEncargos),true,Alignment.centerRight),
                  ],
                ),
               ///TOTAL REMUNERAÇÃO
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    lin('TOTAL REMUNERAÇÃO',true,Alignment.centerLeft,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(_totalAdulto),true,Alignment.centerRight,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(proTot),true,Alignment.centerRight,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(difTot),true,Alignment.centerRight,cor: Colors.blue.shade800),
                  ],
                ),
              ],
            ),
          ],
    );
  }

  Widget _buildEducInfantilTable() {
    final encargos = _totalInfantil * 0.14;
   // final totalRemuneracao = _totalInfantil + encargos;
    final proposta=_totalInfantil+(_totalInfantil*(double.parse(perAumentoInf)/100));
    final dif=proposta-_totalInfantil;
    ///APTS
    final proAPTS=_atsInfantil+(_atsInfantil*(double.parse(perAumentoInf)/100));
    final difAPTS=proAPTS-_atsAdulto;

    ///ENCARGOS
    final proEncargos=encargos+(encargos*(double.parse(perAumentoInf)/100));
    final difEncargos=proEncargos-encargos;

    ///TOTAL REMUNERAçÃO
    final proTot=_totalInfantil+(_totalInfantil*(double.parse(perAumentoInf)/100));
    final difTot=proTot-_totalInfantil;

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
                    lin('Vantagens',true,Alignment.centerLeft),
                    lin('Atual',true,Alignment.center),
                    lin('Proposta',true,Alignment.center),
                    lin('Variação',true,Alignment.center),
                  ],
                ),
                ///VECTO BÁSICO
                TableRow(
                  children: [
                    lin('Vencimento Básico',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_totalInfantil),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(proposta),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(dif),false,Alignment.centerRight),
                  ],
                ),
                ///ADTS
                TableRow(
                  children: [
                    lin('Adicional Tempo Serviço',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_atsAdulto),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(proAPTS),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(difAPTS),false,Alignment.centerRight),
                  ],
                ),
                ///VANTAGENS
                TableRow(
                  children: [
                    lin('Vantagens Pecuniárias',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(_totalAdulto * 0.1),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(_totalAdulto * 0.1),false,Alignment.centerRight),
                    lin('0,00',false,Alignment.centerRight),

                  ],
                ),
                ///ENCARGOS SOCIAIS (14%)
                TableRow(
                  children: [
                    lin('Encargos Sociais (14%)',false,Alignment.centerLeft),
                    lin(Utils.formatVr.format(encargos),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(proEncargos),false,Alignment.centerRight),
                    lin(Utils.formatVr.format(difEncargos),false,Alignment.centerRight),
                  ],
                ),
                ///TOTAL REMUNERAÇÃO
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    lin('TOTAL REMUNERAÇÃO',true,Alignment.centerLeft,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(_totalInfantil),true,Alignment.centerRight,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(proTot),true,Alignment.centerRight,cor: Colors.blue.shade800),
                    lin(Utils.formatVr.format(difTot),true,Alignment.centerRight,cor: Colors.blue.shade800),
                  ],
                ),
              ],
            ),
          ],
        );
  }

  Widget _buildResumoTable() {
    final totalGeral = _totalAdulto + _totalInfantil;
    final encargos = totalGeral * 0.22;
    final totalComEncargos = totalGeral + encargos;

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
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('CARGO',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('PROPOSTA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('VARIAÇÃO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('PROFESSORES'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Utils.formatVr.format(_totalAdulto),textAlign: TextAlign.end),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-', textAlign: TextAlign.end),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-', textAlign: TextAlign.end),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('EDUCADOR INFANTIL'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Utils.formatVr.format(_totalInfantil),textAlign: TextAlign.end),

                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-', textAlign: TextAlign.end),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-', textAlign: TextAlign.end),
                    ),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('TOTAL GERAL',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Utils.formatVr.format(totalGeral),
                          style: const TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.end),

                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-',
                          style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.end),

                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('-',
                          style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.end),

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




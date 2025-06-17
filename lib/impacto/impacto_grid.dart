import 'package:flutter/material.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';

class ImpactoGrid extends StatefulWidget {
  const ImpactoGrid({Key? key}) : super(key: key);

  @override
  _ImpactoGridState createState() => _ImpactoGridState();
}

class _ImpactoGridState extends State<ImpactoGrid> {
  final List<String> vantagens = [
    'VENCIMENTOS BÁSICO',
    'COMPLEMENTO DO PISO NACIONAL',
    'JORNADA SUPLEMENTAR',
    'ADC POR TEMPO DE SERVIÇO - ATS',
    'ABONO DE PERMANENCIA',
    'FG DIRETOR ESCOLA',
    'ADICIONAL ESPECIAL 5%/10%/25%',
    'FG ORIENTAÇÃO PEDAGÓGICA',
    'DIF ENQUADRAMENTO',
    'ENCARGOS SOCIAIS (14%)',
  ];

  final List<String> _fieldNames = [
    'tot_basico_atual',
    'tot_complementacao_piso',
    'tot_jornada_suplementar',
    'tot_adicional_ats',
    'tot_abono_permanencia',
    'tot_gratificacao_direcao',
    'tot_adicionais_especiais',
    'tot_gratificacao_orientacao',
    'tot_diferenca_enquadramento',
    'tot_encargos_sociais',
  ];

  List<double> proposta = [];
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProposta();
  }

  @override
  void dispose() {
    for (final c in controllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _loadProposta() async {
    final grid = await ApiMySql.getGrid();
    final tot = await ApiMySql.get('professor_total', null,null);

    final Map<String, dynamic> gridData = grid.isNotEmpty ? grid[0] : {};
    final Map<String, dynamic> totData = tot.isNotEmpty ? tot[0] : {};

    controllers = List.generate(_fieldNames.length, (i) {
      final field = _fieldNames[i];
      final raw = totData[field]?.toString() ?? '0';
      final formatted = Utils.formatInitialValue(field, raw, 'dinheiro');
      return TextEditingController(text: formatted);
    });
    /*
    f.controllerName: Utils.formatInitialValue(
            f.controllerName, professor?[f.controllerName]?.toString() ?? '',f.tipo
        ),
     */

    focusNodes = List.generate(_fieldNames.length, (i) {
      final focus = FocusNode();
      focus.addListener(() {
        if (!focus.hasFocus) _onFieldLostFocus(i);
      });
      return focus;
    });

    proposta = [
      double.tryParse(gridData['soma_venc_basico_atual'].toString()) ?? 0,
      double.tryParse(gridData['soma_complementacao_piso'].toString()) ?? 0,
      double.tryParse(gridData['soma_jornada_suplementar'].toString()) ?? 0,
      double.tryParse(gridData['soma_adicional_ats'].toString()) ?? 0,
      double.tryParse(gridData['soma_abono_permanencia'].toString()) ?? 0,
      double.tryParse(gridData['soma_gratificacao_direcao'].toString()) ?? 0,
      double.tryParse(gridData['soma_adicionais_especiais'].toString()) ?? 0,
      double.tryParse(gridData['soma_gratificacao_orientacao'].toString()) ?? 0,
      double.tryParse(gridData['soma_diferenca_enquadramento'].toString()) ?? 0,
      double.tryParse(gridData['soma_encargos_sociais'].toString()) ?? 0,
    ];

    setState(() => isLoading = false);
  }

  void _onFieldLostFocus(int i) {
    final campo = _fieldNames[i];
    final valor = Utils.saldoToSave(controllers[i].text);
    ApiMySql.updateTotalProfessor(campo: campo, valor: valor).catchError((e) {
      Utils.snak('Erro ao salvar', e.toString(), false, Colors.red);
    });
    setState(() {}); // atualiza as variações
  }

  double _parse(String text) {
    return double.tryParse(Utils.saldoToSave(text)) ?? 0;
  }

  String _toCurrency(double v) {
    return Utils.toReal(v);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double totalAtual = 0, totalProp = 0, totalVar = 0;
    for (int i = 0; i < controllers.length; i++) {
      final atual = _parse(controllers[i].text);
      final prop = proposta[i];
      totalAtual += atual;
      totalProp += prop;
      totalVar += (prop - atual);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Texto(tit: 'Professor'),
              Card(
                color: Colors.grey.shade300,
                elevation: 0,
                shape: Utils.borda(),
                child: Row(
                  children: [
                    Line(tex: 'VANTAGENS', tam: 205, alin: Alignment.centerLeft, negrito: true),
                    Line(tex: 'TOTAL – ATUAL', tam: 120, alin: Alignment.centerRight, negrito: true),
                    Line(tex: 'PROPOSTA', tam: 120, alin: Alignment.centerRight, negrito: true),
                    Line(tex: 'VARIAÇÃO', tam: 120, alin: Alignment.centerRight, negrito: true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < vantagens.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Line(tex: vantagens[i], tam: 205, alin: Alignment.centerLeft),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: controllers[i],
                          focusNode: focusNodes[i],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          ),
                        ),
                      ),
                      Line(tex: _toCurrency(proposta[i]), tam: 120, alin: Alignment.centerRight),
                      Line(
                        tex: _toCurrency(proposta[i] - _parse(controllers[i].text)),
                        tam: 120,
                        alin: Alignment.centerRight,
                        cor: (proposta[i] - _parse(controllers[i].text)) >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              const Divider(thickness: 1.5),
              Row(
                children: [
                  Line(tex: 'TOTAL', tam: 205, negrito: true, cor: Colors.black, fontSize: 16),
                  Line(tex: _toCurrency(totalAtual), tam: 120, alin: Alignment.centerRight, negrito: true),
                  Line(tex: _toCurrency(totalProp), tam: 120, alin: Alignment.centerRight, negrito: true),
                  Line(tex: _toCurrency(totalVar), tam: 120, alin: Alignment.centerRight, negrito: true),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


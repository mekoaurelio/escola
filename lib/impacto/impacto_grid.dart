import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
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
  // Linhas fixas de "VANTAGENS":
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

  List<double> proposta = [];
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(vantagens.length, (_) => TextEditingController());
    focusNodes  = List.generate(vantagens.length, (_) => FocusNode());

    for (var i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (!focusNodes[i].hasFocus) {
          _onFieldLostFocus(i);
          setState(() {});
        }
      });
    }
    _loadProposta();
  }

  void _onFieldLostFocus(int index) {
    // já está em R$ 1.234,56 — converte para o formato do banco
    final clean = Utils.saldoToSave(controllers[index].text);
    final campo = _fieldNames[index];
    // dispara o update (sem bloquear a UI)
    ApiMySql.updateTotalProfessor(
      campo: campo,
      valor: clean,
    ).catchError((e) {
      // opcional: exiba um snackbar de erro
      Utils.snak('Erro ao gravar', e.toString(), false, Colors.red);
    });
  }

  final _fieldNames = const [
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

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes)  f.dispose();
    super.dispose();
  }

  Future<void> _loadProposta() async {
    final impacto = await ApiMySql.getGrid();
    final row = impacto[0];

    final respostaAtual = await ApiMySql.get('professor_total',null);
    if (respostaAtual.isNotEmpty) {
      final row = respostaAtual[0];
      // Para cada controlador, joga o valor do DB formatado
      for (var i = 0; i < controllers.length; i++) {
        // mapeie o índice para o nome do campo que veio do seu SELECT:
        final fieldNames = [
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
        final raw = row[fieldNames[i]]?.toString() ?? '0';
        // parse e formata como Real
        final v = double.tryParse(raw) ?? 0;
        controllers[i].text = _toCurrency(v);
      }
    }

    setState(() {
      proposta = [
        double.tryParse(row['soma_venc_basico_atual'].toString()) ?? 0,
        double.tryParse(row['soma_complementacao_piso'].toString()) ?? 0,
        double.tryParse(row['soma_jornada_suplementar'].toString()) ?? 0,
        double.tryParse(row['soma_adicional_ats'].toString()) ?? 0,
        double.tryParse(row['soma_abono_permanencia'].toString()) ?? 0,
        double.tryParse(row['soma_gratificacao_direcao'].toString()) ?? 0,
        double.tryParse(row['soma_adicionais_especiais'].toString()) ?? 0,
        double.tryParse(row['soma_gratificacao_orientacao'].toString()) ?? 0,
        double.tryParse(row['soma_diferenca_enquadramento'].toString()) ?? 0,
        double.tryParse(row['soma_encargos_sociais'].toString()) ?? 0,
      ];
      isLoading = false;
    });
  }

  double _parse(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^\d]'), '').replaceFirst(',', '.')) ?? 0;
  }

  String _toCurrency(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final inteiro = parts[0];
    final frac = parts[1];
    final withSep = inteiro.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.'
    );
    return 'R\$ $withSep,$frac';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// Calcula totais
    double totalAtual = 0, totalProp = 0, totalVar = 0;
    for (var i = 0; i < vantagens.length; i++) {
      final t = _parse(controllers[i].text);
      final p = proposta[i];
      totalAtual += t;
      totalProp  += p;
      totalVar   += (p - t);
    }

    return Scaffold(
      backgroundColor: Colors.white,
    //  appBar: AppBar(title: const Text('Simulador'),backgroundColor: Colors.white,),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Texto(tit:'Professor'),
              /// Cabeçalho
              Card(
                  color: Colors.grey.shade300,
                  elevation: 0,
                  shape: Utils.borda(),
                  child: Row(
                    children: [
                      Line(tex: 'VANTAGENS', tam: 205, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,),
                      Line(tex: 'TOTAL – ATUAL', tam: 120, alin: Alignment.centerRight,cor: Colors.black,negrito: true),
                      Line(tex: 'PROPOSTA',       tam: 120, alin: Alignment.centerRight,cor: Colors.black,negrito: true),
                      Line(tex: 'VARIAÇÃO',       tam: 120, alin: Alignment.centerRight,cor: Colors.black,negrito: true),
                    ],
                  ),
              ),

              const SizedBox(height: 8),

              /// Linhas de dados
              for (var i = 0; i < vantagens.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      /// Vantagem
                      Line(tex: vantagens[i], tam: 205, alin: Alignment.centerLeft),

                      /// Input TOTAL – ATUAL
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: controllers[i],
                          focusNode: focusNodes[i],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                         // inputFormatters: [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')],
                            textAlign:TextAlign.right,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          ),
                        ),
                      ),

                      /// PROPOSTA
                      Line(tex: _toCurrency(proposta[i]), tam: 120, alin: Alignment.centerRight),

                      /// VARIAÇÃO
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
              /// Linha de totais
              Row(
                children: [
                  Line(tex: 'TOTAL', tam: 200, alin: Alignment.centerLeft, negrito: true,cor: Colors.black,fontSize: 16,),
                  Line(tex: _toCurrency(totalAtual), tam: 120, alin: Alignment.centerRight, negrito: true,cor: Colors.black,fontSize: 16),
                  Line(tex: _toCurrency(totalProp),  tam: 120, alin: Alignment.centerRight, negrito: true,cor: Colors.black,fontSize: 16),
                  Line(tex: _toCurrency(totalVar),   tam: 120, alin: Alignment.centerRight, negrito: true,cor: Colors.black,fontSize: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

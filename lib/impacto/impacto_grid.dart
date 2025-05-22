import 'package:flutter/material.dart';

import '../data/api_my_sql.dart';

class ImpactoGrid extends StatefulWidget {
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

  // Simula o valor PROPOSTA vindo do banco:
  final List<double> proposta = [
    803232.25,
    8651.95,
    8651.95,
    108964.47,
    17570.99,
    20708.03,
    23066.81,
    3217.94,
    439.29,
    133111.99,
  ];

  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  start()async{
    String sql = 'SELECT SUM(vencimento_basico_atual) AS soma_venc_basico_atual,';
    sql+='SUM(complementacao_piso) AS soma_complementacao_piso,';
    sql+='SUM(jornada_suplementar) AS soma_jornada_suplementar,';
    sql+='SUM(adicional_ats)       AS soma_adicional_ats,';
    sql+='SUM(abono_permanencia)   AS soma_abono_permanencia,';
    sql+='SUM(gratificacao_direcao)     AS soma_gratificacao_direcao,';
    sql+='SUM(diferenca_enquadramento)  AS soma_diferenca_enquadramento,';
    sql+='SUM(encargos_sociais)         AS soma_encargos_sociais,';
    sql+='SUM(adicional_especial_5';
    sql+='+ adicional_especial_10';
    sql+='+ adicional_especial_25)     AS soma_adicionais_especiais';
    sql+=' FROM professor';

    var impacto=await ApiMySql.getGrid();
   // print('impacto');
    print(impacto);
  }

  @override
  void initState() {
    super.initState();
    controllers = List.generate(vantagens.length, (_) => TextEditingController());
    focusNodes  = List.generate(vantagens.length, (_) => FocusNode());
    // Listener para perda de foco
    for (var node in focusNodes) {
      node.addListener(() {
        if (!node.hasFocus) {
          setState(() {}); // dispara rebuild e recalcula totais
        }
      });
    }
    start();
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes)  f.dispose();
    super.dispose();
  }

  double _parse(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  String _toCurrency(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final inteiro = parts[0];
    final frac = parts[1];
    final withSep = inteiro.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
    return 'R\$ $withSep,$frac';
  }

  @override
  Widget build(BuildContext context) {
    // calculando totais:
    double totalAtual = 0, totalProp = 0, totalVar = 0;
    for (var i = 0; i < vantagens.length; i++) {
      final t = _parse(controllers[i].text);
      final p = proposta[i];
      totalAtual += t;
      totalProp  += p;
      totalVar   += (p - t);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Simulador de Vantagens')),
      body: Center(  // <--- Aqui centralizamos
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingRowColor:
            MaterialStateProperty.resolveWith((_) => Colors.grey.shade200),
            columns: [
              DataColumn(label: Text('VANTAGENS')),
              DataColumn(label: Text('TOTAL – ATUAL')),
              DataColumn(label: Text('PROPOSTA')),
              DataColumn(label: Text('VARIAÇÃO')),
            ],
            rows: [
              // Linhas de dados
              ...List.generate(vantagens.length, (i) {
                final prov = proposta[i];
                final total = _parse(controllers[i].text);
                final variacao = prov - total;
                return DataRow(cells: [
                  DataCell(Text(vantagens[i])),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(_toCurrency(prov))),
                  DataCell(Text(
                    _toCurrency(variacao),
                    style: TextStyle(
                      color: variacao >= 0 ? Colors.green : Colors.red,
                    ),
                  )),
                ]);
              }),
              // Linha de totalização
              DataRow(
                color: MaterialStateProperty.resolveWith((_) => Colors.grey.shade100),
                cells: [
                  DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_toCurrency(totalAtual), style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_toCurrency(totalProp), style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(_toCurrency(totalVar), style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

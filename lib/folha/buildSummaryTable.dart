import 'package:GEM/data/api_my_sql.dart';
import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import '../services/utils.dart';

class SummaryTable extends StatefulWidget {
  final int totalProfissionais;
  final double custoMensal;
  final int meses;
  final double ferias;
  final double remuneracaoTotal;
  final double encargosPercentual;
  final double totalEncargos;
  final double totalComEncargos;

  const SummaryTable({
    Key? key,
    required this.totalProfissionais,
    required this.custoMensal,
    required this.meses,
    required this.ferias,
    required this.remuneracaoTotal,
    required this.encargosPercentual,
    required this.totalEncargos,
    required this.totalComEncargos,
  }) : super(key: key);

  @override
  _SummaryTableState createState() => _SummaryTableState();
}

class _SummaryTableState extends State<SummaryTable> {
  late int _meses;
  late double _ferias;
  late double _encargosPercentual;
  late double _custoMensal;
  late double _remuneracaoTotal;
  late double _totalEncargos;
  late double _totalComEncargos;

  @override
  void initState() {
    super.initState();
    updateValues(widget.meses,widget.ferias,widget.encargosPercentual,widget.custoMensal);
  }
  
  void updateValues(int meses,double ferias,double encargos,double custoMensal){
    _remuneracaoTotal=0;
    _totalEncargos=0;
    _totalComEncargos=0;

    _meses = meses;
    _ferias = ferias;
    _encargosPercentual = encargos; //percentual dos encargos
    _custoMensal =   custoMensal;
    _remuneracaoTotal =  custoMensal*(_meses+1+_ferias);
    _totalEncargos = (_remuneracaoTotal * _encargosPercentual)/100;

    _totalComEncargos = _remuneracaoTotal +_totalEncargos;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),

              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Descrição',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Valor',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Linhas da tabela
            _buildTableRow(
              'Total profissionais',
              widget.totalProfissionais.toString(),
              isTotal: true,
            ),
            _buildTableRow('Custo Mensal', Utils.formatVr.format(_custoMensal)),
            _buildEditableTableRow(
              'Meses',
              _meses.toString(),
              [FilteringTextInputFormatter.digitsOnly],
              onSave: (novoValor) {
                ApiMySql.executaSql('UPDATE $TBTotais set meses=$novoValor');
                updateValues(int.parse(novoValor),_ferias,_encargosPercentual,_custoMensal);
                setState(() {
                  _meses = int.tryParse(novoValor) ?? widget.meses;
                });
              },
            ),
            _buildEditableTableRow(
              '1/3 férias',
              _ferias.toString(),
              [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),],

              onSave: (novoValor) {
                final nv=Utils.saldoToSave(novoValor);
                ApiMySql.executaSql('UPDATE $TBTotais set decimo_ter_ferias=$novoValor');
                setState(() {
                  _ferias = double.tryParse(novoValor) ?? widget.ferias;
                  updateValues(_meses,double.parse(novoValor),_encargosPercentual,_custoMensal);
                });
              },
            ),
            _buildTableRow(
              'Remuneração Total',
              _remuneracaoTotal != 0
                  ? Utils.formatVr.format(_remuneracaoTotal)
                  : Utils.formatVr.format('0.0'),
              isTotal: true,
            ),

            _buildEditableTableRow(
              'Encargos Sociais',
              _encargosPercentual.toString(),
              [CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')],
              onSave: (novoValor) {
                final nv=Utils.saldoToSave(novoValor);
                updateValues(_meses,_ferias,double.parse(nv),_custoMensal);
                ApiMySql.executaSql('UPDATE $TBTotais set encargos_sociais=$nv');
                setState(() {
                  _encargosPercentual = double.tryParse(nv) ?? _custoMensal;
                });
              },
            ),


            _buildTableRow(
              'Total Encargos',
              Utils.formatVr.format(_totalEncargos),
              isTotal: true,
            ),
            _buildTableRow(
              'Total COM ENCARGOS',
              Utils.formatVr.format(_totalComEncargos),
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Material(
        color: isHighlighted ? Colors.blue.shade50 : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      color:
                          isHighlighted ? Colors.blue.shade800 : Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight:
                        isTotal || isHighlighted
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color: isHighlighted ? Colors.blue.shade800 : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTableRow(
    String label,
    String value,
    dynamic inputFormatters, {
    required Function(String) onSave,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Utils.mostrarDialogoEditarValor(
              context: context,
              titulo: 'Editar $label',
              labelCampo: label,
              valorInicial: value,
              aoSalvar: onSave,
              inputFormatters: inputFormatters,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(value, style: TextStyle(color: Colors.black)),
                        SizedBox(width: 8),
                        Icon(Icons.edit, size: 16, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

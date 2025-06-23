import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/utils.dart';
import '../widgets/texto.dart';
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

  @override
  void initState() {
    super.initState();
    _meses = widget.meses;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
        _buildTableRow('Total profissionais', widget.totalProfissionais.toString(),isTotal: true),
        _buildTableRow('Custo Mensal', Utils.formatVr.format(widget.custoMensal)),
        _buildEditableTableRow(
          'Meses',
          _meses.toString(),
          onSave: (novoValor) {
            setState(() {
              _meses = int.tryParse(novoValor) ?? widget.meses;
            });
            // Adicione aqui qualquer cálculo que precise ser atualizado
          },
        ),
        _buildTableRow('1/3 férias', widget.ferias.toStringAsFixed(6)),
        _buildTableRow('Remuneração Total', Utils.formatVr.format(widget.remuneracaoTotal), isTotal: true),
        _buildTableRow('Encargos Sociais', '${widget.encargosPercentual.toStringAsFixed(0)}%'),
        _buildTableRow('TOTAL Encargos', Utils.formatVr.format(widget.totalEncargos), isTotal: true),
        _buildTableRow('Total COM ENCARGOS', Utils.formatVr.format(widget.totalComEncargos), isHighlighted: true),
        ],
      ),
    ),
    );
  }

  Widget _buildTableRow(String label, String value, {bool isTotal = false, bool isHighlighted = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
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
                      color: isHighlighted ? Colors.blue.shade800 : Colors.black,
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
                    fontWeight: isTotal || isHighlighted ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildEditableTableRow(String label, String value, {required Function(String) onSave}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                        Text(
                          value,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
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
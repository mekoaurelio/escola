import 'package:flutter/material.dart';
import 'package:psycostatattoo/folha/professor_utils.dart';

import '../services/utils.dart';
import '../widgets/texto.dart';

class TabelaSalarial extends StatefulWidget {
  final Color primaryColor;
  final Color textColor;
  final Color borderColor;
  final int cargaHoraria;
  final List<String> niveis;
  final List<List<double>> calculatedTableValues;
  final Function(String, int) quantidadeDeProfessores;
  final Function(int, int) onCellSelected;

  const TabelaSalarial({
    Key? key,
    required this.primaryColor,
    required this.textColor,
    required this.borderColor,
    required this.cargaHoraria,
    required this.niveis,
    required this.calculatedTableValues,
    required this.quantidadeDeProfessores,
    required this.onCellSelected,
  }) : super(key: key);

  @override
  _TabelaSalarialState createState() => _TabelaSalarialState();
}

class _TabelaSalarialState extends State<TabelaSalarial> {
  int? selectedRow;
  int? selectedColumn;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Texto(tit: 'Tabela Salarial',cor:widget.textColor ,tam: 18,negrito: true,bottom: 4,),
            Texto(tit: 'Valores calculados para cada nível e classe',cor:widget.textColor.withOpacity(0.6),tam: 14,bottom: 16,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: ProfessorUtils().nivelClasse(widget.cargaHoraria,widget.primaryColor,false,90),
                  ),
                  // Rows
                  for (int nivelIndex = 0; nivelIndex < widget.niveis.length; nivelIndex++)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: widget.borderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                            children: [
                              Container(
                                width: 80,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.niveis[nivelIndex],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: nivelIndex == 0 ? Colors.blue : widget.textColor,
                                  ),
                                ),
                              ),
                              for (int coluna = 0; coluna < widget.calculatedTableValues[nivelIndex].length; coluna++)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedRow = nivelIndex;
                                      selectedColumn = coluna;
                                    });
                                    widget.onCellSelected(nivelIndex, coluna);
                                  },
                                  child: Container(
                                    width: 90,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    color: selectedRow == nivelIndex && selectedColumn == coluna
                                        ? Colors.blue.withOpacity(0.2)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            Utils.formatVr.format(widget.calculatedTableValues[nivelIndex][coluna]),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: coluna == 0 ? 16 : 13,
                                              color: coluna == 0 ? Colors.blue : widget.textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '(${widget.quantidadeDeProfessores(widget.niveis[nivelIndex], coluna + 1)})',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
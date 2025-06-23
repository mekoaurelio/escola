import 'package:flutter/material.dart';

class ProfessorDistributionTable extends StatefulWidget {
  final Color primaryColor;
  final Color textColor;
  final Color borderColor;
  final int cargaHoraria;
  final List<String> niveis;
  final List<List<double>> calculatedTableValues;
  final Function(String, int) quantidadeDeProfessores;
  final Function(int, int) onCellSelected;

  const ProfessorDistributionTable({
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
  _ProfessorDistributionTableState createState() => _ProfessorDistributionTableState();
}

class _ProfessorDistributionTableState extends State<ProfessorDistributionTable> {
  int? selectedRow;
  int? selectedColumn;
  bool _isHovered = false;

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
            Text(
              'Distribuição de Professores',
              style: TextStyle(
                color: widget.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Quantidade de professores por nível e classe',
              style: TextStyle(
                color: widget.textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: Text(
                            'Nível',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.primaryColor,
                            ),
                          ),
                        ),
                        for (int i = 1; i <= widget.cargaHoraria; i++)
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              'Classe $i',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Rows
                  for (int nivelIndex = 1; nivelIndex < widget.niveis.length; nivelIndex++)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: widget.borderColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: Material(
                          color: _isHovered
                              ? widget.primaryColor.withOpacity(0.05)
                              : Colors.transparent,
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
                                    color: widget.textColor,
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
                                    width: 80,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    child: Text(
                                      widget.quantidadeDeProfessores(widget.niveis[nivelIndex], coluna + 1) == 0
                                          ? '-'
                                          : widget.quantidadeDeProfessores(widget.niveis[nivelIndex], coluna + 1).toString(),
                                      style: TextStyle(
                                        color: widget.textColor,
                                        fontWeight: selectedRow == nivelIndex && selectedColumn == coluna
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
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
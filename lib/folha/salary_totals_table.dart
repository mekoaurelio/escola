import 'package:flutter/material.dart';

import '../services/utils.dart';
import '../widgets/texto.dart';
import 'professor_utils.dart';

class SalaryTotalsTable extends StatelessWidget {
  final Color primaryColor;
  final Color textColor;
  final String tipo;
  final int cargaHoraria;
  final List<String> niveis;
  final List<List<double>> calculatedTableValues;
  final Function(String, int) quantidadeDeProfessores;
  final List<dynamic> professores;

  const SalaryTotalsTable({
    Key? key,
    required this.primaryColor,
    required this.textColor,
    required this.tipo,
    required this.cargaHoraria,
    required this.niveis,
    required this.calculatedTableValues,
    required this.quantidadeDeProfessores,
    required this.professores,
  }) : super(key: key);

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
              'Totais de Vencimentos',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Somatório de vencimentos por nível e classe',
              style: TextStyle(
                color: textColor.withOpacity(0.6),
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
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: ProfessorUtils().nivelClasse(cargaHoraria,primaryColor,true,100)
                  ),
                  // Rows
                  for (int nivelIndex = 0; nivelIndex < niveis.length; nivelIndex++)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
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
                            child: Texto(tit: niveis[nivelIndex],negrito: true,cor:textColor ,),
                          ),
                          for (int coluna = 0; coluna < calculatedTableValues[nivelIndex].length; coluna++)
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (quantidadeDeProfessores(niveis[nivelIndex], coluna + 1) != 0)
                                    Texto(
                                      tit: '${quantidadeDeProfessores(niveis[nivelIndex], coluna + 1)} Profs.', tam: 11, cor: textColor.withOpacity(0.8),),

                                  if (quantidadeDeProfessores(niveis[nivelIndex], coluna + 1) != 0)
                                    FutureBuilder<double>(
                                      future: ProfessorUtils.totalDeVencimentosProposta(
                                          niveis[nivelIndex],
                                          coluna + 1,
                                          professores,
                                          tipo
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Texto(tit: 'Calculando...', tam: 11, cor: primaryColor);
                                        }
                                        if (snapshot.hasError) {
                                          return Texto(tit: 'Erro', tam: 11, cor: Colors.red);
                                        }
                                        return Texto(
                                          tit: Utils.formatVr.format(snapshot.data ?? 0.0), tam: 11, negrito: true, cor: primaryColor,);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          /// total geral por nível
                          Container(
                            width: 120,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Texto(tit: 'Total',tam: 11,cor:textColor.withOpacity(0.8)),
                                FutureBuilder<double>(
                                  future: ProfessorUtils.calculateTotalForLevel(niveis[nivelIndex], professores, cargaHoraria,tipo),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Texto(tit: 'Calculando...', tam: 11, cor: primaryColor);
                                    }
                                    if (snapshot.hasError) {
                                      return Texto(tit: 'Erro', tam: 11, cor: Colors.red);
                                    }
                                    return Texto(
                                      tit: Utils.formatVr.format(snapshot.data ?? 0.0), tam: 11, negrito: true, cor: primaryColor,);
                                  },
                                )

                              ],
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
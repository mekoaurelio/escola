/*
import 'package:flutter/material.dart';

import '../const/const.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';
import 'professor_utils.dart';

class SalaryTotalsTable extends StatefulWidget {
  final Color primaryColor;
  final Color textColor;
  final String tipo;
  final int cargaHoraria;
  final List<String> novosNiveis;
  final List<List<double>> calculatedTableValues;
  final Function(String, int) quantidadeDeProfessores;
  final List<dynamic> professores;
  final double percAumento;

  const SalaryTotalsTable({
    Key? key,
    required this.primaryColor,
    required this.textColor,
    required this.tipo,
    required this.cargaHoraria,
    required this.calculatedTableValues,
    required this.quantidadeDeProfessores,
    required this.professores,
    required this.novosNiveis,
    required this.percAumento,
  }) : super(key: key);

  @override
  _SalaryTotalsTable createState() => _SalaryTotalsTable();
}

class _SalaryTotalsTable extends State<SalaryTotalsTable> {
  final ScrollController _horizontalController = ScrollController();

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
                  for (int nivelIndex = 0; nivelIndex < novosNiveis.length; nivelIndex++)
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
                          //DESCRIÇÃO DO NIVEL
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Texto(tit: novosNiveis[nivelIndex].toString(),negrito: true,cor:textColor ,),
                          ),
                          //LISTA DE TODOS OS NIVEIS
                          for (int coluna = 0; coluna < calculatedTableValues[nivelIndex].length; coluna++)
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (quantidadeDeProfessores(novosNiveis[nivelIndex].toString(), coluna + 1) != 0)
                                    Texto(tit: '${quantidadeDeProfessores(novosNiveis[nivelIndex].toString(), coluna + 1)} Profs.', tam: 11, cor: textColor.withOpacity(0.8),),

                                  if (quantidadeDeProfessores(novosNiveis[nivelIndex].toString(), coluna + 1) != 0)
                                    FutureBuilder<double>(
                                      future: ProfessorUtils.totalDeVencimentosProposta(
                                        novosNiveis[nivelIndex].toString(), coluna + 1, professores,calculatedTableValues),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Texto(tit: 'Calculando...', tam: 11, cor: primaryColor);
                                        }
                                        if (snapshot.hasError) {
                                          return Texto(tit: 'Erro', tam: 11, cor: Colors.red);
                                        }
                                        return Texto(
                                          tit: Utils.formatVr.format(snapshot.data ?? 0.0)+' ', tam: 11, negrito: true, cor: primaryColor,);
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
                                  future: ProfessorUtils.calculateTotalForLevel(novosNiveis[nivelIndex].toString(), professores, cargaHoraria,percAumento),
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

 */

import 'package:flutter/material.dart';

import '../const/const.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';
import 'professor_utils.dart';

class SalaryTotalsTable extends StatefulWidget {
  final Color primaryColor;
  final Color textColor;
  final String tipo;
  final int cargaHoraria;
  final List<String> novosNiveis;
  final List<List<double>> calculatedTableValues;
  final Function(String, int) quantidadeDeProfessores;
  final List<dynamic> professores;
  final double percAumento;

  const SalaryTotalsTable({
    Key? key,
    required this.primaryColor,
    required this.textColor,
    required this.tipo,
    required this.cargaHoraria,
    required this.calculatedTableValues,
    required this.quantidadeDeProfessores,
    required this.professores,
    required this.novosNiveis,
    required this.percAumento,
  }) : super(key: key);

  @override
  _SalaryTotalsTableState createState() => _SalaryTotalsTableState();
}

class _SalaryTotalsTableState extends State<SalaryTotalsTable> {
  final ScrollController _horizontalController = ScrollController();

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
                color: widget.textColor, // CORREÇÃO: widget.textColor
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Somatório de vencimentos por nível e classe',
              style: TextStyle(
                color: widget.textColor.withOpacity(0.6), // CORREÇÃO
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
        Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
           child:  SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalController, // CORREÇÃO: usando o controller
              child: Column(
                children: [
                  // TITULO DAS COLUNAS
                  // nível, classe1, classe2, classe3, classe4, total
                  Container(
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withOpacity(0.1), // CORREÇÃO
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: ProfessorUtils().nivelClasse(
                          widget.cargaHoraria, // CORREÇÃO
                          widget.primaryColor, // CORREÇÃO
                          true,
                          100
                      )
                  ),



                  // Rows
                  for (int nivelIndex = 0; nivelIndex < widget.novosNiveis.length; nivelIndex++) // CORREÇÃO
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
                          // DESCRIÇÃO DO NIVEL
                          // A,B,, na vertical
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: Texto(
                              tit: widget.novosNiveis[nivelIndex].toString(), // CORREÇÃO
                              negrito: true,
                              cor: widget.textColor, // CORREÇÃO
                            ),
                          ),
                          // LISTA DE TODOS OS NIVEIS
                          for (int coluna = 0; coluna < widget.calculatedTableValues[nivelIndex].length; coluna++) // CORREÇÃO
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  if (widget.quantidadeDeProfessores(widget.novosNiveis[nivelIndex].toString(), coluna + 1) != 0) // CORREÇÃO
                                    Texto(
                                      tit: '${widget.quantidadeDeProfessores(widget.novosNiveis[nivelIndex].toString(), coluna + 1)} Profs.', // CORREÇÃO
                                      tam: 11,
                                      cor: widget.textColor.withOpacity(0.8), // CORREÇÃO
                                    ),

                                  if (widget.quantidadeDeProfessores(widget.novosNiveis[nivelIndex].toString(), coluna + 1) != 0) // CORREÇÃO
                                    FutureBuilder<double>(
                                      future: ProfessorUtils.totalDeVencimentosProposta(
                                          widget.novosNiveis[nivelIndex].toString(), // CORREÇÃO
                                          coluna + 1,
                                          widget.professores, // CORREÇÃO
                                          widget.calculatedTableValues // CORREÇÃO
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Texto(
                                              tit: 'Calculando...',
                                              tam: 11,
                                              cor: widget.primaryColor // CORREÇÃO
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return Texto(tit: 'Erro', tam: 11, cor: Colors.red);
                                        }
                                        return Texto(
                                          tit: Utils.formatVr.format(snapshot.data ?? 0.0)+' ',
                                          tam: 11,
                                          negrito: true,
                                          cor: widget.primaryColor, // CORREÇÃO
                                        );
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
                                Texto(
                                    tit: 'Total',
                                    tam: 11,
                                    cor: widget.textColor.withOpacity(0.8) // CORREÇÃO
                                ),
                                FutureBuilder<double>(
                                  future: ProfessorUtils.calculateTotalForLevel(
                                      widget.novosNiveis[nivelIndex].toString(), // CORREÇÃO
                                      widget.professores, // CORREÇÃO
                                      widget.cargaHoraria, // CORREÇÃO
                                      widget.percAumento // CORREÇÃO
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Texto(
                                          tit: 'Calculando...',
                                          tam: 11,
                                          cor: widget.primaryColor // CORREÇÃO
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Texto(tit: 'Erro', tam: 11, cor: Colors.red);
                                    }
                                    return Texto(
                                      tit: Utils.formatVr.format(snapshot.data ?? 0.0),
                                      tam: 11,
                                      negrito: true,
                                      cor: widget.primaryColor, // CORREÇÃO
                                    );
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
        )
          ],
        ),
      ),
    );
  }
}

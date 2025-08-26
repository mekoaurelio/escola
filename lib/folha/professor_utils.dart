import 'package:flutter/material.dart';

import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../widgets/texto.dart';

class ProfessorUtils {

  static Map<String, int> _professoresPorNivel = {};

 static  int quantidadeDeProfessores(String nivel, int coluna) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';
    return _professoresPorNivel[chave] ?? 0;
  }

  static double totalDeVencimentos(String nivel, int coluna, var professores) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    double total = 0.0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        total += double.tryParse(professor['vencimento'].toString()) ?? 0.0;
      }
    }

    return total;
  }


  static Future<double> totalDeVencimentosProposta(String nivel, int coluna, var professores) async {
    try {
      final totais = await ApiMySql.get(TBTotais, null, null);
      double perAumentoInfantil = double.tryParse(totais[0]['perc_aumento_infantil'].toString()) ?? 0.0;

     // String nivelFormatado = nivel.substring(1);
      String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
      String chave = '$nivel$colunaFormatada';

      double total = 0.0;

      for (var professor in professores) {
        if (professor['nivel'] == chave && professor['vencimento'] != null) {
          double vencimento = double.tryParse(professor['vencimento'].toString()) ?? 0.0;
          total += vencimento;
        }
      }
      // Aplica o aumento percentual
      total += total * perAumentoInfantil / 100;

      return total;
    } catch (e) {
      print('Erro em totalDeVencimentosProposta: $e');
      return 0.0;
    }
  }
  static int totalDeProfissionais(String nivel, int coluna, var professores) {
    // Formata o nível/classe no formato esperado (ex: "B01" para NB coluna 1)
    String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    int total = 0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        total++;
      }
    }

    return total;
  }

  // Método auxiliar para calcular o total por nível
  static Future<double> calculateTotalForLevel(String nivel, var professores, int cargaHoraria) async {
    try {
      // Cache dos totais (busca apenas uma vez)
      final totais = await ApiMySql.get(TBTotais, null, null);
      double perAumentoInfantil = double.parse(totais[0]['perc_aumento_infantil']);

      double total = 0.0;

      for (int coluna = 0; coluna < cargaHoraria; coluna++) {
        String colunaFormatada = (coluna + 1) < 10 ? '0${coluna + 1}' : '${coluna + 1}';
        String chave = '$nivel$colunaFormatada';

        for (var professor in professores) {
          if (professor['nivel'] == chave && professor['vencimento'] != null) {
            double vencimento = double.tryParse(professor['vencimento'].toString()) ?? 0.0;
            double aumento =perAumentoInfantil;
            total += vencimento * (1 + aumento / 100);
          }
        }
       // print('TOTAL $total');
      }

      return total;
    } catch (e) {
      print('Erro em calculateTotalForLevel: $e');
      return 0.0;
    }
  }


  static double calculateNroProfissionalForLevel(String nivel,var professores,int cargaHoraria) {
    double total = 0.0;
    for (int coluna = 0; coluna < cargaHoraria; coluna++) {
      total += ProfessorUtils.totalDeProfissionais(nivel, coluna + 1,professores);
    }
    return total;
  }

  Widget nivelClasse(int cargaHoraria,Color primaryColor,bool temTotal,double tamContainer){
   return Row(
     mainAxisAlignment: MainAxisAlignment.start,
     children: [
       Container(
         width: 80,
         padding: EdgeInsets.symmetric(vertical: 12),
         alignment: Alignment.center,
         child: Texto(tit:'Nível',negrito: true,cor:Colors.blue,
         ),
       ),
       for (int i = 1; i <= cargaHoraria; i++)
         Container(
           width: tamContainer,
           padding: EdgeInsets.symmetric(vertical: 12),
           alignment: Alignment.center,
           child: Texto(tit: 'Classe $i',negrito: true,cor:primaryColor),
         ),
       if(temTotal)
       Container(
         width: 120,
         padding: EdgeInsets.symmetric(vertical: 12),
         alignment: Alignment.center,
         child: Texto(tit:'Total Nível',negrito: true,cor:primaryColor),
       ),
     ],
   );
  }
}

import 'package:flutter/material.dart';
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

   String nivelFormatado = nivel.substring(1); // Remove o "N" do início
    String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
    String chave = '$nivelFormatado$colunaFormatada';

    double total = 0.0;

    for (var professor in professores) {
      if (professor['nivel'] == chave && professor['vencimento'] != null) {
        double sal=double.tryParse(professor['vencimento'].toString()) ?? 0.0;
        String tmp=sal.toStringAsFixed(2);
        sal=double.parse(tmp);
        total += sal;
      }
    }

    return total;
  }

  static Future<double> totalDeVencimentosPropostaNova(String n, int coluna, var professores,
      List<List<double>> calculatedTableValues) async {
   try {

     String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
      String chave = '$n$colunaFormatada';
      chave=chave.replaceAll('NIVEL', '').trim();
      double total = 0.0;
      for (var professor in professores) {
       if (professor.nivel == chave && professor.vencimento != 0) {
         double sal=obterValorPorNivel(calculatedTableValues, chave);
         String tmp=sal.toStringAsFixed(2);
         sal=double.parse(tmp);
         total += sal;
       }
     }
      return total;
    } catch (e) {
      print('Erro em totalDeVencimentosProposta: $e');
      return 0.0;
    }
  }

  static Future<double> totalDeVencimentosProposta(String n, int coluna, var professores,
      List<List<double>> calculatedTableValues) async {
    try {
      String colunaFormatada = coluna < 10 ? '0$coluna' : '$coluna';
      String chave = '$n$colunaFormatada';
      chave=chave.replaceAll('NIVEL', '').trim();
      double total = 0.0;

      for (var professor in professores) {
        if (professor['nivel'] == chave && professor['vencimento'] != null) {
          double sal=obterValorPorNivel(calculatedTableValues, chave);
          String tmp=sal.toStringAsFixed(2);
          sal=double.parse(tmp);
          total += sal;
        }
      }

      return total;
    } catch (e) {
      print('Erro em totalDeVencimentosProposta: $e');
      return 0.0;
    }
  }

  static double obterValorPorNivel(List<List<double>> matrizString, String nivel) {
    try {
      // Mapear as letras para índices da matriz
      Map<String, int> mapeamentoLetras = {
        'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5, 'G': 6, 'H': 7, 'I': 8, 'J': 9,
        'K': 10, 'L': 11, 'M': 12, 'N': 13, 'O': 14, 'P': 15, 'Q': 16, 'R': 17, 'S': 18, 'T': 19,
        'U': 20, 'V': 21, 'W': 22, 'X': 23, 'Y': 24, 'Z': 25
      };

      // Extrair a letra e o número do nível
      String letra = nivel.substring(0, 1).toUpperCase();
      String numeroStr = nivel.substring(1);
      // Converter o número para índice (subtraindo 1 porque arrays começam em 0)
      int indiceColuna = int.parse(numeroStr) - 1;

      // Obter o índice da linha baseado na letra
      int indiceLinha = mapeamentoLetras[letra] ?? 0;
      //indiceLinha--;

      // Verificar se os índices são válidos
      if (indiceLinha >= matrizString.length || indiceColuna >= matrizString[indiceLinha].length) {
        throw Exception('Nível "$nivel" fora dos limites da matriz');
      }

      // Retornar o valor correspondente
      dynamic valor = matrizString[indiceLinha][indiceColuna];
      return double.parse(valor.toString());
    } catch (e) {
      print('Erro ao obter valor para nível "$nivel": $e');
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
  static Future<double> calculateTotalForLevel(String nivel, var professores, int cargaHoraria,double perProgressaoEntreClasse ) async {
    try {
      double total = 0.0;

      for (int coluna = 0; coluna < cargaHoraria; coluna++) {
        String colunaFormatada = (coluna + 1) < 10 ? '0${coluna + 1}' : '${coluna + 1}';
        String chave = '$nivel$colunaFormatada';

        for (var professor in professores) {
          if (professor['nivel'] == chave && professor['vencimento'] != null) {
            double vencimento = double.tryParse(professor['vencimento'].toString()) ?? 0.0;
            double aumento =perProgressaoEntreClasse;
            total += vencimento * (1 + aumento / 100);
          }
        }
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
       //monta o cabeçalho baseado na carga horária
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
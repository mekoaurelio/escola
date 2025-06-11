import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import '../widgets/texto.dart';

class Utils {

  static final formKeyListNotificacaoDetalhe = GlobalKey<FormState>();
  static final maskPerc = MaskTextInputFormatter(mask: '###', filter: { "#": RegExp(r'[0-9]') });
  static final doisDigitos = MaskTextInputFormatter(mask: '##', filter: { "#": RegExp(r'[0-9]') });
  static final tresDigitos = MaskTextInputFormatter(mask: '#.##', filter: { "#": RegExp(r'[0-9]') });
  static final maskDt = MaskTextInputFormatter(mask: '##/##/####', filter: { "#": RegExp(r'[0-9]') });
  static final maskFn2 = MaskTextInputFormatter(mask: '##-#-####-####', filter: { "#": RegExp(r'[0-9]') });
  static final maskFoneFixo = MaskTextInputFormatter(mask: '##-####-####', filter: { "#": RegExp(r'[0-9]') });
  static final formatVr = NumberFormat("#,##0.00", "pt_BR");
  static var formatterD =  DateFormat('dd/MM/yyyy');
  static var formatterh =  DateFormat('hh:mm');

  static double somaVantagens(var partes){
    String valorStr='0';
    for (final parte in partes) {
      print(partes);
      final detalhesVantagem = parte.split(':');
      if (detalhesVantagem.length > 3 && detalhesVantagem[0]!='21003' ) {
        print(detalhesVantagem[3]);
         valorStr = detalhesVantagem[3]
            .replaceAll('R/\$', '')
            .replaceAll('-', '')
            .replaceAll(',', '')
            .trim();
        return double.parse(valorStr);

      }
    }
    return 0;
  }
  static double getVencimento(var partes){
    if (partes.isNotEmpty) {
      // 1. Cálculo do vencimento base
      String vencimentoStr = partes[0];
      int pos = vencimentoStr.indexOf('\$');
      if (pos != -1) {
        vencimentoStr = vencimentoStr.substring(pos + 1).replaceAll(',', '#');
        vencimentoStr = vencimentoStr.replaceAll('.', ',');
        vencimentoStr = vencimentoStr.replaceAll('#', '');
        vencimentoStr = vencimentoStr.replaceAll(',', '.');
        return double.parse(vencimentoStr);
      }
      return 0;
    }
    return 0;
  }
  static double getValueFromMatrix({
    required List<double> baseValues,
    required double progressionRate,
    required String code,
    int numberOfColumns = 6, // Parâmetro novo com valor padrão 6
    bool roundValues = true, // Opcional: controla se valores são arredondados
  }) {
    // Validação dos parâmetros
    if (baseValues.length != 6) {
      throw ArgumentError("baseValues deve conter exatamente 6 valores");
    }
    if (numberOfColumns < 1) {
      throw ArgumentError("numberOfColumns deve ser pelo menos 1");
    }

    // Extrai a linha e coluna do código
    final rowPattern = RegExp(r'^([A-Z]{2})(\d+)$');
    final match = rowPattern.firstMatch(code);

    if (match == null) {
      return 0;
    }

    final rowCode = match.group(1)!;
    final column = int.parse(match.group(2)!);

        // Valida a coluna solicitada
        if (column < 1 || column > numberOfColumns) {
      throw ArgumentError("Coluna $column fora do intervalo (1-$numberOfColumns)");
    }

    // Nomes das linhas fixos conforme a tabela original
    const rowNames = ["BASE", "NA", "NB", "NC", "ND", "NE"];

    // Cria a matriz dinamicamente
    final matrix = <String, List<double>>{};

    for (int i = 0; i < baseValues.length; i++) {
      final rowName = rowNames[i];
      final initialValue = baseValues[i];
      final rowValues = [initialValue];

      // Preenche as colunas adicionais
      for (int j = 1; j < numberOfColumns; j++) {
        double nextValue = rowValues.last * (1 + progressionRate / 100);
        if (roundValues) {
          nextValue = double.parse(nextValue.toStringAsFixed(2));
        }
        rowValues.add(nextValue);
      }

      matrix[rowName] = rowValues;
    }

    // Retorna o valor solicitado
    if (matrix.containsKey(rowCode)) {
      return matrix[rowCode]![column - 1]; // Ajuste de índice 0-based
    } else {
      throw ArgumentError("Código de linha '$rowCode' não encontrado");
    }
  }

  static String getNivel(String input) {
    if (input.isEmpty) return input; // Retorna vazio se a string for vazia

    // Pega o primeiro caractere
    String firstChar = input[0];

    // Pega os caracteres restantes e converte para inteiro
    String remainingChars = input.substring(1);
    int number = int.tryParse(remainingChars) ?? 0; // Usa 0 como fallback se não for número

    // Retorna a combinação do primeiro caractere com o número
    return '$firstChar$number';
  }

  static String formatInitialValue(String key, String rawValue,String tipo) {
    if (tipo == 'data' && rawValue.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawValue);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        return rawValue; // se não parsear, devolve original
      }
    }else
    if(tipo=='dinheiro'){
      try {
        final vr = Utils.vrBco(rawValue);
        return vr;
      } catch (_) {
        return rawValue; // se não parsear, devolve original
      }
    }else
      return rawValue;
  }

  static  borda(){
    return  const Border(
      bottom: BorderSide(
        color: Colors.white70  , // Cor da borda
        width: 0.2, // Espessura da borda
      ),
    );
  }

  static vrStringToDouble(String valorInformado)async{
    String vrInformado=await saldoToSave(valorInformado);
    vrInformado=vrInformado.replaceAll('.', '');
    return double.parse(vrInformado);
  }

  static String saldoToSave(String tex) {
    String sl=tex;
    if(tex.contains('%')) {
      sl = tex.replaceAll('%','');
      sl =sl.trim();
    }
    if(tex.contains('\$')) {
      sl = tex.substring(3, tex.length);
    }
    sl=sl.replaceAll('.', '');
    sl=sl.replaceAll(',', '.');
    return sl;
  }

  static getIdEntidade(){
    return html.window.localStorage['idEntidade'];
  }

  static void setIdEntidade(var idEntidade) {
    html.window.localStorage['idEntidade'] = idEntidade;
  }

  static getIdProfessor(){
    return html.window.localStorage['idEntidade'];
  }

  static void setIdProfessor(var idEntidade) {
    html.window.localStorage['idEntidade'] = idEntidade;
  }

  ///USUÄRIO
  static void setIdUser(var idClinica) {
    html.window.localStorage['idUser'] = idClinica;
  }

  static getIdUser(){
    return html.window.localStorage['idUser'];
  }

  static void setUserName(var UserName) {
    html.window.localStorage['UserName'] = UserName;
  }

  static getUserName(){
    return html.window.localStorage['UserName'];
  }

  static Widget semDados(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/indisponivel.png", width: 150, height: 150, fit: BoxFit.cover,),
          Texto(tit: 'Nenhum dado disponível', cor: Colors.grey, tam: 18,top: 10,),
        ],
      ),
    );
  }

  static String randomNumber(){
    String verificador ='';
    var _random = Random.secure();
    var random = List<int>.generate(22, (i) => _random.nextInt(256));
    verificador = base64Url.encode(random);
    verificador=verificador.substring(0,6);
    verificador=verificador.toUpperCase();
    return verificador;
  }

  ///DATAS ****************************
  static DateTime parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) throw const FormatException('Formato inválido');

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      throw FormatException('Data inválida: $dateStr');
    }
  }

  static int calculateYearsDifference(DateTime fromDate) {
    final now = DateTime.now();
    int years = now.year - fromDate.year;

    // Ajuste se ainda não chegou o aniversário este ano
    if (now.month < fromDate.month ||
        (now.month == fromDate.month && now.day < fromDate.day)) {
      years--;
    }

    return years;
  }


  static dtToMysql(var dateString){
    if(dateString!='') {
      DateFormat dateFormat = DateFormat("dd/MM/yyyy");
      DateTime dateTime = dateFormat.parse(dateString);

      var formatterD = DateFormat('yyyy-MM-dd');
      var formatterH = DateFormat('HH:mm');

      String dt = formatterD.format(dateTime);
      String hr = formatterH.format(dateTime);

      return '$dt $hr';
    }else{
      return '';
    }
  }

  static String dtMySql(String dt,String mask){
    print('$dt $mask');
    var formatterD = DateFormat(mask);
    DateTime xdt=DateTime.parse(dt);
    String dtV = formatterD.format(xdt);
    print('VOLTA $dtV');
    return dtV;
  }

  static String hrMySql(String dt){
    var formatterD = DateFormat('HH:mm');
    DateTime xdt=DateTime.parse(dt);
    String dtV = formatterD.format(xdt);
    return dtV;
  }

  static PopupMenuEntry<String> options(String value,String title){
    return  PopupMenuItem<String>(
      value: value,
      child: Texto(tit:title, cor: Colors.black54),
    );
  }

  static logo(String path){
    return Container(
      width: 312,
      height: 162.5,
      decoration: BoxDecoration(
        image:  DecorationImage(
          image: AssetImage(path),
          // fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        color: Color(0xFFEFE7DE),
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget line(var tex, double tam, [Alignment? alignment]) {
    return Container(
      width: tam,
      alignment: alignment ?? Alignment.center,
      child: Texto(
        tit: tex,
        cor: Colors.black,
        tam: 12,
        top: 10,
        bottom: 10,
      ),
    );
  }

  static vrBco(var vr){
    double xVr=double.parse(vr);
    return toReal(xVr);
  }

  static toReal(double vr){
    return 'R\$ '+Utils.formatVr.format(vr).toString();
  }

  static showDlg(String titulo,String frase,BuildContext context,var positivo,var negativo) async{
    bool volta=false;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.green,
              width: 0.0,
            ),
          ),

          title: Center(child: Texto(tit:titulo,tam: 17,negrito: true,cor:Colors.blue,linhas: 2,)),
          content:  Column(
              mainAxisSize: MainAxisSize.min,
              children:  <Widget>[
                Text(frase,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red,),
                ),
              ]
          ),
          actions: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  OutlinedButton(
                    style: OutlinedButtonStlo(false,6,Colors.white),
                    child: Texto(tit:negativo,negrito: true,tam: 17,cor:Colors.red),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      volta=false;
                    },
                  ),
                  OutlinedButton(
                    style: OutlinedButtonStlo(false,6,Colors.white),
                    child: Texto(tit:positivo,negrito: true,tam: 17,cor:Colors.blue),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      volta=true;
                    },
                  ),
                ]
            ),
          ],
        ));
    return volta;
  }

  static ButtonStyle OutlinedButtonStlo(bool mostraCircular, double elevacao,Color cor){
    return OutlinedButton.styleFrom(
        padding: mostraCircular?const EdgeInsets.symmetric(horizontal: 50, vertical: 15)
            :const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: cor,
        elevation: elevacao,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),)
    );
  }

  static snak(String tit,String frase,bool dismiss,Color corFundo){
    return Get.snackbar(
      tit,
      frase,
      icon: Icon(Icons.person, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: corFundo,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      isDismissible: false,
      //showProgressIndicator:true,
      //dismissDirection: SnackDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.easeOutBack,

    );
  }
}//441
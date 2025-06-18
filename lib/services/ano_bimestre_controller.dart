import 'package:get/get.dart';
import 'dart:html' as html;

class AnoBimestreController extends GetxController {
  final RxString ano = ''.obs;
  final RxString bimestre = ''.obs;

  AnoBimestreController({
    required String anoInicial,
    required String bimestreInicial,
  }) {
    ano.value = anoInicial;
    bimestre.value = bimestreInicial;

    ano.listen((novoAno) {
    });

    bimestre.listen((novoBimestre) {

      print('Bimestre mudou para $novoBimestre');
      // Snackbar opcional aqui
    });
  }

  void atualizaAnoEBimestre(String novoAno, String novoBimestre) {
    ano.value = novoAno;
    bimestre.value = novoBimestre;

    html.window.localStorage['ano'] = novoAno;
    html.window.localStorage['bimestre'] = novoBimestre;
  }

  void atualizarApenasAno(String novoAno) {
    ano.value = novoAno;
    html.window.localStorage['ano'] = novoAno;
  }

  void atualizarApenasBimestre(String novoBimestre) {
    bimestre.value = novoBimestre;
    html.window.localStorage['bimestre'] = novoBimestre;
  }



}

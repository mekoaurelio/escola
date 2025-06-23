/*
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

 */

import 'package:get/get.dart';
import 'dart:html' as html;

class AnoBimestreController extends GetxController {
  final RxString ano = ''.obs;
  final RxString bimestre = ''.obs;

  AnoBimestreController({
    String? anoInicial,
    String? bimestreInicial,
  }) {
    // Carregar do localStorage se disponível, senão usar valores iniciais
    ano.value = html.window.localStorage['ano'] ?? anoInicial ?? '';
    bimestre.value = html.window.localStorage['bimestre'] ?? bimestreInicial ?? '';

    // Listeners opcionais para depuração ou feedback
    ano.listen((novoAno) {
      // print('Ano atualizado: $novoAno');
    });

    bimestre.listen((novoBimestre) {
      // print('Bimestre atualizado: $novoBimestre');
    });
  }

  /// Atualiza os dois valores simultaneamente
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


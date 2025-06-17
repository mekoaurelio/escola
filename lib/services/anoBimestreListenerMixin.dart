import 'ano_bimestre_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

mixin AnoBimestreListenerMixin<T extends StatefulWidget> on State<T> {
  late final AnoBimestreController _controller;
  late final StreamSubscription<String> _anoSub;
  late final StreamSubscription<String> _bimestreSub;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AnoBimestreController>();

    _anoSub = _controller.ano.listen((novoAno) {
      onAnoBimestreMudou(novoAno, _controller.bimestre.value);
    });

    _bimestreSub = _controller.bimestre.listen((novoBimestre) {
      onAnoBimestreMudou(_controller.ano.value, novoBimestre);
    });
  }

  @override
  void dispose() {
    _anoSub.cancel();
    _bimestreSub.cancel();
    super.dispose();
  }

  void onAnoBimestreMudou(String ano, String bimestre);
}

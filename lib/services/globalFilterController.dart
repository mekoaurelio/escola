import 'package:get/get.dart';
import 'utils.dart';

class GlobalFilterController extends GetxController {
  // Use 'final' para as variáveis reativas, é uma boa prática.
  final ano = Rx<String>(Utils.getAno() ?? '25');
  final bimestre = Rx<String>(Utils.getBimestre() ?? '01');
  final municipio = Rx<String>(Utils.getUserMunicipio() ?? 'a_');

  // A função de atualização
  void updateFilters({String? novoMunicipio, String? novoAno, String? novoBimestre}) {
    bool changed = false;

    if (novoMunicipio != null && municipio.value != novoMunicipio) {
      municipio.value = novoMunicipio;
      Utils.setUserMunicipio(novoMunicipio);
      changed = true;
    }
    if (novoAno != null && ano.value != novoAno) {
      ano.value = novoAno;
      Utils.setAno(novoAno);
      changed = true;
    }
    if (novoBimestre != null && bimestre.value != novoBimestre) {
      bimestre.value = novoBimestre;
      Utils.setBimestre(novoBimestre);
      changed = true;
    }

    if (changed) {
      update(); // Notifica os GetBuilders
    }
  }
}
import 'package:get/get.dart';
import 'GlobalFilterController.dart';

// Variáveis globais para fácil acesso. Elas serão atualizadas pelo serviço.
String TBFolha = '';
String TBVantagens = '';
String TBProfessor = '';
String TBInfantil = '';
String TBReceitaFundebSimulador = '';
String TBExercicio = '';
String TBTotais = '';
String TBTotalProfessor='';
String TBDecenio='';
String TBImpostos='';
String TBVaaf='';
String TBDemonReceitas='';
String TBPac='';
String TBImpactoEducacao='';
String TBReceitasEducacionais='';
String TBSimulaCab='';
String TBSimulaForm='';

class TableNameService extends GetxService {
  // Pega a instância do controller global
  final GlobalFilterController _filterController = Get.find<GlobalFilterController>();

  // Este método será chamado automaticamente quando o serviço for inicializado pelo GetX
  @override
  void onInit() {
    super.onInit();
    print("TableNameService inicializado!");

    // Atualiza os nomes das tabelas pela primeira vez
    _updateTableNames();

    // Registra listeners para "ouvir" qualquer mudança nos filtros
    _filterController.municipio.listen((_) => _updateTableNames());
    _filterController.ano.listen((_) => _updateTableNames());
    _filterController.bimestre.listen((_) => _updateTableNames());
  }

  // A ÚNICA função que define os nomes das tabelas em todo o app
  void _updateTableNames() {
    final muni = _filterController.municipio.value;
    final ano = _filterController.ano.value;
    final bimestre = _filterController.bimestre.value;

    TBFolha = '${muni}$ano$bimestre'; // Corrigi o nome da tabela aqui
    TBVantagens = '${muni}vantagens$ano$bimestre';
    TBProfessor = '${muni}professor$ano$bimestre';
    TBInfantil = '${muni}infantil$ano$bimestre';
    TBReceitaFundebSimulador = '${muni}receita_fundeb_simulador$ano$bimestre';
    TBExercicio = '${muni}exercicio$ano$bimestre';
    TBTotais = '${muni}totais$ano$bimestre';
    TBTotalProfessor='${muni}total_professor$ano$bimestre';
    TBDecenio='${muni}decenio$ano$bimestre';
    TBImpostos='${muni}impostos$ano$bimestre';
    TBVaaf='${muni}vaaf$ano$bimestre';
    TBDemonReceitas='${muni}demonstrativo_receita$ano$bimestre';
    TBPac='${muni}pac$ano$bimestre';
    TBImpactoEducacao='${muni}impacto_educacao$ano$bimestre';
    TBReceitasEducacionais='${muni}receitas_educacionais$ano$bimestre';
    TBSimulaCab='${muni}simula_cab$ano$bimestre';
    TBSimulaForm='${muni}simula_form$ano$bimestre';

    print('TABELA ATUAL');
    print(TBFolha);
  }
}
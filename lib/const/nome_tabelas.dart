import '../services/utils.dart';

String ano=Utils.getAno();
String bimestre=Utils.getBimestre();

String muni=Utils.getUserMunicipio();

String TBFolha='${muni}$ano$bimestre';
String TBVantagens='${muni}vantagens$ano$bimestre';
String TBTotalProfessor='${muni}total_professor$ano$bimestre';
String TBDemonReceitas='${muni}ind_demonstrativo_receita2501$ano$bimestre';


///USADAS NO SIMMULADOR
String TBInfantil='${muni}infantil$ano$bimestre';
String TBExercicio='${muni}exercicio$ano$bimestre';
String TBProfessor='${muni}professor$ano$bimestre';
String TBReceitaFundebSimulador='${muni}receita_fundeb_simulador$ano$bimestre';
String TBVaaf='${muni}vaaf$ano$bimestre';
String TBTotais='${muni}totais$ano$bimestre';
String TBDecenio='${muni}decenio$ano$bimestre';
String TBImpostos='${muni}impostos$ano$bimestre';

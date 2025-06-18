import '../services/utils.dart';

String ano=Utils.getAno();
String bimestre=Utils.getBimestre();

String TBFolha='a$ano$bimestre';
String TBVantagens='a_vantagens$ano$bimestre';
String TBTotalProfessor='a_total_professor$ano$bimestre';

///USADAS NO SIMMULADOR
String TBInfantil='a_infantil$ano$bimestre';
String TBExercicio='a_exercicio$ano$bimestre';
String TBProfessor='a_professor$ano$bimestre';
String TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
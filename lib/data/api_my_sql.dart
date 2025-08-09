import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/utils.dart';
import 'package:GEM/services/table_name_service.dart';

class ApiMySql {
  static String pathDados = 'https://www.xmktech.net/dados/';

  static Future<List<dynamic>> gerarInsertQuery(int idUser, Map<String, bool> acessos) async {
    final colunas = ['id_user'];
    final valores = [idUser.toString()];

    acessos.forEach((chave, valor) {
      colunas.add(_formatarColuna(chave));
      valores.add(valor ? 'TRUE' : 'FALSE');
    });

    final query = '''
INSERT INTO login_direitos (${colunas.join(', ')})
VALUES (${valores.join(', ')});
''';
   // print(query);
    return await executaSql(query);
  }

  static Future<List<dynamic>> gerarUpdateQuery(int idUser, Map<String, bool> acessos) async{
    final sets = acessos.entries.map((e) {
      final coluna = _formatarColuna(e.key);
      final valor = e.value ? 'TRUE' : 'FALSE';
      return '$coluna = $valor';
    }).join(', ');

    final query = '''
UPDATE login_direitos
SET $sets
WHERE id_user = $idUser;
''';
    //print(query);
    return await executaSql(query);
  }

  static  String _formatarColuna(String nomeOriginal) {
    return nomeOriginal
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '_');
  }

  static Future<String> fetchPdfText() async {
    final resp = await http.get(Uri.parse('https://www.xmktech.net/dados/extra.php'));
    if (resp.statusCode != 200) {
      throw Exception('Falha ao chamar API: ${resp.statusCode}');
    }
    final data = json.decode(resp.body);
    if (data['success'] != true) {
      throw Exception('Erro na extração: ${data['error']}');
    }
    return data['text'] as String;
  }

  ///**********************************************************************

  static Future<List<dynamic>> get(String table, dynamic id, String? orderBy) async {
    var sql = 'select * from $table';
    if (id != null) {
      sql += ' WHERE id=$id'; // Corrigido de AND para WHERE
    }
    if (orderBy != null) {
      sql += ' order by $orderBy';
    }
   // print(sql);
    return await executaSql(sql);
  }

  static Future<List<dynamic>> executaSql(String sql) async {
    try {
      final response = await http.get(Uri.parse('https://www.xmktech.net/dados/get.php?sql=${Uri.encodeComponent(sql)}'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body.trim());
        return result is List ? result : [result].whereType<dynamic>().toList();
      }
      return [];
    } catch (e) {
      print('Erro ao executar SQL: $e');
      return [];
    }
  }

  //******
  static Future<List<dynamic>> getProfessores(String tipo,String tbFolha,String tbVantagem) async {
    var url = Uri.parse('https://www.xmktech.net/dados/get_prof_infan.php?nocache=${DateTime.now().millisecondsSinceEpoch}');

    // Corpo da requisição em formato JSON
    final body = json.encode({
      'action': 'getProfessor', // O nome da ação que o PHP vai identificar
      'tipo': tipo, // Os parâmetros que o PHP precisa
      'tbfolha': tbFolha,
      'tbvantagem': tbVantagem,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Sucesso
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        // Erro retornado pelo PHP
        final errorData = json.decode(response.body);
        print('Erro do servidor (${response.statusCode}): ${errorData['error']}');
        return [];
      }
    } catch (e) {
      print('Erro de conexão ao buscar professores: $e');
      return [];
    }
  }

//*****

  static Future<dynamic> insereSql(String sql) async {
    String cleanSql = sql.replaceAll(r'\"', '"');
    if(sql.contains('$TBExercicio')) {

    }
    var url = pathDados + 'insert.php?sql=$cleanSql';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'ERRO DE CONEXÃO';
      }
    } catch (e) {
      // Utils.snak('ERRO AO INSERIR', e.toString(), false, Colors.red);
      return 'ERRO AO INSERIR $sql';
    }
  }

  static existe(var TB, var CP, var VALUE) async {
    var sql = 'SELECT * from $TB where $CP=$VALUE';
    List lista = await executaSql(sql);
    return lista;
  }
  ///************************************************************************

  static criaTabela(String tb)async{
    final existsResult = await tabelaExiste(tb);
    final bool tabelaFolhaExiste = existsResult.toString().contains('1');
    if (!tabelaFolhaExiste) {
      await seNaoExistirCriaTabelaGenerica(tb);
      await criaIndice(tb);
      await addAutoIncremento(tb);
      if (tb == TBInfantil) {
        await ApiMySql.dadosInfantilProfessor(
            TBInfantil, 'Piso Incial 2025 INFANTIL');
      }
      if (tb == TBProfessor) {
        await ApiMySql.dadosInfantilProfessor(TBProfessor, 'Piso Incial 2025');
      }

      if (tb == TBExercicio) {
        await ApiMySql.dadosIniciasExercicio(TBExercicio);
      }
      if (tb == TBReceitaFundebSimulador) {
        await ApiMySql.dadosReceitaFundebSimulador(TBReceitaFundebSimulador);
      }
    }
  }

  ///INSERT O REGISTRO INICIAL ***********************************
  static dadosIniciasExercicio(var tb){
    String sql='INSERT INTO $tb';
    sql+=' (descricao, valor, percentual, ordem) VALUES';
    sql+='("FOLHA FUNDEB 60% - 2020", 10, 10, 1),';
    sql+='("FOLHA FUNDEB 60% - 2021", 10, 10, 3),';
    sql+='("FOLHA FUNDEB 60% - 2022", 10, 10, 4),';
    sql+='("FOLHA FUNDEB 70% - 2023", 10, 10, 5),';
    sql+='("FOLHA FUNDEB 70% - 2024", 10, 10, 6),';
    sql+='("FOLHA FUNDEB 70% - 2025 - ESTIMATIVA", 10, 10, 7),';
    sql+='("xxxxx", 0.00, 0.00, 0)' ;
    executaSql(sql);
  }

  static dadosReceitaFundebSimulador(var tb){
    String sql='INSERT INTO $tb';
    sql+=' (descricao, valor, percentual, ordem) VALUES';
    sql+='("xxxxx", 10, 10, 0),';
    sql+='("FUNDEB 2020", 10, 10, 1),';
    sql+='("FUNDEB 2021", 10, 10, 3),';
    sql+='("FUNDEB 2022", 10, 10, 4),';
    sql+='("FUNDEB 2023", 10, 10, 5),';
    sql+='("FUNDEB 2024", 10, 10, 6),';
    sql+='("FUNDEB 2025 - ESTIMATIVA", 10, 10, 7)';
    executaSql(sql);
  }


  static dadosInfantilProfessor(var tb,var title){
    var sql='INSERT INTO $tb';
    sql+='(descricao, valor, percentual, ordem) VALUES';
    sql+='("$title", 10.00, 0.00, 0),';
    sql+='("Progressão entre Classes", 0.00, 2.00, 1),';
    sql+='("Progressão entre Níveis B - PISO SUP.", 10.00, 0.00, 3),';
    sql+='("Progressão entre Níveis NB e NC", 10.00, 10.00, 4),';
    sql+='("Progressão entre Níveis NC e ND", 10.80, 10.00, 5),';
    sql+='("Progressão entre Níveis ND e NE", 10.28, 10.00, 6),';
    sql+='("Encargos Sociais - Estatutário", 0.00, 14.00, 7),';
    sql+='("Progressão entre níveis A-MAG.", 10.00, 80.00, 2)';
    executaSql(sql);
  }

  static dadosDecenio(var tb){
    var sql='INSERT INTO $tb';
    sql+='(descricao, vr1, vr12) VALUES';
    sql+='("FMP", 0.00, 1.00),';
    sql+='("IPI-EXP.", 1.00, 1.00),';
    sql+='("Lei Complementar nro 87", 1.00, 1.00),';
    sql+='("ITR", 1.00, 1.00),';
    sql+='("IPVA", 1.00, 1.00),';
    sql+='("ICMS", 0.00, 1.00)';
    executaSql(sql);
  }

  static dadosDemostrativoReceita(var tb,var bimestre){
    var sql='INSERT INTO $tb';
    sql+='(populacao, dados_exercicio, receita_impostos, receita_transferencia, transferencia_fnde, receita_ao_fundeb, receita_do_fundeb, desp_com_rec_fundeb, prof_educ_basica, minimo70, outras_depesas, resul_liqui_transf, conta25, conta5, conta1000, perc_apli_mde, total_invest_edu, bimestre, total_receita) VALUES';
    sql+='( 0.00, 0.00, 0.80, 0.0, 0.21, 0.47, 0.43, 0.00, 0.06, 0.74, 0.00, 0.00, 0.70, 0.12, 0.00, 0.00, 0.67, "$bimestre", 0.00)';
    executaSql(sql);
  }

  static dadosImpactoEducacaoa(var tb){
    var sql='INSERT INTO $tb';
    sql+='(meta, sitaouac, saldo, creche, pre_escola, anos, matriculas_pactuadas, matriculas_declaradas, vr_pago, matriculas_declaradas2, vr_estimado) VALUES';
    sql+='(0, 0, 0, 0, 0, 0, 0, 0, 0.00, 0, 0.00)';
    executaSql(sql);
  }

  static dadosImpostos(var tb){
    var sql='INSERT INTO $tb';
    sql+='(descricao, vr1, vr12) VALUES';
    sql+='("IOF", 0.00, 1.00),';
    sql+='("ISS", 1.00, 1.00),';
    sql+='("IPTU", 1.00, 1.00),';
    sql+='("ITBI", 1.00, 1.00),';
    sql+='("IR", 1.00, 1.00)';
    print(sql);
    executaSql(sql);
  }

  static dadosPac(var tb){
    var sql='INSERT INTO $tb';
    sql+='(creche, creche_vr, onibus, onibus_vr, manifestacoes, investimentos, previsao, escola_tempo_i, escola_tempo_i_vr) VALUES';
    sql+='(1.00, 0.98, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00)';
    executaSql(sql);
  }

  static dadosTotais(var tb){
    var sql='INSERT INTO $tb';
    sql+='(decendio_projetado, decendio_5, imposto_projetado, imposto_25, matricula, receita, fundeb_10_5, perc_aumento_adulto, perc_aumento_infantil) VALUES';
    sql+='(0.00, 0.00, 0.00, 0.00, 0.00, 0.60, 0.00, 0.00, 0.00)';
    executaSql(sql);
  }

  static dadosVaaf(var tb){
    var sql='INSERT INTO $tb';
    sql+='( vr1, vr2, vr3, vr4, vr5, vr6, vr7, vr8, vr9, vr10, vr11, vr12, vr13, vr14, vr15, vr16, vr17, vr18, vr19, vr20, vr21) VALUES';
    sql+='( 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00)';
    executaSql(sql);
  }

  ///**************************************************************

  static seNaoExistirCriaTabela(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+="id_municipio int(11) NOT NULL DEFAULT 0,";
    sql+='matricula varchar(20) NOT NULL,';
    sql+='nome varchar(255) NOT NULL,';
    sql+='cpf varchar(14) DEFAULT NULL,';
    sql+='unidade varchar(255) DEFAULT NULL,';
    sql+='local_lotacao varchar(255) DEFAULT NULL,';
    sql+='cargo varchar(255) DEFAULT NULL,';
    sql+='nivel varchar(50) DEFAULT NULL,';
    sql+='admissao date DEFAULT NULL,';
    sql+='vencimento decimal(10,2) DEFAULT NULL,';
    sql+="status varchar(1) DEFAULT 'A',";
    sql+='created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP);';
   // print(sql);
    await executaSql(sql);
  }

  static getProfessor() async {
    var sql2 = "SELECT  f.id AS folha_id,f.id_municipio,f.matricula,f.nome,f.cpf,f.unidade,f.local_lotacao,f.vencimento,";
    sql2+="f.cargo,f.nivel,DATE_FORMAT(f.admissao, '%d/%m/%Y') AS admissao,f.competencia_mes,f.vantagens_total,";
    sql2+="f.descontos_total,f.liquido_total,f.fgts_total,GROUP_CONCAT(CONCAT(dv.codigo, ':',dv.descricao, ':',";
    sql2+="dv.percentual, ':',' R/\$ ', FORMAT(dv.valor, 2)) SEPARATOR ' | ') AS vantagens_detalhadas,";
    sql2+=" SUM(CASE WHEN dv.codigo NOT IN ('21003', '21019') THEN dv.valor ELSE 0  END) AS soma_vantagens,";
    sql2+=" SUM(CASE WHEN dv.codigo IN ('21019') THEN dv.valor ELSE 0  END) AS soma_apts,";
    sql2+="(SELECT SUM(vencimento) FROM $TBFolha WHERE status = 'A') AS total_vencimentos_geral";
    sql2+=" FROM $TBFolha f LEFT JOIN $TBVantagens dv ON f.id = dv.folha_id WHERE f.status = 'A'GROUP BY f.id ORDER BY f.id";
   // print(sql2);
    return await executaSql(sql2);
  }

  static getProfessor2(String tipo) async {
    var sql2 = "SELECT f.id AS folha_id,f.id_municipio,f.matricula,f.nome,f.cpf,f.unidade,f.local_lotacao,f.vencimento,";
    sql2+="f.cargo,f.nivel,DATE_FORMAT(f.admissao, '%d/%m/%Y') AS admissao,f.competencia_mes,f.vantagens_total,";
    sql2+="f.descontos_total,f.liquido_total,f.fgts_total,GROUP_CONCAT(CONCAT(dv.codigo, ':',dv.descricao, ':',";
    sql2+="dv.percentual, ':',' R/\$ ', FORMAT(dv.valor, 2)) SEPARATOR ' | ') AS vantagens_detalhadas,";
    sql2+=" SUM(CASE WHEN dv.codigo NOT IN ('21003', '21019') THEN dv.valor ELSE 0 END) AS soma_vantagens,";
    sql2+=" SUM(CASE WHEN dv.codigo IN ('21019') THEN dv.valor ELSE 0 END) AS soma_apts,";
    sql2+="(SELECT SUM(vencimento) FROM a2501 WHERE status = 'A') AS total_vencimentos_geral";
    sql2+=" FROM $TBFolha f LEFT JOIN $TBVantagens dv ON f.id = dv.folha_id WHERE f.status = 'A'";

    // Adiciona filtro baseado no tipo
    if (tipo == 'INFANTIL') {
      sql2 += " AND f.unidade LIKE '%Educ%Inf%'";

    } else if (tipo == 'ADULTO') {
      sql2 += " AND f.unidade NOT LIKE '%Educ%Inf%'";
    }
    sql2 += " GROUP BY f.id ORDER BY f.id";
    // print(sql2);
    return await executaSql(sql2);
  }

  static Future<void> criaIndice(String tb)async{
    await executaSql("ALTER TABLE $tb ADD PRIMARY KEY (id)");
  }

  static Future<void> addAutoIncremento(String tb)async{
    if(tb==TBVantagens){
     // print('ALTER TABLE $tb MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0');
    }
    await executaSql('ALTER TABLE $tb MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0');
  }

  static Future<void> seNaoExistirCriaTabelaVantagens(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='folha_id int(11) NOT NULL,';
    sql+='codigo varchar(10) NOT NULL,';
    sql+='descricao varchar(255) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT 0,';
    sql+='percentual decimal(4,2) NOT NULL DEFAULT 0)';
    //print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaProfessorTotal(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT 0 ,';
    sql+='tot_basico_atual decimal(10,2) NOT NULL,';
    sql+='tot_complementacao_piso decimal(10,2) NOT NULL,';
    sql+='tot_jornada_suplementar decimal(10,2) NOT NULL,';
    sql+='tot_adicional_ats decimal(10,2) NOT NULL,';
    sql+='tot_abono_permanencia decimal(5,2) NOT NULL,';
    sql+='tot_gratificacao_direcao decimal(10,2) NOT NULL,';
    sql+='tot_adicionais_especiais decimal(10,2) NOT NULL,';
    sql+='tot_gratificacao_orientacao decimal(10,2) NOT NULL,';
    sql+='tot_diferenca_enquadramento decimal(10,2) NOT NULL,';
    sql+='tot_encargos_sociais decimal(10,2) NOT NULL)';
  //  await executaSql(sql);
  }

  static seNaoExistirCriaTabelaGenerica(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT 0,';
    sql+='descricao varchar(100) NOT NULL DEFAULT 0,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT 0,';
    sql+='percentual decimal(4,2) NOT NULL DEFAULT 0,';
    sql+='ordem int(11) NOT NULL)';
   // print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaFundeb(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT "0",';
    sql+='ano int(11) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT "0",';
    sql+='percentual_crescimento decimal(5,2) NOT NULL DEFAULT "0")';
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaDecenio(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='descricao varchar(100) NOT NULL,';
    sql+='vr1 decimal(15,2) NOT NULL DEFAULT 0,';
    sql+='vr12 decimal(15,2) NOT NULL DEFAULT 0)';
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaImpostos(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='descricao varchar(100) NOT NULL,';
    sql+='vr1 decimal(15,2) NOT NULL DEFAULT "0",';
    sql+='vr12 decimal(15,2) NOT NULL DEFAULT "0")';
    //print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaTotais(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'decendio_projetado decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'decendio_5 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'imposto_projetado decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'imposto_25 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'matricula decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'receita decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'fundeb_10_5 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'perc_aumento_adulto decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'perc_aumento_infantil decimal(15,2) NOT NULL DEFAULT "0.00")';
    //print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaImpacto(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'meta varchar(100) NOT NULL,';
    sql+= 'sitaouac varchar(100) NOT NULL,';
    sql+= 'saldo varchar(100) NOT NULL,';
    sql+= 'creche varchar(100) NOT NULL,';
    sql+= 'pre_escola varchar(100) NOT NULL,';
    sql+= 'anos varchar(100) NOT NULL,';
    sql+= 'matriculas_pactuadas varchar(100) NOT NULL,';
    sql+= 'matriculas_declaradas varchar(100) NOT NULL,';
    sql+= 'matriculas_declaradas2 varchar(100) NOT NULL,';
    sql+= 'vr_pago decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'vr_estimado decimal(15,2) NOT NULL DEFAULT "0.00")';
    //print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaVaaf(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'vr1 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr2 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr3 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr4 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr5 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr6 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr7 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr8 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr9 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr10 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr11 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr12 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr13 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr14 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr15 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr16 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr17 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr18 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr19 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr20 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'vr21 decimal(10,3) NOT NULL DEFAULT "0.00")';
   // print(sql);
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaPac(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'creche varchar(100) NOT NULL,';
    sql+= 'creche_vr decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'onibus varchar(100) NOT NULL,';
    sql+= 'onibus_vr decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'manifestacoes decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'investimentos decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'previsao decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'escola_tempo_i decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'escola_tempo_i_vr decimal(15,2) NOT NULL DEFAULT 0)';
    await executaSql(sql);
  }

  static Future<void> seNaoExistirCriaTabelaDemonstrativoReceita(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'populacao decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'dados_exercicio decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'receita_impostos decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'receita_transferencia decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'transferencia_fnde decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'receita_ao_fundeb decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'receita_do_fundeb decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'desp_com_rec_fundeb decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'prof_educ_basica decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'minimo70 varchar(100) NOT NULL,';
    sql+= 'outras_depesas decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'resul_liqui_transf decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'conta25 decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'conta5 decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'conta1000 decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'perc_apli_mde varchar(100) NOT NULL,';
    sql+= 'total_invest_edu decimal(15,2) NOT NULL DEFAULT 0,';
    sql+= 'bimestre varchar(100) NOT NULL,';
    sql+= 'total_receita decimal(15,2) NOT NULL DEFAULT 0)';
    await executaSql(sql);
  }

  static criaIndiceVantagem(String tb)async{
    await executaSql('ALTER TABLE $tb ADD PRIMARY KEY (id),ADD KEY folha_id (folha_id)');
  }

  static Future<void> addChaveEStrangeira(String tb,String tbPai)async{
    var sql='ALTER TABLE $tb ADD CONSTRAINT $tb';
    sql+="_fk1 FOREIGN KEY (folha_id) REFERENCES $tbPai (id) ON DELETE CASCADE";
    await executaSql(sql);
  }

  static tabelaExiste(String tb)async{
    var sql='SELECT COUNT(*) as table_exists FROM information_schema.tables';
    sql+=" WHERE table_schema = DATABASE() AND table_name = '$tb'";
    return await executaSql(sql);
  }

  static insertProf(var matricula,var nome, var cpf,var cargo,var local_lotacao,var unidade,var nivel,var admissao,
      var vencimento ) async {
    var vr=Utils.saldoToSave(vencimento);
    var idCompany=0;
    var dt='';
    if(admissao!=null){
      dt=Utils.dtToMysql(admissao);
    }
    String sql = 'INSERT INTO $TBFolha (matricula,nome, cpf,unidade,local_lotacao,cargo,nivel,admissao,vencimento,status) VALUES (';
    sql += '"$matricula", ';
    sql += '"$nome", ';
    sql += '"$cpf", ';
    sql += '"$unidade", ';
    sql += '"$local_lotacao", ';
    sql += '"$cargo", ';
    sql += '"$nivel", ';
    sql += '"$dt", ';
    sql += '$vr, ';
    sql += '"A" ';
    sql += ')';
    return await insereSql(sql);
  }

  static insertVantagens(var matricula,var codigo, var descricao,var valor,String percentual ) async {
    //  var idCompany=Utils.getIdEntidade();
    var vr=Utils.saldoToSave(valor);
    var perc=percentual.replaceAll('%', '');
    perc=perc.replaceAll(',', '.');
    String sql = 'INSERT INTO $TBVantagens (folha_id,codigo,descricao,valor,percentual) VALUES (';
    sql += '"$matricula", ';
    sql += '"$codigo", ';
    sql += '"$descricao", ';
    sql += '$vr, ';
    sql += '$perc ';
    sql += ')';
    return await executaSql(sql);
  }

  /// Dentro de ApiMySql
  static Future<void> updateTotalProfessor({
    required String campo,
    required String valor,
  }) async {
    // Escapa aspas simples
    final escaped = valor.replaceAll("'", "''");
    final sql = '''
    UPDATE $TBTotalProfessor 
    SET $campo = '${escaped.contains('R\$')
        ? Utils.saldoToSave(escaped)
        : escaped.replaceAll(',', '.')}'   
  ''';
    await executaSql(sql);
  }


  static getGrid() async {
    /// usei o PLUS_OPERATOR as vezes o PHP não reconhece o sinal de mais
    /// No arquivo get.php substituo PLUS_OPERATOR por +
    final sql = '''
  SELECT
    SUM(vencimento_basico_atual) AS soma_venc_basico_atual,
    SUM(complementacao_piso) AS soma_complementacao_piso,
    SUM(jornada_suplementar) AS soma_jornada_suplementar,
    SUM(adicional_ats) AS soma_adicional_ats,
    SUM(abono_permanencia) AS soma_abono_permanencia,
    SUM(gratificacao_direcao) AS soma_gratificacao_direcao,
    SUM(diferenca_enquadramento) AS soma_diferenca_enquadramento,
    SUM(gratificacao_orientacao) AS soma_gratificacao_orientacao,
   
    SUM(encargos_sociais) AS soma_encargos_sociais,
    SUM(
      adicional_especial_5
      PLUS_OPERATOR adicional_especial_10
      PLUS_OPERATOR adicional_especial_25
    ) AS soma_adicionais_especiais FROM professor
''';
    // print(sql);
    return  executaSql(sql);
    // return lista;
  }

  static Future getUserByEmailPassword(String idUser, String password,) async {
    String sql = 'Select * from vo_user where id_user="$idUser" and password="$password"';
    return executaSql(sql);
  }

  static Future insertDynamic(Map<String, String> data, String tb) async {
    final idEntidade = '0';

    /// Liste todos os campos e valores vindos do Map
    final campos = <String>[];
    final valores = <String>[];

    data.forEach((campo, valor) {
      if(valor.contains('R\$')){
        valor=Utils.saldoToSave(valor);
      }
      if(valor.contains('%')){
        valor=valor.replaceAll('%', '');
        valor=valor.trim();
        valor=valor.replaceAll(',', '.');
      }
      campos.add(campo);

      /// Escapa aspas simples para não quebrar a query
      final escaped = valor.replaceAll("'", "''");
      valores.add("'$escaped'");
    });

    /// ADD o id do município
    campos.add('id_municipio');
    valores.add(idEntidade);

    final sql = StringBuffer()
      ..write('INSERT INTO $tb (')..write(campos.join(', '))..write(
          ') VALUES (')..write(valores.join(', '))..write(')');

     //print(sql);
    return await insereSql(sql.toString());
  }

  /// Atualiza um registro na tabela [tb], montando o SET a partir de [data].
  /// [idField] é o nome da coluna de chave primária (por padrão “id”).
  /// [idValue] é o valor dessa chave para filtrar o registro a ser atualizado.
  static Future updateDynamic(String tb,
      Map<String, String> data, {
        String idField = 'id',
        required String idValue,
      }) async {
    if (data.isEmpty) {
      throw Exception('Nenhum dado para atualizar.');
    }

    /// Monta lista de "campo = 'valor'"
    final sets = <String>[];
    data.forEach((campo, valor) {
      if(valor.contains('R\$')){
        valor=Utils.saldoToSave(valor);
      }
      if(valor.contains('%')){
        valor=Utils.saldoToSave(valor);
        valor=valor.trim();
      }
      // Escapa aspas simples
      final escaped = valor.replaceAll("'", "''");
      sets.add('$campo = \'$escaped\'');
    });

    final sql = StringBuffer()
      ..write('UPDATE $tb SET ')..write(sets.join(', '))..write(
          ' WHERE $idField = \'${idValue.replaceAll("'", "''")}\'');
  //  print(sql.toString());
    return await executaSql(sql.toString());
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/const.dart';
import '../services/utils.dart';
import 'package:GEM/services/table_name_service.dart';

import '../simulador/formulario/formulario.dart';

class ApiMySql {

  static Future<List<dynamic>> getHoras() async{
    var sql = "SELECT GROUP_CONCAT(DISTINCT horas ORDER BY horas SEPARATOR ',') AS horas_distintas";
    sql+=" FROM $TBFolha WHERE horas IS NOT NULL AND horas !='';";
    return await executaSql(sql);
  }

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
  
  static Future<String> criaIndiceEAutoIncremento(var tb)async{
    bool existe=await temRegistros(tb);
    if(!existe) {
      var criaIndice = "ALTER TABLE $tb ADD PRIMARY KEY (id)";
      await executaSql(criaIndice);
      var criaAutoIncrimento = "ALTER TABLE $tb MODIFY id int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=0";
      await executaSql(criaAutoIncrimento);
    }
    return 'ok';
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
    var path='$pathDados{extra.php}';
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
    return await executaSql(sql);
  }

  static Future<List<dynamic>> getItensFromForm(String table, dynamic id, String? orderBy) async {
    var sql = 'select * from $table';
    sql += ' WHERE id_form=$id';

    if (orderBy != null) {
      sql += ' order by $orderBy';
    }
    // print(sql);
    return await executaSql(sql);
  }

  static Future<List<dynamic>> getTotolSalPorHora(String tFolha,String tSimula,String tVantagem) async {
    var sql = 'SELECT a.horas,s.descricao,SUM(a.vencimento) as total_vencimento,s.id,s.classes,s.progressao,';
    sql+='COUNT(*) as quantidade_registros,COALESCE(SUM(v.valor), 0) as total_vantagens';
    sql+=" FROM $tFolha a LEFT JOIN $tSimula s ON REPLACE(a.horas, 'hs', '') = s.horas";
    sql+= ' LEFT JOIN $tVantagem v ON a.matricula = v.folha_id';
    sql+=' WHERE a.vencimento IS NOT NULL GROUP BY a.horas, s.descricao ORDER BY a.horas;';
  //  print(sql);
    return await executaSql(sql);
  }


  static Future<List<dynamic>> getProgressaoDoProfessor(String hora) async {
    var hr=hora.replaceAll('hs', '');
    var sql="Select * progressao from $TBSimulaCab where horas=$hr";
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
  
  static Future<List<dynamic>> getProfessores(String hora,String tbFolha,String tbVantagem) async {
    var url = Uri.parse('https://www.xmktech.net/dados/get_prof_infan.php?nocache=${DateTime.now().millisecondsSinceEpoch}');

    // Corpo da requisição em formato JSON
    final body = json.encode({
      'action': 'getProfessor', // O nome da ação que o PHP vai identificar
      'tipo': hora, // Os parâmetros que o PHP precisa
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

  static Future<List<dynamic>> getHoraNivel(String cab,String form) async {
    var sql='SELECT c.*,f.id_form,f.nivel,f.label,f.tipo,f.valor,f.perc';
    sql+=' FROM $cab c JOIN $form f ON c.id =f.id_form;';
    print(sql);
    return await executaSql(sql);
  }


  static Future<List<dynamic>> getProPorHora(String hora,String tbFolha,String tbVantagem) async {
    var url = Uri.parse('https://www.xmktech.net/dados/get_prof_por_hora.php?nocache=${DateTime.now().millisecondsSinceEpoch}');

    // Corpo da requisição em formato JSON
    final body = json.encode({
      'action': 'getProfessor', // O nome da ação que o PHP vai identificar
      'hora': hora, // Os parâmetros que o PHP precisa
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
      List<dynamic> lista = [
        {'Erro': 'Erro de conexão ao buscar professores: $e'}, // Map
      ];
      return lista;
    }
  }

  static Future<List<dynamic>> getProfPorNivel(String tbFolha,String hora) async {
    var url = Uri.parse('https://www.xmktech.net/dados/get_prof_por_nivel.php?nocache=${DateTime.now().millisecondsSinceEpoch}');

    // Corpo da requisição em formato JSON
    final body = json.encode({
      'action': 'getProfessor', // O nome da ação que o PHP vai identificar
      'tbfolha': tbFolha,
      'hora': hora,
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

  static Future<bool>temRegistros(var TB) async {
    var sql = 'SELECT * from $TB ';
    List lista = await executaSql(sql);
    bool existe=lista.length>0;
    return existe;
  }
  
  ///**************************************************************

  // select nome,unidade,nivel,horas,vencimento from cia_2505 ORDER BY horas,nivel

  // select nome,unidade,nivel,horas,vencimento from cia_2505 where unidade<>'Professor' ORDER BY horas,nivel

  static getProfessor() async {
    var sql1="SELECT  f.id AS folha_id,f.id_municipio,f.matricula,f.nome,f.cpf,f.unidade,f.local_lotacao,f.horas,s.id as id_simula,";
    sql1+="f.vencimento,f.cargo,f.nivel,DATE_FORMAT(f.admissao, '%d/%m/%Y') AS admissao,";
    sql1+="GROUP_CONCAT(CONCAT(dv.codigo, ':', dv.descricao, ':', dv.percentual, ':', ' R/\$ ', FORMAT(dv.valor, 2)) SEPARATOR ' | ') AS vantagens_detalhadas, SUM(dv.valor) AS soma_vantagens,";
    sql1+="(SELECT SUM(vencimento) FROM $TBFolha WHERE status = 'A') AS total_vencimentos_geral";
    sql1+=" FROM $TBFolha f LEFT JOIN $TBSimulaCab s ON REPLACE(f.horas, 'hs', '') = s.horas";
    sql1+=" LEFT JOIN $TBVantagens dv ON f.matricula = dv.folha_id";
    sql1+=" WHERE f.status = 'A'";
    sql1+=" GROUP BY f.matricula ORDER BY f.matricula";
   // print(sql1);

    return await executaSql(sql1);
  }

  /// ==========================================================
  /// Criação das tabelas                                      =
  /// ==========================================================

  static seNaoExistirCriaTabelaGenerica(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT 0,';
    sql+='descricao varchar(100) NOT NULL DEFAULT 0,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT 0,';
    sql+='percentual decimal(4,2) NOT NULL DEFAULT 0,';
    sql+='ordem int(11) NOT NULL)';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static criaTabelaComuns(String tb)async{
    final tabelaFolhaExiste = await tabelaExiste(tb);
    if (!tabelaFolhaExiste) {
      print('Não tem a tabela $tb');
      await seNaoExistirCriaTabelaGenerica(tb);

      if (tb == TBInfantil) {
        await ApiMySql.dadosInfantilProfessor(TBInfantil, 'Piso Incial 2025 INFANTIL');
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

  static  Future<void> CriaTabelaSimulaForm(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_form int(11) NOT NULL,';
    sql+='label varchar(200) NOT NULL,';
    sql+='tipo varchar(50) NOT NULL,';
    sql+='valor decimal(15,2) DEFAULT NULL,';
    sql+='perc decimal(10,2) DEFAULT NULL,';
    sql+='created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP);';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static  Future<List<dynamic>> CriaTabelaSimulaCab(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='horas int(11) NOT NULL,';
    sql+='descricao varchar(200) NOT NULL,';
    sql+='classes int(11) NOT NULL,';
    sql+='progressao decimal(5,2) NOT NULL,';
    sql+='created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP);';
    var result=await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
    return result;
  }
  
  static CriaTabelaProfessor(String tb)async{
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
    sql+="horas varchar(30) DEFAULT ' ',";
    sql+='created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP);';
    // print(sql);
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }
  
  static Future<void> CriaTabelaVantagens(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='folha_id int(11) NOT NULL,';
    sql+='codigo varchar(10) NOT NULL,';
    sql+='descricao varchar(255) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT 0,';
    sql+='percentual decimal(4,2) NOT NULL DEFAULT 0)';
    //print(sql);
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaProfessorTotal(String tb)async{
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

  static CriaTabelaGenerica(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT 0,';
    sql+='descricao varchar(100) NOT NULL DEFAULT 0,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT 0,';
    sql+='percentual decimal(4,2) NOT NULL DEFAULT 0,';
    sql+='ordem int(11) NOT NULL)';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaFundeb(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT "0",';
    sql+='ano int(11) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT "0",';
    sql+='percentual_crescimento decimal(5,2) NOT NULL DEFAULT "0")';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaDecenio(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='descricao varchar(100) NOT NULL,';
    sql+='vr1 decimal(15,2) NOT NULL DEFAULT 0,';
    sql+='vr12 decimal(15,2) NOT NULL DEFAULT 0)';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaImpostos(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='descricao varchar(100) NOT NULL,';
    sql+='vr1 decimal(15,2) NOT NULL DEFAULT "0",';
    sql+='vr12 decimal(15,2) NOT NULL DEFAULT "0")';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaTotais(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'decendio_projetado decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'decendio_5 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'imposto_projetado decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'imposto_25 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'matricula decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'vaaf decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'vaar decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'meses int NOT NULL DEFAULT "12",';
    sql+= 'decimo_ter_ferias decimal(5,2) NOT NULL DEFAULT "0.30",';
    sql+= 'encargos_sociais decimal(5,2) NOT NULL DEFAULT "22.00",';
    sql+= 'receita decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'fundeb_10_5 decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'qtde_classe int(11) NOT NULL,';
    sql+= 'perc_aumento_infantil decimal(15,2) NOT NULL DEFAULT "0.00",';
    sql+= 'perc_aumento_adulto decimal(15,2) NOT NULL DEFAULT "0.00")';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaImpacto(String tb)async{
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
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaVaaf(String tb)async{
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
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelareceitasEducacionais(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+= 'total_receita decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_01 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_02 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_03 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_04 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_05 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_06 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_07 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_08 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_09 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_10 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_11 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_12 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_13 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_14 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_15 decimal(10,3) NOT NULL DEFAULT "0.00",';
    sql+= 'cp_money_16 decimal(10,3) NOT NULL DEFAULT "0.00",';

    sql+= 'cp_string_01 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_02 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_03 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_04 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_05 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_06 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_07 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_08 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_09 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_10 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_11 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_12 varchar(100) NOT NULL DEFAULT "",';
    sql+= 'cp_string_13 varchar(100) NOT NULL DEFAULT "")';
    await executaSql(sql);
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaPac(String tb)async{
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
    await criaIndiceEAutoIncremento(tb);
  }

  static Future<void> CriaTabelaDemonstrativoReceita(String tb)async{
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
    await criaIndiceEAutoIncremento(tb);
  }

  /// ==========================================================
  /// Cria os dados iniciais                                   =
  /// ==========================================================
  static dadosIniciasExercicio(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      String sql = 'INSERT INTO $tb';
      sql += ' (descricao, valor, percentual, ordem) VALUES';
      sql += '("FOLHA FUNDEB 60% - 2020", 10, 10, 1),';
      sql += '("FOLHA FUNDEB 60% - 2021", 10, 10, 3),';
      sql += '("FOLHA FUNDEB 60% - 2022", 10, 10, 4),';
      sql += '("FOLHA FUNDEB 70% - 2023", 10, 10, 5),';
      sql += '("FOLHA FUNDEB 70% - 2024", 10, 10, 6),';
      sql += '("FOLHA FUNDEB 70% - 2025 - ESTIMATIVA", 10, 10, 7),';
      sql += '("xxxxx", 0.00, 0.00, 0)';
      executaSql(sql);
    }
  }

  static dadosReceitaFundebSimulador(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      String sql = 'INSERT INTO $tb';
      sql += ' (descricao, valor, percentual, ordem) VALUES';
      sql += '("xxxxx", 10, 10, 0),';
      sql += '("FUNDEB 2020", 10, 10, 1),';
      sql += '("FUNDEB 2021", 10, 10, 3),';
      sql += '("FUNDEB 2022", 10, 10, 4),';
      sql += '("FUNDEB 2023", 10, 10, 5),';
      sql += '("FUNDEB 2024", 10, 10, 6),';
      sql += '("FUNDEB 2025 - ESTIMATIVA", 10, 10, 7)';
      executaSql(sql);
    }
  }

  static dadosInfantilProfessor(var tb,var title)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql += '(descricao, valor, percentual, ordem) VALUES';
      sql += '("$title", 10.00, 0.00, 0),';
      sql += '("Progressão entre Classes", 0.00, 2.00, 1),';
      sql += '("Progressão entre Níveis B - PISO SUP.", 10.00, 0.00, 3),';
      sql += '("Progressão entre Níveis NB e NC", 10.00, 10.00, 4),';
      sql += '("Progressão entre Níveis NC e ND", 10.80, 10.00, 5),';
      sql += '("Progressão entre Níveis ND e NE", 10.28, 10.00, 6),';
      sql += '("Encargos Sociais - Estatutário", 0.00, 14.00, 7),';
      sql += '("Progressão entre níveis A-MAG.", 10.00, 80.00, 2)';
      executaSql(sql);
    }
  }

  static dadosDecenio(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql += '(descricao, vr1, vr12) VALUES';
      sql += '("FMP", 0.00, 1.00),';
      sql += '("IPI-EXP.", 1.00, 1.00),';
      sql += '("Lei Complementar nro 87", 1.00, 1.00),';
      sql += '("ITR", 1.00, 1.00),';
      sql += '("IPVA", 1.00, 1.00),';
      sql += '("ICMS", 0.00, 1.00)';
      executaSql(sql);
    }
  }

  static dadosDemostrativoReceita(var tb,var bimestre)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '(populacao, dados_exercicio, receita_impostos, receita_transferencia, transferencia_fnde, receita_ao_fundeb, receita_do_fundeb, desp_com_rec_fundeb, prof_educ_basica, minimo70, outras_depesas, resul_liqui_transf, conta25, conta5, conta1000, perc_apli_mde, total_invest_edu, bimestre, total_receita) VALUES';
      sql +=
      '( 0.00, 0.00, 0.80, 0.0, 0.21, 0.47, 0.43, 0.00, 0.06, 0.74, 0.00, 0.00, 0.70, 0.12, 0.00, 0.00, 0.67, "$bimestre", 0.00)';
      executaSql(sql);
    }
  }

  static dadosReceitasEducacionais(var tb,var bimestre)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '(total_receita, cp_money_01, cp_money_02, cp_money_03, cp_money_04, cp_money_05, cp_money_06, cp_money_07, cp_money_08, cp_money_09, cp_money_10, cp_money_11,';
      sql += 'cp_money_12, cp_money_13, cp_money_14, cp_money_15, cp_money_16,';
      sql += 'cp_string_01, cp_string_02, cp_string_03, cp_string_04, cp_string_05, cp_string_06, cp_string_07, cp_string_08, cp_string_09, cp_string_10, cp_string_11,';
      sql += 'cp_string_12,cp_string_13) VALUES';
      sql += '( 0.0,0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,';
      sql += '"0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0")';
      // print(sql);
      executaSql(sql);
    }
  }

  static dadosImpactoEducacaoa(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '(meta, sitaouac, saldo, creche, pre_escola, anos, matriculas_pactuadas, matriculas_declaradas, vr_pago, matriculas_declaradas2, vr_estimado) VALUES';
      sql += '(0, 0, 0, 0, 0, 0, 0, 0, 0.00, 0, 0.00)';
      executaSql(sql);
    }
  }

  static dadosImpostos(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql += '(descricao, vr1, vr12) VALUES';
      sql += '("IOF", 0.00, 1.00),';
      sql += '("ISS", 1.00, 1.00),';
      sql += '("IPTU", 1.00, 1.00),';
      sql += '("ITBI", 1.00, 1.00),';
      sql += '("IR", 1.00, 1.00)';
      executaSql(sql);
    }
  }

  static dadosPac(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '(creche, creche_vr, onibus, onibus_vr, manifestacoes, investimentos, previsao, escola_tempo_i, escola_tempo_i_vr) VALUES';
      sql += '(1.00, 0.98, 0.00, 0.00, 0, 0, 0.00, 0.00, 0.00)';
      executaSql(sql);
    }
  }

  static dadosTotais(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '(decendio_projetado, decendio_5, imposto_projetado, imposto_25, matricula, receita, fundeb_10_5, qtde_classe, perc_aumento_infantil) VALUES';
      sql += '(0.00, 0.00, 0.00, 0.00, 0.00, 0.60, 0.00, 0.00, 0.00)';
      executaSql(sql);
    }
  }

  static dadosVaaf(var tb)async{
    bool temDados=await _temdados(tb);
    if(!temDados) {
      var sql = 'INSERT INTO $tb';
      sql +=
      '( vr1, vr2, vr3, vr4, vr5, vr6, vr7, vr8, vr9, vr10, vr11, vr12, vr13, vr14, vr15, vr16, vr17, vr18, vr19, vr20, vr21) VALUES';
      sql +=
      '( 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00)';
      executaSql(sql);
    }
  }
///**************************************************************************
  
  static Future<void> addChaveEStrangeiraVantagem(String tb,String tbPai)async{
    var sql='ALTER TABLE $tb ADD CONSTRAINT $tb';
    sql+="_fk1 FOREIGN KEY (folha_id) REFERENCES $tbPai (matricula) ON DELETE CASCADE";
    await executaSql(sql);
  }

  static tabelaExiste(String tb)async{
    var sql='SELECT COUNT(*) as table_exists FROM information_schema.tables';
    sql+=" WHERE table_schema = DATABASE() AND table_name = '$tb'";
    var existsResult= await executaSql(sql);
    final bool tabelaFolhaExiste = existsResult.toString().contains('1');
    return tabelaFolhaExiste;
  }

  static insertProf(var matricula,var nome, var cpf,var cargo,var local_lotacao,var unidade,var nivel,var admissao,
      var vencimento ) async {
    var vr=Utils.saldoToSave(vencimento);
    var idCompany=0;
    var dt='';
    if(admissao!=null){
      dt=Utils.dtToMysql(admissao);
    }
    String sql = 'INSERT INTO a_2502 (matricula,nome, cpf,unidade,local_lotacao,cargo,nivel,admissao,vencimento,status) VALUES (';
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
    TBVantagens = 'a_vantagens2502';
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
   // print(sql);
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

  static Future<bool> _temdados(var tb) async {
    var lista;
    lista=await ApiMySql.get(tb,null,null);
    return lista.length>0;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../const/nome_tabelas.dart';
import '../services/utils.dart';

class ApiMySql {
  static String pathDados = 'https://www.xmktech.net/dados/';

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
  static get(var table, var id, var orderBy) async {
    var sql = 'select * from $table';
    if (id != null) {
      sql += ' AND id=$id';
    }
    if(orderBy!=null){
      sql+=' order by $orderBy';
    }
    //print(sql);
    return executaSql(sql);
  }
/*
  static Future<dynamic> executaSql(String sql) async {
    String cleanSql = sql.replaceAll(r'\"', '"');

    //if(sql.contains('$TBExercicio')){
      //print(sql);
    //}
    List<Map<String, dynamic>> dados = [];
    var url = 'https://www.xmktech.net/dados/get.php?sql=$cleanSql';
    try {
      final response = await http.get(Uri.parse(url));
     // if(sql.contains('Quantidade'))
       // print(response.body);
      if (response.statusCode == 200) {
        String volta = response.body.trim();
        if (volta.contains('NENHUM') || volta.contains('affected_rows')) {
          print('RESULTADO $volta');
          dados = json.decode(volta);
          return dados;
        } else {
          dados = List<Map<String, dynamic>>.from(json.decode(volta));
          //  print('NO EXECUTA $dados');
          return dados;
        }
      } else {
        return dados;
      }
    } catch (e) {
      print('ERRO AO EXECUTAR ==> $e');
      return dados;
    }
  }

 */


  static Future<dynamic> executaSql(String sql) async {
    String cleanSql = sql.replaceAll(r'\"', '"');
    print(cleanSql);
    cleanSql = Uri.encodeComponent(cleanSql)
        .replaceAll('%25', '%') // Mantém os % originais do LIKE
        .replaceAll('+', '%20');

    var url = 'https://www.xmktech.net/dados/get.php?sql=$cleanSql';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
       // print('RESULTADO OK');
       // print(json.decode(response.body.trim()));
        return json.decode(response.body.trim());
      }
      return [];
    } catch (e) {
      print('ERRO AO EXECUTAR ==> $e');
      return [];
    }
  }


  //******
  static Future<List<dynamic>> getProfessores(String tipo) async {
    var url = Uri.parse('https://www.xmktech.net/dados/get_prof_infan.php?nocache=${DateTime.now().millisecondsSinceEpoch}');

    // Corpo da requisição em formato JSON
    final body = json.encode({
      'action': 'getProfessor', // O nome da ação que o PHP vai identificar
      'tipo': tipo, // Os parâmetros que o PHP precisa
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
        print('Dados de professores ($tipo) recebidos com sucesso!');
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
      //print('Inserindo Exercico');
      //print(sql);
      //print('Inserindo Exercico');
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

  static seNaoExistirCriaTabela(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+="id_municipio int(11) NOT NULL DEFAULT '0',";
    sql+='matricula varchar(20) NOT NULL,';
    sql+='nome varchar(255) NOT NULL,';
    sql+='cpf varchar(14) DEFAULT NULL,';
    sql+='unidade varchar(255) DEFAULT NULL,';
    sql+='local_lotacao varchar(255) DEFAULT NULL,';
    sql+='cargo varchar(255) DEFAULT NULL,';
    sql+='nivel varchar(50) DEFAULT NULL,';
    sql+='admissao date DEFAULT NULL,';
    sql+='competencia_mes varchar(20) DEFAULT NULL,';
    sql+='vantagens_total decimal(10,2) DEFAULT NULL,';
    sql+='descontos_total decimal(10,2) DEFAULT NULL,';
    sql+='liquido_total decimal(10,2) DEFAULT NULL,';
    sql+='fgts_total decimal(10,2) DEFAULT NULL,';
    sql+='vencimento decimal(10,2) DEFAULT NULL,';
    sql+="status varchar(1) DEFAULT 'A',";
    sql+='created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP);';
    await executaSql(sql);
  }


  static getProfessor() async {
    var sql2 = "SELECT  f.id AS folha_id,f.id_municipio,f.matricula,f.nome,f.cpf,f.unidade,f.local_lotacao,f.vencimento,";
    sql2+="f.cargo,f.nivel,DATE_FORMAT(f.admissao, '%d/%m/%Y') AS admissao,f.competencia_mes,f.vantagens_total,";
    sql2+="f.descontos_total,f.liquido_total,f.fgts_total,GROUP_CONCAT(CONCAT(dv.codigo, ':',dv.descricao, ':',";
    sql2+="dv.percentual, ':',' R/\$ ', FORMAT(dv.valor, 2)) SEPARATOR ' | ') AS vantagens_detalhadas,";
    sql2+=" SUM(CASE WHEN dv.codigo NOT IN ('21003', '21019') THEN dv.valor ELSE 0  END) AS soma_vantagens,";
    sql2+=" SUM(CASE WHEN dv.codigo IN ('21019') THEN dv.valor ELSE 0  END) AS soma_apts,";
    sql2+="(SELECT SUM(vencimento) FROM a2501 WHERE status = 'A') AS total_vencimentos_geral";
    sql2+=" FROM $TBFolha f LEFT JOIN $TBVantagens dv ON f.id = dv.folha_id WHERE f.status = 'A'GROUP BY f.id ORDER BY f.id";
    print(sql2);
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

    } else if (tipo == 'NORMAL') {
      sql2 += " AND f.unidade NOT LIKE '%Educ%Inf%'";
    }
    sql2 += " GROUP BY f.id ORDER BY f.id";
     print(sql2);
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
    sql+='valor decimal(10,2) NOT NULL,';
    sql+='percentual decimal(4,2) NOT NULL)';
  //  print(sql);
    await executaSql(sql);
  }

  static seNaoExistirCriaProfessorTotal(String tb)async{
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
    await executaSql(sql);
  }

  static seNaoExistirCriaTabelaGenerica(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT "0",';
    sql+='descricao varchar(100) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL,';
    sql+='percentual decimal(4,2) NOT NULL,';
    sql+='ordem int(11) NOT NULL)';
    await executaSql(sql);
  }

  static seNaoExistirCriaTabelaFundeb(String tb)async{
    var sql='CREATE TABLE IF NOT EXISTS $tb (';
    sql+='id int(11) NOT NULL,';
    sql+='id_municipio int(11) NOT NULL DEFAULT "0",';
    sql+='ano int(11) NOT NULL,';
    sql+='valor decimal(10,2) NOT NULL DEFAULT "0",';
    sql+='percentual_crescimento decimal(5,2) NOT NULL DEFAULT "0")';
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
     print(sql);
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

    // print(sql);
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

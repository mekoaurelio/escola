import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/utils.dart';

class ApiMySql {
  static String pathDados = 'https://www.xmktech.net/dados/';

  ///***********************************************************************
  static get(var table, var id,) async {
    var sql = '';
    // var idE=Utils.getIdEntidade();
    var idE = '0';
    sql = 'select * from $table WHERE id_municipio=$idE';
    if (id != null) {
      sql += ' AND id=$id';
    }
    print(sql);
    return executaSql(sql);
  }

  static Future<dynamic> executaSql(String sql) async {
    List<Map<String, dynamic>> dados = [];
    var url = 'https://www.xmktech.net/dados/get.php?sql=$sql';
    try {
      final response = await http.get(Uri.parse(url));
      //  print(response.body);
      if (response.statusCode == 200) {
        String volta = response.body.trim();
        if (volta.contains('NENHUM')) {
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
      print('ERRO AO EXECUTAR ==> ');
      print(e.toString());
      return dados;
    }
  }

  static Future<dynamic> insereSql(String sql) async {
    var url = pathDados + 'insert.php?sql=$sql';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'ERRO DE CONEXÃO';
      }
    } catch (e) {
      Utils.snak('ERRO AO INSERIR', e.toString(), false, Colors.red);
      return 'ERRO AO INSERIR';
    }
  }

  static existe(var TB, var CP, var VALUE) async {
    var sql = 'SELECT * from $TB where $CP=$VALUE';
    List lista = await executaSql(sql);
    return lista;
  }
  ///************************************************************************

  /// Dentro de ApiMySql
  static Future<void> updateTotalProfessor({
    required String campo,
    required String valor,
  }) async {
    // Escapa aspas simples
    final escaped = valor.replaceAll("'", "''");
    final sql = '''
    UPDATE professor_total 
    SET $campo = '${escaped.contains('R\$')
        ? Utils.saldoToSave(escaped)
        : escaped.replaceAll(',', '.')}'
   
  ''';
    await executaSql(sql);
  }


  //area_atuacao_id

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

  static getProdutos(var id,) async {
    String sql = "SELECT p.id AS product_id,p.id_entidade AS entity_id, p.nome AS product_name,p.id_categoria AS category_id,";
    sql += "p.valor AS product_value,p.foto AS foto,";
    sql += "e.id AS company_id,e.fantasia AS company_name";
    sql += " FROM vo_produto p JOIN vo_empresa e ON e.id = p.id_entidade ";

    // sql += "WHERE a.id_entidade =$idEntidade ";
    if (id != null) {
      sql += "AND p.id =$id";
    }
    sql += " GROUP BY p.id";
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

    print(sql);
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

    print(sql);
    return await executaSql(sql.toString());
  }
}

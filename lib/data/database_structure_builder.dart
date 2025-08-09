// database_structure_builder.dart
import 'package:flutter/material.dart';
import '../services/table_name_service.dart';
import '../services/utils.dart';
import 'api_my_sql.dart'; // Seu serviço de utils

// Classe de modelo para guardar os resultados da construção
class BuildResult {
  final bool success;
  final List<String> logs;
  final String? errorMessage;

  BuildResult({required this.success, this.logs = const [], this.errorMessage});

  @override
  String toString() {
    return 'BuildResult(success: $success, logs: ${logs.length} entries, error: $errorMessage)';
  }
}

class DatabaseStructureBuilder {
  final String municipio;
  final String ano;
  final String bimestre;

  late final String _folhaTableName;
  final List<String> _logs = [];

  DatabaseStructureBuilder({
    required this.municipio,
    required this.ano,
    required this.bimestre,
  }) {
    // O nome da tabela principal é construído uma vez no construtor
    _folhaTableName = '$municipio$ano$bimestre';
  }

  // Método auxiliar privado para criar uma tabela com índice e auto-incremento
  // Encapsula a lógica repetitiva
  Future<void> _createTableWithStandardFeatures(String tableName, Future<void> Function(String) createTableFunc) async {
    try {
      _logs.add('Verificando/Criando tabela: $tableName...');
      await createTableFunc(tableName);
      await ApiMySql.criaIndice(tableName);
      await ApiMySql.addAutoIncremento(tableName);
      _logs.add('Tabela $tableName configurada com sucesso.');
    } catch (e) {
      _logs.add('ERRO ao criar tabela $tableName: $e');
      // Re-lança a exceção para ser capturada pelo método build()
      throw Exception('Falha ao criar tabela padrão: $tableName. Causa: $e');
    }
  }

  // Método principal que orquestra a construção
  Future<BuildResult> build() async {
    _logs.clear();
    _logs.add('Iniciando construção da estrutura do banco de dados para $_folhaTableName...');

    try {
      // 1. Verifica se a estrutura principal já existe
      final existsResult = await ApiMySql.tabelaExiste(_folhaTableName);
      final bool tabelaFolhaExiste = existsResult.toString().contains('1');

     // if (tabelaFolhaExiste) {
       // _logs.add('A estrutura principal "$_folhaTableName" já existe. Nenhuma ação necessária.');
       // return BuildResult(success: true, logs: _logs);
     // }

      _logs.add('Estrutura principal "$_folhaTableName" não encontrada. Iniciando criação...');

      // 2. Cria a estrutura passo a passo
      await _buildFolhaTable();
      await _buildVantagensTable();
      await _buildProfessorTotalTable();
      await _buildAuxiliaresTables();
      await _buildDecenioTable();
      await _buildImpostosTable();
      await _buildTotaisTable();
      await _buildVaafTable();
      await _buildImpacto();
      await _buildPac();
      await _buildDemonReceita();

      _logs.add('Construção da estrutura concluída com sucesso!');
      return BuildResult(success: true, logs: _logs);
    } catch (e) {
      _logs.add('ERRO CRÍTICO DURANTE A CONSTRUÇÃO: $e');
      Utils.snak('Erro na Estrutura', 'Falha ao criar a estrutura do banco: $e', false, Colors.red);
      return BuildResult(success: false, logs: _logs, errorMessage: e.toString());
    }
  }

  // Métodos privados para cada passo da construção
  Future<void> _buildFolhaTable() async {
    _logs.add('Criando tabela de folha: $_folhaTableName...');
    await ApiMySql.seNaoExistirCriaTabela(_folhaTableName);
    _logs.add('Tabela de folha criada.');
  }

  Future<void> _buildVantagensTable() async {
    await _createTableWithStandardFeatures(TBVantagens, ApiMySql.seNaoExistirCriaTabelaVantagens);
    await ApiMySql.addChaveEStrangeira(TBVantagens, _folhaTableName);
    _logs.add('Chave estrangeira adicionada a $TBVantagens.');
  }

  Future<void> _buildProfessorTotalTable() async {
    await _createTableWithStandardFeatures(TBTotalProfessor, ApiMySql.seNaoExistirCriaProfessorTotal);
  }

  Future<void> _buildAuxiliaresTables() async {
    _logs.add('Criando tabelas auxiliares...');
    await ApiMySql.criaTabela(TBInfantil);
    await ApiMySql.criaTabela(TBProfessor);
    await ApiMySql.criaTabela(TBExercicio);
    await ApiMySql.criaTabela(TBReceitaFundebSimulador);
    _logs.add('Tabelas auxiliares criadas.');
  }



  Future<void> _buildDecenioTable() async {
    await _createTableWithStandardFeatures(TBDecenio, ApiMySql.seNaoExistirCriaTabelaDecenio);
    await ApiMySql.dadosDecenio(TBDecenio);
  }

  Future<void> _buildImpostosTable() async {
    await _createTableWithStandardFeatures(TBImpostos, ApiMySql.seNaoExistirCriaTabelaImpostos);
    await ApiMySql.dadosImpostos(TBImpostos);
  }

  Future<void> _buildTotaisTable() async {
    await _createTableWithStandardFeatures(TBTotais, ApiMySql.seNaoExistirCriaTabelaTotais);
    await ApiMySql.dadosTotais(TBTotais);
  }

  Future<void> _buildVaafTable() async {
    await _createTableWithStandardFeatures(TBVaaf, ApiMySql.seNaoExistirCriaTabelaVaaf);
    await ApiMySql.dadosVaaf(TBVaaf);
  }

  Future<void> _buildImpacto() async {
    await _createTableWithStandardFeatures(TBImpactoEducacao, ApiMySql.seNaoExistirCriaTabelaImpacto);
    await ApiMySql.dadosImpactoEducacaoa(TBImpactoEducacao);
  }

  Future<void> _buildPac() async {
    await _createTableWithStandardFeatures(TBPac, ApiMySql.seNaoExistirCriaTabelaPac);
    await ApiMySql.dadosPac(TBPac);
  }

  Future<void> _buildDemonReceita() async {
    await _createTableWithStandardFeatures(TBDemonReceitas, ApiMySql.seNaoExistirCriaTabelaDemonstrativoReceita);
    await ApiMySql.dadosDemostrativoReceita(TBDemonReceitas,bimestre);
  }

}
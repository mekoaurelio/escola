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

  //pra não alterar o contúdo das tabelas do sistema
  String _TBFolha = '';
  String _TBVantagens = '';
  String _TBProfessor = '';
  String _TBInfantil = '';
  String _TBReceitaFundebSimulador = '';
  String _TBExercicio = '';
  String _TBTotais = '';
  String _TBTotalProfessor='';
  String _TBDecenio='';
  String _TBImpostos='';
  String _TBVaaf='';
  String _TBDemonReceitas='';
  String _TBPac='';
  String _TBImpactoEducacao='';
  String _TBReceitasEducacionais='';

  DatabaseStructureBuilder({
    required this.municipio,
    required this.ano,
    required this.bimestre,
  }) {
    // O nome da tabela principal é construído uma vez no construtor
    _folhaTableName = '$municipio$ano$bimestre';
    _TBFolha = '${municipio}$ano$bimestre'; // Corrigi o nome da tabela aqui
    _TBVantagens = '${municipio}vantagens$ano$bimestre';
    _TBProfessor = '${municipio}professor$ano$bimestre';
    _TBInfantil = '${municipio}infantil$ano$bimestre';
    _TBReceitaFundebSimulador = '${municipio}receita_fundeb_simulador$ano$bimestre';
    _TBExercicio = '${municipio}exercicio$ano$bimestre';
    _TBTotais = '${municipio}totais$ano$bimestre';
    _TBTotalProfessor='${municipio}total_professor$ano$bimestre';
    _TBDecenio='${municipio}decenio$ano$bimestre';
    _TBImpostos='${municipio}impostos$ano$bimestre';
    _TBVaaf='${municipio}vaaf$ano$bimestre';
    _TBDemonReceitas='${municipio}demonstrativo_receita$ano$bimestre';
    _TBPac='${municipio}pac$ano$bimestre';
    _TBImpactoEducacao='${municipio}impacto_educacao$ano$bimestre';
    _TBReceitasEducacionais='${municipio}receitas_educacionais$ano$bimestre';
  }

  // Método auxiliar privado para criar uma tabela com índice e auto-incremento
  // Encapsula a lógica repetitiva
  Future<void> _createTableWithStandardFeatures(String tableName, Future<void> Function(String) createTableFunc) async {
    try {
      await createTableFunc(tableName);
    } catch (e) {
      throw Exception('Falha ao criar tabela padrão: $tableName. Causa: $e');
    }
  }

  // Método principal que orquestra a construção
  Future<BuildResult> build() async {
    try {
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
      await _buildDemonReceitasEducacionais();

      return BuildResult(success: true, logs: _logs);
    } catch (e) {
      Utils.snak('Erro na Estrutura', 'Falha ao criar a estrutura do banco: $e', false, Colors.red);
      return BuildResult(success: false, logs: _logs, errorMessage: e.toString());
    }
  }

  // Métodos privados para cada passo da construção
  Future<void> _buildFolhaTable() async {
    await ApiMySql.CriaTabelaProfessor(_folhaTableName);
  }

  Future<void> _buildVantagensTable() async {
    await _createTableWithStandardFeatures(_TBVantagens, ApiMySql.CriaTabelaVantagens);
    await ApiMySql.addChaveEStrangeiraVantagem(_TBVantagens, _folhaTableName);
  }

  Future<void> _buildProfessorTotalTable() async {
    await _createTableWithStandardFeatures(_TBTotalProfessor, ApiMySql.CriaProfessorTotal);
  }

  Future<void> _buildAuxiliaresTables() async {
    await ApiMySql.criaTabelaComuns(_TBInfantil);
    await ApiMySql.criaTabelaComuns(_TBProfessor);
    await ApiMySql.criaTabelaComuns(_TBExercicio);
    await ApiMySql.criaTabelaComuns(_TBReceitaFundebSimulador);
  }


  Future<void> _buildImpostosTable() async {
    await _createTableWithStandardFeatures(_TBImpostos, ApiMySql.CriaTabelaImpostos);
    await ApiMySql.dadosImpostos(_TBImpostos);

  }

  Future<void> _buildDecenioTable() async {
    await _createTableWithStandardFeatures(_TBDecenio, ApiMySql.CriaTabelaDecenio);
    await ApiMySql.dadosDecenio(_TBDecenio);
  }

  Future<void> _buildTotaisTable() async {
    await _createTableWithStandardFeatures(_TBTotais, ApiMySql.CriaTabelaTotais);
    await ApiMySql.dadosTotais(_TBTotais);
  }

  Future<void> _buildVaafTable() async {
    await _createTableWithStandardFeatures(_TBVaaf, ApiMySql.CriaTabelaVaaf);
    await ApiMySql.dadosVaaf(_TBVaaf);
  }

  Future<void> _buildImpacto() async {
    await _createTableWithStandardFeatures(TBImpactoEducacao, ApiMySql.CriaTabelaImpacto);
    await ApiMySql.dadosImpactoEducacaoa(_TBImpactoEducacao);
  }

  Future<void> _buildPac() async {
    await _createTableWithStandardFeatures(_TBPac, ApiMySql.CriaTabelaPac);
    await ApiMySql.dadosPac(_TBPac);
  }

  Future<void> _buildDemonReceita() async {
    await _createTableWithStandardFeatures(_TBDemonReceitas, ApiMySql.CriaTabelaDemonstrativoReceita);
    await ApiMySql.dadosDemostrativoReceita(_TBDemonReceitas,bimestre);
  }

  Future<void> _buildDemonReceitasEducacionais() async {
    await _createTableWithStandardFeatures(_TBReceitasEducacionais, ApiMySql.CriaTabelareceitasEducacionais);
    await ApiMySql.dadosReceitasEducacionais(_TBReceitasEducacionais,bimestre);
  }
}
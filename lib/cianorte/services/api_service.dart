import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://seu-servidor.com/api'; // Substitua pela sua URL

  Future<void> sendData(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/professores'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao enviar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  // Métodos adicionais para outras operações CRUD
  Future<void> createCargo(Map<String, dynamic> cargoData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cargos'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(cargoData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao criar cargo: ${response.statusCode}');
    }
  }

  Future<void> createUnidade(Map<String, dynamic> unidadeData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/unidades'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(unidadeData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao criar unidade: ${response.statusCode}');
    }
  }
}
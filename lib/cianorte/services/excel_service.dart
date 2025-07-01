import 'package:excel/excel.dart';

class ExcelService {
  Map<String, dynamic> parseRow(List<Data?> row) {
    // Mapear as colunas da planilha para os campos do banco de dados
    return {
      'tipo': row[0]?.value.toString(),
      'classe': row[1]?.value.toString(),
      'codigoevento': row[2]?.value.toString(),
      'descricaoevento': row[3]?.value.toString(),
      'recisao': row[4]?.value.toString(),
      'codigolotcao': row[5]?.value.toString(),
      'lotacao': row[6]?.value.toString(),
      'matricula': row[7]?.value.toString(),
      'nomeservidor': row[8]?.value.toString(),
      'cargo': row[9]?.value.toString(),
      'despesa': row[10]?.value.toString(),
      'descricaodespesa': row[11]?.value.toString(),
      'fonterecurso': row[12]?.value.toString(),
      'codigoprojetoatividade': row[13]?.value.toString(),
      'projetoatividade': row[14]?.value.toString(),
      'descricaoprojetoatividade': row[15]?.value.toString(),
      'codigoevent': row[16]?.value.toString(),
      'eventodescricao': row[17]?.value.toString(),
      'codigoextra': row[18]?.value.toString(),
      'descricaoextra': row[19]?.value.toString(),
      'deduzir_empenho': row[20]?.value.toString(),
      'valor': row[21]?.value.toString(),
    };
  }

  // Método para normalizar os dados antes de enviar para o banco
  Map<String, dynamic> prepareForDatabase(Map<String, dynamic> rawData) {
    return {
      'servidor': {
        'matricula': rawData['matricula'],
        'nome': rawData['nomeservidor'],
        'tipo': rawData['tipo'],
        'classe': rawData['classe'],
        'cargo': rawData['cargo'],
        'unidade': {
          'codigo_lotacao': rawData['codigolotcao'],
          'nome': rawData['lotacao'],
          'educacao_infantil': rawData['lotacao']?.toString()?.contains('Cmei') ?? false,
        }
      },
      'evento': {
        'codigo': rawData['codigoevento'],
        'descricao': rawData['descricaoevento'],
        'tipo': _determinarTipoEvento(rawData['descricaoevento']),
        'despesa_codigo': rawData['despesa'],
        'despesa_descricao': rawData['descricaodespesa'],
      },
      'lancamento': {
        'valor': double.tryParse(rawData['valor'] ?? '0') ?? 0,
        'competencia': DateTime.now().toIso8601String(), // Usar data atual ou extrair da planilha
        'recisao': rawData['recisao'] == 'S',
        'projeto_atividade': rawData['projetoatividade'],
        'descricao_projeto_atividade': rawData['descricaoprojetoatividade'],
        'codigo_extra': rawData['codigoextra'],
        'descricao_extra': rawData['descricaoextra'],
      }
    };
  }

  String _determinarTipoEvento(String? descricao) {
    if (descricao == null) return 'Informação';
    if (descricao.contains('Despesa') || descricao.contains('Desconto')) {
      return 'Desconto';
    } else if (descricao.contains('Provento') || descricao.contains('Vantagem')) {
      return 'Provento';
    } else {
      return 'Informação';
    }
  }
}
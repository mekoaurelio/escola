import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<void> fetchLrfMunicipio({
  required String tipo,        // "Municipio"
  required String municipio,   // e.g. "DOIS VIZINHOS"
  required String entidade,    // e.g. "MUNICÍPIO DE DOIS VIZINHOS"
  required String relatorio,   // "RREO - Demonstrativo..."
  required String ano,         // "2025"
  required String periodo,     // "01" (1º bimestre)
}) async {
  final baseUrl = Uri.parse('https://servicos.tce.pr.gov.br/TCEPR/Municipal/SIMAM/Paginas/Rel_LRF.aspx?relTipo=1');

  // 1️⃣ GET inicial
  final getResp = await http.get(baseUrl);
  final doc = parse(getResp.body);

  // 2️⃣ Extraia os tokens ASP.NET
  String getTok(String name) =>
      (doc.querySelector('input[name="$name"]')?.attributes['value'] ?? '');

  final viewstate = getTok('__VIEWSTATE');
  final eventValidation = getTok('__EVENTVALIDATION');
  final viewstateGen = getTok('__VIEWSTATEGENERATOR');

  // 3️⃣ Monte o form data
  final form = {
    '__VIEWSTATE': viewstate,
    '__VIEWSTATEGENERATOR': viewstateGen,
    '__EVENTVALIDATION': eventValidation,
    'ctl00$ContentPlaceHolder1$ddlTipo': tipo,
    'ctl00$ContentPlaceHolder1$ddlMunicipio': municipio,
    'ctl00$ContentPlaceHolder1$ddlEntidade': entidade,
    'ctl00$ContentPlaceHolder1$ddlRelatorio': relatorio,
    'ctl00$ContentPlaceHolder1$ddlAno': ano,
    'ctl00$ContentPlaceHolder1$ddlPeriodo': periodo,
    'ctl00$ContentPlaceHolder1$btnConsultar': 'Consultar',
  };


  // 4️⃣ Envie o POST
  final postResp = await http.post(
    baseUrl,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0',
    },
    body: form,
  );

  // 5️⃣ Parse o HTML de resposta
  if (postResp.statusCode == 200) {
    final resultDoc = parse(postResp.body);
    final table = resultDoc.querySelector('#ctl00_ContentPlaceHolder1_GridView1');
    if (table != null) {
      final rows = table.querySelectorAll('tr');
      for (var tr in rows) {
        final cols = tr.querySelectorAll('td');
        final texts = cols.map((td) => td.text.trim()).toList();
        print(texts);
      }
    } else {
      print('Tabela não encontrada');
    }
  } else {
    print('Erro no POST: ${postResp.statusCode}');
  }
}


import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../impacto/model_simula_form.dart';
import '../services/table_name_service.dart';
import '../services/utils.dart';

class Relatorio extends StatefulWidget {

  final totalFolhaDePagamento;
  final totalFolhaNovo;
  final totalVantagens;
  final totalVantagens2;
  final percVantagem;
  final percVantagem2;
  final custoTotalLiquidoCalc;
  final custoTotalLiquidoCalc2;
  final encargosPrev14PercentCalc;
  final encargosPrev14PercentCalc2;
  final decimoTerceiroProporcionalCalc;
  final decimoTerceiroProporcionalCalc2;
  final feriasProporcionalCalc;
  final feriasProporcionalCalc2;
  final totalFolhaMensalCalc;
  final totalFolhaMensalCalc2;
  final totalFolhaAnualCalc;
  final totalFolhaAnualCalc2;

  //DADOS DO EXERCÍCIO
  final receitasDeImpostos;
  final receitaDeTransferencia;
  final receitaTotalFundeb;
  final totF;
  final totF2;
  final perdaGanho;

  final List<ModelSimulaForm> simulaFormjsonList;
  const Relatorio({
    Key? key,

  required this.totalFolhaDePagamento,
    required this. totalFolhaNovo,
    required this. totalVantagens,
    required this. totalVantagens2,
    required this. percVantagem,
    required this. percVantagem2,
    required this. custoTotalLiquidoCalc,
    required this. custoTotalLiquidoCalc2,
    required this. encargosPrev14PercentCalc,
    required this. encargosPrev14PercentCalc2,
    required this. decimoTerceiroProporcionalCalc,
    required this. decimoTerceiroProporcionalCalc2,
    required this. feriasProporcionalCalc,
    required this. feriasProporcionalCalc2,
    required this. totalFolhaMensalCalc,
    required this. totalFolhaMensalCalc2,
    required this. totalFolhaAnualCalc,
    required this. totalFolhaAnualCalc2,
    required this.simulaFormjsonList,

    //DADOS DO EXERCÍCIO
    required this. receitasDeImpostos,
    required this. receitaDeTransferencia,
    //receitasDeImpostos+receitaDeTransferencia
    //receitasDeImpostos+receitaDeTransferencia
    required this. receitaTotalFundeb,
    required this. totF,
    required this. totF2,
    required this. perdaGanho,

  }) : super(key: key);

  @override
  State<Relatorio> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<Relatorio> {
  bool _isLoading=true;

  //ImpactoFinanceiroData? _impactoData;

  String vrVaaf =  '0.0';
  String vrVaar = '0.0';
  double r = 0;
  double vrI = 0;
  double d5 =  0;
  double i25 = 0;
  double vaaf = 0;
  double vaar = 0;
  String vrInput = '0.0';

  String receitaRecebida = '0';
  String receitaTotalFundeb = '0';
  String receitaTotal = '0';

  List<String> valor=[];
  List<String> valorProgressao=[];
  List<String> percentual=[];

  _getNivelValor(String idN){
    //print(idN);
    //print(widget.simulaFormjsonList[0].idForm);
    //print(widget.simulaFormjsonList[0].label);
    List<ModelSimulaForm> filteredItems = widget.simulaFormjsonList.where((item) => item.idForm.toString() == idN).toList();
    print(filteredItems);
    valor.clear();
    valorProgressao.clear();
    percentual.clear();
    filteredItems.forEach((item) {
      valorProgressao.add(item.valorProgressao.toString());
      valor.add(item.valor.toString());
      percentual.add(item.perc.toString());
    });
  }

  // Função auxiliar para construir linhas da tabela de Folha de Pagamento com 3 valores
  pw.TableRow _buildFolhaPagamentoTableRow(String description, String value1, String value2, pw.Font font, {PdfColor? value1Color, PdfColor? value2Color}) {
    return pw.TableRow(
      children: [
        pw.Expanded( // Usa Expanded para a descrição ocupar o espaço necessário
          flex: 3, // Proporção da largura da coluna
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              description,
              style: pw.TextStyle(fontSize: 11, font: font),
            ),
          ),
        ),
        pw.Expanded( // Valor 1
          flex: 2,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              value1,
              style: pw.TextStyle(fontSize: 11, font: font, color: value1Color),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ),
        pw.Expanded( // Valor 2
          flex: 2,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              value2,
              style: pw.TextStyle(fontSize: 11, font: font, color: value2Color),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

// Uma função auxiliar para as linhas de total (com negrito) para esta tabela
  pw.TableRow _buildFolhaPagamentoTotalRow(String description, String value1, String value2, pw.Font font, {PdfColor? value1Color, PdfColor? value2Color}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.blueGrey50), // Fundo leve para o total
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              description,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              value1,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font, color: value1Color),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text(
              value2,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font, color: value2Color),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

// Função auxiliar para construir linhas de dados da tabela (já modificada para textColor, se necessário)
  pw.TableRow _buildTableRow(String description, String value, pw.Font font, {PdfColor? textColor}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            description,
            style: pw.TextStyle(fontSize: 11, font: font),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, font: font, color: textColor),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

// Mantenha a _buildTotalRow inalterada
  pw.TableRow _buildTotalRow(String description, String value, pw.Font font, {bool isSubTotal = false, bool isFinalTotal = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isFinalTotal ? PdfColors.blue50 : (isSubTotal ? PdfColors.blueGrey50 : PdfColors.white),
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            description,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Função auxiliar para itens com bullet point e valor alinhado
  pw.Widget _buildBulletPointItem(String description, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 10, bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: pw.TextStyle(fontSize: 11, font: font)), // Bullet point
          pw.Expanded(
            child: pw.Text(
              description,
              style: pw.TextStyle(fontSize: 11, font: font),
            ),
          ),
          if (value.isNotEmpty) // Apenas mostra o valor se não for vazio
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, font: font),
              textAlign: pw.TextAlign.right,
            ),
        ],
      ),
    );
  }

// Função auxiliar para as linhas do "cartão" de Níveis
  pw.Widget _buildLevelRow(String level, String? percentage, String value1, String value2, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          level,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, font: font),
        ),
        pw.Expanded(
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              if (percentage != null)
                pw.Text(
                  percentage,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, font: font),
                ),
              pw.SizedBox(width: 10),
              pw.Text(
                value1,
                style: pw.TextStyle(fontSize: 11, font: font),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                value2,
                style: pw.TextStyle(fontSize: 11, font: font),
              ),
              // Não incluiremos os ícones de lápis e lixeira, como solicitado
            ],
          ),
        ),
      ],
    );
  }

  // Função para construir a seção do cargo de Professor Especialista
  pw.Widget _buildCargoProfessorSection(pw.Font ttf,var tit,var id) {
    _getNivelValor(id);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start, // Alinha os itens à esquerda
      children: [
        pw.SizedBox(height: 30),
        pw.Text(
          tit,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo,
            font: ttf,
          ),
        ),

        pw.SizedBox(height: 20),
        pw.Text(
          'Cargo permanente: piso – ${_vr(valor[0])}',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            font: ttf,
          ),
        ),
        pw.SizedBox(height: 10),

        // Lista de Níveis com Valores (usando Rows para alinhamento)
        _buildBulletPointItem('Nível A – Formação em nível superior', _vr(valor[0]), ttf),
        _buildBulletPointItem('Nível B - Pós-graduação em nível de especialização', _vr(valor[1]), ttf),
       // _buildBulletPointItem('Nível C - Pós-graduação em nível de mestrado', _vr(valor[2]), ttf),
       // _buildBulletPointItem('Nível D – Pós-graduação em nível de doutorado', _vr(valor[3]), ttf),
       // _buildBulletPointItem('Para uma jornada de 20 horas semanais.', '', ttf), // Este item não tem valor, ou pode ser um espaço
        pw.SizedBox(height: 20), // Espaço antes do "cartão"

        // O "cartão" com Níveis A, B, C, D
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(8),
            boxShadow: [
              pw.BoxShadow(
                color: PdfColors.grey300,
                blurRadius: 2,
                offset: const PdfPoint(0, 1),
              ),
            ],
          ),
          padding: const pw.EdgeInsets.all(12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildLevelRow('NIVEL A', null, _vr(valor[0]), _vr(valorProgressao[0]), ttf),
              pw.Divider(color: PdfColors.grey200),
              _buildLevelRow('NIVEL B', '${percentual[1]}%', _vr(valor[1]), _vr(valorProgressao[1]), ttf),
              pw.Divider(color: PdfColors.grey200),
              // _buildLevelRow('NIVEL C', '${percentual[2]}%', _vr(valor[2]), _vr(valorProgressao[2]), ttf),
              // pw.Divider(color: PdfColors.grey200),
              // _buildLevelRow('NIVEL D', '${percentual[3]}%', _vr(valor[3]), _vr(valorProgressao[3]), ttf),
            ],
          ),
        ),
      ],
    );
  }
  String _vr(var vr){
    return 'R\$ ${Utils.formatVr.format(double.parse(vr))}';
  }

  pw.Widget _tituloAnexo(pw.Font ttf,var tit){
    return pw.Text(
      tit,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.indigo,
        font: ttf,
      ),
    );
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();
    //final Uint8List imageBytes = (await rootBundle.load('assets/images/${_cidadeSelecionada}.png')).buffer.asUint8List();
    final Uint8List imageBytes = (await rootBundle.load('assets/images/Rio Negro.png')).buffer.asUint8List();
    //'assets/images/${_cidadeSelecionada}.png',
    final image = pw.MemoryImage(imageBytes);

    // --- Carregar a fonte aqui ---
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    // -----------------------------

    String cleanText(String text) {
      return text
          .replaceAll(RegExp(r'[\u2028\u2029\u00A0\uFFFD•\u2022\u25CF]'), ' ')
          .replaceAll('', '')
          .trim();
    }

    var text = '''Justificativa:
A Constituição Federal de 1988 determina, em seu artigo 206, inciso V, como um dos princípios da educação brasileira, a valorização dos profissionais da educação, garantindo planos de carreira para o magistério público. A Lei nº 9.394, de 20 de dezembro de 1996, denominada de Lei de Diretrizes e Bases da Educação Nacional, também obriga as administrações públicas a instituírem planos de carreira e remuneração do magistério, através de seu artigo 67:
Art. 67. Os sistemas de ensino promoverão a valorização dos profissionais da educação, assegurando-lhes, inclusive nos termos dos estatutos e dos planos de carreira do magistério público:
I – ingresso exclusivamente por concurso público de provas e títulos;
II – aperfeiçoamento profissional continuado, inclusive com licenciamento periódico remunerado para esse fim;
III – piso salarial profissional;
IV – progressão funcional baseada na titulação ou habilitação e na avaliação de desempenho;
V – período reservado a estudos, planejamento e avaliação, incluindo na carga de trabalho;
VI – condições adequadas de trabalho.
O Fundo de Manutenção e Desenvolvimento da Educação Básica e de Valorização do Magistério – FUNDEB, aprovado agora em caráter permanente pela Constituição nº 108/2020 e regulamentado pela Lei nº 14.113, de 25 de dezembro de 2020, também impões a valorização dos profissionais da educação, incluindo também os que atuam na educação infantil.
O atual plano de carreira do magistério municipal, encontra-se defasado em relação às alterações na legislação aprovada posteriormente, em especial ao Plano Nacional de Educação, ao Plano Municipal de Educação, à lei do novo Fundeb, bem como às expectativas atuais do magistério municipal, razão pela qual apresenta nova redação de seu texto.
A existência e atualização do Plano de Cargos, Carreira e Remuneração do Magistério, além de aplicar a justiça na distribuição e remuneração dos profissionais do magistério do ensino fundamental e educação infantil, de acordo com sua titulação e tempo de serviço no Município, incentivará seu aperfeiçoamento constante, pois este aperfeiçoamento e desempenho profissional vão propiciar um avanço na carreira e, consequentemente, em sua remuneração. O mais importante, porém, é o resultado de tudo isto: a valorização do profissional e a melhor qualidade do ensino.
Desta forma, a aprovação deste projeto de lei, que atualiza o plano de carreira e remuneração do magistério deste Município, além de ser uma exigência constitucional legal, é um compromisso com esses profissionais da educação que tato merecem pela importância de seu trabalho.

2. BASE LEGAL:
Constituição Federal de 1988 – Art. 206, inciso V: valorização dos profissionais da educação escolar, garantida na forma da lei, com plano de carreira para o magistério público.
Lei nº 9.394/1996 (LDB) – Art. 67: institui a obrigatoriedade de planos de carreira para o magistério da educação básica.
Emenda Constitucional nº 108/2020: amplia o financiamento da educação básica e fortalece a valorização do magistério.
Art. 212-A, XII – lei específica disporá sobre o piso salarial profissional nacional para os profissionais do magistério da educação básica pública.
Lei nº 14.113/2020: regulamenta o novo FUNDEB, exigindo a aplicação de no mínimo 70% dos recursos em remuneração dos profissionais da educação.
Lei nº 14.817/2024: diretrizes para a valorização dos profissionais da educação escolar básica pública (art. 206, V, da CF).

3. METODOLOGIA:
A proposta de adequação do PCCR foi elaborada com base em:
Utilização do Sistema GEM – Gestão da Educação Municipal, viabiliza as condições para o município pagar o piso valor abaixo do qual não pode ser fixado o vencimento inicial da carreira.
Aplicação da técnica de dispersão mínima e máxima: diferença entre o vencimento inicial e final de carreira.
Viabilizando alternativas de adequação da carreira do magistério.
Análise da legislação vigente;
Discussões com a equipe técnica da Secretaria Municipal de Educação e secretários e ou representantes da administração do município;
Reuniões com representantes do magistério;
Diagnóstico da estrutura atual do plano de carreira;
Projeção orçamentária e impactos financeiros.

4. PRINCIPAIS DIRETRIZES DO NOVO PCCR:
Estabelecimento de carreiras baseadas em mérito e formação continuada;
Criação de classes e níveis salariais justos e compatíveis com o tempo de serviço e titulação;
A análise dos dados contribuiu para a adequação do PCCR e atendimento dos preceitos legais, propiciando a efetiva valorização profissional.
Validação de periódicos processos de avaliação de desempenho;
Definição clara das atribuições e funções dos profissionais da educação.

''';

    var textAnexo8 = '''A proposta de adequação prevê o enquadramento dos profissionais do magistério nas tabelas de vencimentos.  Serão posicionados nas respectivas tabelas de vencimentos no nível correspondente à habilitação que comprovar  na data da publicação desta lei e na atual classe ao seu vencimento básico, na publicação desta lei.

''';

    var conclusao=''' A proposta de adequação representa um aumento de  495.646,32 (quatrocentos e noventa e cinco mil, seiscentos e quarenta e seis reais e trinta e dois centavos) mensal, correspondente a um aumento de 7,5%.
	A presente proposta tem como objetivo principal, atender o pagamento do piso do magistério.
	Os ocupantes do cargo que não possuem curso superior serão enquadrados nas tabelas de vencimentos, quadro em extinção, até sua conclusão em nível superior, quando serão posicionados no nível A, em classe igual ao seu atual vencimento básico.
	
\n\nCONCLUSÃO:
Para as projeções, foram consideradas as informações sobre o custo total da folha de pagamento e o quantitativo de profissionais alocados em cada nível do plano de carreira. A proposta de adequação está em conformidade com a legislação vigente, que estabelece o piso salarial nacional do magistério, e com a Lei Complementar Municipal nº ............
A estrutura da carreira proposta, contempla o equilíbrio entre a dispersão horizontal e a dispersão total, possibilitando que o plano de carreira e remuneração seja atrativo para os profissionais que desejam ingressar e que proporcione valorização no decurso do exercício profissional e que seja financeiramente viável.

As tabelas a ser aplicado para os profissionais da educação básica a partir do reajuste do Plano de Carreira e Remuneração dos profissionais da educação básica e informações complementares está contemplado no Sistema GEM – Gestão da Educação Municipal.''';

    text = cleanText(text);
    final lines = text.split('\n');

    textAnexo8 = cleanText(textAnexo8);
    final linesAnexo8 = textAnexo8.split('\n');

    conclusao = cleanText(conclusao);
    final linesConclusao = conclusao.split('\n');


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Image(image, width: 100, height: 100),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'PLANO DE CARGOS, CARREIRA E REMUNERAÇÃO DO MAGISTÉRIO',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo800,
                font: ttf, // Aplicando a fonte aqui
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 20),
          ...lines.map((line) {
            if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text(
                  line.trim(),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo,
                    font: ttf, // Aplicando a fonte aqui
                  ),
                ),
              );
            } else {
              return pw.Text(
                line,
                style: pw.TextStyle(fontSize: 11, height: 1.3, font: ttf), // Aplicando a fonte aqui
                textAlign: pw.TextAlign.justify,
              );
            }
          }).toList(),

          pw.SizedBox(height: 20), // Um pouco de espaço antes da tabela

          //5. ANEXO I **************************
          _tituloAnexo(ttf, '5. ANEXO I – Projeção das Receitas do FUNDEB.'),
          pw.SizedBox(height: 10), // Espaço entre o título e a tabela

          // Tabela de Receitas
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueGrey100), // Borda da tabela
            columnWidths: { // Definindo a largura das colunas
              0: pw.FlexColumnWidth(3), // Coluna de Descrição mais larga
              1: pw.FlexColumnWidth(1.5), // Coluna de Valor
            },
            children: [
              // Cabeçalho da tabela
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Receita/Complementação',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Valor',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Linhas de dados
              _buildTableRow('1. Receitas recebidas do FUNDEB', Utils.formatVr.format(double.parse(receitaRecebida)), ttf),
              _buildTableRow('1.1. Complementação da UNIÃO - FUNDEB - VAAF - 10%', Utils.formatVr.format(double.parse(vrVaaf)), ttf),
              _buildTableRow('1.2. Complementação da UNIÃO - FUNDEB - VAAT - 10,5%', Utils.formatVr.format(double.parse(vrInput)), ttf),
              _buildTableRow('1.3. Complementação da UNIÃO - FUNDEB - VAAR - 2,5%', Utils.formatVr.format(double.parse(vrVaar)), ttf),
              _buildTotalRow('Receita Total - FUNDEB', Utils.formatVr.format(double.parse(receitaTotalFundeb)), ttf, isSubTotal: true),

              // Linha vazia para separar visualmente
              pw.TableRow(children: [pw.SizedBox(height: 5), pw.SizedBox(height: 5)]),

              _buildTableRow('2. Receitas recursos próprios 5%', Utils.formatVr.format(d5), ttf),
              _buildTableRow('3. Receitas recursos próprios 25%', Utils.formatVr.format(i25), ttf),
              _buildTotalRow('Receita Total', Utils.formatVr.format(double.parse(receitaTotal)), ttf, isFinalTotal: true),

            ],
          ),
          pw.SizedBox(height: 30),

          // ANEXO II *********************
          _tituloAnexo(ttf, '6. ANEXO II – Despesas com os profissionais do magistério, Fonte FUNDEB-70%'),
          pw.SizedBox(height: 10),

          // Segunda Tabela de Despesas
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueGrey100),
            columnWidths: {
              0: pw.FlexColumnWidth(3), // Coluna de Descrição mais larga
              1: pw.FlexColumnWidth(1.5), // Coluna de Valor
            },
            children: [
              // Cabeçalho da tabela (reutiliza o mesmo estilo)
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Receita/Complementação', // O título da coluna na imagem é o mesmo
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Valor',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Linhas de dados da segunda tabela
              _buildTableRow('1. Valor da folha de vencimentos básicos - Mensal - R/\$', Utils.formatVr.format(widget.totalFolhaDePagamento), ttf),
              _buildTableRow('2. Valor das vantagens pecuniárias - Mensal - R/\$', Utils.formatVr.format(widget.totalVantagens), ttf, textColor: PdfColors.red700), // Com texto vermelho
              _buildTableRow('3. Percentual das vantagens pecuniárias sobre a folha de vencimento', '44.41%', ttf),
              _buildTotalRow('4. Custo total da folha de pagamento líquida mensal', Utils.formatVr.format(widget.custoTotalLiquidoCalc), ttf, isSubTotal: true),
              _buildTableRow('5. Encargos previdenciários', '14%', ttf),
              _buildTableRow('6. Encargos previdenciários (14%)', Utils.formatVr.format(widget.encargosPrev14PercentCalc), ttf),
              _buildTableRow('7. Valor do décimo terceiro 1/12', Utils.formatVr.format(widget.decimoTerceiroProporcionalCalc), ttf),
              _buildTableRow('8. Valor 1/3 férias (proporcional)', Utils.formatVr.format(widget.feriasProporcionalCalc), ttf),
              _buildTotalRow('9. Total folha mensal', Utils.formatVr.format(widget.totalFolhaMensalCalc), ttf, isSubTotal: true),
              _buildTotalRow('10. Total folha bruta anual', Utils.formatVr.format(widget.totalFolhaAnualCalc), ttf, isFinalTotal: true),
            ],
          ),
          // ... seu código da segunda tabela ...

          // Espaço entre as seções
          pw.SizedBox(height: 30),

          _tituloAnexo(ttf, '7. ANEXO II – Estrutura da carreira dos profissionais do magistério'),

          pw.SizedBox(height: 10),
          //_buildCargoProfessorSection(ttf,'7.1. Cargo de professor – 20 horas/semanais','3'),
          //_buildCargoProfessorSection(ttf,'7.2. Cargo - Professor Especialista – 20 horas/semanais','4'),
          //_buildCargoProfessorSection(ttf,'7.3. Cargo - Educador Infantil – 30 horas/semanais','5'),
          //_buildCargoProfessorSection(ttf,'7.4. Cargo - Educador Infantil – 40 horas/semanais','6'),

          _buildCargoProfessorSection(ttf,'7.1. Cargo de professor – 20 horas/semanais','4'),
          _buildCargoProfessorSection(ttf,'7.2. PROF. ED. INFANTIL – 20 horas/semanais','5'),

          pw.SizedBox(height: 30),

          _tituloAnexo(ttf,'8. ANEXO V - IMPACTO FINANCEIRO'),

          pw.SizedBox(height: 20),

          ...linesAnexo8.map((line) {
            if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text(
                  line.trim(),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo,
                    font: ttf, // Aplicando a fonte aqui
                  ),
                ),
              );
            } else {
              return pw.Text(
                line,
                style: pw.TextStyle(fontSize: 11, height: 1.3, font: ttf), // Aplicando a fonte aqui
                textAlign: pw.TextAlign.justify,
              );
            }
          }).toList(),

          pw.SizedBox(height: 30), // Espaço antes da nova tabela

          // Tabela de Dados da Folha de Pagamento
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blueGrey100),
            columnWidths: {
              0: pw.FlexColumnWidth(3),    // Descrição
              1: pw.FlexColumnWidth(1.5),  // Valor 1
              2: pw.FlexColumnWidth(1.5),  // Valor 2
            },
            children: [
              // Cabeçalho unificado para a tabela
              /*
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue800), // Cor de fundo do cabeçalho
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'Dados da Folha de Pagamento : usando 15 classes e 2.80 de progressão',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.white, // Texto branco no cabeçalho
                          font: ttf,
                        ),
                      ),
                    ),
                  ),


                ],
              ),

               */


              // Sub-cabeçalho (vazio para alinhamento com a imagem)
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.blue100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Receita/Complementação', // Reutilizando para manter o layout visual da imagem
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Valor', // Coluna vazia para o alinhamento
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Proposta', // Coluna vazia para o alinhamento
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Linhas de dados
              _buildFolhaPagamentoTableRow('1. Valor da folha de vencimentos básicos - Mensal - R/\$', Utils.formatVr.format(widget.totalFolhaDePagamento), Utils.formatVr.format(widget.totalFolhaNovo), ttf),
              _buildFolhaPagamentoTableRow('2. Valor das vantagens pecuniárias - Mensal - R/\$', Utils.formatVr.format(widget.totalVantagens), Utils.formatVr.format(widget.totalVantagens2), ttf, value1Color: PdfColors.red700, value2Color: PdfColors.red700),
              _buildFolhaPagamentoTableRow('3. Percentual das vantagens pecuniárias sobre a folha de vencimento', Utils.formatVr.format(widget.percVantagem), Utils.formatVr.format(widget.percVantagem2), ttf),
              _buildFolhaPagamentoTotalRow('4. Custo total da folha de pagamento líquida mensal', Utils.formatVr.format(widget.custoTotalLiquidoCalc), Utils.formatVr.format(widget.custoTotalLiquidoCalc2), ttf),
              _buildFolhaPagamentoTableRow('5. Encargos previdenciários', '14%', '14%', ttf),
              _buildFolhaPagamentoTableRow('6. Encargos previdenciários (14%)', Utils.formatVr.format(widget.encargosPrev14PercentCalc), Utils.formatVr.format(widget.encargosPrev14PercentCalc2), ttf),
              _buildFolhaPagamentoTableRow('7. Valor do décimo terceiro 1/12', Utils.formatVr.format(widget.feriasProporcionalCalc), Utils.formatVr.format(widget.feriasProporcionalCalc2), ttf),
              _buildFolhaPagamentoTableRow('8. Valor 1/3 férias (proporcional)', Utils.formatVr.format(widget.decimoTerceiroProporcionalCalc), Utils.formatVr.format(widget.decimoTerceiroProporcionalCalc2), ttf),
              _buildFolhaPagamentoTotalRow('9. Total folha mensal', Utils.formatVr.format(widget.totalFolhaMensalCalc), Utils.formatVr.format(widget.totalFolhaMensalCalc), ttf),
              _buildFolhaPagamentoTotalRow('10. Total folha bruta anual', Utils.formatVr.format(widget.totalFolhaAnualCalc), Utils.formatVr.format(widget.totalFolhaAnualCalc2), ttf),
            ],
          ),

          pw.SizedBox(height: 30),
          /*
          ...linesConclusao.map((line) {
            if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text(
                  line.trim(),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo,
                    font: ttf, // Aplicando a fonte aqui
                  ),
                ),
              );
            } else {
              return pw.Text(
                line,
                style: pw.TextStyle(fontSize: 11, height: 1.3, font: ttf), // Aplicando a fonte aqui
                textAlign: pw.TextAlign.justify,
              );
            }
          }).toList(),

           */
          // ... (seu código antes deste bloco) ...

          ...linesConclusao.map((line) {
            final cleanedLine = line.trim();

            // Adicione esta condição para a palavra "CONCLUSÃO:"
            if (cleanedLine.startsWith('CONCLUSÃO:')) {
              return pw.Column( // Usa Column para poder adicionar SizedBox antes do Text
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 15), // Adiciona um espaço de 15pt antes de "CONCLUSÃO:"
                  pw.Text(
                    cleanedLine,
                    style: pw.TextStyle(
                      fontSize: 13, // Ajuste o tamanho da fonte conforme a imagem
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                      // Removido PdfColors.indigo, pois na imagem parece ser preto
                    ),
                  ),
                  pw.SizedBox(height: 10),

                ],
              );
            }
            // Mantenha sua lógica existente para linhas numeradas
            else if (RegExp(r'^\d+\.').hasMatch(cleanedLine)) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text(
                  cleanedLine,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo,
                    font: ttf,
                  ),
                ),
              );
            }
            // E para as demais linhas de texto
            else {
              return pw.Text(
                cleanedLine,
                style: pw.TextStyle(fontSize: 11, height: 1.3, font: ttf),
                textAlign: pw.TextAlign.justify,
              );
            }
          }).toList(),

// ... o restante do seu código (footer, etc.) ...
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "© ${DateTime.now().year} GEM Analytics - Relatório Confidencial",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                "Página ${context.pageNumber} de ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'pccr.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData()async{

    var totais = await ApiMySql.get(TBTotais, null, null).timeout(const Duration(seconds: 30));

    vrVaaf = totais[0]['vaaf'] ?? '0.0';
    vrVaar = totais[0]['vaar'] ?? '0.0';
    r = double.tryParse(totais[0]['receita']?.toString() ?? '0.0') ?? 0.0; //1
    vrI = double.tryParse(totais[0]['fundeb_10_5']?.toString() ?? '0.0') ?? 0.0; //1.2
    d5 = double.tryParse(totais[0]['decendio_5']?.toString() ?? '0.0') ?? 0.0;
    i25 = double.tryParse(totais[0]['imposto_25']?.toString() ?? '0.0') ?? 0.0;
    vaaf = double.tryParse(totais[0]['vaaf']?.toString() ?? '0.0') ?? 0.0;
    vaar = double.tryParse(totais[0]['vaar']?.toString() ?? '0.0') ?? 0.0;
    vrInput = totais[0]['fundeb_10_5'] ?? '0.0';

     receitaRecebida = totais[0]['receita'] ?? '0.0';

    receitaTotalFundeb = (vrI + r + vaaf + vaar).toString();
    receitaTotal = (vrI + r + d5 + i25).toString();
    setState(() {
      _isLoading=false;
    });
  }

  volta(){
    print('kkkkkk');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator()):
      Column(
        children: [
          const SizedBox(height: 16),
        ElevatedButton(
        onPressed: generatePdf,
        child: const Text('Gerar PDF e baixar'),
      ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: volta,
            child: const Text('Voltar'),
          )
        ],
      );

  }
}


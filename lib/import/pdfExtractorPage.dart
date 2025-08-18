import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:GEM/services/table_name_service.dart';

import '../data/api_my_sql.dart';
import '../services/screenSize.dart';
import '../services/utils.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';
import '../widgets/vantagens.dart';

class PdfExtractorPage extends StatefulWidget {
  const PdfExtractorPage();
  @override
  State<PdfExtractorPage> createState() => _PdfExtractorPageState();
}

class _PdfExtractorPageState extends State<PdfExtractorPage> {
  double progress = 0;
  String status = '';
  final ValueNotifier<double> progresso = ValueNotifier<double>(0.0);

  List<dynamic> lista = [];
  int currentPage = 1;
  int pageSize = 10;

  /// === UPLOAD + EXTRAÇÃO ===
  Future<void> selecionarEEnviarArquivo() async {
    ///CRIA A ESTRUTURA DAS TABELAS
    //await criaStruturaDasTabelas();
    setState(() =>  status = 'Criando a estrutura das tabelas');
    setState(() =>  status = 'Fazendo upLoad do arquivo');

    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      reader.onLoadEnd.listen((e) async {
        final data = reader.result as Uint8List;
        ///FAZ O UPLOAD DO ARQUIVO E INICIA A EXTRAÇÃO
        await uploadFile(file.name, data);
      });
    });



  }

  Future<void> insereDadosIniciais(String tb)async{
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Piso Incial', 0,10,0 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre Classes',010,0,1 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre níveis A-MAG.',0,10,2 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre Níveis B - PISO SUP.', 0,10,3)");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre Níveis NB e NC', 0,10,4 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre Níveis NC e NDl', 0,10,5 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Progressão entre Níveis ND e NE', 0,10,6 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('Encargos Sociais - Estatutário', 14,10,7 )");
  }

  Future<void> insereReceitaFundebSimulador(String tb)async{
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2020', 0,10,1 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2021', 0,10,2 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2022', 0,10,3 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2023', 0,10,4 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2024', 0,10,5 )");
    ApiMySql.executaSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FUNDEB - 2025 - ESTIMATIVA', 0,10,6 )");
  }

  Future<void> insereExercicio(String tb)async {
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('xxx', 0,0,0 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2020', 2,10,1 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2021', 0,10,3 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2022', 10,10,4 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2023', 10,10,5 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2024', 10,10,6 )");
    ApiMySql.insereSql("insert INTO $tb (descricao,percentual,valor,ordem) values('FOLHA FUNDEB 60% - 2025 - ESTIMATIVA ', 80,10,7 )");

  }

  Future<void> insereReceitaFundeb(String tb)async{
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2020,18469352.07,0)");
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2021,10,0)");
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2022,10,0)");
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2023',10,0)");
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2024,10,0)");
    ApiMySql.insereSql("insert INTO $tb (ano,valor,percentual_crescimento) values(2025,10,0)");
  }

  Future<void> uploadFile(String fileName, Uint8List fileBytes) async {
    setState(() {
      progress = 0.0;
      status = 'Enviando arquivo...';
    });

    final uri = Uri.parse('https://www.xmktech.net/dados/upload_pdf.php');
    //final uri = Uri.parse('https://importacao-contracheques.onrender.com/imports');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse('application/pdf'),
    ));

    final streamedResponse = await request.send();
    streamedResponse.stream.listen(
          (value) {
        setState(() {
          progress += value.length / streamedResponse.contentLength!;
          if (progress > 1) progress = 1;
        });
      },
      onDone: () async {
        if (streamedResponse.statusCode == 200) {
          setState(() => status = 'Extraindo dados...');
          await iniciaExtracao();
        } else {
          Utils.snak('Atenção', 'Erro ao extrair dados. Tente novamente', false, Colors.red);
          setState(() => status = 'Extraindo dados...');
        }
      },
      onError: (e) {
        Utils.snak('Atenção', 'Erro ao extrair dados. Tente novamente $e', false, Colors.red);
        setState(() => status = 'Erro no upload ❌');
      },
      cancelOnError: true,
    );
  }

  /// === EXTRAÇÃO + CARREGAMENTO ===
  Future<void> iniciaExtracao() async {
    setState(() =>  status = 'Limpando o Banco de Dados...');
   // Utils.limpaBanco();///NÃO DELETE AS TABELAS APENAS OS DADOS
    setState(() =>  status = 'Processando PDF...');
    final dados = await ApiMySql.fetchPdfText();
    setState(() =>  status = 'Extraindo os dados da folha...');
    processPdfText(dados);
    setState(() =>  status = 'Carregando os dados...');
    await carregarFolha();
  }

  void processPdfText(String rawText) async {
    final lines = rawText.split(RegExp(r'\r?\n'));
    final totalLines = lines.length;
    int processed = 0;
    int index=0;
    // 2. Percorre cada linha, ignorando vazias
    var matricula;
    var nome;
    var cpf;
    var unidade;
    var local;
    var cargo;
    var nivel;
    var admissao;
    var idProf;
    final List<Map<String, String>> vantagens = [];
    ///INSERE TODOS OS PROFESSORES
    for (var line in lines) {
      line = line.trim();
      processed++;
      /// Atualiza progresso
      progresso.value = processed / totalLines;
      if (line.isEmpty || line.startsWith('Cabeçalho')) continue;

      if (line.startsWith('RESUMO ANALÍTICO') || line.startsWith('Competência:')|| line.startsWith('Equiplano')) {
        continue;
      }

      // Detecta cabeçalhos:
      if (line.startsWith('Local:') || line.startsWith('Cargo:') || line.startsWith('Admissão:') || line.startsWith('Nível:') ) {
        continue;
      }

      if (line.contains('Vantagens	Descontos') ) {
        continue;
      }

      // Detecta bloco de “Unidade”
      if (line.startsWith('Unidade:')) {
        final parts = line.split(RegExp(r'\s+'));
        continue;
      }

      // Detecta sumário de Vantagens/Descontos/Líquido/FGTS
      if (line.startsWith('Vantagens:') && line.contains('Descontos:')) {
        final vant = RegExp(r'Vantagens:\s*([\d\.,]+)').firstMatch(line)?.group(1);
        final desc = RegExp(r'Descontos:\s*([\d\.,]+)').firstMatch(line)?.group(1);
        final liq  = RegExp(r'Líquido:\s*([\d\.,]+)').firstMatch(line)?.group(1);
        final fgts = RegExp(r'FGTS:\s*([\d\.,]+)').firstMatch(line)?.group(1);
        // print('Sumário → Vant: $vant, Desc: $desc, Liq: $liq, FGTS: $fgts');
        continue;
      }

      ///CARGO E NÍVEL
      if(index==1){
        String result=parseLine(line);
        if(result!='' && result!=null) {
          var x = result.split('*');
          cargo = x[0];
          nivel = x[1];
        }
      }
      ///UNIDADE E LOCAL
      if(index==2){
        String result=parseLine(line);
        if(result!='' && result!=null) {
          var x = result.split('*');
          unidade = x[0];
          local = x[1];
        }
      }
      if(index==2) {
        if (line.contains('/')) {
          admissao = line;
        }
      }

      if (line.startsWith('Matrícula') ) {
        // print('NOVO REGISTRO');
        //totReg++;
        index=0;
        ///GRAVA UM NOVO REGISTRO
        final regex = RegExp(r'''Matrícula:\s*(\d+)\s+(.+?)\s+CPF:\s*([\d\.\-]+)''');
        final match = regex.firstMatch(line);
        if (match != null) {
          matricula = match.group(1);
          nome      = match.group(2);
          cpf       = match.group(3);

         ///PEGA O VENCIMENTO
         var vencimento;
          for (var v in vantagens) {
            vencimento=v['valor']!;
            break;
          }

          idProf=await ApiMySql.insertProf(matricula, nome, cpf, unidade, local, cargo, nivel, admissao,vencimento);

          if(idProf.toString().contains('ERRO')){
            //totERrr++;
          }else {
            ///insere as vantagens
            for (var v in vantagens) {
              // supondo que você tenha idProf já definido
              await ApiMySql.insertVantagens(matricula, v['codigo'], v['descricao'], v['valor'],v['percentual']!);
            }

          }
          vantagens.clear();
        }
        continue;
      }

      final patternCodigo = RegExp(r'^(\d{5})');
      final patternValor = RegExp(r'\d{1,3}(?:\.\d{3})*,\d{2}');

      line = line.trim();
      final mCod = patternCodigo.firstMatch(line);
      if (mCod != null) { // não é linha de detalhe

        final codigo = mCod!.group(1)!; // ex: "21003"

        if (codigo.startsWith('21')) {
          // encontra todas as ocorrências de números no formato "1.234,56" ou "12,34"
          //print('VANTAGENS $line');
          final detalhe = RegExp(r'^(\d{5})(.+?)\s+([\d\.,]+)').firstMatch(line);
          final cdsimples = detalhe!.group(1)!;
          final descsimples = detalhe!.group(2)!;
          final vrsimples = detalhe!.group(3)!;

          //print('VANTAGENS SIMPLES  $cdsimples $descsimples $vrsimples');

          final allValores = patternValor.allMatches(line).toList();
          if (allValores.isEmpty) continue; // sem valor encontrado


          // último match é o valor correto
          final lastMatch = allValores.last;
          var valorStr = lastMatch.group(0)!; // ex: "4.330,91"

          // descrição: entre o fim do código e o início desse valor
          final descStart = mCod.end;
          final descEnd = lastMatch.start;

          //print('linha');
          //print(line);

          ///VERIFICA SE O PERCENTUAL ESTÁ NO FIM DA FRASE
          var perInt=line.indexOf('%');
          perInt++;
          String? percentualNoFim='0';
          if(perInt==line.length){
            final regex = RegExp(r'(\d+,\d+)%');
            final match = regex.firstMatch(line);
            percentualNoFim = match?.group(1);
            percentualNoFim=percentualNoFim!.substring(2,percentualNoFim!.length);

          //  print('PERCENTUAL NO FIM DA FRASE =>$percentualNoFim');
          }

          var descricao = line.substring(descStart, descEnd).trim();

          final regex = RegExp(r'\d+\.?\d*%'); // Encontra qualquer número seguido de %

          final matches = regex.allMatches(line); // Encontra todas as ocorrências
          var percentual='0';
          if(percentualNoFim=='0') {
            if (matches.isNotEmpty) {
              for (final match in matches) {
                final percen = match.group(
                    0); // Obtém o valor encontrado (ex: "25%")
                percentual = percen!;
              }
            } else {
              //print("Nenhum percentual encontrado.");
            }
          }else{
            percentual=percentualNoFim;
          }

          if(codigo=='21019'){
            int pos=descricao.indexOf('-');
            var des=descricao.substring(0,pos);
            var vr =descricao.substring(pos,descricao.length);
            valorStr=vr;
            descricao=des;
          }else {
            descricao = descricao.replaceAll(RegExp(r'[-\s]+$'), '');
          }

          // agora posso salvar:
          vantagens.add({
            'codigo': codigo,
            'descricao': descricao,
            'valor': valorStr,
            'percentual': percentual,
          });
          continue;
        }
      }
      index++;
    }
/*
    setState(() => status = 'Inserindo Exercícios');
    await insereExercicio(TBExercicio);

    setState(() => status = 'Inserindo Infantil');
    await insereDadosIniciais(TBInfantil);

    setState(() => status = 'Inserindo Professor');
    await insereDadosIniciais(TBProfessor);

    setState(() => status = 'Inserindo Receita FUNDEB Simuulador');
    await insereReceitaFundebSimulador(TBReceitaFundebSimulador);

    await carregarFolha();
    setState(() => status = 'Dados carregados!');
    Utils.snak('Parabéns', 'Dados extraidos com sucesso', false, Colors.green);

 */

  }

  Future<void> carregarFolha() async {
    lista = await ApiMySql.getProfessor();
  }

  parseLine(String line) {
    try{
      final regex = RegExp(r'^([^\t]+)\t+(.+)$');
      final match = regex.firstMatch(line);
      if (match != null) {
        final primeiraParte = match.group(1)!.trim();
        final segundaParte = match.group(2)!.trim();
        return '$primeiraParte*$segundaParte';
      }else{
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  /// === UI ===
  List<dynamic> get currentItems {
    final start = (currentPage - 1) * pageSize;
    final end = start + pageSize;
    return lista.sublist(start, end > lista.length ? lista.length : end);
  }

  Widget cabecalho() {
    return Card(
        color: Colors.grey.shade300,
        elevation: 0,
        shape: Utils.borda(),
        child: Row(
          children: [
            // SizedBox(width: 15,),
            Line(tex: 'Matrícula', tam: 70, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,),
            SizedBox(width: 5,),
            Line(tex: 'CPF', tam: 100, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Professor', tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Unidade', tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Local', tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Cargo', tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Nível', tam: 30, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
            Line(tex: 'Admissão', tam: 70, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (lista.length / pageSize).ceil();
    final screenSizeConfig = ScreenSizeConfig(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Selecionar PDF e Carregar folha'),
              //onPressed: () {
                //Utils.snak('Atenção','Mometaneamente desativada',false,Colors.red);
              //},
              onPressed: selecionarEEnviarArquivo, //iniciaExtracao
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<double>(
              valueListenable: progresso,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                );
              },
            ),
            const SizedBox(height: 10),
            Text(status),
            const SizedBox(height: 20),
            lista.isEmpty
                ? const Text('')
                : Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];

                        // String dateString=Utils.dtMySql(item['admissao'],'yyyy/mm/dd');
                         DateTime parsedDate = Utils.parseDate(item['admissao']);
                         int yearsDifference = Utils.calculateYearsDifference(parsedDate);

                        return Column(
                          children: [
                            cabecalho(),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Line(tex: item['matricula'], tam: 70, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 14,),
                                SizedBox(width: 5,),
                                Line(tex: item['cpf'], tam: 100, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
                                Line(tex: item['nome'], tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 14,),
                                Line(tex: item['cargo'], tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
                                Line(tex: item['local_lotacao'], tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
                                Line(tex: item['unidade'], tam: 200, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
                                Line(tex: item['nivel'], tam: 30, alin: Alignment.centerLeft,cor: Colors.black,negrito: true),
                                Line(tex: item['admissao']+' $yearsDifference anos', tam: 90, alin: Alignment.centerLeft
                                    ,cor: Colors.black,negrito: true,fontSize: 9,),
                              ],
                            ),
                            SizedBox(height: 5,),
                            VantagensList(
                              vantagensDetalhadas: item['vantagens_detalhadas'] ?? '',
                            ),
                            Row(
                              children: [
                                Line(tex: 'Total de Vantagens', tam: 200, alin: Alignment.centerLeft,cor: Colors.blue,negrito: true,),
                                Line(tex: Utils.formatVr.format(double.parse(item['soma_vantagens'])), tam: 300, alin: Alignment.centerRight,cor: Colors.blue,negrito: true,),

                              ],
                            ),
                            SizedBox(height: 10,)
                           ],
                        );
                      },
                    ),
                  ),
                  PaginationFooter(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalItems: lista.length,
                    onPageChanged: (newPage) {
                      // A lógica de atualização do estado permanece no widget pai.
                      setState(() => currentPage = newPage);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

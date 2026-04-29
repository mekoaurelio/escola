
import 'dart:convert';

import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
import '../folha/professor_utils.dart';
import '../relatorios/relatorio.dart';
import '../services/calc_dispersao_valores.dart';
import '../services/utils.dart';
import '../services/valor_input_formatter.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/texto.dart';
import 'model_salarios.dart';
import 'model_simula_form.dart';

class Impacto extends StatefulWidget {
  const Impacto({super.key});

  @override
  State<Impacto> createState() => _ImpactoScreenState();

}
class _ImpactoScreenState extends State<Impacto> {
  final progressaoController = TextEditingController();
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '');
  bool _isloading=true;
  //DADOS DA FOLHA
  double totalFolhaDePagamento=0;
  double totalFolhaNovo=0;
  double totalVantagens=0;
  double percVantagem=0;
  double custoTotalLiquidoCalc=0;
  double encargosPrev14PercentCalc=0;
  double decimoTerceiroProporcionalCalc=0;
  double feriasProporcionalCalc=0;
  double totalFolhaMensalCalc=0;
  double totalFolhaAnualCalc=0;
  double percAumento=0;

  double totalFolha2=0;
  double totalVantagens2=0;
  double percVantagem2=0;
  double custoTotalLiquidoCalc2=0;
  double encargosPrev14PercentCalc2=0;
  double decimoTerceiroProporcionalCalc2=0;
  double feriasProporcionalCalc2=0;
  double totalFolhaMensalCalc2=0;
  double totalFolhaAnualCalc2=0;

  List<ModelSalario> professores=[];
  var professores2;
  List<String> novosNiveis=[];
  List<String> valorNivel=[];

  //DADOS DO EXERCICIO
  double receitasDeImpostos=0;
  double receitaDeTransferencia=0;
  double receitaTotalFundeb=0;
  double perdaGanho=0;
  double totF=0;
  double totF2=0;

  var cab;
  List<dynamic> resultado=[];
  List<dynamic> simulaForm=[];
  List<ModelSimulaForm> simulaFormjsonList=[];
  List<ModelSalario> salariosjsonList=[];

  String tit='Dados da Folha de Pagamento : usando 15 classes e 2.80 de progressão';

  @override
  void initState() {
    super.initState();
    start();
  }

  start()async{
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    await _carregarSoUmavez();
    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    _carregarDados();
  }

  Future<void> _carregarSoUmavez() async {
    print('carrga só uma vez');
    cab=await ApiMySql.executaSql('select * from $TBSimulaCab').timeout(const Duration(seconds: 30));
    //PEGA OS VALORES SIMULAFORM
    var x=await ApiMySql.executaSql('select id,id_form,nivel,label,tipo,valor,valor_progressao,perc from $TBSimulaForm').timeout(const Duration(seconds: 30));
    var str=fixJsonString(x.toString());
    List<dynamic> jsonList = jsonDecode(str);

    var sqlS = """SELECT DISTINCT 
   f.nome,
    f.vencimento,
    f.horas,
    f.nivel,
    GROUP_CONCAT(CONCAT(dv.codigo, ':', dv.descricao, ':', dv.percentual, ':', dv.valor) SEPARATOR ' | ') AS vantagens_detalhadas,
    SUM(dv.valor) AS soma_vantagens,
    SUM(dv.valor) AS soma_apts,
    (SELECT SUM(vencimento) FROM $TBFolha WHERE status = 'A') AS total_vencimentos_geral
    FROM $TBFolha f
    LEFT JOIN $TBVantagens dv ON f.matricula = dv.folha_id
    WHERE f.status = 'A' 
    GROUP BY f.matricula
    ORDER BY f.matricula""";

    var getVr=await ApiMySql.executaSql(sqlS).timeout(const Duration(seconds: 30));
    var strVr=fixSal(getVr.toString());
    List<dynamic> jsonListVr = jsonDecode(strVr.toString());


    String sql = """
SELECT 
    (SELECT SUM(valor) FROM $TBVantagens) as totVan,
    (SELECT SUM(vr12) FROM $TBImpostos) as totImp,
    (SELECT SUM(vr12) FROM $TBDecenio) as totImp2,
    (SELECT SUM(vr1) FROM $TBDecenio) as totImp3,
    t.* FROM $TBTotais t
""";
    resultado = await ApiMySql.executaSql(sql);
    setState(() {
      simulaFormjsonList = jsonList.map((json) => ModelSimulaForm.fromJson(json)).toList();

      salariosjsonList = jsonListVr.map((json) => ModelSalario.fromJson(json)).toList();
      percAumento=double.parse(resultado[0]['perc_aumento_adulto']);
      progressaoController.text=percAumento.toString();
    });
  }

  String fixSal(String original){

  String fixed = original.replaceAll('null', '0');

  fixed = fixed
      .replaceAll('{nome:', '{"nome":')
      .replaceAll('vencimento:', '"vencimento":')
      .replaceAll(', horas:', ', "horas":')
      .replaceAll(', nivel:', ', "nivel":')
      .replaceAll(', vantagens_detalhadas:', ', "vantagens_detalhadas":')
      .replaceAll(', soma_vantagens:', ', "soma_vantagens":')
      .replaceAll(', soma_apts:', ', "soma_apts":')
      .replaceAll(', total_vencimentos_geral:', ', "total_vencimentos_geral":');

  fixed = fixed.replaceAllMapped(
      RegExp(r'"nome": ([^,]+),'),
          (match) => '"nome": "${match.group(1)}",'
  );

  fixed = fixed.replaceAllMapped(
      RegExp(r'"horas": ([^,]+),'),
          (match) => '"horas": "${match.group(1)}",'
  );

  fixed = fixed.replaceAllMapped(
      RegExp(r'"nivel": ([^,]+),'),
          (match) => '"nivel": "${match.group(1)}",'
  );

  fixed = fixed.replaceAllMapped(
      RegExp(r'"vantagens_detalhadas": ([^,]+),'),
          (match) => '"vantagens_detalhadas": "${match.group(1)}",'
  );
  return fixed;
  }

  String fixJsonString(String original) {
    String fixed = original;

    // PRIMEIRO: Corrigir as CHAVES (adicionar aspas nas chaves)
    fixed = fixed
        .replaceAll('{id:', '{"id":')
        .replaceAll(', id_form:', ', "id_form":')
        .replaceAll(', nivel:', ', "nivel":')
        .replaceAll(', label:', ', "label":')
        .replaceAll(', tipo:', ', "tipo":')
        .replaceAll(', valor:', ', "valor":')
        .replaceAll(', valor_progressao:', ', "valor_progressao":')
        .replaceAll(', perc:', ', "perc":');

    fixed = fixed.replaceAllMapped(
        RegExp(r'"nivel": (\w)'),
            (match) => '"nivel": "${match.group(1)}"'
    );

    // Corrigir label (NIVEL A, NIVEL B, etc.)
    fixed = fixed.replaceAllMapped(
        RegExp(r'"label": ([^,]+),'),
            (match) => '"label": "${match.group(1)}",'
    );

    // Corrigir tipo
    fixed = fixed.replaceAll('TipoItem.progressao', '"TipoItem.progressao"');

    // Corrigir created_at (datas)
    fixed = fixed.replaceAllMapped(
        RegExp(r'"created_at": ([^,]+),'),
            (match) => '"created_at": "${match.group(1)}",'
    );
    fixed = fixed.replaceAllMapped(
        RegExp(r'"created_at": ([^}]+)}'),
            (match) => '"created_at": "${match.group(1)}"}'
    );

    return fixed;
  }

  Future<void> _carregarDados() async {
    try {
      //PASSE UMA PROGRESSAO
      await _progressao(5.40);//2.8

      double totalFolha=await _totalFolha(5.40);//2.80
      setState(() {
        //DADOS DA FOLHA
        totalFolhaDePagamento=totalFolha ;//1
        totalVantagens=double.parse(resultado[0]['totVan']) ;//2
        percVantagem =(totalVantagens/totalFolhaDePagamento ) * 100;//3
        String tmp=percVantagem.toStringAsFixed(2);
        percVantagem=double.parse(tmp);
        custoTotalLiquidoCalc = totalFolhaDePagamento + totalVantagens;//4
        encargosPrev14PercentCalc = custoTotalLiquidoCalc * 0.14;//5
        decimoTerceiroProporcionalCalc = (custoTotalLiquidoCalc+encargosPrev14PercentCalc) / 12;//6
        feriasProporcionalCalc = decimoTerceiroProporcionalCalc/3;//7
        totalFolhaMensalCalc = custoTotalLiquidoCalc + decimoTerceiroProporcionalCalc + feriasProporcionalCalc+encargosPrev14PercentCalc;
        totalFolhaAnualCalc = totalFolhaMensalCalc * 12;

        //DADOS DA FOLHA PROGRESSAO
        totalVantagens2=(totalFolhaNovo*percVantagem)/100 ;//2

        //DADOS DO EXERCICIO
        receitasDeImpostos=double.parse(resultado[0]['totImp']);
        receitaDeTransferencia=double.parse(resultado[0]['totImp2']);
        receitaTotalFundeb=double.parse(resultado[0]['total_receitas_fundeb']);
        totF=(totalFolhaAnualCalc/receitaTotalFundeb)*100;
        totF2=(totalFolhaAnualCalc2/receitaTotalFundeb)*100;
        double tot=double.parse(resultado[0]['totImp3']);
        perdaGanho=receitaTotalFundeb-((tot/100)*20);
        _isloading=false;
      });

      atualizaDadosDaProgressao();
      setState(() => tit = 'Dados da Folha de Pagamento : usando 15 classes e 2.80 de progressão');

    } catch (e) {
      setState(() => _isloading = false);
      print('Erro ao carregar dados: $e');
      Utils.snak('Atenção', 'Erro ao carregar dados. Use o botão Recarregar', false, Colors.red);
    }
  }

  _getNivelValor(String idN,String tipo){
    List<ModelSimulaForm> filteredItems = simulaFormjsonList.where((item) => item.idForm.toString() == idN).toList();
    novosNiveis.clear();
    valorNivel.clear();
    filteredItems.forEach((item) {
      novosNiveis.add(item.label);
      if(tipo=='PROGRESSAO'){
        valorNivel.add(item.valorProgressao.toString());
      }else{
        valorNivel.add(item.valor.toString());
      }
    });
  }

  _getSalarios(String horas){
    String hs = horas.contains('hs') ? horas : horas + 'hs';
    List<ModelSalario> filteredItems = salariosjsonList.where((item) => item.horas.toString().trim() == hs).toList();
    professores=filteredItems;
  }

  Future<void> _progressao(double percentualDeProgressao) async{
    setState(() => tit = 'Calculando aguarde....');
    double tot=0;
    for (int i = 0; i < cab.length; i++){
      //PEGA TODOS OS PROFESSORES
      var h=cab[i]['horas'];
      _getSalarios(h);
      _getNivelValor(cab[i]['id'],'PROGRESSAO');
      double progre=0;
      if(percentualDeProgressao>0) {
        progre=percentualDeProgressao;
      }else{
        progre = double.parse(cab[i]['progressao']);
      }
      tot+=await calculaCustoMensal(progre);
    }

    totalFolhaNovo=tot;
    String tmp =totalFolhaNovo.toStringAsFixed(2);
    totalFolhaNovo=double.parse(tmp);

    atualizaDadosDaProgressao();

    setState(() => tit = 'Dados da Folha de Pagamento : usando 15 classes e 2.80 de progressão');
  }

  Future<double> _totalFolha(double percentualDeProgressao) async{
    setState(() => tit = 'Calculando aguarde....');
    double tot=0;
    for (int i = 0; i < cab.length; i++){
      //PEGA TODOS OS PROFESSORES
      //var h=cab[i]['horas']+'hs';
      var h=cab[i]['horas'];
      _getSalarios(h);
      _getNivelValor(cab[i]['id'],'NORMAL');

      double progre=0;
      if(percentualDeProgressao>0) {
        progre=percentualDeProgressao;
      }else{
        progre = double.parse(cab[i]['progressao']);
      }
      tot+=await calculaCustoMensal(progre);
    }
    return tot;
  }

  Future<void> _ajustaSalarioBase(var percentualDeProgressao) async{
    var p=percentualDeProgressao.toString().replaceAll(',', '.');
    double perc=double.parse(p)/100;

    String sql='';
    if (perc == 0) {
      sql = "UPDATE cia_simula_form2601 SET valor_progressao = valor";
    } else {
      sql = "UPDATE cia_simula_form2601 SET valor_progressao = ROUND(valor PLUS_OPERATOR (valor MULT_OPERATOR $perc), 2)";
    }

   await  ApiMySql.executaSql(sql);

    sql='UPDATE $TBTotais SET perc_aumento_adulto = $p';
    await  ApiMySql.executaSql(sql);

    var x=await ApiMySql.executaSql('select id,id_form,nivel,label,tipo,valor,valor_progressao,perc from $TBSimulaForm').timeout(const Duration(seconds: 30));
    var str=fixJsonString(x.toString());
    List<dynamic> jsonList = jsonDecode(str);
    simulaFormjsonList = jsonList.map((json) => ModelSimulaForm.fromJson(json)).toList();
    progressaoController.text=percentualDeProgressao;

    _carregarDados();
  }

  void atualizaDadosDaProgressao(){
    //DADOS DA FOLHA PROGRESSAO
    totalVantagens2=(totalFolhaNovo*percVantagem)/100 ;//2
    percVantagem2 =(totalVantagens2/totalFolhaNovo ) * 100;//3
    custoTotalLiquidoCalc2 = totalFolhaNovo + totalVantagens2;//4
    encargosPrev14PercentCalc2 = custoTotalLiquidoCalc2 * 0.14;//5
    decimoTerceiroProporcionalCalc2 = (custoTotalLiquidoCalc2+encargosPrev14PercentCalc2) / 12;//6
    feriasProporcionalCalc2 = decimoTerceiroProporcionalCalc2/3;//7
    totalFolhaMensalCalc2 = custoTotalLiquidoCalc2 + decimoTerceiroProporcionalCalc2 + feriasProporcionalCalc2+encargosPrev14PercentCalc2;
    totalFolhaAnualCalc2 = totalFolhaMensalCalc2 * 12;
    totF2=(totalFolhaAnualCalc2/receitaTotalFundeb)*100;
  }

  Widget _buildTabela(String title) {
    return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child:Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue, // Cor de fundo azul claro da imagem
              ),
              child: Center(
                child:Texto(tit: title,tam: 18,negrito: true,cor: Colors.grey.shade300,),
              ),
            ),
            Table(
              // Define as larguras relativas das colunas
              columnWidths: const {
                0: FlexColumnWidth(4.5), // Vantagens
                1: FlexColumnWidth(1.5), // Atual
                2: FlexColumnWidth(1.5), // Atual
              },
              // Define a borda para todas as células da tabela
              border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
              children: [
              _buildDataRow('1. Valor da folha de vencimentos básicos - Mensal - R/\$', _currencyFormat.format(totalFolhaDePagamento),_currencyFormat.format(totalFolhaNovo),tooTip: 'Valor sem progressão\nValor bruto da folha',icon: Icons.help),
              _buildDataRow('2. Valor das vantagens pecuniárias - Mensal - R/\$',  _currencyFormat.format(totalVantagens),cor: Colors.red,icon: Icons.help, tooTip: d2,_currencyFormat.format(totalVantagens2)),
              _buildDataRow('3. Percentual das vantagens pecuniárias sobre a folha de vencimento', '${percVantagem.toStringAsFixed(2)}%',icon: Icons.help, tooTip: d3,'${_currencyFormat.format(percVantagem2)}%'),
              _buildDataRow('4. Custo total da folha de pagamento líquida mensal', _currencyFormat.format(custoTotalLiquidoCalc),tam: 18,icon: Icons.help, tooTip: d4,_currencyFormat.format(custoTotalLiquidoCalc2)),
              _buildDataRow('5. Encargos previdenciários', '14%',icon: Icons.help, tooTip: d5 ,'14%'),
              _buildDataRow('6. Encargos previdenciários (14%)', _currencyFormat.format(encargosPrev14PercentCalc),icon: Icons.help, tooTip: d6 ,_currencyFormat.format(encargosPrev14PercentCalc2)),
              _buildDataRow('7. Valor do décimo terceiro 1/12', _currencyFormat.format(decimoTerceiroProporcionalCalc),icon: Icons.help, tooTip: d7,_currencyFormat.format(decimoTerceiroProporcionalCalc2)),
              _buildDataRow('8. Valor 1/3 férias (proporcional)', _currencyFormat.format(feriasProporcionalCalc),icon: Icons.help, tooTip: d8,_currencyFormat.format(feriasProporcionalCalc2)),
              _buildDataRow('9. Total folha mensal', _currencyFormat.format(totalFolhaMensalCalc),icon: Icons.help, tooTip: d9,_currencyFormat.format(totalFolhaMensalCalc2) ),
              _buildDataRow('10. Total folha bruta anual', _currencyFormat.format(totalFolhaAnualCalc),tam: 22,icon: Icons.help, tooTip: d10,_currencyFormat.format(totalFolhaAnualCalc2)),
            ],
            )
          ],
        )
    );
  }

  Widget _buildDadosDoExercicio(String title) {
    return Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child:Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue, // Cor de fundo azul claro da imagem
              ),
              child: Center(
                child:Texto(tit: title,tam: 18,negrito: true,cor: Colors.grey.shade300,),
              ),
            ),
            Table(
              // Define as larguras relativas das colunas
              columnWidths: const {
                0: FlexColumnWidth(4.5), // Vantagens
                1: FlexColumnWidth(1.5), // Atual
                2: FlexColumnWidth(1.5), // Atual
              },
              // Define a borda para todas as células da tabela
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              children: [
                _buildDataRow('1. Receita de Impostos (25%)', _currencyFormat.format(receitasDeImpostos),tooTip: d1,icon: Icons.help,_currencyFormat.format(receitasDeImpostos)),
                _buildDataRow('2. Receitas de Transferências (5%)',  _currencyFormat.format(receitaDeTransferencia),tooTip: d2,icon: Icons.help,_currencyFormat.format(receitaDeTransferencia)),
                _buildDataRow('   Total Receita - (1 + 2)', _currencyFormat.format(receitasDeImpostos+receitaDeTransferencia), tooTip: d3,_currencyFormat.format(receitasDeImpostos+receitaDeTransferencia) ),
                _buildDataRow('3. Custo Total da Folha de Pagamento Anual', _currencyFormat.format(totalFolhaAnualCalc),tam: 18,_currencyFormat.format(totalFolhaAnualCalc2) ),
                _buildDataRow('4. Receitas Recebidas do FUNDEB - (FNDE)', _currencyFormat.format(receitaTotalFundeb),tam: 18,icon: Icons.help, tooTip: d4 ,_currencyFormat.format(receitaTotalFundeb)),

                _buildDataRow('5. Pag dos Profissionais do Magistério (70%)', '${_currencyFormat.format(totF)}%' ,icon: Icons.help, tooTip: d6 , '${_currencyFormat.format(totF2)}%'),

                _buildDataRow('PERDA/GANHO', _currencyFormat.format(perdaGanho),_currencyFormat.format(perdaGanho)),
                _buildDataRow('. TOTAL - Consolidação de recursos para MDE - (1 + 2 + 4) ', _currencyFormat.format(receitasDeImpostos+receitaDeTransferencia+receitaTotalFundeb),icon: Icons.help, tooTip: d7,tam: 18,_currencyFormat.format(receitasDeImpostos+receitaDeTransferencia+receitaTotalFundeb)),
              ],
            )
          ],
        )
    );
  }

  TableRow _buildDataRow(String label, String valor,String novoValor,{Color cor=Colors.black, double tam=15,IconData? icon,String? tooTip}) {
    const cellStyle = TextStyle(fontSize: 15, color: Colors.black87,);
    return TableRow(
      children: [
        _buildTableCell(label, style: cellStyle,icon: icon,tooTip: tooTip),
        _buildTableCell(valor, style: cellStyle, alignment: MainAxisAlignment.end,cor: cor,tam: tam,),
        _buildTableCell(novoValor, style: cellStyle, alignment: MainAxisAlignment.end,cor: cor,tam: tam),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {
        required TextStyle style, MainAxisAlignment alignment = MainAxisAlignment.start,
        Color cor=Colors.black54,double tam=15,IconData? icon,String? tooTip
      }
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Texto(tit:text,icone: icon ,tooltip: tooTip ,mainAxisAlignment: alignment,
      cor: cor,tam: tam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isloading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Largura máxima para todo o conteúdo
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //PROGRESSAO
                    SizedBox(
                      width: 200,
                      child: CustomTextFiel(
                        controller:progressaoController ,
                        label:'Percentual Linear em %' ,
                        hintText: 'code',
                        suffixIcon: Icons.play_circle_fill,
                        inputFormatters: [
                          ValorInputFormatter(),
                        ],
                        //ValorInputFormatter
                        onToggleVisibility: () async {
                          await _ajustaSalarioBase(progressaoController.text);
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    //PDF
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label:  Text('PDF', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: () {
                        generateImpactoPdf(
                          totalFolha: totalFolhaDePagamento,
                          totalVantagens: totalVantagens,
                          percVantagem: percVantagem,
                          custoTotalLiquidoCalc: custoTotalLiquidoCalc,
                          encargosPrev14PercentCalc: encargosPrev14PercentCalc,
                          feriasProporcionalCalc: feriasProporcionalCalc,
                          decimoTerceiroProporcionalCalc: decimoTerceiroProporcionalCalc,
                          totalFolhaMensalCalc: totalFolhaMensalCalc,
                          totalFolhaAnualCalc: totalFolhaAnualCalc,
                          receitasDeImpostos: receitasDeImpostos,
                          receitaDeTransferencia: receitaDeTransferencia,
                          receitaTotalFundeb: receitaTotalFundeb,
                          perdaGanho: perdaGanho,
                          totF: totF,
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                    //EXCEL
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download, color: Colors.white),
                      label:  Text('Excel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        generateExcel(
                          totalFolha: totalFolhaDePagamento,
                          totalVantagens: totalVantagens,
                          percVantagem: percVantagem,
                          custoTotalLiquidoCalc: custoTotalLiquidoCalc,
                          encargosPrev14PercentCalc: encargosPrev14PercentCalc,
                          feriasProporcionalCalc: feriasProporcionalCalc,
                          decimoTerceiroProporcionalCalc: decimoTerceiroProporcionalCalc,
                          totalFolhaMensalCalc: totalFolhaMensalCalc,
                          totalFolhaAnualCalc: totalFolhaAnualCalc,
                          receitasDeImpostos: receitasDeImpostos,
                          receitaDeTransferencia: receitaDeTransferencia,
                          receitaTotalFundeb: receitaTotalFundeb,
                          totF: totF,
                          perdaGanho: perdaGanho,
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                    //RELATORIO
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list_alt_outlined, color: Colors.white),
                      label:  Text('REL', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      onPressed: () async{
                       // await gerarPdf();
                        Get.to(() => Relatorio(
                          totalFolhaDePagamento:totalFolhaDePagamento,
                           totalFolhaNovo:totalFolhaNovo,
                           totalVantagens:totalVantagens,
                           totalVantagens2:totalVantagens2,
                           percVantagem:percVantagem,
                           percVantagem2:percVantagem2,
                           custoTotalLiquidoCalc:custoTotalLiquidoCalc,
                           custoTotalLiquidoCalc2:custoTotalLiquidoCalc2,
                           encargosPrev14PercentCalc:encargosPrev14PercentCalc,
                           encargosPrev14PercentCalc2:encargosPrev14PercentCalc2,
                           decimoTerceiroProporcionalCalc:decimoTerceiroProporcionalCalc,
                           decimoTerceiroProporcionalCalc2:decimoTerceiroProporcionalCalc2,
                           feriasProporcionalCalc:feriasProporcionalCalc,
                           feriasProporcionalCalc2:feriasProporcionalCalc2,
                           totalFolhaMensalCalc:totalFolhaMensalCalc,
                           totalFolhaMensalCalc2:totalFolhaMensalCalc2,
                           totalFolhaAnualCalc:totalFolhaAnualCalc,
                           totalFolhaAnualCalc2:totalFolhaAnualCalc2,

                          receitasDeImpostos:receitasDeImpostos,
                          receitaDeTransferencia:receitaDeTransferencia,
                          receitaTotalFundeb:receitaTotalFundeb,
                          totF:totF,
                          totF2:totF2,
                          perdaGanho:perdaGanho,
                          simulaFormjsonList:simulaFormjsonList,

                        ), arguments: {});
                      },
                    ),
                    //Refresh
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label:  Text('Atualiza', style: TextStyle(color: Colors.black54)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Cor para o botão de exportar
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _carregarDados();
                      },
                    ),
                  ],
                ),
                _buildTabela(tit),
                _buildDadosDoExercicio('Dados Do Execício'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double> calculaCustoMensal(double perProgressao)async{

    final result = calculateTableAndDispersions(
      niveis: novosNiveis,
      valoresIniciaisNiveis: valorNivel,
      cargaHoraria: 15,
      percEntreColunas: perProgressao,
    );

    final calculatedTableValues = result.calculatedTableValues;
    double total=0;
    for (int nivelIndex = 0; nivelIndex < novosNiveis.length; nivelIndex++){
      for (int coluna = 0; coluna < calculatedTableValues[nivelIndex].length; coluna++){
          double x = await ProfessorUtils.totalDeVencimentosPropostaNova(
              novosNiveis[nivelIndex].toString(), coluna + 1, professores,
              calculatedTableValues);
        if(x>0) {
          total+=x;
        }
      }
    }
    return total;
  }

  Future<void> generateImpactoPdf({
    required double totalFolha,
    required double totalVantagens,
    required double percVantagem,
    required double custoTotalLiquidoCalc,
    required double encargosPrev14PercentCalc,
    required double feriasProporcionalCalc,
    required double decimoTerceiroProporcionalCalc,
    required double totalFolhaMensalCalc,
    required double totalFolhaAnualCalc,
    required double receitasDeImpostos,
    required double receitaDeTransferencia,
    required double receitaTotalFundeb,
    required double perdaGanho,
    required double totF,
  }) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Helper para linha de tabela
    pw.TableRow buildRow(String label, String valor,String valor2,
        {bool bold = false, PdfColor color = PdfColors.black}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              valor,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              valor2,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color,
              ),
            ),
          ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Relatório de Impacto Financeiro",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // --- TABELA FOLHA ---
          pw.Text("Dados da Folha de Pagamento", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              buildRow("Descrição", 'Valor Atual','Proposta'),
              buildRow("1. Valor da folha de vencimentos básicos - Mensal", currencyFormat.format(totalFolha),currencyFormat.format(totalFolha)),
              buildRow("2. Valor das vantagens pecuniárias - Mensal", currencyFormat.format(totalVantagens),currencyFormat.format(totalFolha), color: PdfColors.red),
              buildRow("3. Percentual das vantagens sobre a folha", "${percVantagem.toStringAsFixed(2)}%","${percVantagem.toStringAsFixed(2)}%"),
              buildRow("4. Custo total da folha líquida mensal", currencyFormat.format(custoTotalLiquidoCalc),currencyFormat.format(custoTotalLiquidoCalc), bold: true),
              buildRow("5. Encargos previdenciários (14%)", currencyFormat.format(encargosPrev14PercentCalc),currencyFormat.format(encargosPrev14PercentCalc)),
              buildRow("6. Décimo terceiro proporcional", currencyFormat.format(decimoTerceiroProporcionalCalc),currencyFormat.format(decimoTerceiroProporcionalCalc)),
              buildRow("7. Férias proporcionais (1/3)", currencyFormat.format(feriasProporcionalCalc),currencyFormat.format(feriasProporcionalCalc)),
              buildRow("8. Total folha mensal", currencyFormat.format(totalFolhaMensalCalc),currencyFormat.format(totalFolhaMensalCalc), bold: true),
              buildRow("9. Total folha bruta anual", currencyFormat.format(totalFolhaAnualCalc),currencyFormat.format(totalFolhaAnualCalc), bold: true),
             // buildRow("", "",''),
            ],
          ),

          pw.SizedBox(height: 20),

          // --- TABELA EXERCÍCIO ---
          pw.Text("Dados do Exercício", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              buildRow("1. Receita de Impostos", currencyFormat.format(receitasDeImpostos),currencyFormat.format(receitasDeImpostos)),
              buildRow("2. Receitas de Transferências", currencyFormat.format(receitaDeTransferencia),currencyFormat.format(receitaDeTransferencia)),
              buildRow("   Total Receita (1 + 2)", currencyFormat.format(receitasDeImpostos + receitaDeTransferencia),currencyFormat.format(receitasDeImpostos + receitaDeTransferencia)),
              buildRow("3. Custo total da folha anual", currencyFormat.format(totalFolhaAnualCalc),currencyFormat.format(totalFolhaAnualCalc)),
              buildRow("4. Receitas FUNDEB", currencyFormat.format(receitaTotalFundeb),currencyFormat.format(receitaTotalFundeb), bold: true),
              buildRow("5. Profissionais do Magistério (70%)", "${totF.toStringAsFixed(2)}%","${totF.toStringAsFixed(2)}%"),
              buildRow("6. Perda/Ganho", currencyFormat.format(perdaGanho),currencyFormat.format(perdaGanho)),
            ],
          ),
        ],
        // Rodapé para todas as páginas
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "© ${DateTime.now().year} GEM Analytics — Relatório Confidencial",
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

    final pdfBytes = await pdf.save();
    final filename = "impacto_${DateTime.now().toIso8601String().substring(0, 10)}.pdf";

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
    }
  }


  Future<void> generateExcel({
    required double totalFolha,
    required double totalVantagens,
    required double percVantagem,
    required double custoTotalLiquidoCalc,
    required double encargosPrev14PercentCalc,
    required double feriasProporcionalCalc,
    required double decimoTerceiroProporcionalCalc,
    required double totalFolhaMensalCalc,
    required double totalFolhaAnualCalc,
    required double receitasDeImpostos,
    required double receitaDeTransferencia,
    required double receitaTotalFundeb,
    required double totF,
    required double perdaGanho,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Proposta para Folha'];

    // Estilo negrito
    final boldStyle = CellStyle(
      bold: true,
      fontSize: 14,
    );

    // Helper para adicionar linhas (aceita String e double)
    void addRow(String label, var value,var value2) {
      //sheet.appendRow([TextCellValue(label),TextCellValue(value.toString(),TextCellValue(value2.toString()]);

    }

    // Cabeçalho 1
    sheet.appendRow([TextCellValue('Dados da Folha de Pagamento')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = boldStyle;
    sheet.appendRow([]);
    addRow("", '','');

    addRow("Descrição", 'Valor Atual','Proposta');
    addRow('1. Valor da folha de vencimentos básicos - Mensal', totalFolha,totalFolha);
    addRow('2. Valor das vantagens pecuniárias - Mensal', totalVantagens,totalVantagens);
    addRow('3. Percentual das vantagens sobre a folha de vencimento', percVantagem,percVantagem);
    addRow('4. Custo total da folha de pagamento', custoTotalLiquidoCalc,custoTotalLiquidoCalc);
    addRow('5. Encargos previdenciários (14%)', encargosPrev14PercentCalc,encargosPrev14PercentCalc);
    addRow('6. Valor do décimo terceiro proporcional', decimoTerceiroProporcionalCalc,decimoTerceiroProporcionalCalc);
    addRow('7. Valor 1/3 férias (proporcional)', feriasProporcionalCalc,feriasProporcionalCalc);
    addRow('8. Total folha mensal', totalFolhaMensalCalc,totalFolhaMensalCalc);
    addRow('9. Total folha bruta anual', totalFolhaAnualCalc,totalFolhaAnualCalc);

    // Linha em branco extra
    addRow("", '','');

    // Cabeçalho 2
    final headerRowIndex = sheet.maxRows;
    sheet.appendRow([TextCellValue('Dados do Exercício')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRowIndex)).cellStyle = boldStyle;
    sheet.appendRow([]);

    addRow('1. Receita de Impostos 25%', receitasDeImpostos,receitasDeImpostos);
    addRow('2. Receita de Transferências 5%', receitaDeTransferencia,receitaDeTransferencia);
    addRow('3. Receita Total FUNDEB', receitaTotalFundeb,receitaTotalFundeb);
    addRow('4. Percentual gastos com profissionais do magistério', totF,totF);
    addRow('5. Perda/Ganho', perdaGanho,perdaGanho);

    // Converte para bytes
    final List<int>? bytes = excel.encode();

    if (bytes != null) {
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "relatorio_folha.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }
}
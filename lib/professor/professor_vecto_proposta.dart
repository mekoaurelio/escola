import 'package:flutter/material.dart';
import 'package:psycostatattoo/const/nome_tabelas.dart';
import 'package:get/get.dart';

import '../data/api_my_sql.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/screenSize.dart';
import '../services/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';
import '../widgets/texto.dart';

class ProfessorVectoProposta extends StatefulWidget {
  const ProfessorVectoProposta();

  @override
  State<ProfessorVectoProposta> createState() => _ProfessorVectoPropostaState();
}

class _ProfessorVectoPropostaState extends State<ProfessorVectoProposta> {
  TextEditingController controller = TextEditingController();
  List<dynamic> lista = [];
  List<dynamic> listaCompleta = [];
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading=true;
  ///Para os totais
  double somaVencimentos = 0;
  double somaPropostas = 0;

  double valorBase=0;
  double penA=0;
  double penB=0;
  double penC=0;
  double penD=0;
  double penE=0;
  double perc=0;
  List<double> matrizProfessor =[];
  List<double> matrizInfantil =[];
  double percP=0,percI=0;
  int hoverIndex = -1;
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void dispose() {
    anoBimestreController.dispose(); // Cancela o ouvinte quando o widget for destruído
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ever(anoBimestreController.ano, (novoAno) {
      var bimestre=anoBimestreController.bimestre;
      atualizaTela(novoAno,bimestre);
    });

    ever(anoBimestreController.bimestre, (novoBimestre) {
      var ano=anoBimestreController.ano;
      atualizaTela(ano,novoBimestre);
    });

    carregarFolha();
  }

  atualizaTela(var ano,var bimestre){
    setState(() {
      TBProfessor='a_professor$ano$bimestre';
      TBInfantil='a_infantil$ano$bimestre';
      TBFolha='a$ano$bimestre';
      TBVantagens='a_vantagens$ano$bimestre';
      listaCompleta=[];
      lista=[];
      carregarFolha();
    });
  }

  Future<void> carregaMatriz(var tb,String tipo) async {

    valorBase = double.parse(tb[0]['valor']); ///PISO
    penA = double.parse(tb[2]['valor']);
    penB = double.parse(tb[3]['valor']);
    penC = double.parse(tb[4]['valor']);
    penD = double.parse(tb[5]['valor']);
    penE = double.parse(tb[6]['valor']);
    perc=double.parse(tb[1]['percentual']); ///Percentual de progressão entre níveis

    if(tipo=='P'){
      percP=perc;
    }else{
      percI=perc;
    }
    matrizProfessor = [valorBase, penA, penB, penC, penD, penE];
    matrizInfantil = [valorBase, penA, penB, penC, penD, penE];
  }

  Future<void> carregarFolha() async {
    var profs = await ApiMySql.get(TBProfessor, null, 'ordem');
    var infantil = await ApiMySql.get(TBInfantil, null, 'ordem');
    await carregaMatriz(profs,'P');
    await carregaMatriz(infantil,'I');

    listaCompleta = await ApiMySql.getProfessor(); // Salva a lista completa
    lista = listaCompleta; // Inicialmente, lista exibida é igual à completa
    setState(() {
      pageSize=lista.length;
      isLoading=false;
    });
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
            Line(tex: 'Matrícula', tam: 90, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 16,),
            Line(tex: 'Professor', tam: 250, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'Tipo', tam: 70, alin: Alignment.center,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'Nível', tam: 70, alin: Alignment.center,cor: Colors.black,negrito: true,fontSize: 16),

            Line(tex: 'Vencimento', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'APTS', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'Vantagens', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'Total', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: 'Proposta', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16)
          ],
        )
    );
  }

  Widget totais() {
    return  Row(
          children: [
            Line(tex: '', tam: 90, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 16,),
            Line(tex: '', tam: 250, alin: Alignment.centerLeft,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: '', tam: 70, alin: Alignment.center,cor: Colors.black,fontSize: 13),
            Line(tex: '', tam: 70, alin: Alignment.center,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: Utils.formatVr.format(somaVencimentos).toString() , tam: 100, alin: Alignment.centerRight,cor: Colors.blue,negrito: true,fontSize: 13),
            Line(tex: '', tam: 100, alin: Alignment.center,cor: Colors.black,fontSize: 13),
            Line(tex: '', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: '', tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,fontSize: 16),
            Line(tex: Utils.formatVr.format(somaPropostas).toString(), tam: 100, alin: Alignment.centerRight,cor: Colors.blue,negrito: true,fontSize: 13)
          ],
        );
  }

  void _calcularTotais() {
    somaVencimentos = 0;
    somaPropostas = 0;

    for (var item in lista) {
      // Cálculo do vencimento
      String vantagensDetalhadas = item['vantagens_detalhadas'];
      final vantagens = vantagensDetalhadas.split(' | ');
      String vencimento = vantagens[0];
      int pos = vencimento.indexOf('\$');
      vencimento = vencimento.substring(pos + 1).replaceAll('.', '').replaceAll(',', '.');
      double vencimentoValue = double.tryParse(vencimento) ?? 0;
      somaVencimentos += vencimentoValue;

      // Cálculo da proposta
      String n = Utils.getNivel(item['nivel']);
      n = 'N$n';
      var vrP = Utils.getValueFromMatrix(
        baseValues: item['unidade'].toString().contains('Prof.Educ.Inf') ? matrizInfantil : matrizProfessor,
        progressionRate: perc,
        code: n,
        numberOfColumns: 99,
      );
      somaPropostas += vrP;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (lista.length / pageSize).ceil();
    final screenSizeConfig = ScreenSizeConfig(context);

    // Chama o cálculo dos totais uma vez no build
    if (!isLoading && (somaVencimentos == 0 || somaPropostas == 0)) {
      _calcularTotais();
    }

    return isLoading?const Center(child: CircularProgressIndicator()):
    Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            lista.isEmpty
                ? Utils.vazio('Nenhum Dado para esse ano/bimestre')
                : Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Texto(tit:'Progressão Entre Níveis Professor $percP%',
                            aoClicarIcone: () {
                              Utils.mostrarDialogoEditarValor(
                                context: context,
                                titulo: 'Progressão Entre Níveis Professor',
                                labelCampo: 'Percentual',
                                valorInicial: percP.toString(),
                                aoSalvar: (novoValor) {
                                  setState(() {
                                    percP = double.tryParse(novoValor)!;
                                    //_calculateTableAndDispersions();
                                  });
                                },
                              );
                            },
                          ),
                          Texto(tit:'Progressão Entre Níveis Infantil $percI%',),
                        ],
                      ),
                      SizedBox(width: 50,),
                      Expanded(
                          child: CustomTextFiel(
                            controller: controller,
                            label: '',
                            //hintText: ,
                            left: 10,
                            prefixIcon: Icons.search_outlined,
                            obrigatorio: false,
                            onChanged:onChange ,
                          )
                      ),
                    ],
                  ),
                  cabecalho(),
                  totais(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];
                        ///Acha o valor do salário base ********************
                        String vantagensDetalhadas=currentItems[index]['vantagens_detalhadas'];
                        final vantagens = vantagensDetalhadas.split(' | ');
                        String vencimento=vantagens[0];
                        int pos=vencimento.indexOf('\$');
                        String descriVantagem=vencimento.substring(0,pos);
                        int posV=descriVantagem.indexOf(':');
                        descriVantagem=descriVantagem.substring(posV+1,descriVantagem.length);
                        vencimento=vencimento.substring(pos+1,vencimento.length);
                        
                        bool isInfante=currentItems[index]['unidade'].toString().contains('Prof.Educ.Inf');//Prof.Educ.Inf.Lic.Plena

                        ///acha os salario PROPOSTO *******
                        String n=Utils.getNivel(item['nivel']);
                        String mk=n;
                        n='N$n';
                       var vrP= Utils.getValueFromMatrix(
                          baseValues:isInfante? matrizInfantil:matrizProfessor,
                          //baseValues: matrizProfessor,
                          progressionRate: perc,
                          code: n,
                          numberOfColumns: 99, ///quantidade de colunas
                        );
                       ///Veririca quem tem a proposta Menor do que o vencimento
                       String vecto=vencimento.replaceAll(',', '');
                        bool propostaMenorVecto=double.parse(vecto)<double.parse(vrP.toString());

                        String proposta=Utils.formatVr.format(vrP).toString();
                        String atps=item['soma_apts'].toString().replaceAll('-', '');
                        double sumVantagem=double.parse(item['soma_vantagens']);
                        double total=double.parse(atps)+sumVantagem+double.parse(vecto);

                       // bool propostaMenorVecto=total<double.parse(vrP.toString());

                        return MouseRegion(
                            onEnter: (_) => setState(() => hoverIndex = index),
                            onExit: (_) => setState(() => hoverIndex = -1),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.0,         // Espessura da linha
                                  ),
                                ),
                                color: hoverIndex == index ? Colors.blue.shade50 : Colors.transparent,
                              ),
                            child: Row(
                              children: [
                                Line(tex: item['matricula'], tam: 90, alin: Alignment.centerLeft,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13,top: 10,),
                                Line(tex: item['nome'], tam: 250, alin: Alignment.centerLeft,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),
                                Line(tex: isInfante?'Normal':'Infantil', tam: 70, alin: Alignment.center,cor: Colors.black,fontSize: 13),
                                Line(tex: item['nivel'], tam: 70, alin: Alignment.center,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),
                                Line(tex: vencimento, tam: 100, alin: Alignment.centerRight,cor: propostaMenorVecto?Colors.black:Colors.red,fontSize: 13),
                                Line(tex: Utils.formatVr.format(double.parse(atps)), tam: 100, alin: Alignment.centerRight,cor: Colors.black,),
                                Line(tex: Utils.formatVr.format(double.parse(item['soma_vantagens'])), tam: 100, alin: Alignment.centerRight,cor: Colors.black,),
                                Line(tex: Utils.formatVr.format(total), tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,),

                                Line(tex:proposta.toString(), tam: 100, alin: Alignment.centerRight,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),

                                Line(tex:proposta=='0,00'?' Nível inválido $mk':descriVantagem.contains('Vencimento')?'':' $descriVantagem',
                                    tam: 100, alin: Alignment.centerLeft,cor: Colors.red,negrito: true,fontSize: 11),
                              ],
                            )
                          ),
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
                      setState(() {
                        currentPage = newPage;
                      });
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

  void onChange(String text) {
    setState(() {
      if (text.isEmpty) {
        // Se o campo de pesquisa estiver vazio, mostra todos os itens
        lista = listaCompleta;
        currentPage = 1; // Volta para a primeira página
      } else {
        // Filtra a lista completa
        lista = listaCompleta.where((professor) {
          final nome = professor['nome'].toString().toLowerCase();
          final matr = professor['matricula'].toString().toLowerCase();
          final nivel = professor['nivel'].toString().toLowerCase();
          final unidade = professor['unidade'].toString().toLowerCase();

          return nome.contains(text.toLowerCase()) ||
              matr.contains(text.toLowerCase()) ||
              nivel.contains(text.toLowerCase()) ||
              unidade.contains(text.toLowerCase());
        }).toList();
        currentPage = 1; // Reseta para a primeira página após pesquisa
      }
      // Atualiza os totais após filtrar
      _calcularTotais();
    });
  }
}
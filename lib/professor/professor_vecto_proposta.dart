import 'package:flutter/material.dart';

import '../data/api_my_sql.dart';
import '../services/screenSize.dart';
import '../services/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
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

  @override
  void initState() {
    super.initState();
    carregarFolha();
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
    var profs = await ApiMySql.get('sim_prof', null, 'ordem');
    var infantil = await ApiMySql.get('sim_edu_infantil', null, 'ordem');
    await carregaMatriz(profs,'P');
    await carregaMatriz(infantil,'I');
    /*
     valorBase = double.parse(profs[0]['valor']); ///PISO
     penA = double.parse(profs[2]['valor']);
     penB = double.parse(profs[3]['valor']);
     penC = double.parse(profs[4]['valor']);
     penD = double.parse(profs[5]['valor']);
     penE = double.parse(profs[6]['valor']);
     perc=double.parse(profs[1]['percentual']); ///Percentual de cálculo entre as colunas
  
    matrizProfessor = [valorBase, penA, penB, penC, penD, penE];
    matrizInfantil = [valorBase, penA, penB, penC, penD, penE];

     */

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

  Widget _buildFooter(int totalPages, ScreenSizeConfig screenSizeConfig) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage = 1) : null,
            icon: Icon(Icons.first_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
            icon: Icon(Icons.arrow_back, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Text('Página $currentPage de $totalPages',
              style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54)),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
            icon: Icon(Icons.arrow_forward, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage = totalPages) : null,
            icon: Icon(Icons.last_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Text('${lista.length} Itens',
              style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54)),
        ],
      ),
    );
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
                ? const Text('Nenhum dado carregado ainda.')
                : Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Texto(tit:'Cálculos feitos com $percP% de progressão entre níveis de Professor e de $percI% Infantil'),
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
                        print(vantagensDetalhadas);
                        final vantagens = vantagensDetalhadas.split(' | ');
                        String vencimento=vantagens[0];
                        int pos=vencimento.indexOf('\$');
                        String descriVantagem=vencimento.substring(0,pos);
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
                        return
                            Row(
                              children: [
                                Line(tex: item['matricula'], tam: 90, alin: Alignment.centerLeft,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13,),
                                Line(tex: item['nome'], tam: 250, alin: Alignment.centerLeft,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),
                                Line(tex: isInfante?'Normal':'Infantil', tam: 70, alin: Alignment.center,cor: Colors.black,fontSize: 13),
                                Line(tex: item['nivel'], tam: 70, alin: Alignment.center,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),
                                Line(tex: vencimento, tam: 100, alin: Alignment.centerRight,cor: propostaMenorVecto?Colors.black:Colors.red,fontSize: 13),
                                Line(tex: Utils.formatVr.format(double.parse(atps)), tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,),
                                Line(tex: Utils.formatVr.format(double.parse(item['soma_vantagens'])), tam: 100, alin: Alignment.centerRight,cor: Colors.black,negrito: true,),
                                Line(tex:proposta.toString(), tam: 100, alin: Alignment.centerRight,cor: propostaMenorVecto?Colors.black:Colors.red,negrito: true,fontSize: 13),

                                Line(tex:proposta=='0,00'?' Nível inválido $mk':descriVantagem.contains('Vencimento')?'':' $descriVantagem',
                                    tam: 200, alin: Alignment.centerLeft,cor: Colors.red,negrito: true,fontSize: 11),
                              ],
                            );
                      },
                    ),
                  ),
                  _buildFooter(totalPages, screenSizeConfig),
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
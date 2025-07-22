import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/screenSize.dart';
import '../services/utils.dart';
import '../simulador/simulador_alt.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';
import '../widgets/painel.dart';
import '../widgets/texto.dart';

class ProfessorConferencia extends StatefulWidget {
  const ProfessorConferencia();

  @override
  State<ProfessorConferencia> createState() => _ProfessorConferenciaState();
}

class _ProfessorConferenciaState extends State<ProfessorConferencia> {
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
  var _anoLocal='',_bimestreLocal='';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ever(anoBimestreController.ano, (novoAno) {
      _bimestreLocal=anoBimestreController.bimestre.toString();
      Utils.setAno(novoAno);
      atualizaTela(novoAno,_bimestreLocal);
    });

    ever(anoBimestreController.bimestre, (novoBimestre) {
      _anoLocal=anoBimestreController.ano.toString();
      Utils.setBimestre(novoBimestre);
      atualizaTela(_anoLocal,novoBimestre);
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
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue, // Cor de fundo azul claro da imagem
        ),
        child: Row(
          children: [
            SizedBox(width: 15,),
            Line(tex: 'Matrícula', tam: 90, alin: Alignment.centerLeft,cor: Colors.grey.shade300,negrito: true,fontSize: 16,),
            Line(tex: 'Professor', tam: 250, alin: Alignment.centerLeft,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'Tipo', tam: 70, alin: Alignment.center,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'Nível', tam: 70, alin: Alignment.center,cor: Colors.grey.shade300,negrito: true,fontSize: 16),

            Line(tex: 'Vencimento', tam: 100, alin: Alignment.centerRight,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'APTS', tam: 100, alin: Alignment.centerRight,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'Vantagens', tam: 100, alin: Alignment.centerRight,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'Total', tam: 100, alin: Alignment.centerRight,cor: Colors.grey.shade300,negrito: true,fontSize: 16),
            Line(tex: 'Proposta', tam: 100, alin: Alignment.centerRight,cor: Colors.grey.shade300,negrito: true,fontSize: 16)
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (lista.length / pageSize).ceil();
    const double maxTableWidth = 1500;
    return isLoading?const Center(child: CircularProgressIndicator()):
    Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTableWidth),
            child: Column(
              children: [
                CustomTextFiel(
                  controller: controller,
                  label: '',
                  //hintText: ,
                  left: 10,
                  prefixIcon: Icons.search_outlined,
                  obrigatorio: false,
                  onChanged:onChange ,
                ),
                Expanded(child:
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias, // Essencial para cortar os cantos
                  child: Column(
                    children: [
                      lista.isEmpty
                          ? Utils.vazio('Nenhum Dado para esse ano/bimestre')
                          :
                      Expanded(
                        child: Column(
                          children: [
                            cabecalho(),
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

                                  Color cor=Colors.black;
                                  bool negrito=false;
                                  String tootip='';

                                  if(!propostaMenorVecto){
                                    cor=Colors.red;
                                    negrito=true;
                                  }
                                  if(proposta=='0,00' || !descriVantagem.contains('Vencimento')) {
                                    if(proposta=='0,00'){
                                      tootip='Nivel inválido $mk';
                                    }else {
                                      tootip = descriVantagem;
                                    }
                                    cor = Colors.blue;
                                    negrito=true;
                                  }

                                  return MouseRegion(
                                    onEnter: (_) => setState(() => hoverIndex = index),
                                    onExit: (_) => setState(() => hoverIndex = -1),
                                    child: Tooltip(
                                      message: tootip, // Mensagem dinâmica
                                      preferBelow: false, // Opcional: controla a posição
                                      padding: EdgeInsets.all(8), // Opcional: espaçamento interno
                                      decoration: BoxDecoration( // Opcional: estilo do tooltip
                                        color: Colors.blue[700],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      textStyle: TextStyle( // Opcional: estilo do texto
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
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
                                              SizedBox(width: 15,),
                                              Line(tex: item['matricula'], tam: 90, alin: Alignment.centerLeft,cor: cor,negrito:
                                              negrito,top: 10,fontSize: 18,),
                                              Line(tex: item['nome'], tam: 250, alin: Alignment.centerLeft,cor: cor,negrito: true),
                                              Line(tex: isInfante?'Normal':'Infantil', tam: 70, alin: Alignment.center,cor: cor,negrito: negrito,),
                                              Line(tex: item['nivel'], tam: 70, alin: Alignment.center,cor: cor,negrito: negrito,),
                                              Line(tex: vencimento, tam: 100, alin: Alignment.centerRight,cor: cor,negrito: !propostaMenorVecto,),
                                              ///adicional por tempo de serviço
                                              Line(tex: Utils.formatVr.format(double.parse(atps)), tam: 100, alin: Alignment.centerRight,cor:cor,negrito: negrito,),
                                              ///vantagens
                                              Line(tex: Utils.formatVr.format(double.parse(item['soma_vantagens'])), tam: 100, alin: Alignment.centerRight,
                                                cor: cor,negrito: negrito,),
                                              ///total
                                              Line(tex: Utils.formatVr.format(total), tam: 100, alin: Alignment.centerRight,cor: cor,negrito: negrito,),
                                              ///valor proposto
                                              Line(tex:proposta.toString(), tam: 100, alin: Alignment.centerRight,cor: cor,negrito: true,),

                                              IconButton(
                                                onPressed: () => edite('Alterando','nivel',item['nivel'],item['matricula']),
                                                icon: Icon(Icons.edit, color: Colors.black54, size: 15),
                                              ),
                                              IconButton(
                                                onPressed: () => delete(item['matricula'],item['nome']),
                                                icon: Icon(Icons.delete, size: 15, color: Colors.black38,),
                                              ),

                                              ///apenas os nomes das licencas
                                              // Line(tex:proposta=='0,00'?' Nível inválido $mk':descriVantagem.contains('Vencimento')?'':' $descriVantagem',
                                              //   tam: 100, alin: Alignment.centerLeft,cor: Colors.red,negrito: true,fontSize: 11),
                                            ],
                                          )
                                      ),
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
                                setState(() => currentPage = newPage);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) )
              ],
            )
          )
        ),
      )
    );
  }

  delete(var matricula,var nome)async{
    final bool confirmar = await Utils.showDlg('Atenção', 'Confirma a exclusão de \n$nome?', context, 'Sim', 'Não',
    );
    if (confirmar) {
      String _a=Utils.getAno();
      String _b=Utils.getBimestre();
      await ApiMySql.executaSql("Update $TBFolha  set status='D' WHERE matricula=$matricula");
      setState(() => atualizaTela(_a,_b));
    }
  }

  edite(var title,var campo,vrInicial,var matricula )async{
    await Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: title,
      labelCampo: campo,
      valorInicial: vrInicial,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))], // Permite apenas letras e números],
      aoSalvar: (novoValor) async{
        String _a=Utils.getAno();
        String _b=Utils.getBimestre();
        print("Update $TBFolha  set nivel='$novoValor' WHERE matricula=$matricula");
        await ApiMySql.executaSql("Update $TBFolha  set nivel='$novoValor' WHERE matricula=$matricula");
        setState(() => atualizaTela(_a,_b));

      },
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
    });
  }
}
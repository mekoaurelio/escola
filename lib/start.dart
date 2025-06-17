import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';

import 'auxiliares/cargo_lista.dart';
import 'auxiliares/encargo_social_lista.dart';
import 'auxiliares/fonte_receita_lista.dart';
import 'auxiliares/lista_cod_descri.dart';
import 'const/nome_tabelas.dart';
import 'grafico/grafico_fundeb_exercicio.dart';
import 'grafico/home.dart';
import 'impacto/impacto_grid2.dart';
import 'impacto/impacto_main.dart';
import 'import/pdfExtractorPage.dart';
import 'professor/professor_vecto_proposta.dart';
import 'professor/professores.dart';
import 'professor/tabela_professor.dart';
import 'professor/tabela_professor_infantil.dart';
import 'services/ano_bimestre_controller.dart';
import 'services/utils.dart';
import 'simulador/executa_simulador.dart';
import 'widgets/texto.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  final Color appBarColorCrypto = const Color(0xFF2459A9);
  String _currentPage = 'Home';
  int _currentTabIndex = 0;
  String _currentAno = '00';
  String _currentBimestre = '00';
  bool temAnoBimestre=false;
  final anoBimestreController = Get.find<AnoBimestreController>();


  final List<Map<String, String>> _anos = [
    {'code': '00','name': 'Escolha o Ano'},
    {'code': '20', 'name': '2020'},
    {'code': '21', 'name': '2021'},
    {'code': '22', 'name': '2022'},
    {'code': '23', 'name': '2023'},
    {'code': '24', 'name': '2024'},
    {'code': '25', 'name': '2025'},
  ];

  final List<Map<String, String>> _bimestres = [
    {'code': '00','name': 'Escolha o Bimestre'},
    {'code': '01','name': 'Primeiro Bimestre'},
    {'code': '02','name': 'Segundo Bimestre'},
    {'code': '03','name': 'Terceiro Bimestre'},
    {'code': '04','name': 'Quarto Bimestre'},
    {'code': '05','name': 'Quinto Bimestre'},
    {'code': '06','name': 'Sexto Bimestre'},
  ];

  final List<Map<String, dynamic>> _mainNavigationItems = [
    {'title': 'Simulador', 'icon': Icons.swap_vertical_circle_rounded, 'index': 1},
   // {'title': 'Impacto', 'icon': Icons.lightbulb_outline, 'index': 2},
    {'title': 'Impacto', 'icon': Icons.lightbulb_outline, 'index': 2},
    {'title': 'Extracao'.tr, 'icon': Icons.archive_outlined, 'index': 3},
    {'title': 'Vecto X Proposto', 'icon': Icons.auto_graph_outlined, 'index': 4},
    {'title': 'Home', 'icon': Icons.home, 'index': 5},
  ];

  ///SUB-MENUS DE AUXILIARES
  final List<Map<String, dynamic>> _auxiliaryItems = [
    {'title': 'cargos'.tr, 'table': 'cargo'},
    {'title': 'encargos_sociais'.tr, 'table': 'encargos_sociais'},
    {'title': 'fonte_receita'.tr, 'table': 'fonte_receita'},
    {'title': 'formacao'.tr, 'table': 'formacao'},
    {'title': 'regime_contratacao'.tr, 'table': 'regime_contratacao'},
    {'title': 'secretaria'.tr, 'table': 'secretaria'},
    {'title': 'area_atuacao'.tr, 'table': 'area_atuacao'},
  ];
  ///SUB-MENUS DE PROFESSORES
  final List<Map<String, dynamic>> _professorItems = [
    {'title': 'Professores', 'table': 'cargo','icon': Icons.person},
    {'title': 'Tabela Professor', 'table': 'encargos_sociais'},
    {'title': 'Professor Infantil', 'table': 'fonte_receita'},
  ];
  ///SUB-MENUS DE GRÁFICOS
  final List<Map<String, dynamic>> _graficosItems = [
    {'title': 'FUNDEB e execução', 'table': 'cargo','icon': Icons.person},
    {'title': 'Comparativo Fundeb e execuçao', 'table': 'encargos_sociais'},

  ];

  Widget _getContent() {
    final title = _currentPage;

    final auxItem = _auxiliaryItems.firstWhereOrNull((item) => item['title'] == title);
    if (auxItem != null) {
      final table = auxItem['table'];
      switch (table) {
        case 'cargo':
          return CargoLista(table: table, title: '');
        case 'encargos_sociais':
          return EncargoSocialLista(table: table);
        case 'fonte_receita':
          return FonteReceitaLista(table: table);
        default:
          return ListaCodDescri(key: ValueKey(table), table: table, title: '');
      }
    }

    final pageMap = <String, Widget>{
      'professores'.tr: Professores(),
      'Simulador': SimuladorExecuta(),
    //  'Impacto': ImpactoMain(),
      'Impacto': ImpactoGrid2(),
      'Extracao'.tr: PdfExtractorPage(),
      'Tabela Professor': SimuladorTabelaProfessor(),
      'Professor Infantil': TabelaProfessorInfantil(),
      'Vecto X Proposto': ProfessorVectoProposta(),
      'Comparativo Fundeb e execuçao': FundebChartSelector(),
      'FUNDEB e execução': Home(),
      'Home': FundebChartSelector(),
    };

    return pageMap[title] ?? Container();
  }

  void _changeAno(String? ano) {
    if (ano != null && ano != '00') {
      var bimestre=Utils.getBimestre()?? 'Primeiro Bimestre';
      final controller = Get.find<AnoBimestreController>();
      controller.atualizaAnoEBimestre(ano,bimestre); // atualiza o controller
     // Utils.snak('NO START MUDOU ANO', 'ANO $ano BISMESTRE $bimestre', false, Colors.green);
      atualizaNomeDasTabelas();
      setState(() {
        _currentAno = ano;
      });
    }
  }

  void _changeBimestre(String? bimestre) {
    if (bimestre != null && bimestre != '00') {
     var ano=Utils.getAno() ?? "25";
      final controller = Get.find<AnoBimestreController>();
      controller.atualizaAnoEBimestre(ano,bimestre); // atualiza o controller
     //Utils.snak('NO  MUDOU BOMESTRE', 'ANO $ano BISMESTRE $bimestre', false, Colors.green);
     // Utils.setBimestre(bimestre);
      atualizaNomeDasTabelas();

      setState(() {
        _currentBimestre = bimestre;
      });
    }
  }

  atualizaNomeDasTabelas(){
    try{
    String ano=Utils.getAno();
    String bimestre=Utils.getBimestre();

     TBFolha='a$ano$bimestre';
     TBVantagens='a_vantagens$ano$bimestre';
     TBTotalProfessor='a_total_professor$ano$bimestre';
     TBReceitaFundeb='a_receita_fundeb$ano$bimestre';

    ///USADAS NO SIMMULADOR
     TBInfantil='a_infantil$ano$bimestre';
     TBExercicio='a_exercicio$ano$bimestre';
     TBProfessor='a_professor$ano$bimestre';
     TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
    }catch (e) {
      Utils.snak('Atenção', 'Não tem imposrtação', false, Colors.red);
    }
  }

  /*
  void _onNavigationItemSelected(int index, [String? overrideTitle]) {
    //setState(() {
      //_currentTabIndex = index;
      //_currentPage = overrideTitle ?? _getPageFromIndex(index);

      final title = overrideTitle ?? _getPageFromIndex(index);
      setState(() {
        _currentTabIndex = index;
        _currentPage = title;
      });
      storage.write('lastPage', title); // <--- salva a última página

    //});
  }

   */

  void _onNavigationItemSelected(int index, [String? overrideTitle]) {
    final title = overrideTitle ?? _getPageFromIndex(index);
    setState(() {
      _currentTabIndex = index;
      _currentPage = title;
    });
    Utils.setPagina(title);
  }

  String _getPageFromIndex(int index) {
    final item = _mainNavigationItems.firstWhereOrNull((item) => item['index'] == index);
    return item?['title'] ?? 'Home';
  }

  start(){
    try {
      String ano = Utils.getAno();
      String bimestr = Utils.getBimestre();
      setState(() => temAnoBimestre = true);
    }catch (e) {
      setState(() => temAnoBimestre = false);
    }
  }

  @override
  void initState() {
    super.initState();
    start();
    // Recupera última página usada
    String? last = Utils.getPagina();
    if (last != null) {
      setState(() {
        _currentPage = last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) =>
        constraints.maxWidth < 600 ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {

    return !temAnoBimestre?Utils.vazio('aaaaa'):
      Column(
      children: [
        _buildAppBar(),
        Expanded(child: _getContent()),
        _buildBottomNavigationBar(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return  !temAnoBimestre?Row(
      children: [
        _buildNavigationDrawer(),
        Expanded(
          child: Column(
            children: [
              _buildAppBar(),
              _currentPage=='Extracao'?
              Expanded(
                child: Column(
                  children: [
                   // _buildAppBar(),
                    Expanded(child: _getContent()),
                  ],
                ),
              ):
              Expanded(child: Utils.vazio('Nenhum dados extraído para esse Ano/Bimestre')),
            ],
          ),
        ),
      ],
    )://Utils.vazio('bbbbb'):
          
    
    Row(
      children: [
        _buildNavigationDrawer(),
        Expanded(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _getContent()),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appBarColorCrypto,
      title: Texto(tit: _currentPage, cor: Colors.white),
      actions: [
        _anosDropdown(),
        const SizedBox(width: 16),
        _bimestreDropdown(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _anosDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentAno,
        dropdownColor: Colors.grey,
        onChanged: _changeAno,
        items: _anos.map((ano) {
          return DropdownMenuItem<String>(
            value: ano['code'],
            child: Texto(tit:ano['name']!,cor:Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _bimestreDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentBimestre,
        dropdownColor: Colors.grey,
        onChanged: _changeBimestre,
        items: _bimestres.map((bim) {
          return DropdownMenuItem<String>(
            value: bim['code'],
            child: Texto(tit:bim['name']!,cor: Colors.white,),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) => _onNavigationItemSelected(index),
      items: _mainNavigationItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon']),
          label: item['title'],
        );
      }).toList(),
    );
  }

  Widget _buildNavigationDrawer() {
    return Container(
      width: 240,
      color: Colors.grey[100],
      child: ListView(
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/images/Xmktec_logo.jpeg', height: 105),
          Texto(tit: 'title'.tr + ' V.010', cor: Colors.black54),
          const SizedBox(height: 20),
          _buildProfessoresExpansionTile(),
          _buildGraficosExpansionTile(),
          ..._mainNavigationItems.map((item) => _buildDrawerItem(item['title'], item['icon'], item['index'])),
          _buildAuxiliaryExpansionTile(),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index) {
    final isSelected = _currentPage == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
      selected: isSelected,
      onTap: () => _onNavigationItemSelected(index),
    );
  }

  ///MENU AUXILIARES
  Widget _buildAuxiliaryExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.settings,color: Colors.grey,),
      title: Texto(tit:'auxiliar'.tr, cor: Colors.grey),
      children: _auxiliaryItems.map((item) {
        final title = item['title'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Texto(tit:title, cor: isSelected ? Colors.black : Colors.grey),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999, title),
        );
      }).toList(),
    );
  }
  ///MENU PROFESSORES
  Widget _buildProfessoresExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.perm_contact_cal_sharp,color: Colors.grey,),
      title: Text('Professores', style: const TextStyle(color: Colors.grey)),
      children: _professorItems.map((item) {
        final title = item['title'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999, title),
        );
      }).toList(),
    );
  }
  ///MENU PROFESSORES
  Widget _buildGraficosExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.auto_graph_outlined),
      title: Texto(tit:'Gráficos', cor:Colors.grey ,),
      children: _graficosItems.map((item) {
        final title = item['title'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Texto(tit:title, cor: isSelected ? Colors.black : Colors.grey),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999, title),
        );
      }).toList(),
    );
  }
}

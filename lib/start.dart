import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auxiliares/cargo_lista.dart';
import 'auxiliares/encargo_social_lista.dart';
import 'auxiliares/fonte_receita_lista.dart';
import 'auxiliares/lista_cod_descri.dart';
import 'cianorte/import_page.dart';
import 'dashboard/dashboard_screen.dart';
import 'const/nome_tabelas.dart';
import 'grafico/grafico_fundeb_exercicio.dart';
import 'grafico/receita_municipio.dart';
import 'impacto/impacto_grid2.dart';
import 'import/pdfExtractorPage.dart';
import 'professor/professor_vecto_proposta.dart';
import 'professor/professores.dart';
import 'folha/tabela_professor.dart';
import 'services/anoBimestreListenerMixin.dart';
import 'services/ano_bimestre_controller.dart';
import 'services/progressaoScreen.dart';
import 'services/utils.dart';
import 'simulador/simula.dart';
import 'simulador/tabela_simulador.dart';
import 'simulador/vaaf.dart';
import 'widgets/texto.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> with AnoBimestreListenerMixin{
  final Color appBarColorCrypto = const Color(0xFF2459A9);
  String _currentPage = 'DashboardScreen';
  int _currentTabIndex = 0;
  String _currentAno = '00';
  String _currentBimestre = '00';
  bool temAnoBimestre=false;
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    //atualizaTela(ano,bimestre);
  }

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
   // {'title': 'Simulador', 'icon': Icons.swap_vertical_circle_rounded, 'index': 1},
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
  ///SUB-MENUS DE SIMULADOR
  final List<Map<String, dynamic>> _simuladorItems = [
    {'title': 'Simulador', 'table': 'cargo','icon': Icons.person},
    {'title': 'VAAF', 'table': 'encargos_sociais'},
    {'title': 'Tabelas', 'table': 'fonte_receita'},
  ];
  ///SUB-MENUS DE GRÁFICOS
  final List<Map<String, dynamic>> _graficosItems = [
    {'title': 'FUNDEB e execução', 'table': 'cargo','icon': Icons.person},
    {'title': 'Comparativo Fundeb e execuçao', 'table': 'encargos_sociais'},
    {'title': 'Receitas', 'table': 'encargos_sociais'},
  ];

  Widget _getContent() {
    final title = _currentPage;

    final auxItem = _auxiliaryItems.firstWhereOrNull((item) => item['title'] == title);
    if (auxItem != null) {
      final table = auxItem['table'];
      switch (table) {
        case 'cargo':
          return Simula();
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
      'Simulador': ProgressaoScreen(),
      'VAAF': VAAF(),
      'Tabelas': TabelasSimulador(),
      'Extracao'.tr: PdfExtractorPage(),
      'Impacto': ImpactoGrid2(),
      'Tabela Professor': SimuladorTabelaProfessor(
        key: ValueKey('SimuladorTabelaProfessor_normal'), // Chave única
        table: 'a_professor',tipo: 'ADULTO',
      ),
      'Professor Infantil': SimuladorTabelaProfessor(
        key: ValueKey('SimuladorTabelaProfessor_infantil'), // Chave única
        table: 'a_infantil',tipo: 'INFANTIL',
      ),

      'Vecto X Proposto': ProfessorVectoProposta(),
      'Comparativo Fundeb e execuçao': FundebChartSelector(),
      'Receitas': GraficoReceitaMunicipio(),
      'Home': DashboardScreen(),
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
    if (bimestre != null && bimestre != '01') {
     var ano=Utils.getAno() ?? "25";
      final controller = Get.find<AnoBimestreController>();
      controller.atualizaAnoEBimestre(ano,bimestre); // atualiza o controller
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

    ///USADAS NO SIMMULADOR
     TBInfantil='a_infantil$ano$bimestre';
     TBExercicio='a_exercicio$ano$bimestre';
     TBProfessor='a_professor$ano$bimestre';
     TBReceitaFundebSimulador='a_receita_fundeb_simulador$ano$bimestre';
    }catch (e) {
      Utils.snak('Atenção', 'Não tem imposrtação', false, Colors.red);
    }
  }

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
      final controller = Get.find<AnoBimestreController>();
      controller.atualizaAnoEBimestre('25','01'); // atualiza o controller
      atualizaNomeDasTabelas();
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
    return Column(
      children: [
        _buildAppBar(),
        Expanded(child: _getContent()),
        _buildBottomNavigationBar(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return
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
          Center(
            child: Texto(tit: 'title'.tr + ' V.011', cor: Colors.black54),
          ),

          const SizedBox(height: 20),
          _buildProfessoresExpansionTile(),
          _buildSimuladorExpansionTile(),
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

  ///MENU SIMULADOR
  Widget _buildSimuladorExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.swap_vertical_circle_rounded,color: Colors.grey,),
      title: Text('Simulador', style: const TextStyle(color: Colors.grey)),
      children: _simuladorItems.map((item) {
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

  ///MENU GRAFICOS
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

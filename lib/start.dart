
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
import 'professor/professor_conferencia.dart';
import 'professor/professores.dart';
import 'folha/tabela_professor.dart';
import 'services/anoBimestreListenerMixin.dart';
import 'services/ano_bimestre_controller.dart';
import 'services/progressaoScreen.dart';
import 'services/utils.dart';
import 'simulador/simula.dart';
import 'simulador/tabela_simulador.dart';
import 'simulador/projecao_recursos_fundeb.dart';
import 'widgets/texto.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}
/*
class _StartState extends State<Start> with AnoBimestreListenerMixin{
  final Color appBarColorCrypto = const Color(0xFF2459A9);
  String _currentPage = 'Home';
  String _tituloDaPagina='DashBoard';
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
    {'title': 'Home', 'icon': Icons.home, 'index': 5,'tituloTela':'DashBoard'},
    {'title': 'Impacto', 'icon': Icons.lightbulb_outline, 'index': 2,'tituloTela':'Impacto'},
    {'title': 'Extracao'.tr, 'icon': Icons.archive_outlined, 'index': 3,'tituloTela':'Extração'},
  ];

  ///SUB-MENUS DE AUXILIARES
  final List<Map<String, dynamic>> _auxiliaryItems = [
    {'title': 'cargos'.tr, 'table': 'cargo','tituloTela':'Cargos'},
    {'title': 'encargos_sociais'.tr, 'table': 'encargos_sociais','tituloTela':'Encargos Sociais'},
    {'title': 'fonte_receita'.tr, 'table': 'fonte_receita','tituloTela':'Fonte de Receita'},
    {'title': 'formacao'.tr, 'table': 'formacao','tituloTela':'Formação'},
    {'title': 'regime_contratacao'.tr, 'table': 'regime_contratacao','tituloTela':'Regime Contratação'},
    {'title': 'secretaria'.tr, 'table': 'secretaria','tituloTela':'Secretarias'},
    {'title': 'area_atuacao'.tr, 'table': 'area_atuacao','tituloTela':'Area de Atuação'},
  ];
  ///SUB-MENUS DE PROFESSORES
  final List<Map<String, dynamic>> _professorItems = [
    {'title': 'Professores', 'table': 'cargo','icon': Icons.person,'tituloTela':'Professores'},
    {'title': 'Professor Educador', 'table': 'encargos_sociais','tituloTela':'Professor Educador'},
    {'title': 'Professor Infantil', 'table': 'fonte_receita','tituloTela':'Professor Infantil'},
    {'title': 'Conferência', 'icon': Icons.auto_graph_outlined, 'index': 4,'tituloTela':'Conferência'},
  ];
  ///SUB-MENUS DE SIMULADOR
  final List<Map<String, dynamic>> _simuladorItems = [
    {'title': 'Simulador', 'table': 'cargo','icon': Icons.person,'tituloTela':'Simulador'},
    {'title': 'VAAF', 'table': 'encargos_sociais','tituloTela':'VAAF'},
    {'title': 'Tabelas', 'table': 'fonte_receita','tituloTela':'Projeção de Recursos'},
  ];
  ///SUB-MENUS DE GRÁFICOS
  final List<Map<String, dynamic>> _graficosItems = [
    {'title': 'FUNDEB e execução', 'table': 'cargo','icon': Icons.person,'tituloTela':'Gra'},
    {'title': 'Comparativo Fundeb e execuçao', 'table': 'encargos_sociais','tituloTela':'Comparativo FUNDEB'},
    {'title': 'Receitas', 'table': 'encargos_sociais','tituloTela':'Receitas'},
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
      'Tabelas': ProjecaoDeRecursos(),
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

  void _onNavigationItemSelected(int index, String titPagina,[String? overrideTitle]) {
    final title = overrideTitle ?? _getPageFromIndex(index);
    setState(() {
      _currentTabIndex = index;
      _currentPage = title;
      _tituloDaPagina=titPagina;

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
      title: Texto(tit: _tituloDaPagina, cor: Colors.grey.shade200,tam: 20,),

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
      onTap: (index) => _onNavigationItemSelected(index,''),
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
            child: Texto(tit: 'title'.tr + ' V.012', cor: Colors.black54),
          ),

          const SizedBox(height: 20),
          ..._mainNavigationItems.map((item) => _buildDrawerItem(
              item['title'], item['icon'], item['index'],item['tituloTela'])
          ),
          _buildProfessoresExpansionTile(),
          _buildSimuladorExpansionTile(),
          _buildGraficosExpansionTile(),
          _buildAuxiliaryExpansionTile(),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, int index,String titPagina) {
    final isSelected = _currentPage == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
      title: Text(titPagina, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
      selected: isSelected,
      onTap: () => _onNavigationItemSelected(index, titPagina),
    );
  }

  ///MENU AUXILIARES
  Widget _buildAuxiliaryExpansionTile() {
    return ExpansionTile(
      leading: const Icon(Icons.settings,color: Colors.grey,),
      title: Texto(tit:'auxiliar'.tr, cor: Colors.grey),
      children: _auxiliaryItems.map((item) {
        final title = item['tituloTela'];
        final tituloTela = item['tituloTela'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Texto(tit:title, cor: isSelected ? Colors.black : Colors.grey),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999,tituloTela, title),
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
        final tituloTela = item['tituloTela'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999,tituloTela, title),
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
        final titleMenuLateral = item['title'];
        final tituloTela = item['tituloTela'];
        final isSelected = _currentPage == titleMenuLateral;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          ///Descrição do menu lateral
          ///Não influencia nas chamadas
          title: Text(titleMenuLateral, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
          // title: Text(title, style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999,tituloTela, titleMenuLateral),
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
        final tituloTela = item['tituloTela'];
        final isSelected = _currentPage == title;
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Texto(tit:title, cor: isSelected ? Colors.black : Colors.grey),
          selected: isSelected,
          onTap: () => _onNavigationItemSelected(999,tituloTela, title),
        );
      }).toList(),
    );
  }
}

 */

// dentro do seu arquivo start.dart

class _StartState extends State<Start> with AnoBimestreListenerMixin {
  final Color appBarColorCrypto = const Color(0xFF2459A9);
  bool temAnoBimestre=false;

  // === 1. FONTE DA VERDADE PARA NAVEGAÇÃO ===
  late final List<Map<String, dynamic>> _allPages;

  // === 2. ESTADO REATORADO ===
  String _currentPageId = 'home'; // Usamos um ID único, não um título

  // Demais variáveis de estado
  String _currentAno = '00';
  String _currentBimestre = '00';
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    // Sua lógica aqui, se necessário
  }

  // Listas para os Dropdowns
  final List<Map<String, String>> _anos = [
    {'code': '00', 'name': 'Escolha o Ano'},
    {'code': '25', 'name': '2025'},
    // ... outros anos
  ];
  final List<Map<String, String>> _bimestres = [
    {'code': '00', 'name': 'Escolha o Bimestre'},
    {'code': '01', 'name': 'Primeiro Bimestre'},
    // ... outros bimestres
  ];

  @override
  void initState() {
    super.initState();
    _initializePages(); // Inicializa a lista de páginas
    start();

    // Recupera a última página pelo ID
    String? lastPageId = Utils.getPagina();
    if (lastPageId != null && _allPages.any((p) => p['id'] == lastPageId)) {
      _navigateTo(lastPageId);
    }
  }
  /*
    'professores'.tr: Professores(),
      'Simulador': ProgressaoScreen(),
      'VAAF': VAAF(),
      'Tabelas': ProjecaoDeRecursos(),
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
   */

  void _initializePages() {
    // Definimos todas as páginas em um só lugar
    _allPages = [
      // === GRUPO: MAIN ===
      {
        'id': 'home',
        'group': 'main',
        'drawerLabel': 'Home',
        'appBarTitle': 'Dashboard',
        'icon': Icons.home,
        'builder': () => DashboardScreen(),
      },
      {
        'id': 'impacto',
        'group': 'main',
        'drawerLabel': 'Impacto',
        'appBarTitle': 'Análise de Impacto',
        'icon': Icons.lightbulb_outline,
        'builder': () => ImpactoGrid2(),
      },
      {
        'id': 'extracao',
        'group': 'main',
        'drawerLabel': 'Extração',
        'appBarTitle': 'Extração de Dados',
        'icon': Icons.archive_outlined,
        'builder': () => PdfExtractorPage(),
      },

      // === GRUPO: PROFESSORES ===
      {
        'id': 'prof_lista_normal',
        'group': 'professores',
        'drawerLabel': 'Professores',
        'appBarTitle': 'Lista de Professores',
        'builder': () => Professores(),
      },
      {
        'id': 'prof_educador',
        'group': 'professores',
        'drawerLabel': 'Professor Educador',
        'appBarTitle': 'Professor Educador ',
        'builder': () => SimuladorTabelaProfessor(
          key: const ValueKey('SimuladorTabelaProfessor_normal'),
          table: 'a_professor', tipo: 'NORMAL',
        ),
      },
      {
        'id': 'prof_infantil',
        'group': 'professores',
        'drawerLabel': 'Educador Infantil',
        'appBarTitle': 'Educadores Infantis',
        'builder': () => SimuladorTabelaProfessor(
          key: const ValueKey('SimuladorTabelaProfessor_infantil'),
          table: 'a_infantil', tipo: 'INFANTIL',
        ),
      },

      {
        'id': 'prof_conferencia',
        'group': 'professores',
        'drawerLabel': 'Conferência',
        'appBarTitle': 'Conferência',
        'builder': () => ProfessorConferencia(),
      },

      // === GRUPO: SIMULADOR ===
      {
        'id': 'simulador_progressao',
        'group': 'simulador',
        'drawerLabel': 'Simulador',
        'appBarTitle': 'Simulador de Progressão',
        'builder': () => ProgressaoScreen(),
      },
      {
        'id': 'simulador_vaaf',
        'group': 'simulador',
        'drawerLabel': 'Projeção dos Recursos \ndo FUNDEB',
        'appBarTitle': 'Projeção dos Recursos do FUNDEB',
        'builder': () => ProjecaoRecursosFundeb(),
      },
      {
        'id': 'simulador_projecao',
        'group': 'simulador',
        'drawerLabel': 'Projeção de Recursos',
        'appBarTitle': 'Projeção de Recursos',
        'builder': () => ProjecaoDeRecursos(),
      },
      {
        'id': 'simulador_magisterio',
        'group': 'simulador',
        'drawerLabel': 'Simulador Magistério',
        'appBarTitle': 'Simulador Magistério',
        'builder': () => const Simula(), // A tela que você está trabalhando
      },

      // === GRUPO: GRÁFICOS ===
      {
        'id': 'grafico_comparativo_fundeb',
        'group': 'graficos',
        'drawerLabel': 'Comparativo FUNDEB',
        'appBarTitle': 'Gráfico: Comparativo FUNDEB',
        'builder': () => FundebChartSelector(),
      },
      {
        'id': 'grafico_receitas',
        'group': 'graficos',
        'drawerLabel': 'Receitas',
        'appBarTitle': 'Gráfico: Receitas do Município',
        'builder': () => GraficoReceitaMunicipio(),
      },

      // === GRUPO: AUXILIARES ===
      {
        'id': 'aux_cargos',
        'group': 'auxiliares',
        'drawerLabel': 'Cargos',
        'appBarTitle': 'Cadastro de Cargos',
        'builder': () => CargoLista(table: 'cargo', title: 'xxxx',),
      },
      {
        'id': 'aux_encargos',
        'group': 'auxiliares',
        'drawerLabel': 'Encargos Sociais',
        'appBarTitle': 'Cadastro de Encargos Sociais',
        'builder': () => EncargoSocialLista(table: 'encargos_sociais'),
      },
      // ... Adicione os outros auxiliares aqui no mesmo formato
    ];
  }

  // === 3. LÓGICA DE NAVEGAÇÃO SIMPLIFICADA ===
  void _navigateTo(String pageId) {
    if (_allPages.any((p) => p['id'] == pageId)) {
      setState(() {
        _currentPageId = pageId;
      });
      Utils.setPagina(pageId); // Salva o ID único
    }
  }

  // === 4. GETCONTENT SIMPLIFICADO ===
  Widget _getContent() {
    final page = _allPages.firstWhere(
          (p) => p['id'] == _currentPageId,
      orElse: () => _allPages.firstWhere((p) => p['id'] == 'home'), // Fallback seguro
    );
    // Chama a função builder para criar o widget
    return (page['builder'] as Widget Function())();
  }

  Map<String, dynamic> get _currentPageData {
    return _allPages.firstWhere(
          (p) => p['id'] == _currentPageId,
      orElse: () => _allPages.firstWhere((p) => p['id'] == 'home'),
    );
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


  // === 5. UI ATUALIZADA ===
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
    return Row(
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
      // O título vem da nossa fonte da verdade
      title: Texto(tit: _currentPageData['appBarTitle'], cor: Colors.grey.shade200, tam: 20),
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
    final mainItems = _allPages.where((p) => p['group'] == 'main').toList();
    // Encontra o índice correto para a seleção
    final currentIndex = mainItems.indexWhere((p) => p['id'] == _currentPageId);

    return BottomNavigationBar(
      currentIndex: currentIndex != -1 ? currentIndex : 0,
      onTap: (index) => _navigateTo(mainItems[index]['id']),
      items: mainItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon']),
          label: item['drawerLabel'],
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
          Center(child: Texto(tit: 'title'.tr + ' V.012', cor: Colors.black54)),
          const SizedBox(height: 20),

          // Itens principais
          ..._allPages
              .where((p) => p['group'] == 'main')
              .map((item) => _buildDrawerItem(item)),

          // Menus expansíveis
          _buildExpansionTile('professores', 'Professores', Icons.perm_contact_cal_sharp),
          _buildExpansionTile('simulador', 'Simulador', Icons.swap_vertical_circle_rounded),
          _buildExpansionTile('graficos', 'Gráficos', Icons.auto_graph_outlined),
          _buildExpansionTile('auxiliares', 'Auxiliares', Icons.settings),
        ],
      ),
    );
  }

  // Widget de item de gaveta genérico
  Widget _buildDrawerItem(Map<String, dynamic> pageData) {
    final isSelected = _currentPageId == pageData['id'];
    return ListTile(
      leading: Icon(pageData['icon'], color: isSelected ? Colors.black : Colors.grey),
      title: Text(pageData['drawerLabel'], style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
      selected: isSelected,
      onTap: () => _navigateTo(pageData['id']),
    );
  }

  // Widget de menu expansível genérico
  Widget _buildExpansionTile(String groupName, String title, IconData icon) {
    // Filtra as páginas que pertencem a este grupo
    final items = _allPages.where((p) => p['group'] == groupName).toList();
    return ExpansionTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      children: items.map((item) {
        final isSelected = _currentPageId == item['id'];
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Text(item['drawerLabel'], style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
          selected: isSelected,
          onTap: () => _navigateTo(item['id']),
        );
      }).toList(),
    );
  }
}


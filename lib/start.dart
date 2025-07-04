
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

 */

class _StartState extends State<Start> with AnoBimestreListenerMixin {
  final Color appBarColorCrypto = const Color(0xFF2459A9);
  late final List<Map<String, dynamic>> _allPages;
  String _currentPageId = 'home';
  String _currentAno = '25'; // Default para evitar '00'
  String _currentBimestre = '01'; // Default para evitar '00'
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    // Sua lógica aqui, se necessário
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

  @override
  void initState() {
    super.initState();
    _initializePages();
    start();
    String? lastPageId = Utils.getPagina();
    if (lastPageId != null && _allPages.any((p) => p['id'] == lastPageId)) {
      _navigateTo(lastPageId);
    }
  }

  void _initializePages() {
    Utils.setAno('25');
    Utils.setBimestre('01');
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

  void _navigateTo(String pageId, {bool fromDrawer = false}) {
    if (_allPages.any((p) => p['id'] == pageId)) {
      // Se a navegação veio da gaveta mobile, fecha a gaveta.
      if (fromDrawer && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      setState(() {
        _currentPageId = pageId;
      });
      Utils.setPagina(pageId);
    }
  }

  Widget _getContent() {
    final page = _allPages.firstWhere(
          (p) => p['id'] == _currentPageId,
      orElse: () => _allPages.firstWhere((p) => p['id'] == 'home'),
    );
    return (page['builder'] as Widget Function())();
  }

  Map<String, dynamic> get _currentPageData {
    return _allPages.firstWhere((p) => p['id'] == _currentPageId, orElse: () => _allPages.firstWhere((p) => p['id'] == 'home'));
  }

  // Suas funções de lógica (start, _changeAno, etc.) permanecem as mesmas.
  void start() {/*...*/}
  void _changeAno(String? ano) {/*...*/}
  void _changeBimestre(String? bimestre) {/*...*/}
  void atualizaNomeDasTabelas() {/*...*/}

  // ===================================================================
  // ESTRUTURA DE UI RESPONSIVA
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O LayoutBuilder decide qual layout principal usar.
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) { // Ponto de quebra para mobile/tablet
            return _buildMobileLayout();
          } else {
            return _buildDesktopLayout();
          }
        },
      ),
    );
  }

  // --- LAYOUT DESKTOP ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildNavigationDrawer(), // Gaveta lateral fixa
        Expanded(
          child: Column(
            children: [
              _buildDesktopAppBar(),
              Expanded(child: _getContent()),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildDesktopAppBar() {
    return AppBar(
      backgroundColor: appBarColorCrypto,
      elevation: 1,
      automaticallyImplyLeading: false, // Não mostra o botão de voltar/menu
      title: Texto(tit: _currentPageData['appBarTitle'], cor: Colors.white, tam: 20),
      actions: [
        _buildFilterControls(), // Filtros ficam na AppBar no desktop
        const SizedBox(width: 16),
      ],
    );
  }

  // --- LAYOUT MOBILE ---
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildMobileAppBar(),
      // Usamos a MESMA gaveta do desktop, mas agora ela é acessível pelo ícone.
      drawer: _buildNavigationDrawer(),
      body: Column(
        children: [
          _buildFilterControls(), // Filtros ficam no TOPO do conteúdo no mobile
          const Divider(height: 1),
          Expanded(child: _getContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: appBarColorCrypto,
      elevation: 1,
      // O ícone da gaveta (hambúrguer) aparecerá automaticamente
      title: Text(_currentPageData['appBarTitle'], style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  // --- WIDGETS COMPARTILHADOS ---

  /// Controles de filtro (Ano e Bimestre) extraídos para um widget separado.
  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: appBarColorCrypto, // Fundo consistente
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para não ocupar a linha toda no mobile
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _anosDropdown(),
          const SizedBox(width: 24),
          _bimestreDropdown(),
        ],
      ),
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

  /// Gaveta de Navegação - Usada por AMBOS os layouts.
  Widget _buildNavigationDrawer() {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: [
          Column(
            children: [
              SizedBox(
                height: 150,
                child: Center(
                  child: Image.asset('assets/images/Xmktec_logo.jpeg', height: 105),
                ),
              ),
              Texto(tit:'V.014'),
            ],
          ),

          ..._allPages.where((p) => p['group'] == 'main').map((item) => _buildDrawerItem(item)),
          const Divider(),
          _buildExpansionTile('professores', 'Professores', Icons.perm_contact_cal_sharp),
          _buildExpansionTile('simulador', 'Simulador', Icons.swap_vertical_circle_rounded),
          _buildExpansionTile('graficos', 'Gráficos', Icons.auto_graph_outlined),
          _buildExpansionTile('auxiliares', 'Auxiliares', Icons.settings),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(Map<String, dynamic> pageData) {
    final isSelected = _currentPageId == pageData['id'];
    return ListTile(
      leading: Icon(pageData['icon'], color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(
        pageData['drawerLabel'],
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      onTap: () => _navigateTo(pageData['id'], fromDrawer: true), // Passa o parâmetro
    );
  }

  Widget _buildExpansionTile(String groupName, String title, IconData icon) {
    final items = _allPages.where((p) => p['group'] == groupName).toList();
    // Verifica se alguma página dentro deste grupo está selecionada, para manter o Tile expandido.
    bool isExpanded = items.any((item) => item['id'] == _currentPageId);

    return ExpansionTile(
      key: PageStorageKey(groupName), // Mantém o estado (aberto/fechado)
      initiallyExpanded: isExpanded,
      leading: Icon(icon, color: isExpanded ? Theme.of(context).primaryColor : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isExpanded ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      children: items.map((item) {
        final isSelected = _currentPageId == item['id'];
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 50.0),
          title: Text(
            item['drawerLabel'],
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () => _navigateTo(item['id'], fromDrawer: true),
        );
      }).toList(),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auxiliares/usuario_lista.dart';
import 'const/const.dart';
import 'const/nome_tabelas.dart';
import 'dashboard/dashboard_screen.dart';
import 'doc/document_screen.dart';
import 'impacto/impacto_grid2.dart';
import 'import/pdfExtractorPage.dart';
import 'professor/professor_conferencia.dart';
import 'professor/professores.dart';
import 'folha/tabela_professor.dart';
import 'services/escolher_municipio.dart';
import 'services/progressaoScreen.dart';
import 'services/utils.dart';
import 'simulador/simula.dart';
import 'simulador/tabela_simulador.dart';
import 'simulador/projecao_recursos_fundeb.dart';
import 'widgets/texto.dart';
import 'package:GEM/services/GlobalFilterController.dart';

class Start extends StatefulWidget {
  var acessos;

   Start({
    super.key,
    this.acessos,
  });

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  late List<Map<String, dynamic>> _allPages=[];
  String _currentPageId = 'home';
  String _currentAno = '25'; // Default para evitar '00'
  String _currentBimestre = '01'; // Default para evitar '00'
  bool temAnoBimestre=false;
  String _cidadeSelecionada = 'Dois Vizinhos';
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

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

  void _initializePages(){
   // Utils.setUserMunicipio('a_');
    String muni=Utils.getUserMunicipio();
    ///pega os direitos de acesso

    _allPages = [
      // === GRUPO: MAIN ===
      {
        'id': 'home',
        'group': 'main',
        'drawerLabel': 'Home',
        'appBarTitle': 'Dashboard',
        'icon': Icons.home,
        'builder': () => DashboardScreen(userName: Utils.getUserName(),),
      },
      ///EXTRACÃO DE DADOS
      {
        'id': 'extracao',
        'group': 'main',
        'drawerLabel': 'Extração de Dados',
        'appBarTitle': 'Extração de Dados',
        'icon': Icons.archive_outlined,
        'builder': () => PdfExtractorPage(),
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
          table: '${muni}professor', tipo: 'NORMAL',
        ),
      },
      {
        'id': 'prof_infantil',
        'group': 'professores',
        'drawerLabel': 'Educador Infantil',
        'appBarTitle': 'Educadores Infantis',
        'builder': () => SimuladorTabelaProfessor(
          key: const ValueKey('SimuladorTabelaProfessor_infantil'),
          table: '${muni}infantil', tipo: 'INFANTIL',
        ),
      },
      {
        'id': 'prof_conferencia',
        'group': 'professores',
        'drawerLabel': 'Folha de Pagamento',
        'appBarTitle': 'Folha de Pagamento',
        'builder': () => ProfessorConferencia(),
      },

      // === GRUPO: IMPÁCTO ===
      {
        'id': 'impacto',
        'group': 'impacto',
        'drawerLabel': 'Impacto',
        'appBarTitle': 'Análise de Impacto',
        'icon': Icons.lightbulb_outline,
        'builder': () => ImpactoGrid2(),
      },

      // === GRUPO: AUXILIARES ===
      {
        'id': 'aux_cargos',
        'group': 'auxiliares',
        'drawerLabel': 'Documentação',
        'appBarTitle': 'Documentação',
        'builder': () => DocumentScreen(sala: 'principal'),
      },
      {
        'id': 'aux_encargos',
        'group': 'auxiliares',
        'drawerLabel': 'Encargos Sociais',
        'appBarTitle': 'Cadastro de Encargos Sociais',
        'builder': () => PdfExtractorPage(),//importação dois vizinhos
        //'builder': () => ImportarVantagens(),// importação Rio Negrinho

      },
      {
        'id': 'aux_usuarios',
        'group': 'auxiliares',
        'drawerLabel': 'Usuários',
        'appBarTitle': 'Usuários',
        'builder': () => UsuariosLista(table: 'login', title: 'xxxx',),
      },
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

  void start() {
    atualizaNomeDasTabelas();
    setState(() => temAnoBimestre = true);
  }

  /*
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

   */

  void _changeAno(String? ano) {
    if (ano != null && ano != '00') {
      // Usa o novo controller para atualizar o estado global
      filterController.updateFilters(novoAno: ano);
      atualizaNomeDasTabelas();
      setState(() {
        _currentAno = ano;
      });
    }
  }

  // 6. CORRIJA a função _changeBimestre()
  void _changeBimestre(String? bimestre) {
    if (bimestre != null && bimestre != '00') { // O código do bimestre é '01', '02', etc.
      filterController.updateFilters(novoBimestre: bimestre);
      atualizaNomeDasTabelas();
      setState(() {
        _currentBimestre = bimestre;
      });
    }
  }
/*
  atualizaNomeDasTabelas(){
    try{
      String muni=Utils.getUserMunicipio();
      String ano=Utils.getAno();
      String bimestre=Utils.getBimestre();

      TBFolha='${muni}$ano$bimestre';
      TBVantagens='${muni}vantagens$ano$bimestre';
      TBTotalProfessor='${muni}total_professor$ano$bimestre';

      ///USADAS NO SIMMULADOR
      TBInfantil='${muni}infantil$ano$bimestre';
      TBExercicio='${muni}exercicio$ano$bimestre';
      TBProfessor='${muni}professor$ano$bimestre';
      TBReceitaFundebSimulador='${muni}receita_fundeb_simulador$ano$bimestre';
    }catch (e) {
      Utils.snak('Atenção', 'Não tem imposrtação', false, Colors.red);
    }
  }

 */

  void atualizaNomeDasTabelas() {
    try {
      // Lê os valores reativos diretamente do controller
      String muni = filterController.municipio.value;
      String ano = filterController.ano.value;
      String bimestre = filterController.bimestre.value;

      TBFolha = '${muni}$ano$bimestre';
      TBVantagens = '${muni}vantagens$ano$bimestre';
      TBTotalProfessor='${muni}total_professor$ano$bimestre';

      ///USADAS NO SIMMULADOR
       TBInfantil='${muni}infantil$ano$bimestre';
       TBExercicio='${muni}exercicio$ano$bimestre';
       TBProfessor='${muni}professor$ano$bimestre';
       TBReceitaFundebSimulador='${muni}receita_fundeb_simulador$ano$bimestre';
       TBVaaf='${muni}vaaf$ano$bimestre';
       TBTotais='${muni}totais$ano$bimestre';
       TBDecenio='${muni}decenio$ano$bimestre';
       TBImpostos='${muni}impostos$ano$bimestre';

      print('Tabelas atualizadas para: $TBFolha'); // Bom para depuração
    } catch (e) {
      Utils.snak('Atenção', 'Não tem importação', false, Colors.red);
    }
  }

  // ===================================================================
  // ESTRUTURA DE UI RESPONSIVA
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoOadrao,
      // O LayoutBuilder decide qual layout principal usar.
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) { // Ponto de quebra para mobile/tablet
            return _buildMobileLayout();
          } else {
            return _allPages.isEmpty?Container(): _buildDesktopLayout();
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
             // _buildDesktopAppBar(),
              Expanded(child: _getContent()),
            ],
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildDesktopAppBar() {
    return AppBar(
      backgroundColor: appBarColor,
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
      backgroundColor: corFundoOadrao,
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
      backgroundColor: appBarColor,
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
      color: appBarColor, // Fundo consistente
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
  Widget _buildNavigationDrawer() {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                /// Seletor de cidade
                if(Utils.getUserType()=='M')
                  Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CidadeSelector(
                    cidadeSelecionada: _cidadeSelecionada,
                    onChanged: (novaCidade) {
                      // O setState é apenas para a UI da Start (mudar o nome da cidade e a imagem)
                      setState(() {
                        _cidadeSelecionada = novaCidade;
                      });

                      // A lógica de negócio é centralizada
                      String novoMunicipioCode = 'a_'; // Padrão
                      if (novaCidade == 'Cianorte') {
                        novoMunicipioCode = 'cia_';
                      }

                      // ATUALIZE APENAS O CONTROLLER. Ele cuidará de persistir o dado com o Utils.
                      filterController.updateFilters(novoMunicipio: novoMunicipioCode);

                      // A chamada _initializePages() aqui pode ser necessária se a lista de páginas
                      // realmente depende do município (como no seu caso com SimuladorTabelaProfessor).
                      _initializePages();
                    },

                  ),
                ),

                /// Logo da cidade
                SizedBox(
                  height: 110,
                  child: Center(
                    child: Image.asset(
                      'assets/images/${_cidadeSelecionada}.png',
                      height: 105,
                    ),
                  ),
                ),
                ///Nome do município
                /*
                Texto(
                  tit: _cidadeSelecionada,
                  cor: Colors.black87,
                  tam: 18,
                ),

                 */

                ..._allPages.where((p) => p['group'] == 'main').map((item) => _buildDrawerItem(item)),
                const Divider(),

                if (widget.acessos != null)
                  if (widget.acessos[0]['simulador'] == '1')
                    _buildExpansionTile('simulador', 'Simulador', Icons.swap_vertical_circle_rounded),
                if (widget.acessos[0]['professores'] == '1')
                  _buildExpansionTile('professores', 'Professores', Icons.perm_contact_cal_sharp),
                if (widget.acessos[0]['impacto'] == '1')
                  _buildExpansionTile('impacto', 'Impácto', Icons.auto_graph_outlined),
                if (widget.acessos[0]['documentacao'] == '1')
                  _buildExpansionTile('auxiliares', 'Auxiliares', Icons.settings),
              ],
            ),
          ),

          // Rodapé
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: const Text(
              'Copyright © 2025 XmkTech. V.003\nAll rights reserved (41-9-9558-2579)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
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

import 'package:GEM/data/api_my_sql.dart';
import 'package:GEM/services/table_name_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auxiliares/usuario_lista.dart';
import 'const/const.dart';
import 'dashboard/dashboard_screen.dart';
import 'doc/document_screen.dart';
import 'impacto/impacto.dart';
import 'import/importar_dados.dart';
import 'import/pdfExtractorPage.dart';
import 'professor/professor_conferencia.dart';
import 'folha/tabela_professor.dart';
import 'services/escolher_municipio.dart';
import 'services/utils.dart';
import 'simulador/formulario/listaFormulariosScreen.dart';
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
  String _cidadeSelecionada = 'GEM';
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  //var horas;
  List<Map<String, String>> formItens = [];

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    start();
    String? lastPageId = Utils.getPagina();
    if (lastPageId != null && _allPages.any((p) => p['id'] == lastPageId)) {
      _navigateTo(lastPageId);
    }
  }

  void _loadDataBasedOnCurrentFilters() {
    start();
  }

  void _initializePages(){
    String muni = filterController.municipio.value;

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
        'builder': () => ExcelReaderPage(),
      },

      // === GRUPO: SIMULADOR ===

      {
        'id': 'simulador_progressao',
        'group': 'simulador',
        'drawerLabel': 'Estrutura Carreira',
        'appBarTitle': 'Simulador de Progressão',
        'builder': () => ListaFormulariosScreen(),
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

      /// ==========================================================
      /// Entradas dinâmicas para cada hora                        =
      /// ==========================================================
      ...formItens.map((itens) => {
        'id': 'prof_educador_${itens['id']}',
        'group': 'professores',
        'drawerLabel': '${itens['descricao']}',
        'appBarTitle': '${itens['descricao']}',
        'builder': () => SimuladorTabelaProfessor(
          key: ValueKey('SimuladorTabelaProfessor_${itens['id']}'),
          table: '${muni}professor',
          hora: itens['horas']!,
          idItens: itens['id']!,
          descricao: itens['descricao']!,
        ),
      }).toList(),

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
        'builder': () => Impacto(),
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

  void start() async{
    ///Pega as horas
    var getHoras=await ApiMySql.get(TBSimulaCab, null, null);
    formItens.clear();
    for(int i = 0 ; i<getHoras.length ; i++) {
      formItens.add({
        'id': getHoras[i]['id']?.toString() ?? 'Nome não disponível',
        'descricao': getHoras[i]['descricao'].toString(),
        'horas': getHoras[i]['horas'].toString(),
      });
    }

    setState(() {
      var cid= filterController.municipio.value;
       _cidadeSelecionada =Utils.getNomeMunicipio(cid);

    });
    _initializePages();
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
         // Filtros ficam na AppBar no desktop
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
         // Filtros ficam no TOPO do conteúdo no mobile
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
                    onChanged: (novaCidade) async{
                      // O setState é apenas para a UI da Start (mudar o nome da cidade e a imagem)
                      setState(() {
                        _cidadeSelecionada = novaCidade;
                      });
                      String novoMunicipioCode = 'a_';
                      switch (novaCidade) {
                        case 'GEM':
                          novoMunicipioCode = 'a_';
                        case 'Cianorte':
                          novoMunicipioCode = 'cia_';
                        case 'Indaial':
                          novoMunicipioCode = 'ind_';
                        case 'Rio Negro':
                          novoMunicipioCode = 'rne_';
                      }
                      // ATUALIZE APENAS O CONTROLLER. Ele cuidará de persistir o dado com o Utils.
                      filterController.updateFilters(novoMunicipio: novoMunicipioCode);
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

                ..._allPages.where((p) => p['group'] == 'main').map((item) => _buildDrawerItem(item)),
                const Divider(),

                if (widget.acessos != null)
                  if (widget.acessos[0]['simulador'] == '1')
                    _buildExpansionTile('simulador', 'Estrutura', Icons.swap_vertical_circle_rounded),

                if (widget.acessos[0]['professores'] == '1')
                  _buildExpansionTile('professores', 'Professores', Icons.perm_contact_cal_sharp),

                if (widget.acessos[0]['impacto'] == '1')
                  _buildExpansionTile('impacto', 'Impacto', Icons.auto_graph_outlined),

                if (widget.acessos[0]['folha_de_pagamento'] == '1')
                  _buildExpansionTile('professores', 'Folha de Pagamento', Icons.auto_graph_outlined),


                if (widget.acessos[0]['encargos_sociais'] == '1')
                  _buildExpansionTile('auxiliares', 'Encargos Sociais', Icons.settings),

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
              'Copyright © 2025 XmkTech. V.023\nAll rights reserved (41-9-9558-2579)',
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_flags/country_flags.dart';

import 'auxiliares/cargo_lista.dart';
import 'auxiliares/encargo_social_lista.dart';
import 'auxiliares/fonte_receita_lista.dart';
import 'auxiliares/lista_cod_descri.dart';
import 'data/api_my_sql.dart';
import 'impacto/impacto_main.dart';
import 'import/pdfExtractorPage.dart';
import 'professor/professor_lista.dart';
import 'simulador/executa_simulador.dart';
import 'widgets/texto.dart';

class Start extends StatefulWidget {
  const Start({Key? key}) : super(key: key);

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  // Constants
  static const _initialPage = 'Galeria';
  static const _initialLanguage = 'pt';
  static const _initialTabIndex = 0;

  // State variables
  String _currentPage = _initialPage;
  int _currentTabIndex = _initialTabIndex;
  String _currentLanguage = _initialLanguage;

  // Language options
  final List<Map<String, String>> _languages = [
    {'code': 'pt', 'country': 'BR', 'name': 'Português'},
    {'code': 'en', 'country': 'AU', 'name': 'English'},
    {'code': 'es', 'country': 'ES', 'name': 'Español'},
  ];

  // Navigation items
  final List<Map<String, dynamic>> _mainNavigationItems = [
    {'title': 'professores'.tr, 'icon': Icons.perm_contact_cal_sharp, 'index': 0},
    {'title': 'simulador'.tr, 'icon': Icons.calendar_month, 'index': 1},
    {'title': 'Impacto', 'icon': Icons.lightbulb_outline, 'index': 2},
    {'title': 'extracao', 'icon': Icons.lightbulb_outline, 'index': 3},
  ];

  final List<Map<String, dynamic>> _auxiliaryNavigationItems = [
    {'title': 'cargos'.tr, 'index': 4},
    {'title': 'encargos_sociais'.tr, 'index': 5},
    {'title': 'fonte_receita'.tr, 'index': 6},
    {'title': 'formacao'.tr, 'index': 7},
    {'title': 'regime_contratacao'.tr, 'index': 8},
    {'title': 'secretaria'.tr, 'index': 9},
    {'title': 'area_atuacao'.tr, 'index': 10},
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {

  }

  // Supondo que você já tenha recebido do seu endpoint uma variável `rawText` (String)
// com todo o conteúdo que você mostrou:

  /// Maps page names to database table names
  String _getTableFromPage(String page) {
    final pageToTableMap = {
      'cargos'.tr: 'cargo',
      'encargos_sociais'.tr: 'encargos_sociais',
      'fonte_receita'.tr: 'fonte_receita',
      'formacao'.tr: 'formacao',
      'regime_contratacao'.tr: 'regime_contratacao',
      'secretaria'.tr: 'secretaria',
      'area_atuacao'.tr: 'area_atuacao',
    };
    return pageToTableMap[page] ?? '';
  }

  /// Gets the appropriate content widget for the current page
  Widget _getContent() {
    final isAuxiliaryPage = _auxiliaryNavigationItems.any(
          (item) => item['title'] == _currentPage,
    );
    var tb=_getTableFromPage(_currentPage);
    if (isAuxiliaryPage) {
      ///mesmo sendo uma tabela auxiliar não é do tipo código e descrição
      if (_currentPage == 'cargos'.tr) {
        return CargoLista(table: tb,title: '',);
      }
      if (_currentPage == 'encargos_sociais'.tr) {
        return EncargoSocialLista(table: tb,);
      }
      if (_currentPage == 'fonte_receita'.tr) {
        return FonteReceitaLista(table: tb,);
      }

      /// Aqui são todas as tabelas que são código e descrição
      return  ListaCodDescri(
        key: ValueKey(tb), // <-- isso força o rebuild com base no nome da tabela
        table: tb,
        title: '',
      );
      /// QUEM NÃO É CÓDIGO E DESCRIÇÃO
    }else {

      if (_currentPage == 'professores'.tr) return ProfessorLista(table: 'professor',);
      if (_currentPage == 'simulador'.tr) return SimuladorExecuta();
      if (_currentPage == 'Impacto') return ImpactoMain();
      if (_currentPage == 'extracao') return PdfExtractorPage();



      // if (_currentPage == 'simulador'.tr) return Simulador();
      return Container();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 600
              ? _buildMobileLayout()
              : _buildDesktopLayout();
        },
      ),
    );
  }

  /// Builds the layout for mobile devices
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(child: _getContent()),
        _buildBottomNavigationBar(),
      ],
    );
  }

  /// Builds the layout for desktop devices
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

  /// Builds the app bar with language selector
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(_currentPage),
      actions: [
        _buildLanguageDropdown(),
        const SizedBox(width: 16),
      ],
    );
  }

  /// Builds the language dropdown selector
  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _currentLanguage,
        dropdownColor: Colors.white,
        onChanged: (String? value) {
          if (value != null) {
            _changeLanguage(value);
          }
        },
        items: _languages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang['code'],
            child: Row(
              children: [
                CountryFlag.fromCountryCode(
                  lang['country']!,
                  height: 20,
                  width: 30,
                ),
                const SizedBox(width: 8),
                Text(lang['name']!),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Handles language change
  void _changeLanguage(String languageCode) {
    final countryCode = languageCode == 'en'
        ? 'AU'
        : languageCode == 'pt'
        ? 'BR'
        : 'ES';

    Get.updateLocale(Locale(languageCode, countryCode));
    setState(() {
      _currentLanguage = languageCode;
      // Update page title after language change
      _currentPage = _getPageFromIndex(_currentTabIndex);
    });
  }

  /// Builds the bottom navigation bar for mobile
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

  /// Builds the navigation drawer for desktop
  Widget _buildNavigationDrawer() {
    return Container(
      width: 240,
      color: Colors.grey[100],
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/images/Xmktec_logo.jpeg', height: 105),
          Texto(tit: 'title'.tr+' V.003', cor: Colors.black54),
          const SizedBox(height: 20),
          ..._mainNavigationItems.map((item) => _buildDrawerItem(
            item['title'],
            item['icon'],
            item['index'],
          )),
          _buildDrawerItem(
            'auxiliar'.tr,
            Icons.settings,
            3,
            subItems: _auxiliaryNavigationItems,
          ),
        ],
      ),
    );
  }

  /// Builds a drawer navigation item (can have sub-items)
  Widget _buildDrawerItem(
      String title,
      IconData icon,
      int index, {
        List<Map<String, dynamic>>? subItems,
      }) {
    final bool isSelected = _currentPage == title;

    if (subItems == null || subItems.isEmpty) {
      return ListTile(
        leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.black : Colors.grey),
        ),
        selected: isSelected,
        onTap: () => _onNavigationItemSelected(index),
      );
    }

    return ExpansionTile(
      leading: Icon(icon, color: isSelected ? Colors.black : Colors.grey),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.black : Colors.grey),
      ),
      children: subItems.map((subItem) {
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 72.0),
          title: Text(
            subItem['title'],
            style: TextStyle(
              color: _currentPage == subItem['title']
                  ? Colors.black
                  : Colors.grey,
            ),
          ),
          selected: _currentPage == subItem['title'],
          onTap: () => _onNavigationItemSelected(subItem['index']),
        );
      }).toList(),
    );
  }

  /// Handles navigation item selection
  void _onNavigationItemSelected(int index) {
    setState(() {
      _currentTabIndex = index;
      _currentPage = _getPageFromIndex(index);
    });
  }

  /// Maps index to page title
  String _getPageFromIndex(int index) {
    if (index >= 4 && index <= 11) {
      return _auxiliaryNavigationItems[index - 4]['title'];
    }

    switch (index) {
      case 0:
        return 'professores'.tr;
      case 1:
        return 'simulador'.tr;
      case 2:
        return 'Impacto';
      case 3:
        return 'extracao'.tr;
      default:
        return 'putro'.tr;
    }
  }
}
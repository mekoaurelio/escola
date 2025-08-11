import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../const/const.dart';
import '../data/database_structure_builder.dart';
import '../indicadores/calculadora.dart';
import '../indicadores/educationImpactPage.dart';
import '../indicadores/educationalReceiptsScreen.dart';
import '../indicadores/pacDashboardPage.dart';
import '../indicadores/receiptsDemonstrativePage.dart';
import '../login/login.dart';
import '../services/utils.dart';
import '../simulador/simula.dart';
import '../widgets/texto.dart';
import 'package:GEM/services/GlobalFilterController.dart';
// ==========================================================
// 1. O Layout Principal da Aplicação
// ==========================================================

class MainLayout extends StatelessWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos um Scaffold para a estrutura geral da página
    return Scaffold(
      body: Row(
        children: [
          // A Sidebar fica fixa à esquerda
          const Sidebar(),

          // O conteúdo principal ocupa o resto do espaço
          Expanded(
            child: Column(
              children: [
                // A AppBar customizada fica no topo
                const CustomAppBar(),

                // O conteúdo da tela (seu DashboardScreen) ocupa o restante do espaço
                Expanded(
                  child: DashboardScreen(userName: Utils.getUserName(),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 2. A Sidebar (Menu Lateral)
// ==========================================================
class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            // Substitua por seu logo real
            child: Image.network('https://i.imgur.com/k2gU3xQ.png', height: 120),
          ),
          const Divider(height: 1),
          _SidebarMenuItem(
            icon: Icons.grid_view_rounded,
            title: 'Home',
            isSelected: true, // Marca o item "Home" como selecionado
            onTap: () {},
          ),
          _SidebarMenuItem(
            icon: Icons.upload_file,
            title: 'Extração de Dados',
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),
          // Itens expansíveis
          _SidebarExpansionItem(
            icon: Icons.calculate,
            title: 'Simulador',
            children: ['Magistério', 'Outro Simulador'],
          ),
          _SidebarExpansionItem(
            icon: Icons.group,
            title: 'Professores',
            children: ['Lista', 'Cadastro'],
          ),
          _SidebarExpansionItem(
            icon: Icons.insights,
            title: 'Impacto',
            children: ['Relatórios', 'Gráficos'],
          ),
          _SidebarExpansionItem(
            icon: Icons.support_agent,
            title: 'Auxiliares',
            children: ['Suporte', 'Configurações'],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 3. A AppBar Customizada (Barra Superior)
// ==========================================================
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Barra de Pesquisa
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Pesquise aqui',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Ícones da direita
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            // Substitua pela imagem do usuário
            backgroundImage: NetworkImage('https://i.imgur.com/gK1f1wz.png'),
            radius: 18,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}

// ==========================================================
// 4. O seu DashboardScreen, agora como conteúdo principal
// ==========================================================
class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreen();

}

class _DashboardScreen extends State<DashboardScreen> {
  String _currentAno = '25'; // Default para evitar '00'
  String _currentBimestre = '01'; // Default para evitar '00'
  final GlobalFilterController _filterController = Get.find<GlobalFilterController>();


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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Seção de Boas-vindas e Filtros ---
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      // Chama a nova função estática
                      onTap: () =>changeUser(context),
                      child: Text('Bem-vindo, ${widget.userName}!',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildFilterControls(),
/*
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFilterChip('2025'),
                        const SizedBox(width: 16),
                        _buildFilterChip('Primeiro Bimestre'),
                      ],
                    )

 */
                  ],
                ),
                SizedBox(width: 10,),
                // --- Banner de Educação ---
                Column(
                  children: [
                    Container(
                      width: 720,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo_main.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                )

              ],
            ),
            const SizedBox(height: 24),
            // --- Grid de Cards ---
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetricCard(
                  context: context,
                  title: "Simulador Magistério",
                  previewWidget: const Simula(),
                ),
                _buildMetricCard(
                  context: context,
                  title: "Calculadora IQEP - Icms educação",
                  previewWidget: const IcmsDashboardPage(),
                ),
                _buildMetricCard(
                  context: context,
                  title: "Demonstrativos Das Receitas De Educação",
                  previewWidget: const ReceiptsDemonstrativePage(),
                ),
                _buildMetricCard(
                  context: context,
                  title: "Programa De Aceleração Do Crescimento",
                  previewWidget: const PacDashboardPage(),
                ),
                _buildMetricCard(
                  context: context,
                  title: "Impacto Da Educação",
                  previewWidget: const EducationImpactPage(),
                ),
                _buildMetricCard(
                  context: context,
                  title: "Receitas Educacionais",
                  previewWidget: const EducationalReceiptsPage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void changeUser(BuildContext context)async{
    final bool confirmar = await Utils.showDlg(
      'Atenção',
      'Deseja trocar de usuário?',
      context,
      'Sim',
      'Não',
    );
    if (confirmar) {
      Utils.setIdUser('');
      Utils.setUserName('');
      Utils.setUserMunicipio('');
      Utils.setUserType('');
      Get.offAll(() => Login(), arguments: {});
    }
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required Widget previewWidget,
  }) {
    return SizedBox(
      width: 500, // Ajuste a largura conforme necessário
      height: 400, // Ajuste a altura conforme necessário
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => FullScreenPage(
                title: title,
                child: previewWidget,
              ),
            ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- O TÍTULO (Permanece o mesmo) ---
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade700,
                child: Text(
                  title,
                  textAlign: TextAlign.center, // Centralizar o texto do título também melhora a aparência
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // --- A ÁREA DA MINIATURA (Corrigida) ---
              Expanded(
                child: Container(
                  color: Colors.white,
                  // 1. ADICIONADO: O widget Center para posicionar a miniatura no meio do espaço.
                  child: Center(
                    child: IgnorePointer(
                      child: Transform.scale(
                        // Pode ser necessário ajustar a escala para um visual melhor
                        scale: 0.45,
                        // 2. ALTERADO: O alinhamento da transformação para o centro.
                        alignment: Alignment.center,
                        child: OverflowBox(
                          // O OverflowBox continua sendo a abordagem correta aqui
                          maxWidth: 1000,
                          maxHeight: 700,
                          child: previewWidget,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeAno(String? ano) async{
    if (ano != null && ano != '00') {
      _criaEsturaDasTabelas();
      setState(() {
        _currentAno = ano;
      });
    }
  }

  void _criaEsturaDasTabelas()async {
    final _muni = _filterController.municipio.value;
    // 2. Cria uma instância do Builder
    final builder = DatabaseStructureBuilder(
      municipio: _muni,
      ano: _currentAno,
      bimestre: _currentBimestre,
    );

    // 3. Executa a construção
    final BuildResult result = await builder.build();

    // 4. Analisa o resultado
    print(result); //

  }

  void _changeBimestre(String? bimestre) {
    if (bimestre != null && bimestre != '00') { // O código do bimestre é '01', '02', etc.
      _filterController.updateFilters(novoBimestre: bimestre);
      _criaEsturaDasTabelas();
      setState(() {
        _currentBimestre = bimestre;
      });
    }
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
            child: Texto(tit:ano['name']!,cor:Colors.black87),
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
            child: Texto(tit:bim['name']!,cor: Colors.black87,),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent, // Fundo consistente
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
}


// ==========================================================
// 5. Widgets de Helper e a Tela Cheia
// ==========================================================

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.grey[200] : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarExpansionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> children;

  const _SidebarExpansionItem({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.grey.shade600),
        title: Text(title),
        children: children.map((child) =>
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: _SidebarMenuItem(
                icon: Icons.circle, // Um ícone simples para sub-item
                title: child,
                onTap: () {},
              ),
            )
        ).toList(),
      ),
    );
  }
}

// A sua página de tela cheia, um pouco simplificada
class FullScreenPage extends StatelessWidget {
  final String title;
  final Widget child;

  const FullScreenPage({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: child, // O widget interativo original
      ),
    );
  }
}
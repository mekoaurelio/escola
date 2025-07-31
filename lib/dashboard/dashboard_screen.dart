import 'package:flutter/material.dart';
import '../indicadores/calculadora.dart';
import '../indicadores/educationImpactPage.dart';
import '../indicadores/educationalReceiptsScreen.dart';
import '../indicadores/pacDashboardPage.dart';
import '../indicadores/receiptsDemonstrativePage.dart';
import '../simulador/simula.dart';
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
                  child: DashboardScreen(),
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
class DashboardScreen extends StatelessWidget {
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
                    const Text('Bem-vindo, Júlio!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFilterChip('2025'),
                        const SizedBox(width: 16),
                        _buildFilterChip('Primeiro Bimestre'),
                      ],
                    )
                  ],
                ),
                SizedBox(width: 10,),
                // --- Banner de Educação ---
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

  // --- Widgets de Helper para o DashboardScreen ---

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
        ],
      ),
    );
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
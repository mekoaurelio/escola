import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/ano_bimestre_controller.dart';
import '../services/screenSize.dart';
import '../services/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';
import '../widgets/vantagens.dart';

class Professores extends StatefulWidget {
  const Professores({Key? key}) : super(key: key); // Adicionado Key

  @override
  State<Professores> createState() => _ProfessoresState();
}
class _ProfessoresState extends State<Professores> with AnoBimestreListenerMixin{
  final TextEditingController controller = TextEditingController();
  List<dynamic> lista = [];
  List<dynamic> listaCompleta = [];
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  String? errorMessage;
  final anoBimestreController = Get.find<AnoBimestreController>();

  @override
  void onAnoBimestreMudou(String ano, String bimestre) {
    atualizaTela(ano,bimestre);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  atualizaTela(var ano,var bimestre){
    setState(() {
      TBFolha='a$ano$bimestre';
      TBVantagens='a_vantagens$ano$bimestre';
      listaCompleta=[];
      lista=[];
      _loadData();
    });
  }


  Future<void> _loadData() async {
    try {
      listaCompleta = await ApiMySql.getProfessor();
      lista = listaCompleta;
      setState(() {
        // Define um pageSize inicial, mas permite que o usuário altere se necessário
        pageSize = lista.isNotEmpty ? 10 : 1;
        isLoading = false;
      });
    } catch (e) {
      // Boa prática: tratar erros de API
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  // O método parseLine não era usado e foi removido.

  List<dynamic> get currentItems {
    final start = (currentPage - 1) * pageSize;
    // Garante que o start não seja negativo
    if (start < 0) return [];
    final end = start + pageSize;
    return lista.sublist(start, end > lista.length ? lista.length : end);
  }

  void _onSearchChanged(String text) {
    setState(() {
      if (text.isEmpty) {
        lista = listaCompleta;
      } else {
        lista = listaCompleta.where((professor) {
          final nome = professor['nome']?.toString().toLowerCase() ?? '';
          final matr = professor['matricula']?.toString().toLowerCase() ?? '';
          final nivel = professor['nivel']?.toString().toLowerCase() ?? '';
          final unidade = professor['unidade']?.toString().toLowerCase() ?? '';

          final query = text.toLowerCase();
          return nome.contains(query) ||
              matr.contains(query) ||
              nivel.contains(query) ||
              unidade.contains(query);
        }).toList();
      }
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return Scaffold(body: Center(child: Text(errorMessage!)));
    }

    final totalPages = (lista.length / pageSize).ceil();
    final screenSizeConfig = ScreenSizeConfig(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomTextFiel(
              controller: controller,
              label: 'Pesquisar por nome, matrícula, nível ou unidade...',
              left: 10,
              prefixIcon: Icons.search_outlined,
              obrigatorio: false,
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: lista.isEmpty
                  ?  Utils.vazio('Nenhum Professor Encontrado para esse ano/bimestre')
                  : Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        final item = currentItems[index];
                        // 2. AGORA USAMOS O NOSSO NOVO WIDGET, PASSANDO OS DADOS
                        return _ProfessorListItem(item: item);
                      },
                    ),
                  ),
                  PaginationFooter(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalItems: lista.length,
                    onPageChanged: (newPage) {
                      // A lógica de atualização do estado permanece no widget pai.
                      setState(() {
                        currentPage = newPage;
                      });
                    },
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refatorado para ser um widget mais limpo e constante
  Widget _buildHeader() {
    const headerTextStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

    return Card(
      color: Colors.grey.shade300,
      elevation: 0,
      shape: Utils.borda(),
      child:  Padding( // Adicionado padding para alinhar melhor com os itens
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Line(tex: 'Matrícula', tam: 70, alin: Alignment.centerLeft, ),
            SizedBox(width: 5),
            Line(tex: 'CPF', tam: 85, alin: Alignment.centerLeft, ),
            Line(tex: 'Professor', tam: 200, alin: Alignment.centerLeft,  ),
            Line(tex: 'Cargo', tam: 200, alin: Alignment.centerLeft,), // Ordem corrigida
            Line(tex: 'Local', tam: 200, alin: Alignment.centerLeft, ),
            Line(tex: 'Unidade', tam: 200, alin: Alignment.centerLeft,  ),
            Line(tex: 'Nível', tam: 30, alin: Alignment.centerLeft,  ),
            Line(tex: 'Admissão', tam: 90, alin: Alignment.centerLeft, ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildFooter(int totalPages, ScreenSizeConfig screenSizeConfig) {
    // Conteúdo do rodapé permanece o mesmo...
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage = 1) : null,
            icon: Icon(Icons.first_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
            icon: Icon(Icons.arrow_back, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Text('Página $currentPage de $totalPages',
              style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54)),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
            icon: Icon(Icons.arrow_forward, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage = totalPages) : null,
            icon: Icon(Icons.last_page, color: Colors.black54, size: screenSizeConfig.getFooterIconSize()),
          ),
          Text('${lista.length} Itens',
              style: TextStyle(fontSize: screenSizeConfig.getBodyFontSize(), color: Colors.black54)),
        ],
      ),
    );
  }

 */



}

// 3. O NOVO WIDGET STATEFUL PARA O ITEM DA LISTA
class _ProfessorListItem extends StatefulWidget {
  final dynamic item;

  const _ProfessorListItem({required this.item, Key? key}) : super(key: key);

  @override
  __ProfessorListItemState createState() => __ProfessorListItemState();
}

class __ProfessorListItemState extends State<_ProfessorListItem> {
  // Cada item agora tem sua própria variável de estado de hover.
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final DateTime parsedDate = Utils.parseDate(item['admissao']);
    final int yearsDifference = Utils.calculateYearsDifference(parsedDate);
    final double somaVantagens = double.tryParse(item['soma_vantagens'] ?? '0.0') ?? 0.0;

    return MouseRegion(
      // Atualiza o estado APENAS deste widget
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
          // A cor depende do estado local _isHovered
          color: _isHovered ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Line(tex: item['matricula'] ?? '', tam: 70, alin: Alignment.centerLeft, negrito: true, fontSize: 14),
                const SizedBox(width: 5),
                Line(tex: item['cpf'] ?? '', tam: 85, alin: Alignment.centerLeft,fontSize: 9,),
                Line(tex: item['nome'] ?? '', tam: 200, alin: Alignment.centerLeft, fontSize: 14,negrito: true,),
                Line(tex: item['cargo'] ?? '', tam: 200, alin: Alignment.centerLeft),
                Line(tex: item['local_lotacao'] ?? '', tam: 200, alin: Alignment.centerLeft),
                Line(tex: item['unidade'] ?? '', tam: 200, alin: Alignment.centerLeft),
                Line(tex: item['nivel'] ?? '', tam: 30, alin: Alignment.centerLeft),
                Line(tex: '${item['admissao'] ?? ''} ($yearsDifference anos)', tam: 90, alin: Alignment.centerLeft, fontSize: 9),
              ],
            ),
            const SizedBox(height: 5),
            VantagensList(
              vantagensDetalhadas: item['vantagens_detalhadas'] ?? '',
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Line(tex: 'Total de Vantagens', tam: 200, alin: Alignment.centerLeft, cor: Colors.blue, negrito: true),
                Line(tex: Utils.formatVr.format(double.parse(item['soma_vantagens'])), tam: 300, alin: Alignment.centerRight, cor: Colors.blue, negrito: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

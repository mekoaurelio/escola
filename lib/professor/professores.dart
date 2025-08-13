import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:GEM/services/table_name_service.dart';

import '../const/const.dart';
import '../data/api_my_sql.dart';
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

class _ProfessoresState extends State<Professores> {
  final TextEditingController controller = TextEditingController();
  List<dynamic> lista = [];
  List<dynamic> listaCompleta = [];
  int currentPage = 1;
  int pageSize = 10;
  bool isLoading = true;
  String? errorMessage;
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadData();
  }

  void _loadDataBasedOnCurrentFilters() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      listaCompleta = await ApiMySql.getProfessor();
      lista = listaCompleta;

      if (mounted) {
        setState(() {
          pageSize = lista.isNotEmpty ? 10 : 1;
          isLoading = false;
        });
      }

    } catch (e) {
      // Boa prática: tratar erros de API
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }


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
        lista =
            listaCompleta.where((professor) {
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
      return  Scaffold(
          backgroundColor: corFundoOadrao,
          body: Center(child: CircularProgressIndicator())
      );
    }
    if (errorMessage != null) {
      return Scaffold(
          backgroundColor: corFundoOadrao,
          body: Center(child: Text(errorMessage!))
      );
    }

    var totalPages=0;
    if(lista.isNotEmpty) {
      totalPages = (lista.length / pageSize).ceil();
    }
    const double maxTableWidth = 1500;
    return Scaffold(
      backgroundColor: corFundoOadrao,
      body:lista.isEmpty?Utils.vazio('Nenhum Professor'):

      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTableWidth),
            // Usamos um Card como container geral da tabela para dar sombra e um visual limpo
            child: Column(
              children: [
                CustomTextFiel(
                  controller: controller,
                  label: 'Pesquisar por nome, matrícula, nível ou unidade...',
                  left: 10,
                  prefixIcon: Icons.search_outlined,
                  obrigatorio: false,
                  onChanged: _onSearchChanged,
                ),
                Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias, // Essencial para cortar os cantos
                      child: Column( // A estrutura principal que separa cabeçalho, corpo e rodapé
                        children: [
                          // ===================================
                          // 1. CABEÇALHO (FIXO)
                          // ===================================
                          _buildHeader(),

                          // ===================================
                          // 2. CORPO (ROLÁVEL)
                          // ===================================
                          Expanded(
                            child:  ListView.builder(
                              itemCount: currentItems.length,
                              itemBuilder: (context, index) {
                                final item = currentItems[index];
                                // 2. AGORA USAMOS O NOSSO NOVO WIDGET, PASSANDO OS DADOS
                                return _ProfessorListItem(item: item);
                              },
                            ),
                          ),

                          // ===================================
                          // 3. RODAPÉ (FIXO)
                          // ===================================
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
                )

              ],
            )


          ),
        ),
      ),
    );
  }

  // Refatorado para ser um widget mais limpo e constante
  Widget _buildHeader() {
    const headerTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue, // Cor de fundo azul claro da imagem
          ),
          child:Row(
            children: [
              SizedBox(width: 15,),
              Line(tex: 'Matrícula', tam: 70, alin: Alignment.centerLeft, cor: Colors.grey.shade300, negrito: true,fontSize: 16,),
              SizedBox(width: 5),
              Line(tex: 'CPF', tam: 85, alin: Alignment.centerLeft, cor: Colors.grey.shade300, negrito: true,fontSize: 16,),
              Line(
                tex: 'Professor',
                tam: 200,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,
                  fontSize: 16
              ),
              Line(
                tex: 'Cargo',
                tam: 200,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,
                  fontSize: 16
              ), // Ordem corrigida
              Line(
                tex: 'Local',
                tam: 200,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,
                  fontSize: 16
              ),
              Line(
                tex: 'Unidade',
                tam: 200,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,fontSize: 16
              ),
              Line(
                tex: 'Nível',
                tam: 50,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,fontSize: 16
              ),
              Line(
                tex: 'Admissão',
                tam: 90,
                alin: Alignment.centerLeft,
                cor: Colors.grey.shade300,
                negrito: true,fontSize: 14
              ),
            ],
          ),
        );
  }
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
    int  yearsDifference=0;
    if(item['admissao']!=null) {
      final DateTime parsedDate = Utils.parseDate(item['admissao']);
       yearsDifference = Utils.calculateYearsDifference(parsedDate);
    }
    final double somaVantagens = double.tryParse(item['soma_vantagens'] ?? '0.0') ?? 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          // A cor depende do estado local _isHovered
          color: _isHovered ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Line(
                  tex: item['matricula'] ?? '',
                  tam: 75,
                  alin: Alignment.centerLeft,
                  negrito: true,
                  fontSize: 18,
                ),
                const SizedBox(width: 5),
                Line(
                  tex: item['cpf'] ?? '           ',
                  tam: 85,
                  alin: Alignment.centerLeft,
                  fontSize: 9,
                ),
                Line(
                  tex: item['nome'] ?? '',
                  tam: 200,
                  alin: Alignment.centerLeft,
                  fontSize: 14,
                  negrito: true,
                ),
                Line(
                  tex: item['cargo'] ?? '',
                  tam: 200,
                  alin: Alignment.centerLeft,
                ),
                Line(
                  tex: item['local_lotacao'] ?? '',
                  tam: 200,
                  alin: Alignment.centerLeft,
                ),
                Line(
                  tex: item['unidade'] ?? '',
                  tam: 200,
                  alin: Alignment.centerLeft,
                ),
                Line(
                  tex: item['nivel'] ?? '',
                  tam: 30,
                  alin: Alignment.centerLeft,
                ),
                Line(
                  tex: '${item['admissao'] ?? ''} ($yearsDifference anos)',
                  tam: 90,
                  alin: Alignment.centerLeft,
                  fontSize: 9,
                ),
              ],
            ),

            const SizedBox(height: 5),
            VantagensList(
              vantagensDetalhadas: item['vantagens_detalhadas'] ?? '',
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Line(
                  tex: 'Total de Vantagens',
                  tam: 200,
                  alin: Alignment.centerLeft,
                  cor: Colors.blue,
                  negrito: true,
                ),
                Line(
                  tex: Utils.formatVr.format(
                    double.parse(item['soma_vantagens']),
                  ),
                  tam: 300,
                  alin: Alignment.centerRight,
                  cor: Colors.blue,
                  negrito: true,
                ),
              ],
            ),



          ],
        ),
      ),
    );
  }
}

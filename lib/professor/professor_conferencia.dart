import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/line.dart';
import '../widgets/paginationFooter.dart';

class ProfessorConferencia extends StatefulWidget {
  const ProfessorConferencia({super.key});

  @override
  State<ProfessorConferencia> createState() => _ProfessorConferenciaState();
}

class _ProfessorConferenciaState extends State<ProfessorConferencia> {
  final TextEditingController controller = TextEditingController();
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  List<dynamic> listaCompleta = [];
  List<dynamic> lista = [];
  List<dynamic> getHoraNivel = [];

  int currentPage = 1;
  int pageSize = 10;
  int hoverIndex = -1;

  bool isLoading = true;

  // debounce para pesquisa
  DateTime? _lastSearch;

  @override
  void initState() {
    super.initState();
    filterController.municipio.listen((_) => _loadData());
    filterController.ano.listen((_) => _loadData());
    filterController.bimestre.listen((_) => _loadData());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final horaNivel = await ApiMySql.getHoraNivel(TBSimulaCab, TBSimulaForm)
          .timeout(const Duration(seconds: 30));
      if (horaNivel.isEmpty || horaNivel.contains('Erro')) {
        Utils.snak('Atenção', 'Não foi possível carregar os níveis', false, Colors.red);
        setState(() => isLoading = false);
        return;
      }
      final professores = await ApiMySql.getProfessor()
          .timeout(const Duration(seconds: 30));

      setState(() {
        getHoraNivel = horaNivel;
        listaCompleta = professores;
        lista = professores;
        pageSize = professores.length;
        isLoading = false;
      });
    } catch (e) {
      Utils.snak('Erro', 'Falha ao carregar dados: $e', false, Colors.red);
      setState(() => isLoading = false);
    }
  }

  /// === Cálculos ===
  List<double> calcularProgressao(double valorInicial, double percentual, int iteracoes) {
    final resultados = <double>[valorInicial];
    var valorAtual = valorInicial;

    for (int i = 0; i < iteracoes; i++) {
      valorAtual *= (1 + (percentual / 100));
      resultados.add(valorAtual);
    }
    return resultados;
  }

  double salarioProposto(String nivel, String hora) {
    try {
      final hr = hora.replaceAll('hs', '');
      final _nivel = nivel.substring(0, 1);
      final _classe = int.tryParse(nivel.substring(1)) ?? 0;

      final encontrado = getHoraNivel.firstWhere(
            (e) => e['horas'] == hr && e['nivel'] == _nivel,
        orElse: () => {},
      );

      if (encontrado.isEmpty) return 0;

      final valor = double.tryParse(encontrado['valor'].toString()) ?? 0;
      final resultados = calcularProgressao(valor, 2, 30);

      return (_classe > 0 && _classe <= resultados.length)
          ? resultados[_classe - 1]
          : 0;
    } catch (_) {
      return 0;
    }
  }

  /// === UI Helpers ===
  List<dynamic> get currentItems {
    final start = (currentPage - 1) * pageSize;
    final end = start + pageSize;
    return lista.sublist(start, end > lista.length ? lista.length : end);
  }

  Widget cabecalho() {
    const headers = [
      ['Matrícula', 90],
      ['Professor', 250],
      ['Horas', 70],
      ['Nível', 70],
      ['Vencimento', 100],
      ['APTS', 100],
      ['Vantagens', 100],
      ['Total', 100],
      ['Proposta', 100],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.blue,
      child: Row(
        children: [
          const SizedBox(width: 15),
          for (var h in headers)
            Line(
              tex: h[0] as String,
              tam: h[1] as double,
              alin: Alignment.center,
              cor: Colors.grey.shade300,
              negrito: true,
              fontSize: 16,
            ),
        ],
      ),
    );
  }

  Widget buildRow(dynamic item, int index) {
    final vencimento = double.tryParse(item['vencimento'].toString()) ?? 0;
    final horas = item['horas'];
    final nivel = item['nivel'];
    final vrP = salarioProposto(nivel, horas);
    final proposta = Utils.formatVr.format(vrP);

    final sumVantagem = double.tryParse(item['soma_vantagens'].toString()) ?? 0;
    final descriVantagem = item['vantagens_detalhadas'];
    final total = vencimento + sumVantagem;

    Color cor = Colors.black;
    bool negrito = false;
    String tooltip = '';

    if (vencimento < vrP) {
      cor = Colors.red;
      negrito = true;
      tooltip = 'Valor Proposto menor que Vencimento';
    } else if (vrP == 0) {
      cor = Colors.blue;
      negrito = true;
      tooltip = 'Nível inválido';
    } else {
      tooltip = descriVantagem ?? '';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => hoverIndex = index),
      onExit: (_) => setState(() => hoverIndex = -1),
      child: Tooltip(
        message: tooltip,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        child: Container(
          color: hoverIndex == index ? Colors.blue.shade50 : Colors.transparent,
          child: Row(
            children: [
              const SizedBox(width: 15),
              Line(tex: item['matricula'], tam: 90, alin: Alignment.centerLeft, cor: cor, negrito: negrito, fontSize: 18),
              Line(tex: item['nome'], tam: 250, alin: Alignment.centerLeft, cor: cor, negrito: true),
              Line(tex: '$horas', tam: 70, alin: Alignment.center, cor: cor, negrito: negrito),
              Line(tex: "$nivel", tam: 70, alin: Alignment.center, cor: cor, negrito: negrito),
              Line(tex: Utils.formatVr.format(vencimento), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: !negrito),
              Line(tex: 'ATPS', tam: 100, alin: Alignment.centerRight, cor: cor),
              Line(tex: Utils.formatVr.format(sumVantagem), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: negrito),
              Line(tex: Utils.formatVr.format(total), tam: 100, alin: Alignment.centerRight, cor: cor, negrito: negrito),
              Line(tex: proposta, tam: 100, alin: Alignment.centerRight, cor: cor, negrito: true),
              IconButton(
                onPressed: () => edite('Alterando', 'nivel', nivel, item['matricula']),
                icon: const Icon(Icons.edit, size: 15, color: Colors.black54),
              ),
              IconButton(
                onPressed: () => delete(item['matricula'], item['nome']),
                icon: const Icon(Icons.delete, size: 15, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = lista.isEmpty ? 0 : (lista.length / pageSize).ceil();
    const double maxTableWidth = 1500;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      body: lista.isEmpty
          ? Utils.vazio('Nenhum Registro')
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxTableWidth),
            child: Column(
              children: [
                // pesquisa
                CustomTextFiel(
                  controller: controller,
                  label: '',
                  prefixIcon: Icons.search_outlined,
                  obrigatorio: false,
                  onChanged: onChange,
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        cabecalho(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentItems.length,
                            itemBuilder: (context, index) => buildRow(currentItems[index], index),
                          ),
                        ),
                        PaginationFooter(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          totalItems: lista.length,
                          onPageChanged: (newPage) => setState(() => currentPage = newPage),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> delete(var matricula, var nome) async {
    final confirmar = await Utils.showDlg(
      'Atenção',
      'Confirma a exclusão de \n$nome?',
      context,
      'Sim',
      'Não',
    );
    if (confirmar) {
      await ApiMySql.executaSql("Update $TBFolha set status='D' WHERE matricula=$matricula");
      _loadData();
    }
  }

  Future<void> edite(var title, var campo, vrInicial, var matricula) async {
    await Utils.mostrarDialogoEditarValor(
      context: context,
      titulo: title,
      labelCampo: campo,
      valorInicial: vrInicial,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
      aoSalvar: (novoValor) async {
        await ApiMySql.executaSql("Update $TBFolha set nivel='$novoValor' WHERE matricula=$matricula");
        _loadData();
      },
    );
  }

  void onChange(String text) {
    final now = DateTime.now();
    if (_lastSearch != null && now.difference(_lastSearch!).inMilliseconds < 300) return;
    _lastSearch = now;

    setState(() {
      if (text.isEmpty) {
        lista = listaCompleta;
      } else {
        final query = text.toLowerCase();
        lista = listaCompleta.where((professor) {
          return professor['nome'].toString().toLowerCase().contains(query) ||
              professor['matricula'].toString().toLowerCase().contains(query) ||
              professor['nivel'].toString().toLowerCase().contains(query) ||
              professor['unidade'].toString().toLowerCase().contains(query);
        }).toList();
      }
      currentPage = 1;
    });
  }
}

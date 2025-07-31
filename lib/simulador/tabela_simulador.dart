import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:GEM/services/GlobalFilterController.dart';
import 'package:get/get.dart';

import '../const/nome_tabelas.dart';
import '../data/api_my_sql.dart';
import '../services/anoBimestreListenerMixin.dart';
import '../services/utils.dart';
import '../widgets/texto.dart';

class ProjecaoDeRecursos extends StatelessWidget {
  const ProjecaoDeRecursos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projeção de Recursos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProjecaoRecursosScreen(),
    );
  }
}

class ProjecaoRecursosScreen extends StatefulWidget {
  const ProjecaoRecursosScreen({super.key});

  @override
  State<ProjecaoRecursosScreen> createState() => _ProjecaoRecursosScreenState();
}
class _ProjecaoRecursosScreenState extends State<ProjecaoRecursosScreen> {
  final List<Map<String, dynamic>> decenios = [];
  final List<Map<String, dynamic>> impostos = [];
  var totais;
  bool isLoading = true;
  String vrInput='0.0';
  String receitaTotalFundeb='0.0';
  String receitaTotal='0.0';
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();

  @override
  void initState() {
    super.initState();
    // Registra os listeners. Eles reagirão a mudanças SE a tela estiver visível.
    filterController.municipio.listen((_) => _reactToFilterChange());
    filterController.ano.listen((_) => _reactToFilterChange());
    filterController.bimestre.listen((_) => _reactToFilterChange());

    _loadDataBasedOnCurrentFilters();
  }

  void _loadDataBasedOnCurrentFilters() {
    // Pega os valores atuais diretamente do controller
    String muni = filterController.municipio.value;
    String ano = filterController.ano.value;
    String bimestre = filterController.bimestre.value;
    setState(() {
      TBFolha=TBFolha='${muni}$ano$bimestre';
      TBVantagens=TBVantagens='${muni}vantagens$ano$bimestre';
      TBProfessor = '${muni}professor$ano$bimestre';
      TBInfantil = '${muni}infantil$ano$bimestre'; // Corrigido: removido espaço
      TBReceitaFundebSimulador = '${muni}receita_fundeb_simulador$ano$bimestre';
      TBExercicio = '${muni}exercicio$ano$bimestre';
      TBTotais='${muni}totais$ano$bimestre';
    });
    _carregarDados();
  }

  void _reactToFilterChange() {
    print("Listener do GetX acionado! (Mudança ocorreu com a tela aberta)");
    _loadDataBasedOnCurrentFilters();
  }

  List<Map<String, dynamic>> _mapearDados(List<Map<String, dynamic>> dados) {
    return dados.map((item) => {
      'id': int.tryParse(item['id'].toString()) ?? 0,
      'descricao': item['descricao'] as String,
      'valorProjetado': double.tryParse(item['vr1'].toString()) ?? 0.0,
      'recursoProprio': double.tryParse(item['vr2'].toString()) ?? 0.0,
    }).toList();
  }

  Future<void> _carregarDados() async {
    // seu código de carregamento
    try {
      final dadosDecenios = (await ApiMySql.get(TBDecenio, null, null) as List).cast<Map<String, dynamic>>();
      final dadosImpostos = (await ApiMySql.get(TBImpostos, null, null) as List).cast<Map<String, dynamic>>();
      var tt=await ApiMySql.get(TBTotais,null,null);
      if(tt.isEmpty){ // Verificação mais segura
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        totais=tt;
        decenios.clear(); // Limpa antes de adicionar para evitar duplicatas em recargas
        impostos.clear();
        decenios.addAll(_mapearDados(dadosDecenios));
        impostos.addAll(_mapearDados(dadosImpostos));
        vrInput = totais[0]['fundeb_10_5'] ?? '0.0';

        var vrI = double.tryParse(totais[0]['fundeb_10_5']?.toString() ?? '0.0') ?? 0.0;
        var r = double.tryParse(totais[0]['receita']?.toString() ?? '0.0') ?? 0.0;
        var d5 = double.tryParse(totais[0]['decendio_5']?.toString() ?? '0.0') ?? 0.0;
        var i25 = double.tryParse(totais[0]['imposto_25']?.toString() ?? '0.0') ?? 0.0;

        receitaTotalFundeb = (vrI + r).toString();
        receitaTotal = (vrI + r + d5 + i25).toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Erro ao carregar dados: $e');
      Utils.snak('Atenção', 'Erro ao carregar dados: $e', false, Colors.red);
    }
  }

  Future<void> _editarCampo({required int index, required bool isDecenio, required String campo}) async {
    final list = isDecenio ? decenios : impostos;
    final controller = TextEditingController(text: list[index][campo].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${campo == 'descricao' ? 'Descrição' : 'Valor Projetado'}'),
        content: TextField(
          controller: controller,
          keyboardType: campo == 'valorProjetado' ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: campo == 'valorProjetado'
              ? [CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt')]
              : [],
          decoration: InputDecoration(labelText: campo == 'descricao' ? 'Nova descrição' : 'Novo valor'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                if (campo == 'descricao') {
                  list[index][campo] = controller.text;
                } else {
                  // print()
                  final valor = double.tryParse(Utils.saldoToSave(controller.text)) ?? 0.0;
                  list[index]['valorProjetado'] = valor ;
                  list[index]['recursoProprio'] = valor * (isDecenio ? 0.05 : 0.25);
                }
              });
              _salvarDadosTabela(isDecenio: isDecenio, index: index);
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  double _calcularTotal(List<Map<String, dynamic>> items, String campo) {
    return items.fold(0.0, (sum, item) => sum + (item[campo] ?? 0.0));
  }

  Future<void> _salvarDadosTabela({required bool isDecenio, required int index}) async {
    final item = isDecenio ? decenios[index] : impostos[index];
    final tabela = isDecenio ? TBDecenio : TBImpostos;
    final double vr1 = item['valorProjetado'] ?? 0.0;
    final double vr2 = item['recursoProprio'] ?? 0.0;
    var dados=isDecenio ? decenios:impostos;

    try {
      var des=item['descricao'];

      var tot1=_calcularTotal(dados, 'valorProjetado');
      var tot2=_calcularTotal(dados, 'recursoProprio');
      var _result;
      _result=await ApiMySql.executaSql("Update $tabela set descricao='$des', vr1=$vr1,vr2=$vr2  where id = ${item['id']}");
      Utils.verificaErro(_result);

      if(isDecenio){
        _result=await ApiMySql.executaSql("Update $TBTotais set decendio_projetado=$tot1, decendio_5=$tot2");
      }else {
        _result=await ApiMySql.executaSql("Update $TBTotais set imposto_projetado=$tot1, imposto_25=$tot2");
      }
      Utils.verificaErro(_result);

    } catch (e) {
      print('Falha ao salvar: $e');
      Utils.snak('Erro', 'Falha ao salvar: $e', false, Colors.red);
    }
  }

  // ===================================================================
  // WIDGETS DA UI REATORADOS
  // ===================================================================

  /// Helper para criar a linha de cabeçalho das tabelas principais.
  Widget _buildTableHeader(List<String> titles, List<int> flexFactors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200, width: 2)),
      ),
      child: Row(
        children: List.generate(titles.length, (index) {
          return Expanded(
            flex: flexFactors[index],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Texto(
                tit: titles[index],
                negrito: true,
                cor: Colors.blue.shade800,
                alin: index == 0 ? TextAlign.left : TextAlign.right,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Helper para criar uma linha de dados das tabelas principais.
  Widget _buildTableRow(Map<String, dynamic> item, int index, bool isDecenio) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coluna Descrição
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () => _editarCampo(index: index, isDecenio: isDecenio, campo: 'descricao'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Texto(tit: item['descricao'], alin: TextAlign.left)),
                    const Icon(Icons.edit, size: 14, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          // Coluna Valor Projetado
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => _editarCampo(index: index, isDecenio: isDecenio, campo: 'valorProjetado'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Texto(tit: Utils.formatVr.format(item['valorProjetado']),)),
                    const Icon(Icons.edit, size: 14, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
          // Coluna Recurso Próprio
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Texto(tit: Utils.formatVr.format(item['recursoProprio']), alin: TextAlign.right),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper para criar a linha de total das tabelas principais.
  Widget _buildTotalRow(List<Map<String, dynamic>> dados) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.blue.shade50),
      child: Row(
        children: [
          Expanded(flex: 5, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Texto(tit: 'Total', negrito: true, cor: Colors.blue.shade800, alin: TextAlign.left))),
          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Texto(tit: Utils.formatVr.format(_calcularTotal(dados, 'valorProjetado')), negrito: true, cor: Colors.blue.shade800, alin: TextAlign.right))),
          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Texto(tit: Utils.formatVr.format(_calcularTotal(dados, 'recursoProprio')), negrito: true, cor: Colors.blue.shade800, alin: TextAlign.right))),
        ],
      ),
    );
  }

  /// Método `_buildTabela` refatorado para usar os helpers.
  Widget _buildTabela(String titulo, List<Map<String, dynamic>> dados, bool isDecenio) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue,
            child: Texto(tit: titulo, negrito: true, tam: 16,
              alin: TextAlign.center, bottom: 10,top: 10,left: 20,cor: Colors.grey.shade300,),
          ),
          _buildTableHeader(['Descrição', 'Valor Projetado Ano', 'Recurso Próprio'], [5, 3, 3]),
          ...dados.map((item) => _buildTableRow(item, dados.indexOf(item), isDecenio)),
          _buildTotalRow(dados),
        ],
      ),
    );
  }

  /// Método `_resumo` refatorado.
  Widget _resumo() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue,
              child: Texto(tit: 'Consolidações de Recursos Anuais para MDE', negrito: true, tam: 16,
                  alin: TextAlign.center, bottom: 10,top: 10,left: 20,cor: Colors.grey.shade300,),
            ),

            _buildResumoHeader(),
            _buildResumoRow('1. Receitas recebidas do FUNDEB', totais[0]['receita']),
            _buildResumoRow('1.1. Complementação da UNIÃO - FUNDEB - VAAF - 10%', '0'),
            _buildEditableResumoRow(
              label: '1.2. Complementação da UNIÃO - FUNDEB - VAAT - 10,5%',
              value: vrInput,
              onEdit: () {
                Utils.mostrarDialogoEditarValor(
                  context: context,
                  titulo: 'Informe o Valor',
                  labelCampo: 'Valor',
                  valorInicial: vrInput,
                  aoSalvar: (novoValor) async{
                    double valorNumerico = Utils.vrStringToDouble(novoValor);
                    await ApiMySql.executaSql('Update $TBTotais set fundeb_10_5=$valorNumerico');
                    _carregarDados(); // Recarrega todos os dados para atualizar os totais
                  },
                );
              },
            ),
            _buildResumoRow('1.3. Complementação da UNIÃO - FUNDEB - VAAR - 2,5%', '320000'),
            _buildResumoRow('Receita Total - FUNDEB', receitaTotalFundeb, isTotal: true),
            _buildResumoRow('2. Receitas recursos próprios 5%', totais[0]['decendio_5']),
            _buildResumoRow('3. Receitas recursos próprios 25%', totais[0]['imposto_25']),
            _buildResumoRow('Receita Total', receitaTotal, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(bottom: BorderSide(color: Colors.blue.shade200))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Texto(tit: 'Receita/Complementação', negrito: true, cor: Colors.blue.shade800, alin: TextAlign.left))),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Texto(tit: 'Valor', negrito: true, cor: Colors.blue.shade800, alin: TextAlign.right))),
        ],
      ),
    );
  }

  Widget _buildResumoRow(String title, String value, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isTotal ? Colors.blue.shade100 : Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Texto(tit: title, negrito: isTotal, cor: isTotal ? Colors.blue.shade900 : Colors.black87, alin: TextAlign.left)),
          Expanded(flex: 1, child: Texto(tit: Utils.formatVr.format(double.tryParse(value) ?? 0.0), negrito: isTotal, cor: isTotal ? Colors.blue.shade900 : Colors.black, alin: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildEditableResumoRow({required String label, required String value, required VoidCallback onEdit}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Texto(tit: label, alin: TextAlign.left)),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Texto(tit: value, alin: TextAlign.right,)),
                    const Icon(Icons.edit, size: 14, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totais == null
          ? Utils.vazio('Nenhum Dado Encontrado')
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Largura máxima para todo o conteúdo
            child: Column(
              children: [
                _resumo(),
                const SizedBox(height: 32),
                _buildTabela('Tabela 02 - Projeção do mínimo de 5% para investimento em MDE', decenios, true),
                const SizedBox(height: 32),
                _buildTabela('Tabela 03 - Projeção do mínimo de 25% para investimento em MDE', impostos, false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:GEM/services/GlobalFilterController.dart';

import '../data/api_my_sql.dart';
import '../services/table_name_service.dart';
import '../services/utils.dart';

class EducationalReceiptsPage extends StatefulWidget {
  const EducationalReceiptsPage({Key? key}) : super(key: key); // Adicionado Key

  @override
  State<EducationalReceiptsPage> createState() => _EducationImpactPage();
}


class _EducationImpactPage extends State<EducationalReceiptsPage> {
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  bool _isMaster=false;
  bool _isLoading=true;
  var lista;

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

  void _loadData() async {
    // MODIFICAÇÃO 2: Garante que o estado de loading seja setado antes do await.
   // if (mounted) {
     // setState(() {
       // _isLoading = true;
      //});
   // }

    // Use 'await' e forneça um valor padrão (lista vazia) se a API retornar null.
    var result = await ApiMySql.get(TBReceitasEducacionais, null, null);
    print('RECEITA');
    print(result);
    lista = result ?? []; // Se result for null, lista se torna [].

    if (mounted) { // Sempre verifique se o widget está montado após um await.
      setState(() {
        _isLoading = false;
        _isMaster = Utils.getUserType() == 'M';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo cinza claro para a página inteira
      backgroundColor: const Color(0xFFF0F2F5),
      body: _isLoading? const Center(child: CircularProgressIndicator()):
      lista.isEmpty // Verificação crucial aqui!
          ? Utils.vazio('Nenhum Dado Encontado'):
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- CARD 1: TOTAL DE RECEITAS ---
               TotalReceiptsCard(
                year: 2025,
                isMaster:_isMaster,
                 fieldToUpdate:'total_receita',
                totalAmount: lista[0]['total_receita'],
                 onValueUpdated: _loadData,
              ),
              const SizedBox(height: 24),

              // --- CARD 2: FONTES DE FINANCIAMENTO BÁSICA ---
              TitledTableCard(
                title: 'FONTES DE FINANCIAMENTO DA EDUCAÇÃO BÁSICA',
                imagePath: 'assets/images/dollar_up.png',
                data: [
                  {'label': 'VINCULAÇÃO - FUNDEB', 'value': lista[0]['cp_money_01'],'cp':'cp_money_01'},
                   {'label': '103 - 5% de Transferência', 'value': lista[0]['cp_money_02'], 'isSubItem': true,'cp':'cp_money_02'},
                  {'label': '104 - 25% de Transferência', 'value': lista[0]['cp_money_03'], 'isSubItem': true,'cp':'cp_money_03'},
                   {'label': 'TOTAL', 'value': lista[0]['cp_money_04'], 'isTotal': true,'cp':'cp_money_04'},
                ],
                isMaster: _isMaster,
                onValueUpdated: _loadData,
              ),
              const SizedBox(height: 24),

              // --- CARD 3: FONTES ADICIONAIS ---
              TitledTableCard(
                title: 'FONTES ADICIONAIS PARA FINANCIAMENTO DA EDUCAÇÃO',
                imagePath: 'assets/images/dollar_up.png',
                data:  [
                  {'label': 'SALÁRIO-EDUCAÇÃO', 'value': lista[0]['cp_money_05'],'cp':'cp_money_05'},
                  {'label': 'PNAE', 'value': lista[0]['cp_money_06'],'cp':'cp_money_06'},
                  {'label': 'PNATE', 'value': lista[0]['cp_money_07'],'cp':'cp_money_07'},
                  {'label': 'PETE', 'value': lista[0]['cp_money_08'],'cp':'cp_money_08'},
                  {'label': 'PDDE', 'value': lista[0]['cp_money_09'],'cp':'cp_money_09'},
                  {'label': 'PROGRAMA ESCOLA EM TEMPO INTEGRAL (1.385 alunos pactuados)', 'value': lista[0]['cp_money_10'],'cp':'cp_money_10'},
                  {'label': 'NOVO PAC', 'value': lista[0]['cp_money_11'],'cp':'cp_money_11'},
                  {'label': 'PACTO NACIONAL DE RETOMADA', 'value': lista[0]['cp_money_12'],'cp':'cp_money_12'},
                  {'label': 'TRANSFERÊNCIA DE CONVÊNIOS', 'value': lista[0]['cp_money_13'],'cp':'cp_money_13'},
                  {'label': 'OUTRAS RECEITAS', 'value': lista[0]['cp_money_14'],'cp':'cp_money_14'},
                  {'label': 'TOTAL', 'value': lista[0]['cp_money_15'], 'isTotal': true,'cp':'cp_money_15'},
                ],
                isMaster: _isMaster,
                onValueUpdated: _loadData,
              ),
              const SizedBox(height: 24),

              // --- CARD 4: ATENDIMENTO DA REDE PÚBLICA ---
              TitledTableCard(
                title: 'ATENDIMENTO DA REDE PÚBLICA MUNICIPAL',
                imagePath: 'assets/images/dollar_up.png',
                data:  [
                  {'label': 'CRECHE PÚBLICA INTEGRAL', 'value': lista[0]['cp_string_01'],'cp':'cp_string_01'},
                  {'label': 'CRECHE PÚBLICA PARCIAL', 'value': lista[0]['cp_string_02'],'cp':'cp_string_02'},
                  {'label': 'CRECHE CONVENIADA INTEGRAL', 'value': lista[0]['cp_string_03'],'cp':'cp_string_03'},
                  {'label': 'PRÉ-ESCOLA PÚBLICA INTEGRAL', 'value': lista[0]['cp_string_04'],'cp':'cp_string_04'},
                  {'label': 'PRÉ-ESCOLA PÚBLICA PARCIAL', 'value': lista[0]['cp_string_05'],'cp':'cp_string_05'},
                  {'label': 'PRÉ-ESCOLA CONVENIADA INTEGRAL', 'value': lista[0]['cp_string_06'],'cp':'cp_string_06'},
                  {'label': 'PRÉ-ESCOLA CONVENIADA PARCIAL', 'value': lista[0]['cp_string_07'],'cp':'cp_string_07'},
                  {'label': 'ENSINO FUNDAMENTAL PÚBLICO INICIAL', 'value': lista[0]['cp_string_08'],'cp':'cp_string_08'},
                  {'label': 'ENSINO FUNDAMENTAL PÚBLICO INTEGRAL', 'value': lista[0]['cp_string_09'],'cp':'cp_string_09'},
                  {'label': 'EJA PRESENCIAL', 'value': lista[0]['cp_string_10'],'cp':'cp_string_10'},
                  {'label': 'EDUCAÇÃO ESPECIAL', 'value': lista[0]['cp_string_11'],'cp':'cp_string_11'},
                  {'label': 'EDUCAÇÃO ESPECIAL - AEE', 'value': lista[0]['cp_string_12'],'cp':'cp_string_12'},
                  {'label': 'TOTAL', 'value': lista[0]['cp_string_13'], 'isTotal': true,'cp':'cp_string_13'},
                ],
                isMaster: _isMaster,
                onValueUpdated: _loadData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA OS CARDS COM TABELAS
class TitledTableCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Map<String, dynamic>> data;
  final bool isMaster;
  final String? fieldToUpdate;
  final VoidCallback? onValueUpdated;

  const TitledTableCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.data,
    this.isMaster=false,
    this.fieldToUpdate,
    this.onValueUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Cabeçalho escuro do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF343A40), // Cor cinza escuro
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  imagePath,
                  width: 28,  // Definimos a largura e altura para manter o tamanho
                  height: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Corpo do card com as linhas de dados
          Column(
            children: data.map((item) {
              return TableDataRow(
                label: item['label']!,
                value: item['value']!,
                isTotal: item['isTotal'] ?? false,
                isSubItem: item['isSubItem'] ?? false,
                isMaster: isMaster,
                fieldToUpdate: item['cp']!,
                onValueUpdated: onValueUpdated,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA CADA LINHA DA TABELA
class TableDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final bool isSubItem;
  final bool isMaster;
  final String? fieldToUpdate;
  final VoidCallback? onValueUpdated;

  const TableDataRow({
    Key? key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isSubItem = false,
    this.isMaster=false,
    this.fieldToUpdate,
    this.onValueUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo de texto padrão
    TextStyle labelStyle = TextStyle(
      fontSize: 13,
      color: const Color(0xFF565656),
    );
    TextStyle valueStyle = TextStyle(
      fontSize: 13,
      color: const Color(0xFF333333),
      fontWeight: FontWeight.w500,
    );

    // Se for a linha de total, aplica negrito e muda a cor do texto
    if (isTotal) {
      labelStyle = labelStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFFFFFFF));
      valueStyle = valueStyle.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFFFFFFF));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        isSubItem ? 32 : 16, // Adiciona indentação se for um sub-item
        12,
        16,
        12,
      ),
      decoration: BoxDecoration(//#  0xFF67C8FF COR/AUXILIAR 02
        color: isTotal ? const Color(0xFF67C8FF) : Colors.white, // Fundo azul claro para total
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3, // Dá mais espaço para o rótulo
            child: Text(label, style: labelStyle),
          ),

          InkWell(
            onTap: () =>
            isMaster?
            Utils.showEditableValueDialog(
              tB: TBReceitasEducacionais,
              context: context,
              initialValue: value,
              fieldToUpdate: fieldToUpdate!,
              valueType: fieldToUpdate!.contains('money')?'VR':'String', // Supondo que seja um número simples
              onValueUpdated: onValueUpdated,
            ):null,
            child:  Text( fieldToUpdate!.contains('money')?Utils.toReal(double.parse(value!)):value,
                style: valueStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// WIDGET ESPECÍFICO PARA O PRIMEIRO CARD (TOTAL DE RECEITAS)
class TotalReceiptsCard extends StatelessWidget {
  final int year;
  final String totalAmount;
  final bool isMaster;
  final String? fieldToUpdate;
  final VoidCallback? onValueUpdated;

  const TotalReceiptsCard({
    Key? key,
    required this.year,
    required this.totalAmount,
    this.isMaster=false,
    this.fieldToUpdate,
    this.onValueUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Cabeçalho azul do card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'RECEITAS EDUCACIONAIS - $year',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Corpo branco do card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text(
                  'TOTAL DE RECEITAS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () =>
                  isMaster?
                  Utils.showEditableValueDialog(
                    tB: TBReceitasEducacionais,
                    context: context,
                    initialValue: totalAmount,
                    fieldToUpdate: fieldToUpdate!,
                    valueType: 'VR',
                    onValueUpdated: onValueUpdated,
                  ):null,
                  child:  Text(Utils.toReal(double.parse(totalAmount!)),
                    style: const TextStyle(
                      color: Color(0xFF28a745), // Cor verde
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
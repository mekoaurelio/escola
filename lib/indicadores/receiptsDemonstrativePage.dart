import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:GEM/services/GlobalFilterController.dart';
import 'package:GEM/services/table_name_service.dart';
import '../data/api_my_sql.dart';
import '../services/utils.dart';

// Define os tipos de ícones que uma linha pode ter
enum RowIconType { none, dollar, emptyCircle }

class ReceiptsDemonstrativePage extends StatefulWidget {
  const ReceiptsDemonstrativePage({Key? key}) : super(key: key); // Adicionado Key

  @override
  State<ReceiptsDemonstrativePage> createState() => _ReceiptsDemonstrativePage();
}


class _ReceiptsDemonstrativePage extends State<ReceiptsDemonstrativePage> {
  final GlobalFilterController filterController = Get.find<GlobalFilterController>();
  var demon;
  bool _isLOading=true;
  bool _isMaster=false;

  @override
  void initState() {
    filterController.municipio.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.ano.listen((_) => _loadDataBasedOnCurrentFilters());
    filterController.bimestre.listen((_) => _loadDataBasedOnCurrentFilters());
    _loadData();
  }

  void _loadDataBasedOnCurrentFilters() {
    _loadData();
  }

  void _loadData()async{
    demon=await ApiMySql.get(TBDemonReceitas,null,null);
    setState(() {
      _isLOading=false;
      _isMaster=Utils.getUserType()=='M';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLOading?Center(child: CircularProgressIndicator()):
      SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- CARD 1: INFORMAÇÕES DO MUNICÍPIO ---
            InfoCard(
              title: 'INFORMAÇÕES DO MUNICÍPIO',
              icon: Icons.description,
              headerColor: const Color(0xFFEDCB06), // Amarelo
              children:  [
                DataRowItem(
                  label: 'POPULAÇÃO ESTIMADA 2022 (IBGE)',
                  value: demon[0]['populacao']??'0.00',
                  campo:'populacao',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  label: 'DADOS DO EXERCÍCIO DE 2025',
                  value: '2º BIMESTRE',
                  campo: '',
                  tipo: '%',
                  ismaster: _isMaster,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- CARD 2: RECEITAS MUNICIPAIS ---
            InfoCard(
              title: 'RECEITAS MUNICIPAIS',
              icon: Icons.attach_money,//#3CD856
              headerColor: const Color(0xFF3CD856), // Verde
              children:  [
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receita de Impostos',
                  value: demon[0]['receita_impostos']??'0.00',
                  campo: 'receita_impostos',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receitas de Transferências',
                  value: demon[0]['receita_transferencia']??'0.00',
                  campo: 'receita_transferencia',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'TOTAL RECEITA',
                  value: demon[0]['receita_transferencia']??'0.00',
                  campo: ' ',
                  isHighlighted: true,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.emptyCircle,
                  label: 'Transferências FNDE',
                  value: demon[0]['transferencia_fnde']??'0.00',
                  campo: 'transferencia_fnde',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- CARD 3: FUNDEB E REMUNERAÇÃO ---
            InfoCard(
              title: 'FUNDEB E REMUNERAÇÃO',
              icon: Icons.account_balance,//#0077FF
              headerColor: const Color(0xFF0077FF), // Azul
              children:  [
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receitas Destinadas ao FUNDEB (20% das Transf.)',
                  value: demon[0]['receita_ao_fundeb']??'0.00',
                  campo: 'receita_ao_fundeb',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Receitas Recebidas do FUNDEB (FUNDEB, impostos, transf. + fundo FUND. Comple. União:VAAT,VAAF,VAAR)',
                  value:  demon[0]['receita_do_fundeb']??'0.00',
                  campo: 'receita_do_fundeb',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: 'Despesas com recursos do FUNDEB',
                  campo: '',
                  value: '0',
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '1-Profissionais educaçao básica (mínimo 70%)',
                  value: demon[0]['prof_educ_basica']??'0.00',
                  campo: 'prof_educ_basica',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '1.2-Minimo 70% FUNDEB na remuneração dos profs. ed. básica',
                  value: demon[0]['minimo70']??'0.00',
                  campo: 'minimo70',
                  onValueUpdated: _loadData,
                  tipo: '%',
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.dollar,
                  label: '2- Outras despesas máximo 30%',
                  value: demon[0]['outras_depesas']??'0.00',
                  campo: 'outras_depesas',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
                DataRowItem(
                  iconType: RowIconType.emptyCircle,
                  label: 'Resultado líquido das Transf. do FUNDEB',
                  value: demon[0]['resul_liqui_transf']??'0.00',
                  campo: 'resul_liqui_transf',
                  onValueUpdated: _loadData,
                  ismaster: _isMaster,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // --- CARD 4: INVESTIMENTO EM EDUCAÇÃO ---
            InfoCard(
              title: 'INVESTIMENTO EM EDUCAÇÃO ',
              icon: Icons.school,//#FF7228
              headerColor: const Color(0xFFFF7228), // Laranja
              children:  [
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 25% (1.104) 25% da receita de impostos',
                    value: demon[0]['conta25']??'0.00',campo: 'conta25',onValueUpdated: _loadData,ismaster: _isMaster,),
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 5% (1.103) 5% da receita das transferências',
                    value: demon[0]['conta5']??'0.00',campo: 'conta5',onValueUpdated: _loadData,ismaster: _isMaster,),
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'Conta 1000 (Livre)',
                    value: demon[0]['conta1000']??'0.00',campo: 'conta1000',onValueUpdated: _loadData,ismaster: _isMaster,),
                DataRowItem(iconType: RowIconType.emptyCircle, label: 'acho que é uma soma',
                    value: '0',campo: '.'),
                DataRowItem(label: 'PERCENTUAL DE APLICAÇÃO MDE',
                    value: demon[0]['perc_apli_mde']??'0.00',campo: 'perc_apli_mde', isHighlighted: true,ismaster: _isMaster,
                  onValueUpdated: _loadData,tipo: '%'),
                DataRowItem(label: 'TOTAL DE INVESTIMENTO EM EDUCAÇÃO',
                    value: demon[0]['total_invest_edu']??'0.00',campo: 'total_invest_edu', isHighlighted: true,ismaster: _isMaster,
                  onValueUpdated: _loadData,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA OS CARDS PRINCIPAIS
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color headerColor;
  final List<Widget> children;
  final bool isMaster;

  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.headerColor,
    required this.children,
    this.isMaster=false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cabeçalho colorido
          Container(
            color: headerColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
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
          // Corpo branco com as linhas de dados
          ...children,
        ],
      ),
    );
  }
}

/// WIDGET REUTILIZÁVEL PARA CADA LINHA DE DADOS
class DataRowItem extends StatelessWidget {
  final String label;
  final String? value;
  final String? value2; // Para a linha com 3 colunas
  final RowIconType iconType;
  final bool isHighlighted;
  final bool isAlert;
  final String? campo;
  final VoidCallback? onValueUpdated;
  final String? tipo;
  final bool ismaster;

  const DataRowItem({
    Key? key,
    required this.label,
    this.value,
    this.value2,
    this.iconType = RowIconType.none,
    this.isHighlighted = false,
    this.isAlert = false,
    required this.campo,
    this.onValueUpdated,
    this.tipo='VR',
    this.ismaster=false,
  }) : super(key: key);

  Widget _buildIcon() {
    Widget iconWidget;
    switch (iconType) {
      case RowIconType.dollar:
        iconWidget = Container(
          width: 18,
          height: 18,
          child: Image.asset('assets/images/dolar.png',color: isAlert ? Colors.red : Colors.grey.shade800,)
        );
        break;
      case RowIconType.emptyCircle:
        iconWidget = Icon(Icons.radio_button_unchecked, size: 18, color: Colors.grey[400]);
        break;
      case RowIconType.none:
      default:
        iconWidget = const SizedBox(width: 18); // Mantém o alinhamento
    }
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: iconWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color labelColor = isAlert ? Colors.red : Colors.grey.shade700;
    Color valueColor = isAlert ? Colors.red : Colors.grey.shade800;
    FontWeight labelWeight = FontWeight.normal;
    FontWeight valueWeight = FontWeight.w500;

    if (isHighlighted) {//67C8FF
      backgroundColor = const Color(0xFF67C8FF);
      labelColor = Colors.white;
      //#67C8FF
      valueColor = Colors.white;
      labelWeight = FontWeight.bold;
      valueWeight = FontWeight.bold;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      child: Row(
        children: [
          _buildIcon(),
          ///descrição
          Expanded(
            flex: 5, // Mais espaço para o label
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: labelColor,
                fontWeight: labelWeight,
              ),
            ),
          ),

          ///VALOR
          if (value2 != null) // Lógica para a linha de 3 colunas
            Expanded(
              flex: 2,
              child: Text(value2!,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: valueColor, fontWeight: valueWeight),
              ),
            ),
          if (value != null)
            Expanded(
                child:  Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(tipo=='VR'?Utils.toReal(double.parse(value!)):
                      value!.isAlphabetOnly?
                      value:'$value%',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if(ismaster)
                      Expanded(
                        child: IconButton(
                          onPressed: () => _editarValor(context,value,campo!,tipo!,label),
                          icon: Icon(Icons.edit, size:18, color: Colors.grey,),
                        ),
                    ),
                    if(!ismaster)
                      Expanded(
                        child: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.circle_outlined, size:18, color: Colors.grey,),
                        ),
                      ),
                  ],
                )
            )
        ],
      ),
    );
  }

  Future<void> _editarValor(BuildContext context,var vrinicial,String campo,String tipo,String label) async {
    await Utils.mostrarDialogoEditarValor(
      inputFormatters: [
        tipo=='VR'?
        CurrencyTextInputFormatter.currency(symbol: 'R\$', locale: 'pt'):
        CurrencyTextInputFormatter.currency(symbol: '%', locale: 'pt')
      ],
      context: context,
      titulo: label,
      labelCampo: tipo=='VR'?'Valor':'Percentual',
      valorInicial: vrinicial,
      aoSalvar: (novoValor) async {
        var valorNumerico=novoValor;
        if(tipo=='VR') {
          valorNumerico = Utils.saldoToSave(novoValor);
          await ApiMySql.executaSql('Update $TBDemonReceitas set $campo=$valorNumerico');
        }else{
          String nvr=novoValor.replaceAll('%', '').trim();
          await ApiMySql.executaSql('Update $TBDemonReceitas set $campo="$nvr"');
        }
        onValueUpdated?.call();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Adicionado para formatação
import '../data/api_my_sql.dart';
// import '../services/utils.dart'; // Substituído por Intl para demonstração
import '../services/utils.dart';
import '../widgets/line.dart';
import '../widgets/texto.dart';

// Classe de modelo para armazenar os dados calculados de forma clara e segura.
class ImpactoFinanceiroData {
  final double totalVencimentos;
  final double totalVantagens;
  final double percentualVantagens;
  final double custoTotalLiquido;
  final double encargosPrev14Percent;
  final double decimoTerceiroProporcional;
  final double feriasProporcional;
  final double totalFolhaMensal;
  final double totalFolhaAnual;

  // Dados do FUNDEB (exemplo)
  final double receitaFundebEstimada;
  final double impactoFolhaSobreFundeb;
  final double impactoFolhaSobreMDE;

  ImpactoFinanceiroData({
    required this.totalVencimentos,
    required this.totalVantagens,
    required this.percentualVantagens,
    required this.custoTotalLiquido,
    required this.encargosPrev14Percent,
    required this.decimoTerceiroProporcional,
    required this.feriasProporcional,
    required this.totalFolhaMensal,
    required this.totalFolhaAnual,
    required this.receitaFundebEstimada,
    required this.impactoFolhaSobreFundeb,
    required this.impactoFolhaSobreMDE,
  });

  // Factory constructor para criar a instância a partir dos dados brutos da API.
  // Centraliza toda a lógica de cálculo e parsing.
  factory ImpactoFinanceiroData.fromApiData(List<dynamic> apiLista) {
    double totVencimentos = 0;
    double totVantagens = 0;

    for (var item in apiLista) {
      String vantagensDetalhadas = item['vantagens_detalhadas'] ?? '';
      final partes = vantagensDetalhadas.split(' | ');

      if (partes.isNotEmpty) {
        double vcto=Utils.getVencimento(partes);
        totVencimentos += vcto ?? 0;
      }

      //double va=Utils.somaVantagens(partes);
      //print(va);
      //totVantagens += va;

      // 2. Cálculo do total das vantagens

      for (final parte in partes) {
        final detalhesVantagem = parte.split(':');
        if (detalhesVantagem.length > 3 && detalhesVantagem[0]!='21003' ) {
          String valorStr = detalhesVantagem[3]
              .replaceAll('R/\$', '')
              .replaceAll('-', '')
              .replaceAll(',', '')
              .trim();
          totVantagens += double.tryParse(valorStr) ?? 0;
        }
      }

    }

    // Cálculos financeiros
    final double percentualVantagensCalc = (totVantagens > 0) ? (totVantagens/totVencimentos ) * 100 : 0.0;
    final double custoTotalLiquidoCalc = totVencimentos + totVantagens;
    final double encargosPrev14PercentCalc = custoTotalLiquidoCalc * 0.14;
    final double decimoTerceiroProporcionalCalc = encargosPrev14PercentCalc / 12;
    final double feriasProporcionalCalc = (1/3)*encargosPrev14PercentCalc;
    final double totalFolhaMensalCalc = custoTotalLiquidoCalc + decimoTerceiroProporcionalCalc + feriasProporcionalCalc;
    final double totalFolhaAnualCalc = totalFolhaMensalCalc * 12;

    // Dados de exemplo do FUNDEB
    final double receitaFundeb = totalFolhaMensalCalc; // Exemplo
    final double impactoFundeb = totalFolhaMensalCalc * 0.10;
    final double impactoMDE = impactoFundeb * 0.7; // Exemplo

    return ImpactoFinanceiroData(
      totalVencimentos: totVencimentos,
      totalVantagens: totVantagens,
      percentualVantagens: percentualVantagensCalc,
      custoTotalLiquido: custoTotalLiquidoCalc,
      encargosPrev14Percent: encargosPrev14PercentCalc,
      decimoTerceiroProporcional: decimoTerceiroProporcionalCalc,
      feriasProporcional: feriasProporcionalCalc,
      totalFolhaMensal: totalFolhaMensalCalc,
      totalFolhaAnual: totalFolhaAnualCalc,
      receitaFundebEstimada: receitaFundeb,
      impactoFolhaSobreFundeb: impactoFundeb,
      impactoFolhaSobreMDE: impactoMDE,
    );
  }
}


class ImpactoGrid2 extends StatefulWidget {
  const ImpactoGrid2({Key? key}) : super(key: key);

  @override
  _ImpactoGrid2State createState() => _ImpactoGrid2State();
}

class _ImpactoGrid2State extends State<ImpactoGrid2> {
  ImpactoFinanceiroData? _impactoData;
  bool _isLoading = true;
  double receitaFundeb=0;

  // Usar NumberFormat para uma formatação de moeda consistente.
  // Supondo que Utils.formatVr fazia algo parecido.
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '');

  // Constantes de texto, declaradas como static const para melhor performance.

  static final List<Texto> _vantagensLabels = [
    Texto(tit: '1. Valor da folha de vencimentos básicos - mensal - R/\$', icone: Icons.help),
    Texto(tit: '2. Valor das vantagens pecuniárias - mensal - R/\$', icone: Icons.help),
    Texto(tit: '3. Percentual das vantagens pecuniárias sobre a folha de vencimento', icone: Icons.help),
    Texto(tit: '4. Custo total da folha de pagamento líquida mensal', icone: Icons.help),
    Texto(tit: '5. Encargos previdenciários', icone: Icons.help),
    Texto(tit: '6. Encargos previdenciários (14%)', icone: Icons.help),
    Texto(tit: '7. Valor do décimo terceiro 1/12', icone: Icons.help),
    Texto(tit: '8. Valor 1/3 férias (proporcional)', icone: Icons.help),
    Texto(tit: '9. Total folha mensal', icone: Icons.help),
    Texto(tit: '10. Total folha bruta anual', icone: Icons.help),
  ];

  static final List<Texto> _fundebLabels = [
    Texto(tit: 'Receita estimado do FUNDEB para o exercício', icone: Icons.help),
    Texto(tit: 'Impacto financeiro da folha de pagamento(ano) sobre os recursos do FUNDEB(%)', icone: Icons.help),
    Texto(tit: 'Impacto financeiro da folha de pagamento(ano) sobre os recursos da receita MDE(%)', icone: Icons.help),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lista = await ApiMySql.getProfessor();
      final fundeb = await ApiMySql.get('sim_fundeb_receita', null,null);
      setState(() {
        receitaFundeb=double.parse(fundeb[4]['valor']);
        _impactoData = ImpactoFinanceiroData.fromApiData(lista);
        _isLoading = false;
      });
    } catch (e) {
      // É uma boa prática tratar possíveis erros da API
      setState(() => _isLoading = false);
      // Opcional: mostrar um snackbar ou mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _impactoData == null
          ? const Center(child: Text("Não foi possível carregar os dados."))
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVantagensSection(_impactoData!),
              const SizedBox(height: 16),
              const Divider(thickness: 1.5),
              const SizedBox(height: 16),
              _buildFundebSection(_impactoData!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVantagensSection(ImpactoFinanceiroData data) {
    final values = [
      _currencyFormat.format(data.totalVencimentos),
      _currencyFormat.format(data.totalVantagens),
      '${data.percentualVantagens.toStringAsFixed(2)}%',
      _currencyFormat.format(data.custoTotalLiquido),
      '14%', // Valor fixo conforme o original
      _currencyFormat.format(data.encargosPrev14Percent),
      _currencyFormat.format(data.decimoTerceiroProporcional),
      _currencyFormat.format(data.feriasProporcional),
      _currencyFormat.format(data.totalFolhaMensal),
      _currencyFormat.format(data.totalFolhaAnual),
    ];

    return Column(
      children: List.generate(_vantagensLabels.length, (index) {
        final bool isTotal = index >= 8;
        return _HoverableDataRow(
          label: _vantagensLabels[index].tit,
          icon: _vantagensLabels[index].icone,
          value: values[index],
          isHighlighted: isTotal,
        );
      }),
    );
  }

  Widget _buildFundebSection(ImpactoFinanceiroData data) {
    final values = [
      _currencyFormat.format(receitaFundeb),
      _currencyFormat.format(data.impactoFolhaSobreFundeb),
      '${data.impactoFolhaSobreMDE.toStringAsFixed(2)}%',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Texto(tit:'RECEITA ESTIMADO DO EXERCÍCIO', negrito: true, top: 10, bottom: 10),
        ...List.generate(_fundebLabels.length, (index) {
          return _HoverableDataRow(
            label: _vantagensLabels[index].tit,
            icon: _vantagensLabels[index].icone,
            value: values[index],
            isHighlighted: true, // Todas as linhas do fundeb são destacadas
          );
        }),
      ],
    );
  }
}

// WIDGET OTIMIZADO PARA A LINHA COM HOVER
// Gerencia o próprio estado de hover, evitando reconstruções desnecessárias da tela inteira.

class _HoverableDataRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final IconData? icon;

  const _HoverableDataRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  __HoverableDataRowState createState() => __HoverableDataRowState();
}

class __HoverableDataRowState extends State<_HoverableDataRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isHighlighted ? Colors.blue : Colors.black;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1.0)),
          color: _isHovered ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            ///DESCRIÇão
            Line(
              tex: widget.label,
              tam: 600,
              alin: Alignment.centerLeft,
              fontSize: 14,
              cor: textColor,
              negrito: widget.isHighlighted,
              exibirIcone: true,
              icone: widget.icon!,
            ),
            ///VALOR
            Line(
              tex: widget.value,
              tam: 150, // Aumentei um pouco para acomodar valores maiores
              alin: Alignment.centerRight,
              fontSize: 14,
              cor: textColor,
              negrito: widget.isHighlighted,
            ),
          ],
        ),
      ),
    );
  }
}
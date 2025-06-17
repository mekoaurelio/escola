// Classe de modelo para armazenar os dados calculados de forma clara e segura.
import '../services/utils.dart';

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
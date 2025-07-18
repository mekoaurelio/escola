import 'package:flutter/material.dart';

import '../widgets/texto.dart';

class DadosDoMunicipio extends StatelessWidget {
  const DadosDoMunicipio({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF4F4F7);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body:Center(
        child: Container(
          width: MediaQuery.of(context).size.width *0.44,
          child:SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMunicipioInfoCard(),
                const SizedBox(height: 16),
                _buildReceitasCard(),
                const SizedBox(height: 16),
                _buildFundebCard(),
                const SizedBox(height: 16),
                _buildInvestimentoCard(),
              ],
            ),
          ),
        )
      )
    );
  }

  Widget _buildMunicipioInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_city, color: Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                const Text(
                  "INFORMAÇÕES DO MUNICÍPIO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildInfoRow("POPULAÇÃO ESTIMADA 2022 (IBGE)", "150.024",Icons.people_outline_outlined),
            _buildInfoRow("DADOS DO EXERCÍCIO DE 2025", "2º BIMESTRE",Icons.data_thresholding_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildReceitasCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                const Text(
                  "RECEITAS MUNICIPAIS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildFinancialRow("1-Receita de Impostos", "83.029.413,57",corTexto:Colors.green.shade900,
                iconColor: Colors.green,icon:Icons.monetization_on_outlined ),
            _buildFinancialRow("2-Receitas de Transferências", "171.356.979,58",corTexto:Colors.green.shade900,
                iconColor: Colors.green,icon:Icons.monetization_on_outlined),
            _buildFinancialRow("Total Receita", "254.386.393,15", isTotal: true,corTexto:Colors.green.shade900,
                iconColor: Colors.green,icon:Icons.monetization_on_outlined),
            _buildFinancialRow("5-Transf. FNDE", "5.585.913,04"),
          ],
        ),
      ),
    );
  }

  Widget _buildFundebCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                const Text(
                  "FUNDEB E REMUNERAÇÃO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildFinancialRow("10-Receitas Destinadas ao Fundeb", "34.271.395,92",corTexto:Colors.green.shade900,
                icon: Icons.monetization_on_outlined,iconColor: Colors.green),
            _buildFinancialRow("11-Receitas Recebidas do FUNDEB", "43.465.227,43",corTexto:Colors.green.shade900,
                icon: Icons.monetization_on_outlined,iconColor: Colors.green),
            _buildFinancialRow("13-Pag dos Profs do Magistério (70%)", "34.549.863,34",corTexto:Colors.red.shade900,
                icon: Icons.money_off_csred_outlined,iconColor: Colors.red),
            _buildFinancialRow("GANHO/PERDA", "9.193.831,51",
                isPositive: true, isHighlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestimentoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF1F3C88)),
                const SizedBox(width: 8),
                const Text(
                  "INVESTIMENTO EM EDUCAÇÃO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 12),
            _buildFinancialRow("Conta 25% (1.104)", "20.757.353,39"),
            _buildFinancialRow("Conta 5% (1.103)", "8.567.848,98"),
            _buildFinancialRow("Conta 1000 (Livre)", "-"),
            _buildFinancialRow("19.1. Mínimo 70%", "12.057.915,04"),
            _buildPercentageRow("38-Perc de Aplicação em MDE", "80,54%"),
            _buildPercentageRow("TOTAL INVESTIMENTO EM EDUCAÇÃO", "20,26%"),
            _buildFinancialRow("", "66.318.427,81", isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///Título
          Texto(tit: label,tam: 14,cor:Colors.black54 ,fontWeight: FontWeight.w600,prefixIcon:icon ,
          ),
          ///Valor
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value,
      {bool isTotal = false, bool isPositive = false,Color corTexto=Colors.black87,IconData icon=Icons.circle_outlined,
        Color iconColor=Colors.grey,
        bool isHighlight = false}) {
    Color textColor = Colors.black87;
    if (isTotal) {
      textColor = const Color(0xFF1F3C88);
    } else if (isPositive) {
      textColor = const Color(0xFF27AE60);
    } else if (isHighlight) {
      textColor = const Color(0xFFE74C3C);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///titulo
          Expanded(
            flex: 2,
            child: Texto(tit: label,tam: 18,cor:corTexto ?? Colors.black87 ,prefixIcon: icon,iconColor: iconColor,
              fontWeight: isTotal || isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          ///valor
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isTotal ? 20 : 18,
                color:corTexto ?? textColor ,
                fontWeight: isTotal || isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ///Titulo
          Texto(tit: label,tam: 14,cor:Colors.black54,left: 20,fontWeight: FontWeight.bold,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:  Colors.blue.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF1F3C88),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}